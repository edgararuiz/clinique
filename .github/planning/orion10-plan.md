# Plan: simulated LDL study modelled on ORION-10

## Goal

One exported function that returns a simulated, analysis-ready LDL dataset
modelled on ORION-10 (inclisiran vs placebo, NCT03399370). Fitting the
trial's primary mixed model (MMRM) to it should give results close to the
published ones.

The output has the components of an ADaM ADLB filtered to LDL, but plain
column names.

## Sources

1. Statistical analysis plan (SAP):
   https://cdn.clinicaltrials.gov/large-docs/70/NCT03399370/SAP_001.pdf
2. FDA statistical review (demographics in Table 5):
   https://www.accessdata.fda.gov/drugsatfda_docs/nda/2022/214012Orig1s000StatR.pdf
3. NEJM paper: https://doi.org/10.1056/NEJMoa1912387. Its Supplementary
   Appendix (Figure S3, the spread of each subject's Day 510 change) and
   the protocol are in `sources/`. The main paper itself was not read.

## Design

### The function

```r
simulate_ldl(n, study = c("orion10"))
```

1. `n` is the number of subjects, randomized 1:1. It has no default, so the
   caller must give it; ORION-10 randomized 1,561.
2. `study` picks the trial to model, checked with `match.arg()`. Only
   `"orion10"` for now.
3. For reproducible results, call `set.seed()` first.

### The output

One row per subject per scheduled visit:

| # | Column | Meaning |
|---|---|---|
| 1 | `subject_id` | Subject identifier. |
| 2 | `treatment` | "Inclisiran" or "Placebo". |
| 3 | `age`, `sex`, `race` | Demographics, matching Table 5 of the FDA review. |
| 4 | `visit` | Day 150, 270, 330, 450, 510 or 540, as an ordered factor. These are the MMRM's visits: LDL is also measured on Day 90, but the SAP excludes it from the model (Section 6.4.6.1). |
| 5 | `day` | The study day of the visit. |
| 6 | `ldl_baseline` | LDL at baseline, in mg/dL. |
| 7 | `ldl` | LDL at the visit, in mg/dL. |
| 8 | `ldl_pct_change` | Percent change from baseline; the model's outcome. |

### How LDL is simulated

Every number below is labelled with where it came from. "Read by eye"
means it was read off a published figure, to about ±1 point for means and
±0.05 for SDs. "Assumed" means no public source gives it. The local copies
of all sources are in `.github/planning/sources/`.

1. Baseline LDL from a right-skewed distribution matching the published
   baseline mean and spread. A log-normal fits: LDL can't go below zero and
   has a long right tail. Convert the published mean and SD to the
   log-scale parameters:

   ```r
   bl_mean <- 104.6  # mg/dL; FDA review Table 5: 104.5 and 104.8 by arm
   bl_sd <- 38.3     # FDA review Table 5: 39.6 and 37.0 by arm
   sdlog <- sqrt(log(1 + (bl_sd / bl_mean)^2))
   meanlog <- log(bl_mean) - sdlog^2 / 2
   ldl_baseline <- rlnorm(n, meanlog, sdlog)
   ```

2. Mean percent change per visit and arm. The targets are the observed
   means in Figure 2 of the FDA review (ORION-10 panel, PDF page 57),
   read by eye. They are not Table 10's values, which include imputed
   values for missing data; the simulation has no missing data, so it
   matches what was observed.

   Doses are on Days 1, 90, 270 and 450, which gives the sawtooth: the
   drop is deepest 60 days after a dose (Days 150, 330, 510) and weaker
   just before the next dose (Days 270, 450).

   ```r
   # Days:            150    270    330    450    510    540
   mu_inclisiran <- c(-59.4, -48.3, -56.0, -46.0, -56.3, -53.8)  # read by eye
   mu_placebo    <- c(  1.2,   4.8,   5.8,   3.0,   1.4,   1.8)  # read by eye
   ```

3. Within-subject correlation across visits, from a multivariate normal
   with an unstructured covariance, so an MMRM is the right model for it.

   The draws are on the log scale of the ratio LDL / baseline, not on
   percent change directly. A normal draw of percent change can fall below
   -100%, which gives a negative LDL; a ratio of `exp(x)` is always
   positive. For example, a log ratio of -0.69 is a ratio of 0.5, a -50%
   change. Figure S3 of the NEJM appendix supports this: each subject's
   observed Day 510 change is right-skewed in both arms.

   The SD per arm comes from the quartiles in Figure S3, Panel B (NEJM
   appendix, PDF page 24), read by eye and converted to the log scale:

   1. Placebo: quartiles about +11%, -5% and -16%, so a log-scale SD of
      about 0.21.
   2. Inclisiran: quartiles about -43%, -59% and -72%, so a log-scale SD
      of about 0.53.

   The figure only covers Day 510, so the same SD is used at every visit
   (assumed). Correlation between visits is assumed: 0.7 for visits 180
   days apart, higher for nearer visits, lower for farther ones.

   Averaging after `exp()` pulls the mean percent change up, so the
   log-scale means are shifted down by `sd^2 / 2`. With that shift, the
   expected percent change equals the target exactly.

   ```r
   day <- c(150, 270, 330, 450, 510, 540)
   r <- 0.7^(abs(outer(day, day, "-")) / 180)  # assumed
   arm_sd <- c(Inclisiran = 0.53, Placebo = 0.21)  # read by eye

   arm <- sample(rep(c("Inclisiran", "Placebo"), length.out = n))
   targets <- rbind(Inclisiran = mu_inclisiran, Placebo = mu_placebo)
   mu_log <- log(1 + targets / 100) - arm_sd^2 / 2

   log_ratio <- matrix(NA_real_, n, 6)
   for (a in c("Inclisiran", "Placebo")) {
     rows <- arm == a
     sigma <- arm_sd[[a]]^2 * r
     log_ratio[rows, ] <- MASS::mvrnorm(sum(rows), mu = mu_log[a, ], Sigma = sigma)
   }
   ldl <- ldl_baseline * exp(log_ratio)
   pct_change <- 100 * (exp(log_ratio) - 1)
   ```

   The SAP's MMRM fits one covariance for both arms, while the simulation
   gives inclisiran a wider spread. The real trial very likely had the
   same mismatch, so this keeps the data realistic; the treatment
   estimates stay unbiased.

   `MASS` ships with R, so it adds no install burden.

4. Demographics, from FDA review Table 5, pooled over both arms
   (randomization makes the arm differences chance):

   ```r
   age <- round(pmin(pmax(rnorm(n, 66.1, 8.9), 35), 90))
   # Mean 66.4 and 65.7 by arm, SD 8.9, range 35 to 90. Normal shape: assumed.
   sex <- sample(c("Male", "Female"), n, replace = TRUE, prob = c(0.694, 0.306))
   # 1,083 of 1,561 male.
   race <- sample(c("White", "Black", "Other"), n, replace = TRUE,
     prob = c(0.857, 0.126, 0.017))
   # 1,338, 197 and 26 of 1,561.
   ```

5. No missing values: every subject has LDL at all six visits.

### Check

A test fits the SAP's MMRM with the `mmrm` package
(`ldl_pct_change ~ treatment * visit + ldl_baseline`, unstructured
covariance, Kenward-Roger) to `simulate_ldl(1561)` and checks two
treatment differences against the Figure 2 targets:

1. Time-adjusted (the average of the six visit differences): about -56.3.
   The MMRM is the SAP's primary analysis for this endpoint.
2. Day 510: about -57.7. The SAP's primary analysis for this endpoint is
   an ANCOVA on Day 510 alone; the MMRM is one of its sensitivity analyses
   (SAP Section 6.4.6.1).

The published values with imputation are smaller, -53.9 and -52.3 (FDA
review Table 10). The docs should say why the simulation differs.

## Steps

1. Write `simulate_ldl()` in `R/simulate-ldl.R`.
2. Add the MMRM test.
3. Document the function briefly, citing the sources and linking to the
   vignette. Say the data is simulated and not affiliated with or endorsed
   by the trial's sponsor.
4. Add a vignette, `vignettes/orion10.Rmd`, that walks through the
   simulation approach: the sources and which numbers came from each, the
   by-eye readings and assumptions, the log-ratio scale, why the targets
   are Figure 2 and not Table 10, and fitting the SAP's MMRM to the
   result. Add `knitr`, `rmarkdown`, `mmrm` and `emmeans` to Suggests and
   `VignetteBuilder: knitr` to DESCRIPTION.
5. Update the README with a short example that fits the model and links
   to the vignette.
