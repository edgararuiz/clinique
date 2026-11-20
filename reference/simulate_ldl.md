# Simulate an LDL cholesterol trial dataset

Returns simulated, analysis-ready LDL cholesterol data modelled on a
published clinical trial. Every subject is made up. The data has one row
per subject per scheduled visit, with no missing values, ready for the
trial's mixed model for repeated measures (MMRM).

## Usage

``` r
simulate_ldl(n, study = c("orion10"))
```

## Arguments

- n:

  Number of subjects, randomized 1:1. When `n` is odd, the extra subject
  gets the active treatment. ORION-10 randomized 1,561.

- study:

  The trial to model. Only `"orion10"` for now.

## Value

A data frame with one row per subject per visit, sorted by subject and
then visit, and these columns:

- `subject_id`: Subject identifier, such as `"001-0001"`.

- `treatment`: Factor, `"Placebo"` or `"Inclisiran"`, with placebo as
  the reference level.

- `age`: Age in years.

- `sex`: `"Male"` or `"Female"`.

- `race`: `"White"`, `"Black"` or `"Other"`.

- `visit`: Ordered factor, `"Day 150"` to `"Day 540"`.

- `day`: Study day of the visit.

- `ldl_baseline`: LDL at baseline, in mg/dL.

- `ldl`: LDL at the visit, in mg/dL.

- `ldl_pct_change`: Percent change in LDL from baseline.

## Details

The only study available is ORION-10 (inclisiran vs placebo,
NCT03399370). The baseline LDL, the mean percent change at each visit
and the demographics follow the trial's published results. The mean
percent changes follow the observed means, not the published estimates
that fill in missing values, so the treatment effect is a few points
larger than the published one.
[`vignette("orion10", package = "clinique")`](https://edgararuiz.github.io/clinique/articles/orion10.md)
explains each number, its source and the assumptions.

The data is simulated. It is not affiliated with or endorsed by the
trial's sponsor.

## References

Statistical analysis plan:
<https://cdn.clinicaltrials.gov/large-docs/70/NCT03399370/SAP_001.pdf>

FDA statistical review:
<https://www.accessdata.fda.gov/drugsatfda_docs/nda/2022/214012Orig1s000StatR.pdf>

Ray KK, et al. Two Phase 3 Trials of Inclisiran in Patients with
Elevated LDL Cholesterol. N Engl J Med 2020;382:1507-1519.
[doi:10.1056/NEJMoa1912387](https://doi.org/10.1056/NEJMoa1912387)

## Examples

``` r
set.seed(1)
ldl <- simulate_ldl(100)
head(ldl)
#>   subject_id treatment age    sex  race   visit day ldl_baseline       ldl
#> 1   001-0001   Placebo  70 Female White Day 150 150     89.60336  96.17405
#> 2   001-0001   Placebo  70 Female White Day 270 270     89.60336 119.41800
#> 3   001-0001   Placebo  70 Female White Day 330 330     89.60336 106.97133
#> 4   001-0001   Placebo  70 Female White Day 450 450     89.60336 119.43851
#> 5   001-0001   Placebo  70 Female White Day 510 510     89.60336 111.94626
#> 6   001-0001   Placebo  70 Female White Day 540 540     89.60336 115.37867
#>   ldl_pct_change
#> 1       7.333092
#> 2      33.274030
#> 3      19.383169
#> 4      33.296914
#> 5      24.935342
#> 6      28.766009
```
