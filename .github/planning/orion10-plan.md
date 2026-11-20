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
3. NEJM paper (treatment effect): https://doi.org/10.1056/NEJMoa1912387

## Design

### The function

```r
ldl_simulate(n, study = c("orion10"))
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

Numbers marked "FDA review" or "SAP" are verified against the local copies
in `sources/`. Numbers marked "placeholder" are not; step 1 replaces them.

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

2. Mean percent change per visit and arm, following the published curves:
   inclisiran falls after the first dose and stays near its low point;
   placebo stays near zero. One vector per arm, one value per visit.

   Doses are on Days 1, 90, 270 and 450. Days 150, 330 and 510 fall 60
   days after a dose, near the low point, so the drop is deepest there.
   Days 270, 450 and 540 fall 90 to 180 days after a dose, as the effect
   wears off.

   Two published numbers per arm fix the values (FDA review Table 10):
   the Day 510 value, and the time-adjusted value, which the SAP defines as
   the average over the six visits (Section 6.4.6.1). The other visits are
   placeholders, chosen so the averages match. The NEJM paper's
   by-visit figure would replace them.

   ```r
   # Days:          150    270    330    450    510    540
   mu_inclisiran <- c(-53.0, -50.0, -53.0, -50.0, -51.4, -50.4)
   mu_placebo    <- c(  3.0,   3.0,   3.0,   2.5,   1.0,   2.5)
   # Day 510: -51.4 and 1.0 (FDA review). Averages: -51.3 and 2.5 (FDA review).
   ```

3. Within-subject correlation across visits, from a multivariate normal with
   an unstructured covariance, so an MMRM is the right model for it.

   The draws are on the log scale of the ratio LDL / baseline, not on
   percent change directly. A normal draw of percent change can fall below
   -100%, which gives a negative LDL; a ratio of `exp(x)` is always
   positive. For example, a log ratio of -0.69 is a ratio of 0.5, a -50%
   change.

   The covariance is built from an SD per visit and a correlation matrix,
   where nearer visits correlate more. Each subject's row of deviations is
   added to their arm's means, then converted back to percent change:

   ```r
   mu_log <- log(1 + rbind(mu_inclisiran, mu_placebo) / 100)

   visit_sd <- c(0.30, 0.32, 0.32, 0.34, 0.34, 0.35)  # log scale, placeholders
   day <- c(150, 270, 330, 450, 510, 540)
   r <- 0.7^(abs(outer(day, day, "-")) / 180)  # placeholder shape
   sigma <- diag(visit_sd) %*% r %*% diag(visit_sd)

   arm <- sample(rep(c("Inclisiran", "Placebo"), length.out = n))
   mu <- mu_log[match(arm, c("Inclisiran", "Placebo")), ]
   log_ratio <- mu + MASS::mvrnorm(n, mu = rep(0, 6), Sigma = sigma)
   ldl <- ldl_baseline * exp(log_ratio)
   pct_change <- 100 * (exp(log_ratio) - 1)
   ```

   `MASS` ships with R, so it adds no install burden. The correlation
   formula only sets the starting shape; the MMRM's unstructured
   covariance doesn't assume any shape, so it will still fit.

   One side effect: averaging after `exp()` pulls the mean percent change
   above the target. In a test run with these placeholders, inclisiran's
   means came out 2 to 3 points high and placebo's 4 to 7 points high.
   Step 1 calibrates `mu` so the simulated means land on the published
   ones.

4. No missing values: every subject has LDL at all six visits.

### Check

A test fits the SAP's MMRM with the `mmrm` package
(`ldl_pct_change ~ treatment * visit + ldl_baseline`, unstructured
covariance, Kenward-Roger) and checks two treatment differences against
the FDA review (Table 10):

1. Time-adjusted: the average of the six visit differences, near -53.9.
   The MMRM is the SAP's primary analysis for this endpoint.
2. Day 510: near -52.3. The SAP's primary analysis for this endpoint is an
   ANCOVA on Day 510 alone; the MMRM is one of its sensitivity analyses
   (Section 6.4.6.1).

## Steps

1. Pull the remaining target numbers from the sources: percent change at
   the visits other than Day 510, the SD and correlation across visits,
   and demographics.
2. Write `ldl_simulate()` in `R/ldl-simulate.R`.
3. Add the MMRM test.
4. Document the function, citing the sources. Say the data is simulated
   and not affiliated with or endorsed by the trial's sponsor.
5. Update the README with an example that fits the model.
