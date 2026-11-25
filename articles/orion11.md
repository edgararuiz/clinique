# Simulating ORION-11

`simulate_orion11(n)` makes up LDL cholesterol data that looks like the
ORION-11 trial. ORION-11 is ORION-10’s sister trial, so the simulation
works the same way. This article covers what is different. For the
method itself (the log-normal baseline, the log-ratio scale, the
correlation between visits), see
[`vignette("orion10")`](https://edgararuiz.github.io/clinique/articles/orion10.md).

The data is simulated. It is not affiliated with or endorsed by the
trial’s sponsor.

## The trial

ORION-11 (NCT03400800) tested inclisiran against placebo with the same
doses as ORION-10: injections on Days 1, 90, 270 and 450. It randomized
1,617 adults 1:1: 810 to inclisiran and 807 to placebo.

Three things set it apart from ORION-10:

1.  **The population.** ORION-11 enrolled in Europe and South Africa,
    not North America. As well as people with atherosclerotic
    cardiovascular disease (ASCVD), it took people at equal risk without
    it, such as those with type 2 diabetes. Inclisiran lowered LDL about
    5 points less than in ORION-10.
2.  **A covariate.** The trial randomized subjects within groups defined
    by current use of statins or other lipid-lowering drugs. Its
    statistical analysis plan (SAP) adds that group to the model.
    ORION-10 also randomized this way, but its SAP leaves the group out
    of the model.
3.  **Day 90.** ORION-10’s SAP removes Day 90 from the model. ORION-11’s
    SAP keeps it. Both SAPs define the time-adjusted endpoint as the
    average after Day 90, so in ORION-11 Day 90 is in the model but not
    in that average.

The two SAPs are otherwise word for word the same in how they define the
model.

## Sources

1.  The SAP:
    <https://cdn.clinicaltrials.gov/large-docs/00/NCT03400800/SAP_001.pdf>.
    Section 6.4.6.1 and Appendix 1 define the model.
2.  The FDA statistical review, which covers ORION-9, -10 and -11:
    <https://www.accessdata.fda.gov/drugsatfda_docs/nda/2022/214012Orig1s000StatR.pdf>
3.  The NEJM paper’s Supplementary Appendix:
    <https://doi.org/10.1056/NEJMoa1912387>
4.  The trial’s results on ClinicalTrials.gov:
    <https://clinicaltrials.gov/study/NCT03400800>

The means and spreads come from published figures. For this study they
were measured from the figure images, using the axis tick marks to turn
pixels into percentages, rather than read by eye. The same measurement
on the ORION-10 figures matched the ORION-10 values to within 0.2 points
for the means and 0.02 for the SDs.

## The data

``` r

library(clinique)

set.seed(1)
ldl <- simulate_orion11(1617)
ldl
#> # A tibble: 11,319 × 11
#>    subject_id treatment    age sex   race  visit     day ldl_baseline
#>    <fct>      <fct>      <dbl> <fct> <fct> <ord>   <dbl>        <dbl>
#>  1 001-0001   Inclisiran    49 Male  White Day 90     90         73.6
#>  2 001-0001   Inclisiran    49 Male  White Day 150   150         73.6
#>  3 001-0001   Inclisiran    49 Male  White Day 270   270         73.6
#>  4 001-0001   Inclisiran    49 Male  White Day 330   330         73.6
#>  5 001-0001   Inclisiran    49 Male  White Day 450   450         73.6
#>  6 001-0001   Inclisiran    49 Male  White Day 510   510         73.6
#>  7 001-0001   Inclisiran    49 Male  White Day 540   540         73.6
#>  8 001-0002   Inclisiran    72 Male  White Day 90     90         66.7
#>  9 001-0002   Inclisiran    72 Male  White Day 150   150         66.7
#> 10 001-0002   Inclisiran    72 Male  White Day 270   270         66.7
#> # ℹ 11,309 more rows
#> # ℹ 3 more variables: ldl <dbl>, ldl_pct_change <dbl>,
#> #   statin_use <fct>
```

The visits are Days 90, 150, 270, 330, 450, 510 and 540. The last
column, `statin_use`, says whether the subject was taking a statin or
another lipid-lowering drug at the start.

``` r

table(ldl$statin_use[ldl$visit == "Day 90"])
#> 
#>   No  Yes 
#>   54 1563
```

## What differs from ORION-10

Every other number follows the ORION-10 method. Only the values change:

| Setting | ORION-10 | ORION-11 | ORION-11 source |
|----|----|----|----|
| Visits | Days 150 to 540 | Days 90 to 540 | SAP, Appendix 1 |
| Baseline LDL, mean (SD) | 104.6 (38.3) | 105.4 (39.2) | FDA review, Table 6, pooled over arms |
| Age, mean (SD) | 66.1 (8.9) | 64.8 (8.5) | ClinicalTrials.gov |
| Male | 69.4% | 71.7% | ClinicalTrials.gov |
| White, Black, Other | 85.7%, 12.6%, 1.7% | 98.1%, 1.2%, 0.6% | ClinicalTrials.gov |
| On a statin | Not in the data | 96.2% | FDA review, Table 6 |
| Log-scale SD, placebo | 0.21 | 0.23 | NEJM appendix, Figure S3, Panel D |
| Log-scale SD, inclisiran | 0.53 | 0.44 | NEJM appendix, Figure S3, Panel D |

The SDs come from the quartiles of each subject’s Day 510 change: about
+16%, -3% and -15% for placebo, and -40%, -54% and -67% for inclisiran.

The mean percent change at each visit, from Figure 2 of the FDA review:

| day | inclisiran | placebo |
|----:|-----------:|--------:|
|  90 |      -46.8 |     1.8 |
| 150 |      -51.2 |     3.2 |
| 270 |      -42.3 |     3.8 |
| 330 |      -51.8 |     2.8 |
| 450 |      -39.7 |     3.4 |
| 510 |      -49.4 |     4.2 |
| 540 |      -47.7 |     3.4 |

The sawtooth is the same as ORION-10’s: deepest 60 days after a dose
(Days 150, 330 and 510), weaker just before the next one (Days 270 and
450).

`statin_use` has no effect on the percent change in this data (assumed).
The model still adjusts for it, as the SAP says.

## Checking the means

``` r

observed <- aggregate(ldl_pct_change ~ visit + treatment, data = ldl, FUN = mean)
reshape(observed, idvar = "visit", timevar = "treatment", direction = "wide")
#>     visit ldl_pct_change.Placebo ldl_pct_change.Inclisiran
#> 1  Day 90               1.960530                 -47.93995
#> 2 Day 150               3.174345                 -52.28128
#> 3 Day 270               2.733365                 -43.59529
#> 4 Day 330               1.634143                 -53.01784
#> 5 Day 450               2.853272                 -41.07580
#> 6 Day 510               4.779536                 -50.49106
#> 7 Day 540               3.897049                 -49.18231
```

## Fitting the SAP’s model

The SAP’s model has fixed effects for treatment, visit, treatment by
visit, baseline LDL and statin use. It uses an unstructured covariance,
REML and Kenward-Roger degrees of freedom:

``` r

fit <- mmrm::mmrm(
  ldl_pct_change ~ treatment * visit + statin_use + ldl_baseline +
    us(visit | subject_id),
  data = ldl,
  reml = TRUE,
  method = "Kenward-Roger"
)

means <- emmeans::emmeans(fit, ~ treatment | visit)
diffs <- summary(emmeans::contrast(means, "revpairwise"))
diffs[, c("visit", "estimate", "SE")]
#>     visit  estimate       SE
#> 1  Day 90 -49.87363 1.139954
#> 2 Day 150 -55.42878 1.102210
#> 3 Day 270 -46.30181 1.188689
#> 4 Day 330 -54.62514 1.070123
#> 5 Day 450 -43.90223 1.237178
#> 6 Day 510 -55.24375 1.148522
#> 7 Day 540 -53.05251 1.146009
```

The two co-primary endpoints. Day 90 is in the model, but the
time-adjusted average only uses the visits after it:

``` r

c(
  day_510 = diffs$estimate[diffs$visit == "Day 510"],
  time_adjusted = mean(diffs$estimate[diffs$visit != "Day 90"])
)
#>       day_510 time_adjusted 
#>     -55.24375     -51.42570
```

The Figure 2 targets give about -53.6 at Day 510 and -50.5
time-adjusted. The published estimates, which fill in missing values in
a cautious way that pulls inclisiran toward zero, are -49.8 and -49.1
(FDA review, Table 10). The simulation aims at the targets, because it
has no missing values. Each visit’s estimate has a standard error of
about 1.2, though, so one simulated dataset can land a couple of points
to either side of its target. This one lands about 1.6 points beyond the
target at Day 510.

## ORION-10 and ORION-11 side by side

The same drug in two populations. Fitting each trial’s own model to its
own data shows the smaller effect in ORION-11:

``` r

set.seed(1)
orion10 <- simulate_orion10(1561)
fit10 <- mmrm::mmrm(
  ldl_pct_change ~ treatment * visit + ldl_baseline + us(visit | subject_id),
  data = orion10,
  reml = TRUE,
  method = "Kenward-Roger"
)
diffs10 <- summary(emmeans::contrast(
  emmeans::emmeans(fit10, ~ treatment | visit),
  "revpairwise"
))

data.frame(
  trial = c("ORION-10", "ORION-11"),
  day_510 = c(
    diffs10$estimate[diffs10$visit == "Day 510"],
    diffs$estimate[diffs$visit == "Day 510"]
  ),
  time_adjusted = c(
    mean(diffs10$estimate),
    mean(diffs$estimate[diffs$visit != "Day 90"])
  )
)
#>      trial   day_510 time_adjusted
#> 1 ORION-10 -57.32027     -56.07347
#> 2 ORION-11 -55.24375     -51.42570
```

## What is assumed

1.  The correlation between visits, the same rule as ORION-10.
2.  The same SD at every visit, taken from Day 510.
3.  No effect of statin use on the percent change.
4.  The normal shape of the age distribution.
5.  Every number measured from a figure carries some measurement error.
