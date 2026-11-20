# Simulating ORION-10

`simulate_ldl(n, study = "orion10")` makes up LDL cholesterol data that
looks like the ORION-10 trial. This article explains how. It lists each
number the simulation uses, where the number came from, and what was
assumed.

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
ldl <- simulate_ldl(1561)
head(ldl)
#>   subject_id  treatment age  sex  race   visit day ldl_baseline
#> 1   001-0001 Inclisiran  78 Male White Day 150 150     84.68047
#> 2   001-0001 Inclisiran  78 Male White Day 270 270     84.68047
#> 3   001-0001 Inclisiran  78 Male White Day 330 330     84.68047
#> 4   001-0001 Inclisiran  78 Male White Day 450 450     84.68047
#> 5   001-0001 Inclisiran  78 Male White Day 510 510     84.68047
#> 6   001-0001 Inclisiran  78 Male White Day 540 540     84.68047
#>        ldl ldl_pct_change
#> 1 25.36234      -70.04937
#> 2 39.64797      -53.17932
#> 3 23.01864      -72.81706
#> 4 30.83611      -63.58534
#> 5 15.58256      -81.59841
#> 6 18.90423      -77.67581
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
figure, read by eye:

1.  Placebo: quartiles about +11%, -5% and -16%, so an SD of about 0.21.
2.  Inclisiran: quartiles about -43%, -59% and -72%, so an SD of about
    0.53.

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
#> 1 Day 150               1.505769                 -58.25524
#> 2 Day 270               5.386907                 -46.56692
#> 3 Day 330               6.601761                 -55.17030
#> 4 Day 450               3.209258                 -45.38831
#> 5 Day 510               1.821706                 -55.51716
#> 6 Day 540               1.832897                 -53.00408
```

## Fitting the SAP’s model

The SAP’s MMRM, fitted with the `mmrm` package:

``` r

ldl$subject_id <- factor(ldl$subject_id)

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
#>     -57.33066     -55.70184
```

The Figure 2 targets give about -57.7 at Day 510 and -56.3
time-adjusted. The published estimates, which fill in missing values,
are -52.3 and -53.9 (FDA review, Table 10).

## What is assumed

1.  The correlation between visits.
2.  The same SD at every visit.
3.  The normal shape of the age distribution.
4.  Every number read by eye from a figure carries some reading error.
