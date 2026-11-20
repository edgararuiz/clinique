# clinique

<!-- badges: start -->
<!-- badges: end -->

clinique simulates realistic clinical trial data. Each dataset is modelled
on a published trial and its statistical analysis plan, so the trial's own
analysis gives results close to the published ones. Every subject is made
up.

The first dataset is modelled on ORION-10, a trial of inclisiran, a drug
that lowers LDL cholesterol, against placebo. The data is simulated and is
not affiliated with or endorsed by the trial's sponsor.

## Installation

You can install the development version of clinique from
[GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("edgararuiz/clinique")
```

## Example

`simulate_ldl()` returns one row per subject per visit, ready for the
trial's mixed model for repeated measures (MMRM):

``` r
library(clinique)

set.seed(1)
ldl <- simulate_ldl(1561)
ldl$subject_id <- factor(ldl$subject_id)

fit <- mmrm::mmrm(
  ldl_pct_change ~ treatment * visit + ldl_baseline + us(visit | subject_id),
  data = ldl,
  reml = TRUE,
  method = "Kenward-Roger"
)

means <- emmeans::emmeans(fit, ~ treatment | visit)
emmeans::contrast(means, "revpairwise")
```

`vignette("orion10", package = "clinique")` explains where each number in
the simulation comes from.
