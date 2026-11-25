# Simulating ORION-10

`simulate_orion10(n)` makes up LDL cholesterol data that looks like the
ORION-10 trial. This article explains how. It lists each number the
simulation uses, where the number came from, and what was assumed.

The data is simulated. It is not affiliated with or endorsed by the
trial’s sponsor.

## The trial

ORION-10 (NCT03399370) tested inclisiran, a drug that lowers LDL
cholesterol, against placebo. It randomized 1,561 adults with
atherosclerotic cardiovascular disease: 781 to inclisiran and 780 to
placebo. Doses were given on Days 1, 90, 270 and 450.

The trial’s statistical analysis plan (SAP) defines the main analysis as
a mixed model for repeated measures (MMRM). The outcome is the percent
change in LDL from baseline at each visit. The model has fixed effects
for treatment, visit, treatment by visit, and baseline LDL. It uses an
unstructured covariance, REML and Kenward-Roger degrees of freedom.

## Sources

1.  The SAP:
    <https://cdn.clinicaltrials.gov/large-docs/70/NCT03399370/SAP_001.pdf>
2.  The FDA statistical review, which covers ORION-9, -10 and -11:
    <https://www.accessdata.fda.gov/drugsatfda_docs/nda/2022/214012Orig1s000StatR.pdf>
3.  The NEJM paper’s Supplementary Appendix:
    <https://doi.org/10.1056/NEJMoa1912387>

Each number below is labelled with its source. “Read by eye” means it
was read off a published figure, to about 1 point for means and 0.05 for
standard deviations (SDs). “Assumed” means no public source gives it.

## The data

``` r

library(clinique)

set.seed(1)
ldl <- simulate_orion10(1561)
head(ldl)
#> # A tibble: 6 × 10
#>   subject_id treatment   age sex   race  visit   day ldl_baseline   ldl
#>   <fct>      <fct>     <dbl> <fct> <fct> <ord> <dbl>        <dbl> <dbl>
#> 1 001-0001   Inclisir…    78 Male  White Day …   150         84.7  44.2
#> 2 001-0001   Inclisir…    78 Male  White Day …   270         84.7  37.8
#> 3 001-0001   Inclisir…    78 Male  White Day …   330         84.7  27.8
#> 4 001-0001   Inclisir…    78 Male  White Day …   450         84.7  42.2
#> 5 001-0001   Inclisir…    78 Male  White Day …   510         84.7  51.2
#> 6 001-0001   Inclisir…    78 Male  White Day …   540         84.7  68.7
#> # ℹ 1 more variable: ldl_pct_change <dbl>
```

There is one row per subject per visit. The visits are Days 150, 270,
330, 450, 510 and 540. LDL was also measured on Day 90, but the SAP
leaves Day 90 out of the model (SAP Section 6.4.6.1), so the data leaves
it out too.

There are no missing values. Real trials lose subjects, but this data is
meant for practising the analysis, not the handling of missing data.

## How each part is simulated

### Treatment

Subjects are randomized 1:1. When `n` is odd, the extra subject gets
inclisiran, as in the trial (781 vs 780).

### Demographics

Age, sex and race come from Table 5 of the FDA review. The two arms are
pooled, because differences between randomized arms are chance.

1.  Age: a normal distribution with mean 66.1 and SD 8.9, cut to the
    range 35 to 90 and rounded. Table 5 gives the mean, SD and range;
    the normal shape is assumed.
2.  Sex: 69.4% male (1,083 of 1,561).
3.  Race: 85.7% White, 12.6% Black, 1.7% Other (1,338, 197 and 26 of
    1,561).

### Baseline LDL

Baseline LDL comes from a log-normal distribution with mean 104.6 mg/dL
and SD 38.3 (FDA review, Table 5). A log-normal fits LDL: it is never
below zero and has a long right tail, like the real values (median 94,
maximum 466).

### Percent change at each visit

The mean percent change for each arm and visit comes from Figure 2 of
the FDA review, read by eye:

| day | inclisiran | placebo |
|----:|-----------:|--------:|
| 150 |      -59.4 |     1.2 |
| 270 |      -48.3 |     4.8 |
| 330 |      -56.0 |     5.8 |
| 450 |      -46.0 |     3.0 |
| 510 |      -56.3 |     1.4 |
| 540 |      -53.8 |     1.8 |

Inclisiran’s values follow the dosing schedule. The drop is deepest 60
days after a dose (Days 150, 330 and 510) and weaker just before the
next dose (Days 270 and 450).

These targets are the means of the values the trial observed. They are
not the published estimates in Table 10 of the FDA review. Those
estimates fill in missing values in a cautious way that pulls inclisiran
toward zero. For example, Table 10 gives -51.4% for inclisiran at Day
510, while Figure 2 shows about -56.3%. The simulated data has no
missing values, so it matches what was observed. As a result, the
simulated treatment effect is a few points larger than the published
one.

### Spread and correlation

The simulation works on the log of the ratio LDL / baseline, not on the
percent change itself. For example, a log ratio of -0.69 is a ratio of
0.5, which is a -50% change. This has two benefits:

1.  LDL is always above zero. A normal draw of percent change could fall
    below -100%, which would mean negative LDL.
2.  The changes are right-skewed, like the real ones. Figure S3, Panel B
    of the NEJM appendix shows each subject’s observed Day 510 change.
    Both arms have a long right tail.

The SD of the log ratio for each arm comes from the quartiles in that
figure. The simulation uses SDs read by eye: 0.21 for placebo and 0.53
for inclisiran. Measuring the figure from its image, using the axis tick
marks to turn pixels into percentages, later gave these quartiles:

1.  Placebo: about +14%, -3% and -17%, so an SD of about 0.23.
2.  Inclisiran: about -50%, -64% and -75%, so an SD of about 0.52.

The measured SDs are within 0.02 of the ones the simulation uses, well
inside the reading error, so the simulation keeps them.

The figure only covers Day 510, so the same SD is used at every visit
(assumed).

Values from the same subject are correlated: someone whose LDL is high
at Day 150 tends to be high at Day 270 too. No source gives the
correlations, so they are assumed: 0.7 for visits 180 days apart, higher
for nearer visits and lower for farther ones.

|         | Day 150 | Day 270 | Day 330 | Day 450 | Day 510 | Day 540 |
|:--------|--------:|--------:|--------:|--------:|--------:|--------:|
| Day 150 |    1.00 |    0.79 |    0.70 |    0.55 |    0.49 |    0.46 |
| Day 270 |    0.79 |    1.00 |    0.89 |    0.70 |    0.62 |    0.59 |
| Day 330 |    0.70 |    0.89 |    1.00 |    0.79 |    0.70 |    0.66 |
| Day 450 |    0.55 |    0.70 |    0.79 |    1.00 |    0.89 |    0.84 |
| Day 510 |    0.49 |    0.62 |    0.70 |    0.89 |    1.00 |    0.94 |
| Day 540 |    0.46 |    0.59 |    0.66 |    0.84 |    0.94 |    1.00 |

Each subject’s six log ratios are drawn together from a multivariate
normal distribution with these SDs and correlations.

### Drawing correlated values

A multivariate normal draw starts from independent standard normal
values, one per visit, and mixes them with a matrix that carries the SDs
and correlations. There is more than one way to get that matrix, and the
choice matters for reproducibility.

A common choice is
[`MASS::mvrnorm()`](https://rdrr.io/pkg/MASS/man/mvrnorm.html), which
gets the matrix from an eigendecomposition,
[`eigen()`](https://rdrr.io/r/base/eigen.html). Each eigenvector can
point either way, and different operating systems can pick different
directions. Both choices are correct, but they turn the same random
numbers into different values, so the same seed can give different data
on macOS, Windows and Linux.

The simulation uses base R’s
[`chol()`](https://rdrr.io/r/base/chol.html) instead. It returns the
Cholesky factor: the upper-triangular matrix `U` with positive values on
its diagonal such that `t(U) %*% U` equals the covariance matrix. There
is only one such matrix, so the same seed gives the same data on every
operating system. Other packages and functions also compute Cholesky
factors, and some return the lower-triangular form or reorder the
variables first, which would change the draws, so the simulation always
uses [`chol()`](https://rdrr.io/r/base/chol.html) from base R:

``` r

sigma <- 0.21^2 * r
u <- chol(sigma)
all.equal(t(u) %*% u, sigma, check.attributes = FALSE)
#> [1] TRUE

# Three subjects' log ratios for placebo, before adding the means
z <- matrix(rnorm(3 * 6), ncol = 6)
z %*% u
#>           Day 150     Day 270    Day 330     Day 450     Day 510
#> [1,]  0.151163983  0.05547910 0.02177950  0.11458818 -0.01274272
#> [2,]  0.109610951  0.07192938 0.20694003  0.07681469  0.08472587
#> [3,] -0.003806269 -0.04063802 0.02029003 -0.01177654 -0.13189043
#>          Day 540
#> [1,] -0.08788813
#> [2,]  0.20425785
#> [3,] -0.06156666
```

Taking the exponential of a log ratio pulls the average percent change
up. To correct for this, each log-scale mean is lowered by half the
variance (`sd^2 / 2`). With that correction, the expected percent change
equals the target.

### LDL at each visit

LDL at a visit is the baseline LDL times the ratio. The percent change
is `100 * (ldl / ldl_baseline - 1)`.

## Checking the means

The simulated means land close to the targets:

``` r

observed <- aggregate(ldl_pct_change ~ visit + treatment, data = ldl, FUN = mean)
reshape(observed, idvar = "visit", timevar = "treatment", direction = "wide")
#>     visit ldl_pct_change.Placebo ldl_pct_change.Inclisiran
#> 1 Day 150              0.6610071                 -59.51710
#> 2 Day 270              4.1789412                 -49.17163
#> 3 Day 330              4.9699932                 -56.61357
#> 4 Day 450              2.4044646                 -46.98384
#> 5 Day 510              0.6983163                 -56.61450
#> 6 Day 540              0.5236311                 -54.05911
```

## Fitting the SAP’s model

The SAP’s MMRM, fitted with the `mmrm` package:

``` r

fit <- mmrm::mmrm(
  ldl_pct_change ~ treatment * visit + ldl_baseline + us(visit | subject_id),
  data = ldl,
  reml = TRUE,
  method = "Kenward-Roger"
)
```

The treatment difference at each visit:

``` r

means <- emmeans::emmeans(fit, ~ treatment | visit)
diffs <- summary(emmeans::contrast(means, "revpairwise"))
diffs
#> visit = Day 150:
#>  contrast             estimate   SE   df t.ratio p.value
#>  Inclisiran - Placebo    -60.2 1.17 1559 -51.243 <0.0001
#> 
#> visit = Day 270:
#>  contrast             estimate   SE   df t.ratio p.value
#>  Inclisiran - Placebo    -53.4 1.33 1559 -40.194 <0.0001
#> 
#> visit = Day 330:
#>  contrast             estimate   SE   df t.ratio p.value
#>  Inclisiran - Placebo    -61.6 1.20 1558 -51.409 <0.0001
#> 
#> visit = Day 450:
#>  contrast             estimate   SE   df t.ratio p.value
#>  Inclisiran - Placebo    -49.4 1.33 1559 -37.106 <0.0001
#> 
#> visit = Day 510:
#>  contrast             estimate   SE   df t.ratio p.value
#>  Inclisiran - Placebo    -57.3 1.17 1558 -48.908 <0.0001
#> 
#> visit = Day 540:
#>  contrast             estimate   SE   df t.ratio p.value
#>  Inclisiran - Placebo    -54.6 1.22 1559 -44.620 <0.0001
```

The trial had two co-primary endpoints:

1.  The percent change at Day 510. The SAP’s main analysis for this is
    an analysis of covariance (ANCOVA) on Day 510 alone; the MMRM is one
    of its sensitivity analyses.
2.  The time-adjusted percent change: the average over the visits after
    Day
    90. The MMRM is the SAP’s main analysis for this.

``` r

c(
  day_510 = diffs$estimate[diffs$visit == "Day 510"],
  time_adjusted = mean(diffs$estimate)
)
#>       day_510 time_adjusted 
#>     -57.32027     -56.07347
```

The Figure 2 targets give about -57.7 at Day 510 and -56.3
time-adjusted. The published estimates, which fill in missing values,
are -52.3 and -53.9 (FDA review, Table 10).

## What is assumed

1.  The correlation between visits.
2.  The same SD at every visit.
3.  The normal shape of the age distribution.
4.  Every number read by eye from a figure carries some reading error.
