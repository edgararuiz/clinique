# Simulate the ORION-11 trial

Returns simulated, analysis-ready LDL cholesterol data modelled on
ORION-11, a trial of inclisiran against placebo (NCT03400800). ORION-11
is ORION-10's sister trial: the same drug, doses and visits, in a
population from Europe and South Africa. Every subject is made up. The
data has one row per subject per scheduled visit, with no missing
values, ready for the trial's mixed model for repeated measures (MMRM).

## Usage

``` r
simulate_orion11(n)
```

## Arguments

- n:

  Number of subjects, at least 2. Subjects are randomized 1:1; when `n`
  is odd, the extra subject gets inclisiran. ORION-11 randomized 1,617.

## Value

A tibble with one row per subject per visit, sorted by subject and then
visit. Columns that aren't numeric are factors:

- `subject_id`: Subject identifier, such as `"001-0001"`.

- `treatment`: `"Placebo"` or `"Inclisiran"`, with placebo as the
  reference level.

- `age`: Age in years.

- `sex`: `"Female"` or `"Male"`.

- `race`: `"Black"`, `"Other"` or `"White"`.

- `visit`: Ordered factor, `"Day 90"` to `"Day 540"`. Unlike ORION-10's,
  the ORION-11 analysis plan keeps Day 90 in the model.

- `day`: Study day of the visit.

- `ldl_baseline`: LDL at baseline, in mg/dL.

- `ldl`: LDL at the visit, in mg/dL.

- `ldl_pct_change`: Percent change in LDL from baseline.

- `statin_use`: `"No"` or `"Yes"`, current use of statins or other
  lipid-lowering therapy. A randomization stratum, which the trial's
  analysis plan adjusts for.

## Details

The baseline LDL, the mean percent change at each visit and the
demographics follow the trial's published results. The mean percent
changes follow the observed means, not the published estimates that
account for missing values, so the treatment effect is a few points
larger than the published one.
[`vignette("orion11", package = "clinique")`](https://edgararuiz.github.io/clinique/articles/orion11.md)
explains each number, its source and the assumptions.

The data is simulated. It is not affiliated with or endorsed by the
trial's sponsor.

## Reproducibility

Call [`set.seed()`](https://rdrr.io/r/base/Random.html) first to get the
same data each time. The same seed gives the same data on every
operating system. The correlated values at each visit are drawn with
base R's [`chol()`](https://rdrr.io/r/base/chol.html), which returns the
one upper-triangular Cholesky factor of the covariance matrix. Methods
based on [`eigen()`](https://rdrr.io/r/base/eigen.html), such as
[`MASS::mvrnorm()`](https://rdrr.io/pkg/MASS/man/mvrnorm.html), can
return different factors on different systems, and so different data for
the same seed.

## References

Statistical analysis plan:
<https://cdn.clinicaltrials.gov/large-docs/00/NCT03400800/SAP_001.pdf>

FDA statistical review:
<https://www.accessdata.fda.gov/drugsatfda_docs/nda/2022/214012Orig1s000StatR.pdf>

Ray KK, et al. Two Phase 3 Trials of Inclisiran in Patients with
Elevated LDL Cholesterol. N Engl J Med 2020;382:1507-1519.
[doi:10.1056/NEJMoa1912387](https://doi.org/10.1056/NEJMoa1912387)

## Examples

``` r
set.seed(1)
orion11 <- simulate_orion11(100)
head(orion11)
#> # A tibble: 6 × 11
#>   subject_id treatment   age sex   race  visit   day ldl_baseline   ldl
#>   <fct>      <fct>     <dbl> <fct> <fct> <ord> <dbl>        <dbl> <dbl>
#> 1 001-0001   Placebo      69 Fema… White Day …    90         158.  145.
#> 2 001-0001   Placebo      69 Fema… White Day …   150         158.  146.
#> 3 001-0001   Placebo      69 Fema… White Day …   270         158.  192.
#> 4 001-0001   Placebo      69 Fema… White Day …   330         158.  201.
#> 5 001-0001   Placebo      69 Fema… White Day …   450         158.  205.
#> 6 001-0001   Placebo      69 Fema… White Day …   510         158.  194.
#> # ℹ 2 more variables: ldl_pct_change <dbl>, statin_use <fct>
```
