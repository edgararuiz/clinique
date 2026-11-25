# Plan: simulated LDL study modelled on ORION-11

## Goal

Add `simulate_orion11(n)`, modelled on ORION-11 (inclisiran vs placebo,
NCT03400800). Fitting the trial's MMRM to the data should give results
close to the published ones.

ORION-11 is ORION-10's sister trial: same drug, same doses, same visits,
nearly the same SAP. That is its teaching value. It differs from ORION-10
in three ways an analyst has to notice:

1. A different population: Europe and South Africa, and people with
   ASCVD-risk equivalents (such as type 2 diabetes) as well as ASCVD. The
   drug effect is about 5 points smaller.
2. Its SAP adds current statin use as a covariate in the MMRM. ORION-10's
   SAP does not.
3. Its SAP keeps Day 90 in the MMRM. ORION-10's SAP says to leave it out.
   Both SAPs define the time-adjusted endpoint as the average after Day 90,
   so Day 90 is in the model but not in that average.

## Sources

The local copies are in `.github/planning/sources/` (git-ignored).

1. ORION-11 SAP, version 1.5, 12 August 2019: `orion11_sap.pdf`,
   https://cdn.clinicaltrials.gov/large-docs/00/NCT03400800/SAP_001.pdf.
   Section 6.4.6.1 and Appendix 1 define the MMRM. I diffed it against
   ORION-10's SAP; the model text differs only in the two points above.
2. FDA statistical review (the same one ORION-10 uses):
   `inclisiran_statr.pdf`. Table 6 (ORION-11 demographics), Table 10
   (published results with imputation) and Figure 2 (observed mean
   percent change by visit, ORION-11 panel, PDF page 57).
3. NEJM Supplementary Appendix (the same one ORION-10 uses):
   `nejm_appendix.pdf`. Figure S3, Panel D (each subject's Day 510
   change, ORION-11, PDF page 25).
4. ClinicalTrials.gov results for NCT03400800: age, sex, race and country
   of enrollment.

## Measuring the figures

For ORION-10, the figures were read by eye. For ORION-11, I measured them
from the PDF images in R, using the axis tick marks to convert pixels to
percent. I checked the method on the ORION-10 panels first:

1. Figure 2, ORION-10 panel: the measured means match the values already
   in `orion10_settings` to within 0.2 points at every visit.
2. Figure S3, Panel B: the measured log-scale SDs are 0.23 (placebo) and
   0.52 (inclisiran), against 0.21 and 0.53 read by eye.

The vignette calls these values "measured from the figure".

## Design

### The function

```r
simulate_orion11(n)
```

1. `n` is required, as for the other studies. Subjects are randomized 1:1;
   the extra subject of an odd `n` gets inclisiran. ORION-11 randomized
   1,617 (810 inclisiran, 807 placebo).

### The output

The 10 core columns, as in ORION-10, plus one stratum:

| # | Column | Values |
|---|---|---|
| 1 | `subject_id` | "001-0001" and so on |
| 2 | `treatment` | "Placebo" (reference), "Inclisiran" |
| 3 | `age` | Years |
| 4 | `sex` | "Female", "Male" |
| 5 | `race` | "Black", "Other", "White" |
| 6 | `visit` | "Day 90", "Day 150", "Day 270", "Day 330", "Day 450", "Day 510", "Day 540" |
| 7 | `day` | The study day |
| 8 | `ldl_baseline` | mg/dL |
| 9 | `ldl` | mg/dL |
| 10 | `ldl_pct_change` | Percent change from baseline |
| 11 | `statin_use` | "No", "Yes": current use of statins or other lipid-lowering therapy |

Factor levels are alphabetical, as in the other studies.

The SAP also stratified randomization by country, but country is only in
a sensitivity analysis, not the MMRM, so the data leaves it out.

### How LDL is simulated

The same engine as ORION-10 and ODYSSEY LONG TERM; only the settings are
new.

1. Baseline LDL: log-normal with mean 105.4 mg/dL and SD 39.2 (derived).
   FDA Table 6 gives 107.1 (41.8) for inclisiran and 103.7 (36.4) for
   placebo; these are the pooled mean and SD.

2. Mean percent change, measured from FDA Figure 2 (ORION-11 panel):

   ```r
   # Days:            90     150    270    330    450    510    540
   mu_inclisiran <- c(-46.8, -51.2, -42.3, -51.8, -39.7, -49.4, -47.7)
   mu_placebo    <- c(  1.8,   3.2,   3.8,   2.8,   3.4,   4.2,   3.4)
   ```

   The sawtooth follows the same dosing as ORION-10 (Days 1, 90, 270 and
   450), but the drop is about 5 points smaller at every visit.

3. Spread: log-scale SDs of 0.23 (placebo) and 0.44 (inclisiran),
   measured from the quartiles in Figure S3, Panel D (placebo +16%, -3%,
   -15%; inclisiran -40%, -54%, -67%). As in ORION-10, the same SD is
   used at every visit (assumed).

4. Correlation between visits: the ORION-10 rule, 0.7 for visits 180
   days apart (assumed).

5. Demographics, pooled over both arms:

   1. Age: normal with mean 64.8 and SD 8.5 (ClinicalTrials.gov), cut to
      20 to 88 (the range in FDA Table 6) and rounded.
   2. Sex: 1,160 of 1,617 male (71.7%; ClinicalTrials.gov).
   3. Race: 1,587 White, 20 Black and 10 Other (ClinicalTrials.gov).

   The settings store these as counts divided by 1,617, so the
   probabilities add up to exactly 1.

6. `statin_use`: 1,555 of 1,617 Yes (96.2%; FDA Table 6). It has no
   effect on percent change (assumed), as for the ODYSSEY strata.

7. No missing values.

### Check

The test fits the SAP's MMRM to `simulate_orion11(1617)`:

```r
ldl_pct_change ~ treatment * visit + statin_use + ldl_baseline +
  us(visit | subject_id)
```

with REML and Kenward-Roger, and checks two differences against the
Figure 2 targets, to within 3 points:

1. Day 510: about -53.6 (-49.4 minus 4.2).
2. Time-adjusted, the average of the Day 150 to 540 differences: about
   -50.5.

The published values with imputation are -49.8 and -49.1 (FDA Table 10).
The vignette explains the gap, as the ORION-10 vignette does.

## Files

Following the per-study layout:

| # | File | Holds |
|---|---|---|
| 1 | `R/orion11.R` | `simulate_orion11()`, its help page and `orion11_settings` |
| 2 | `tests/testthat/test-orion11.R` | Settings check, output shape, `statin_use` levels, the MMRM check |
| 3 | `tests/testthat/helper-ldl.R` | Add `orion11_settings` to `ldl_settings`, so the engine and draw tests cover it |
| 4 | `vignettes/orion11.Rmd` | "Simulating ORION-11" |

## Steps

1. Add `R/orion11.R` with the function, help page and settings.
2. Add the tests, and add ORION-11 to `ldl_settings` in the test helper.
3. Write `vignettes/orion11.Rmd`. It follows the ORION-10 vignette's
   structure but keeps the shared parts short, linking to the ORION-10
   vignette for the method. Its own sections:
   1. The trial, and how it differs from ORION-10.
   2. Sources, and how the figures were measured.
   3. The data, including `statin_use` and Day 90.
   4. The settings that differ from ORION-10, in one table.
   5. Fitting the SAP's MMRM, with the statin covariate and Day 90 in the
      model but not in the time-adjusted average. Then the two endpoints
      against the targets and the published values.
   6. ORION-10 and ORION-11 side by side: the same model fitted to both,
      showing the smaller effect in ORION-11.
   7. What is assumed.
4. Update the README: add an ORION-11 row to the studies table ("What it
   teaches: a sister trial; reading its SAP closely, since it adds a
   covariate and keeps Day 90") and a line in "Learn more". The figure
   keeps its two panels; ORION-11 would look like ORION-10.
5. Run `air`, `devtools::document()`, `devtools::build_readme()`,
   `devtools::check()` and `pkgdown::check_pkgdown()`, then build the
   site.
