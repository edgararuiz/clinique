# Simulate the ORION-10 trial

Returns simulated, analysis-ready LDL cholesterol data modelled on
ORION-10, a trial of inclisiran against placebo (NCT03399370). Every
subject is made up. The data has one row per subject per scheduled
visit, with no missing values, ready for the trial's mixed model for
repeated measures (MMRM).

## Usage

``` r
simulate_orion10(n)
```

## Arguments

- n:

  Number of subjects, at least 2. Subjects are randomized 1:1; when `n`
  is odd, the extra subject gets inclisiran. ORION-10 randomized 1,561.

## Value

A tibble with one row per subject per visit, sorted by subject and then
visit. Columns that aren't numeric are factors:

- `subject_id`: Subject identifier, such as `"001-0001"`.

- `treatment`: `"Placebo"` or `"Inclisiran"`, with placebo as the
  reference level.

- `age`: Age in years.

- `sex`: `"Female"` or `"Male"`.

- `race`: `"Black"`, `"Other"` or `"White"`.

- `visit`: Ordered factor, `"Day 150"` to `"Day 540"`. LDL was also
  measured on Day 90, but the trial's analysis plan leaves it out of the
  model.

- `day`: Study day of the visit.

- `ldl_baseline`: LDL at baseline, in mg/dL.

- `ldl`: LDL at the visit, in mg/dL.

- `ldl_pct_change`: Percent change in LDL from baseline.

## Details

The baseline LDL, the mean percent change at each visit and the
demographics follow the trial's published results. The mean percent
changes follow the observed means, not the published estimates that
account for missing values, so the treatment effect is a few points
larger than the published one.
[`vignette("orion10", package = "clinique")`](https://edgararuiz.github.io/clinique/articles/orion10.md)
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
<https://cdn.clinicaltrials.gov/large-docs/70/NCT03399370/SAP_001.pdf>

FDA statistical review:
<https://www.accessdata.fda.gov/drugsatfda_docs/nda/2022/214012Orig1s000StatR.pdf>

Ray KK, et al. Two Phase 3 Trials of Inclisiran in Patients with
Elevated LDL Cholesterol. N Engl J Med 2020;382:1507-1519.
[doi:10.1056/NEJMoa1912387](https://doi.org/10.1056/NEJMoa1912387)

## Examples

``` r
set.seed(1)
orion10 <- simulate_orion10(100)
head(orion10)
#> # A tibble: 6 × 10
#>   subject_id treatment   age sex   race  visit   day ldl_baseline   ldl
#>   <fct>      <fct>     <dbl> <fct> <fct> <ord> <dbl>        <dbl> <dbl>
#> 1 001-0001   Placebo      70 Fema… White Day …   150         89.6  69.6
#> 2 001-0001   Placebo      70 Fema… White Day …   270         89.6  80.8
#> 3 001-0001   Placebo      70 Fema… White Day …   330         89.6  80.1
#> 4 001-0001   Placebo      70 Fema… White Day …   450         89.6  78.6
#> 5 001-0001   Placebo      70 Fema… White Day …   510         89.6  93.3
#> 6 001-0001   Placebo      70 Fema… White Day …   540         89.6  98.4
#> # ℹ 1 more variable: ldl_pct_change <dbl>
```
