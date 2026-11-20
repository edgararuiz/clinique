# clinique

clinique simulates realistic clinical trial data. Each dataset is
modelled on a published trial and its statistical analysis plan, so the
trial’s own analysis gives results close to the published ones. Every
subject is made up.

The first dataset is modelled on ORION-10, a trial of inclisiran, a drug
that lowers LDL cholesterol, against placebo. The data is simulated and
is not affiliated with or endorsed by the trial’s sponsor.

## Installation

You can install the development version of clinique from
[GitHub](https://github.com/) with:

``` r

# install.packages("pak")
pak::pak("edgararuiz/clinique")
```

## Example

[`simulate_ldl()`](https://edgararuiz.github.io/clinique/reference/simulate_ldl.md)
returns one row per subject per visit, ready for the trial’s mixed model
for repeated measures (MMRM):

``` r

library(clinique)

set.seed(1)
ldl <- simulate_ldl(1561)
head(ldl)
#>   subject_id  treatment age  sex  race   visit day ldl_baseline      ldl
#> 1   001-0001 Inclisiran  78 Male White Day 150 150     84.68047 25.36234
#> 2   001-0001 Inclisiran  78 Male White Day 270 270     84.68047 39.64797
#> 3   001-0001 Inclisiran  78 Male White Day 330 330     84.68047 23.01864
#> 4   001-0001 Inclisiran  78 Male White Day 450 450     84.68047 30.83611
#> 5   001-0001 Inclisiran  78 Male White Day 510 510     84.68047 15.58256
#> 6   001-0001 Inclisiran  78 Male White Day 540 540     84.68047 18.90423
#>   ldl_pct_change
#> 1      -70.04937
#> 2      -53.17932
#> 3      -72.81706
#> 4      -63.58534
#> 5      -81.59841
#> 6      -77.67581
```

Fit the trial’s MMRM and compare the arms at each visit:

``` r

ldl$subject_id <- factor(ldl$subject_id)

fit <- mmrm::mmrm(
  ldl_pct_change ~ treatment * visit + ldl_baseline + us(visit | subject_id),
  data = ldl,
  reml = TRUE,
  method = "Kenward-Roger"
)

means <- emmeans::emmeans(fit, ~ treatment | visit)
#> mmrm() registered as emmeans extension
emmeans::contrast(means, "revpairwise")
#> visit = Day 150:
#>  contrast             estimate   SE   df t.ratio p.value
#>  Inclisiran - Placebo    -59.8 1.16 1559 -51.635 <0.0001
#> 
#> visit = Day 270:
#>  contrast             estimate   SE   df t.ratio p.value
#>  Inclisiran - Placebo    -51.9 1.36 1560 -38.165 <0.0001
#> 
#> visit = Day 330:
#>  contrast             estimate   SE   df t.ratio p.value
#>  Inclisiran - Placebo    -61.8 1.22 1559 -50.824 <0.0001
#> 
#> visit = Day 450:
#>  contrast             estimate   SE   df t.ratio p.value
#>  Inclisiran - Placebo    -48.6 1.34 1560 -36.176 <0.0001
#> 
#> visit = Day 510:
#>  contrast             estimate   SE   df t.ratio p.value
#>  Inclisiran - Placebo    -57.3 1.20 1560 -47.578 <0.0001
#> 
#> visit = Day 540:
#>  contrast             estimate   SE   df t.ratio p.value
#>  Inclisiran - Placebo    -54.8 1.25 1560 -43.733 <0.0001
```

[`vignette("orion10", package = "clinique")`](https://edgararuiz.github.io/clinique/articles/orion10.md)
explains where each number in the simulation comes from.
