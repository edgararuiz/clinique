# Plan: simulated LDL study modelled on ODYSSEY LONG TERM

## Goal

Add ODYSSEY LONG TERM (alirocumab vs placebo, NCT01507831) as the second
study in `simulate_ldl()`. Fitting the trial's primary mixed model (MMRM)
to the data should give results close to the published ones.

ODYSSEY LONG TERM is worth adding because it differs from ORION-10 in
ways an analyst has to handle:

1. It randomized 2:1, not 1:1.
2. It has seven visits, four weeks apart at first, not six visits months
   apart.
3. The drug effect is flat over time. Alirocumab is injected every two
   weeks, so there is no dosing sawtooth.
4. The model adds the four randomization strata as covariates, with their
   interactions with visit.
5. The SAP uses Satterthwaite degrees of freedom, not Kenward-Roger.
6. The SAP asks for least-squares means weighted by the observed share of
   each stratum ("population weights"), not equal weights.

## Sources

The local copies are in `.github/planning/sources/` (git-ignored).

1. NEJM protocol supplement for Robinson et al. 2015
   (https://doi.org/10.1056/NEJMoa1501031): `odyssey_lt_protocol.pdf`.
   It holds every protocol version and the SAP (dated 20 December 2013,
   from PDF page 1525). The SAP's primary analysis is Section 2.4.4.1.1
   (PDF page 1560). The strata are in SAP Section 1.1 (PDF page 1533).
2. NEJM Supplementary Appendix: `odyssey_lt_appendix.pdf`. Table S1
   (visit-by-visit data counts) and Table S2 (PDF page 64; least-squares
   means and standard errors at Week 24).
3. FDA statistical review of alirocumab, which covers all 10 ODYSSEY
   trials: `alirocumab_statr.pdf`,
   https://www.accessdata.fda.gov/drugsatfda_docs/nda/2015/125559Orig1s000StatR.pdf.
   Tables 3 and 4 (visits, strata), Table 12 (demographics), Table 27
   (results at Weeks 12 and 24) and Figure 7 (observed mean percent change
   by visit, PDF page 56).
4. ClinicalTrials.gov results for NCT01507831: age, sex and baseline LDL
   by arm, and the list of trial sites.

The NEJM main paper was not read; NEJM blocks automated downloads.

## Design

### The function

The signature stays the same; only the choices for `study` grow:

```r
simulate_ldl(n, study = c("orion10", "odyssey_lt"))
```

1. `"odyssey_lt"` rather than `"odyssey"`: there were 10 ODYSSEY trials.
2. Subjects are randomized 2:1. When `n` is not a multiple of 3, the
   extra subjects go to alirocumab first. ODYSSEY LONG TERM randomized
   2,341 (1,553 alirocumab, 788 placebo); `simulate_ldl(2341, "odyssey_lt")`
   gives 1,561 and 780.
3. `simulate_ldl(n)` keeps returning ORION-10 data, because `"orion10"`
   stays the first choice.

### The output

Every study returns the same 10 core columns, in the same order. Studies
whose SAP adjusts for randomization strata add those columns at the end.

| # | Column | ORION-10 | ODYSSEY LONG TERM |
|---|---|---|---|
| 1 | `subject_id` | Same | Same |
| 2 | `treatment` | "Placebo", "Inclisiran" | "Placebo", "Alirocumab" |
| 3 | `age` | Same | Same |
| 4 | `sex` | Same | Same |
| 5 | `race` | Same | Same |
| 6 | `visit` | "Day 150" to "Day 540" | "Week 4" to "Week 52" |
| 7 | `day` | The study day | `7 * week`, the nominal day (Week 24 is day 168) |
| 8 | `ldl_baseline` | Same | Same |
| 9 | `ldl` | Same | Same |
| 10 | `ldl_pct_change` | Same | Same |
| 11 | `hefh` | Not present | "Yes" or "No" |
| 12 | `prior_mi_stroke` | Not present | "Yes" or "No" |
| 13 | `statin_intensity` | Not present | "High" or "Low/moderate" |
| 14 | `region` | Not present | "North America", "Western Europe", "Eastern Europe" or "Rest of World" |

The strata, in plain words:

1. `hefh`: heterozygous familial hypercholesterolemia, an inherited form
   of high LDL.
2. `prior_mi_stroke`: a past heart attack (myocardial infarction) or
   ischemic stroke.
3. `statin_intensity`: "High" is atorvastatin 40 to 80 mg or rosuvastatin
   20 to 40 mg daily. "Low/moderate" is any other statin dose.
4. `region`: where the subject was enrolled.

`visit` only covers Weeks 4 to 52. The trial also measured LDL at Weeks
64 and 78, but the SAP's primary MMRM uses Weeks 4 to 52 only.

### How LDL is simulated

The method is the same as ORION-10's: a log-normal baseline, then a
multivariate normal draw of each subject's log ratio LDL / baseline,
shifted down by `sd^2 / 2` so that the expected percent change equals the
target. Only the numbers change. "Read by eye" means read off a published
figure, to about ±1 point. "Derived" means calculated from published
numbers. "Assumed" means no public source gives it.

1. Baseline LDL: log-normal with mean 122.4 mg/dL and SD 42.2
   (ClinicalTrials.gov; 121.9 and 122.7 by arm). FDA Table 12 gives the
   same, rounded: 122 (42).

2. Mean percent change per visit and arm: the observed means in FDA
   Figure 7 (LONG TERM panel), read by eye.

   ```r
   # Weeks:             4      8     12     16     24     36     52
   mu_alirocumab <- c(-64.9, -65.9, -63.8, -64.9, -61.3, -60.5, -57.5)
   mu_placebo    <- c(  1.6,   1.2,   1.6,   1.2,   1.4,   0.4,   5.1)
   ```

   These agree with the published least-squares means in FDA Table 27:
   alirocumab -63% and placebo +1% at Week 12, and -61% and +1% at Week
   24 (verified against the table).

3. Spread: one SD of about 28 percentage points for both arms (derived).
   Appendix Table S2 gives least-squares means ± standard error at Week
   24: -57.8 ± 0.8 with 1,278 subjects and 3.5 ± 1.1 with 652. Standard
   error times the square root of n gives 28.6 and 28.1.

   Two limits on this number:

   1. Table S2 is for measured LDL, not the calculated LDL of the primary
      endpoint. The two are close, but not the same.
   2. The MMRM pools the arms into one covariance, so these standard
      errors can't tell the arms apart. An equal SD on the
      percent-change scale is assumed. ORION-10 supports this: its
      percent-change SDs were about 21 (placebo) and 24 (inclisiran),
      although their log-scale SDs were very different.

   On the log scale, an SD of 28 points gives about 0.66 for alirocumab
   (mean ratio 0.38) and 0.27 for placebo (mean ratio 1.01):

   ```r
   sdlog <- function(pct_sd, mean_pct) sqrt(log(1 + (pct_sd / (100 + mean_pct))^2))
   sdlog(28, -62)  # 0.66
   sdlog(28, 1)    # 0.27
   ```

   As in ORION-10, the same SD is used at every visit (assumed).

4. Correlation between visits: the ORION-10 rule, 0.7 for visits 180
   days apart (assumed). For these visits it ranges from 0.95 (Weeks 4
   and 8) to 0.51 (Weeks 4 and 52).

5. Demographics, pooled over both arms:

   1. Age: normal with mean 60.5 and SD 10.4 (ClinicalTrials.gov), cut to
      18 to 90 and rounded. The range is assumed: the trial enrolled
      adults, and no source gives the maximum.
   2. Sex: 62.2% male (1,457 of 2,341; ClinicalTrials.gov).
   3. Race: 93% White, 3% Black, 4% Other (2,175, 77 and 89 of 2,341;
      FDA Table 12).

6. Strata, drawn independently:

   1. `hefh`: 17.8% Yes (417 of 2,341; FDA Table 12).
   2. `prior_mi_stroke`: 48.1% Yes (1,125; FDA Table 12).
   3. `statin_intensity`: 44.1% High (1,032; FDA Table 12).
   4. `region`: 24% North America, 40% Western Europe, 21% Eastern
      Europe, 15% Rest of World (assumed). No source gives the split. FDA
      Table 12 gives 21% enrolled in the US. Canada had 14 sites to the
      US's 115, so North America is about 24%. The other 76% is split in
      proportion to each region's site count on ClinicalTrials.gov:
      101, 53 and 37 sites.

   The strata have no effect on percent change (assumed). The SAP still
   adjusts for them, as it would in the real trial. Real subjects with
   heFH have higher baseline LDL, but this simulation draws baseline LDL
   the same way for everyone (assumed).

7. No missing values: every subject has LDL at all seven visits.

### Check

A test fits the SAP's MMRM with the `mmrm` package:

```r
ldl_pct_change ~ treatment * visit +
  hefh * visit + prior_mi_stroke * visit + statin_intensity * visit +
  region * visit + ldl_baseline * visit + us(visit | subject_id)
```

with REML and Satterthwaite degrees of freedom, on
`simulate_ldl(2341, "odyssey_lt")`. It checks the Week 24 difference
against the Figure 7 target, -62.7 (-61.3 minus 1.4), to within 3 points.

The published value is -62 (95% CI -64 to -59; FDA Table 27), close to
the target, because the sponsor's MMRM treats missing values as missing
at random. The FDA's preferred analysis, which assumes subjects who stop
treatment return to baseline, gives -58 (FDA Table 14). The vignette
should explain both.

### File layout

Keep each script short by splitting the code by job. Each helper does
real work; none only calls another function. Each script has a test file
of the same name.

| # | Script | Holds | Test file |
|---|---|---|---|
| 1 | `R/simulate-ldl.R` | `simulate_ldl()`: checks the arguments, calls the helpers, builds the data frame. | `tests/testthat/test-simulate-ldl.R` |
| 2 | `R/ldl-studies.R` | `ldl_studies`: the settings for each study, data only. | `tests/testthat/test-ldl-studies.R` |
| 3 | `R/draw-subjects.R` | Helpers that draw the treatment arms, demographics and strata. | `tests/testthat/test-draw-subjects.R` |
| 4 | `R/draw-ldl.R` | Helpers that draw baseline LDL and the log ratios at each visit. | `tests/testthat/test-draw-ldl.R` |

What each test file checks:

1. `test-simulate-ldl.R`: the output for both studies (core columns, no
   missing values, ordered visits, the percent-change formula, strata
   columns for `odyssey_lt` only), the argument errors, and the MMRM
   check for each study.
2. `test-ldl-studies.R`: each study's settings fit together. One target
   and one day per visit, a target row and an SD per arm, probabilities
   that add up to 1.
3. `test-draw-subjects.R`: the 1:1 and 2:1 splits (11 subjects give 6
   and 5 for ORION-10, 8 and 3 for ODYSSEY LONG TERM), and the levels of
   each demographic and stratum.
4. `test-draw-ldl.R`: LDL is always above zero, and with many subjects
   the mean percent change at each visit lands near its target, without
   fitting a model.

## Steps

1. Refactor the code into the four scripts above, so each study's entry
   in `ldl_studies` holds everything that varies: the arm names and
   ratio, the visit labels and days, the targets and SDs, the
   demographics, and any strata. ORION-10 output must stay identical for
   the same seed, so the README and vignette numbers don't change. Check
   this by saving `simulate_ldl(1561)` after `set.seed(1)` before the
   refactor and comparing with `identical()` after it.
2. Add the `odyssey_lt` entry.
3. Split the tests into the four test files above, one per script, and
   add the ODYSSEY LONG TERM checks to each.
4. Help page: keep it short.
   1. The `study` parameter lists both studies, one line each, with
      links to their vignettes.
   2. The `n` parameter says the ratio depends on the study.
   3. The return value is the core-column table, then a short "Columns
      for some studies" list: the four strata, for `"odyssey_lt"`.
   4. Add the sources for ODYSSEY LONG TERM and the not-affiliated line.
5. Vignette `vignettes/odyssey-lt.Rmd`, titled "Simulating ODYSSEY LONG
   TERM". It follows the ORION-10 vignette's structure, so a reader who
   has seen one knows where to look in the other:
   1. The trial: alirocumab, a PCSK9 antibody injected every two weeks;
      2,341 subjects with high cardiovascular risk on a statin; 2:1;
      78 weeks; percent change at Week 24 as the primary endpoint.
   2. Sources, with the same "read by eye", "derived" and "assumed"
      labels.
   3. The data: `head()` of the output, the strata columns, and why only
      Weeks 4 to 52 appear.
   4. How each part is simulated: treatment, demographics, strata (with
      plain explanations of heFH, statin intensity and region), baseline
      LDL, the targets table, and why the curve is flat (dosing every two
      weeks, against ORION-10's twice a year). Then the spread, showing
      how the SD comes from standard error times the square root of n,
      and the correlation, reusing ORION-10's rule.
   5. Checking the means against the targets.
   6. Fitting the SAP's model: the strata and their interactions with
      visit, Satterthwaite degrees of freedom, and population-weighted
      least-squares means (`emmeans(..., weights = "proportional")`),
      explaining in plain words why the SAP asks for them. Then the Week
      24 difference, against -62.7 (the target), -62 (the sponsor) and
      -58 (the FDA), with why each differs.
   7. How this study differs from ORION-10: a short table covering the
      randomization ratio, visits, effect over time, covariates, degrees
      of freedom and least-squares mean weights.
   8. What is assumed.
6. Rewrite the README around a new story: clinique gives you data shaped
   like a real trial, and you fit that trial's own analysis to it.
   1. Intro: what the package does, in two short paragraphs. Every
      subject is made up; not affiliated with either sponsor.
   2. Installation, unchanged.
   3. A table of the available studies: the `study` value, drug, n,
      design, and the one thing each study teaches (ORION-10: an effect
      that changes with dosing; ODYSSEY LONG TERM: strata covariates and
      population weights).
   4. One figure: mean percent change by visit for both studies side by
      side, in base R graphics. The sawtooth next to the flat line shows
      in one look why the two studies differ.
   5. One short example: simulate ODYSSEY LONG TERM, fit its MMRM and
      print the Week 24 difference.
   6. "Learn more": one line per study linking to its vignette.
7. pkgdown: run `pkgdown::check_pkgdown()` and build the site. Both
   vignettes should appear under Articles.
8. Run `air format .`, `devtools::document()`, `devtools::build_readme()`
   and `devtools::check()`.
