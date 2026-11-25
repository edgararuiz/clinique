# Simulate the ODYSSEY LONG TERM trial

Returns simulated, analysis-ready LDL cholesterol data modelled on
ODYSSEY LONG TERM, a trial of alirocumab against placebo (NCT01507831).
Every subject is made up. The data has one row per subject per scheduled
visit, with no missing values, ready for the trial's mixed model for
repeated measures (MMRM).

## Usage

``` r
simulate_odyssey_lt(n)
```

## Arguments

- n:

  Number of subjects, at least 3, so that both arms get at least one
  subject. Subjects are randomized 2:1; when `n` is not a multiple of 3,
  the extra subjects get alirocumab. ODYSSEY LONG TERM randomized 2,341.

## Value

A tibble with one row per subject per visit, sorted by subject and then
visit. Columns that aren't numeric are factors:

- `subject_id`: Subject identifier, such as `"001-0001"`.

- `treatment`: `"Placebo"` or `"Alirocumab"`, with placebo as the
  reference level.

- `age`: Age in years.

- `sex`: `"Female"` or `"Male"`.

- `race`: `"Black"`, `"Other"` or `"White"`.

- `visit`: Ordered factor, `"Week 4"` to `"Week 52"`. LDL was also
  measured at Weeks 64 and 78, but the trial's primary model stops at
  Week 52.

- `day`: Nominal study day of the visit, seven times the week.

- `ldl_baseline`: LDL at baseline, in mg/dL.

- `ldl`: LDL at the visit, in mg/dL.

- `ldl_pct_change`: Percent change in LDL from baseline.

The last four columns are the randomization strata, which the trial's
analysis plan adjusts for:

- `hefh`: Heterozygous familial hypercholesterolemia, `"No"` or `"Yes"`.

- `prior_mi_stroke`: Prior heart attack or ischemic stroke, `"No"` or
  `"Yes"`.

- `statin_intensity`: `"High"` or `"Low/moderate"`.

- `region`: `"Eastern Europe"`, `"North America"`, `"Rest of World"` or
  `"Western Europe"`.

## Details

The baseline LDL, the mean percent change at each visit, the
demographics and the randomization strata follow the trial's published
results.
[`vignette("odyssey-lt", package = "clinique")`](https://edgararuiz.github.io/clinique/articles/odyssey-lt.md)
explains each number, its source and the assumptions.

The data is simulated. It is not affiliated with or endorsed by the
trial's sponsors.

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

FDA statistical review:
<https://www.accessdata.fda.gov/drugsatfda_docs/nda/2015/125559Orig1s000StatR.pdf>

Robinson JG, et al. Efficacy and Safety of Alirocumab in Reducing Lipids
and Cardiovascular Events. N Engl J Med 2015;372:1489-1499. Its
statistical analysis plan is in the protocol supplement.
[doi:10.1056/NEJMoa1501031](https://doi.org/10.1056/NEJMoa1501031)

## Examples

``` r
set.seed(1)
odyssey <- simulate_odyssey_lt(90)
head(odyssey)
#> # A tibble: 6 × 14
#>   subject_id treatment   age sex   race  visit   day ldl_baseline   ldl
#>   <fct>      <fct>     <dbl> <fct> <fct> <ord> <dbl>        <dbl> <dbl>
#> 1 001-0001   Alirocum…    42 Fema… Other Week…    28         66.8  14.3
#> 2 001-0001   Alirocum…    42 Fema… Other Week…    56         66.8  15.9
#> 3 001-0001   Alirocum…    42 Fema… Other Week…    84         66.8  19.9
#> 4 001-0001   Alirocum…    42 Fema… Other Week…   112         66.8  11.4
#> 5 001-0001   Alirocum…    42 Fema… Other Week…   168         66.8  24.0
#> 6 001-0001   Alirocum…    42 Fema… Other Week…   252         66.8  31.8
#> # ℹ 5 more variables: ldl_pct_change <dbl>, hefh <fct>,
#> #   prior_mi_stroke <fct>, statin_intensity <fct>, region <fct>
```
