# Simulating ODYSSEY LONG TERM

`simulate_ldl(n, study = "odyssey_lt")` makes up LDL cholesterol data
that looks like the ODYSSEY LONG TERM trial. This article explains how.
It lists each number the simulation uses, where the number came from,
and what was assumed. It follows the same structure as
[`vignette("orion10")`](https://edgararuiz.github.io/clinique/articles/orion10.md),
so you can compare the two side by side.

The data is simulated. It is not affiliated with or endorsed by the
trial’s sponsors.

## The trial

ODYSSEY LONG TERM (NCT01507831) tested alirocumab, a drug that lowers
LDL cholesterol, against placebo. Alirocumab is an antibody against
PCSK9, a protein that controls how much LDL the liver clears from the
blood. It is injected under the skin every two weeks.

The trial randomized 2,341 adults at high cardiovascular risk whose LDL
stayed high on the highest statin dose they could take. They were
randomized 2:1: 1,553 to alirocumab and 788 to placebo. Treatment lasted
78 weeks.

The primary endpoint is the percent change in LDL from baseline to Week
24. The trial’s statistical analysis plan (SAP) analyzes it with a mixed
model for repeated measures (MMRM) that uses every visit from Week 4 to
Week 52.

## Sources

1.  The SAP, dated 20 December 2013. It is part of the protocol
    supplement to the NEJM paper
    (<https://doi.org/10.1056/NEJMoa1501031>). Section 2.4.4.1.1 defines
    the primary analysis.
2.  The NEJM paper’s Supplementary Appendix, same link.
3.  The FDA statistical review, which covers all 10 ODYSSEY trials:
    <https://www.accessdata.fda.gov/drugsatfda_docs/nda/2015/125559Orig1s000StatR.pdf>
4.  The trial’s results on ClinicalTrials.gov:
    <https://clinicaltrials.gov/study/NCT01507831>

Each number below is labelled with its source. “Read by eye” means it
was read off a published figure, to about 1 point. “Derived” means it
was calculated from published numbers. “Assumed” means no public source
gives it.

## The data

``` r

library(clinique)

set.seed(1)
ldl <- simulate_ldl(2341, study = "odyssey_lt")
head(ldl)
#>   subject_id treatment age  sex  race   visit day ldl_baseline      ldl
#> 1   001-0001   Placebo  62 Male White  Week 4  28     84.99889 64.67659
#> 2   001-0001   Placebo  62 Male White  Week 8  56     84.99889 68.25461
#> 3   001-0001   Placebo  62 Male White Week 12  84     84.99889 78.92457
#> 4   001-0001   Placebo  62 Male White Week 16 112     84.99889 70.22783
#> 5   001-0001   Placebo  62 Male White Week 24 168     84.99889 68.53246
#> 6   001-0001   Placebo  62 Male White Week 36 252     84.99889 73.73389
#>   ldl_pct_change hefh prior_mi_stroke statin_intensity         region
#> 1     -23.908900   No              No     Low/moderate Eastern Europe
#> 2     -19.699416   No              No     Low/moderate Eastern Europe
#> 3      -7.146352   No              No     Low/moderate Eastern Europe
#> 4     -17.377949   No              No     Low/moderate Eastern Europe
#> 5     -19.372529   No              No     Low/moderate Eastern Europe
#> 6     -13.253116   No              No     Low/moderate Eastern Europe
```

There is one row per subject per visit. The visits are Weeks 4, 8, 12,
16, 24, 36 and 52. The `day` column is the nominal study day, seven
times the week: Week 24 is day 168. The trial also measured LDL at Weeks
64 and 78, but the SAP’s primary model stops at Week 52, so the data
does too.

The last four columns are the randomization strata. They are explained
below.

There are no missing values. Real trials lose subjects, but this data is
meant for practising the analysis, not the handling of missing data.

## How each part is simulated

### Treatment

Subjects are randomized 2:1. When `n` is not a multiple of 3, the extra
subjects get alirocumab. For example, 2,341 subjects give 1,561 on
alirocumab and 780 on placebo. The trial had 1,553 and 788.

### Demographics

1.  Age: a normal distribution with mean 60.5 and SD 10.4
    (ClinicalTrials.gov), cut to the range 18 to 90 and rounded. The
    normal shape and the range are assumed.
2.  Sex: 62.2% male (1,457 of 2,341; ClinicalTrials.gov).
3.  Race: 93% White, 3% Black, 4% Other (2,175, 77 and 89 of 2,341; FDA
    review, Table 12).

### Randomization strata

The trial randomized subjects within groups called strata, so that each
group got the same 2:1 split. The SAP then adjusts for the same groups
in its model. There are four:

1.  `hefh`: heterozygous familial hypercholesterolemia, an inherited
    form of high LDL. 17.8% Yes (FDA review, Table 12).
2.  `prior_mi_stroke`: a past heart attack (myocardial infarction) or
    ischemic stroke. 48.1% Yes (FDA review, Table 12).
3.  `statin_intensity`: “High” means atorvastatin 40 to 80 mg or
    rosuvastatin 20 to 40 mg a day. 44.1% High (FDA review, Table 12).
4.  `region`: where the subject enrolled. 24% North America, 40% Western
    Europe, 21% Eastern Europe, 15% Rest of World (assumed). No source
    gives this split. It was worked out from two facts: 21% of subjects
    enrolled in the US (FDA review, Table 12), and the number of trial
    sites in each region (ClinicalTrials.gov).

``` r

table(ldl$region[ldl$visit == "Week 4"])
#> 
#> Eastern Europe  North America  Rest of World Western Europe 
#>            507            544            339            951
```

The strata have no effect on the percent change in this data (assumed).
The model still adjusts for them, as the trial’s would.

### Baseline LDL

Baseline LDL comes from a log-normal distribution with mean 122.4 mg/dL
and SD 42.2 (ClinicalTrials.gov). A log-normal fits LDL: it is never
below zero and has a long right tail.

### Percent change at each visit

The mean percent change for each arm and visit comes from Figure 7 of
the FDA review, read by eye:

| week | alirocumab | placebo |
|-----:|-----------:|--------:|
|    4 |      -64.9 |     1.6 |
|    8 |      -65.9 |     1.2 |
|   12 |      -63.8 |     1.6 |
|   16 |      -64.9 |     1.2 |
|   24 |      -61.3 |     1.4 |
|   36 |      -60.5 |     0.4 |
|   52 |      -57.5 |     5.1 |

These agree with the published least-squares means in Table 27 of the
FDA review: -63% and +1% at Week 12, and -61% and +1% at Week 24.

The alirocumab curve is almost flat. LDL drops by Week 4 and stays down,
because a dose every two weeks keeps the drug level steady. ORION-10 is
different: inclisiran is given twice a year, so its effect rises and
falls between doses.

### Spread and correlation

As in ORION-10, the simulation works on the log of the ratio LDL /
baseline. This keeps LDL above zero.

No source shows the spread of each subject’s change. It is derived from
the standard errors in Table S2 of the NEJM appendix. A standard error
is the SD divided by the square root of the number of subjects, so the
SD is the standard error times that square root:

``` r

c(
  alirocumab = 0.8 * sqrt(1278),
  placebo = 1.1 * sqrt(652)
)
#> alirocumab    placebo 
#>   28.59930   28.08772
```

Both come to about 28 percentage points. Two cautions apply:

1.  Table S2 covers LDL measured directly in the lab, while the primary
    endpoint uses LDL calculated from other lipids. The two are close
    but not the same.
2.  The MMRM uses one covariance for both arms, so these standard errors
    can’t show a difference between arms. The same SD of 28 points is
    assumed for both. ORION-10’s data supports this: its two arms had
    similar SDs on the percent scale.

On the log scale, an SD of 28 points works out to about 0.66 for
alirocumab and 0.27 for placebo, because alirocumab’s LDL is smaller
after treatment:

``` r

sdlog <- function(pct_sd, mean_pct) {
  sqrt(log(1 + (pct_sd / (100 + mean_pct))^2))
}
c(alirocumab = sdlog(28, -62), placebo = sdlog(28, 1))
#> alirocumab    placebo 
#>  0.6585494  0.2721120
```

The same SD is used at every visit (assumed).

Values from the same subject are correlated. No source gives the
correlations, so ORION-10’s rule is reused (assumed): 0.7 for visits 180
days apart, higher for nearer visits and lower for farther ones.

|         | Week 4 | Week 8 | Week 12 | Week 16 | Week 24 | Week 36 | Week 52 |
|:--------|-------:|-------:|--------:|--------:|--------:|--------:|--------:|
| Week 4  |   1.00 |   0.95 |    0.89 |    0.85 |    0.76 |    0.64 |    0.51 |
| Week 8  |   0.95 |   1.00 |    0.95 |    0.89 |    0.80 |    0.68 |    0.54 |
| Week 12 |   0.89 |   0.95 |    1.00 |    0.95 |    0.85 |    0.72 |    0.57 |
| Week 16 |   0.85 |   0.89 |    0.95 |    1.00 |    0.89 |    0.76 |    0.61 |
| Week 24 |   0.76 |   0.80 |    0.85 |    0.89 |    1.00 |    0.85 |    0.68 |
| Week 36 |   0.64 |   0.68 |    0.72 |    0.76 |    0.85 |    1.00 |    0.80 |
| Week 52 |   0.51 |   0.54 |    0.57 |    0.61 |    0.68 |    0.80 |    1.00 |

Each subject’s seven log ratios are drawn together from a multivariate
normal distribution, and each log-scale mean is lowered by half the
variance so the expected percent change equals the target.

## Checking the means

The simulated means land close to the targets:

``` r

observed <- aggregate(ldl_pct_change ~ visit + treatment, data = ldl, FUN = mean)
reshape(observed, idvar = "visit", timevar = "treatment", direction = "wide")
#>     visit ldl_pct_change.Placebo ldl_pct_change.Alirocumab
#> 1  Week 4              1.1484275                 -64.31839
#> 2  Week 8              0.8242056                 -65.52504
#> 3 Week 12              0.9538569                 -63.95962
#> 4 Week 16              0.5300950                 -64.96155
#> 5 Week 24              1.2794846                 -61.12624
#> 6 Week 36             -0.6486210                 -60.77591
#> 7 Week 52              3.9355577                 -56.70056
```

## Fitting the SAP’s model

The SAP’s MMRM has fixed effects for:

1.  Treatment, visit and treatment by visit.
2.  Each of the four strata, and each stratum by visit.
3.  Baseline LDL, and baseline LDL by visit.

It uses an unstructured covariance, REML, and Satterthwaite degrees of
freedom. ORION-10 used Kenward-Roger instead.

``` r

ldl$subject_id <- factor(ldl$subject_id)

fit <- mmrm::mmrm(
  ldl_pct_change ~ treatment * visit +
    hefh * visit +
    prior_mi_stroke * visit +
    statin_intensity * visit +
    region * visit +
    ldl_baseline * visit +
    us(visit | subject_id),
  data = ldl,
  reml = TRUE,
  method = "Satterthwaite"
)
```

### Population weights

A least-squares mean is a model’s estimate for one arm, averaged over
the other terms in the model. By default, emmeans gives every level of
every stratum the same weight. For example, it would treat the four
regions as if each had a quarter of the subjects.

The SAP asks for “population weights” instead: each level counts in
proportion to its share of the subjects. Its reason is that the strata
are not balanced. Only 18% of subjects have familial
hypercholesterolemia, so giving them half the weight would describe a
population that doesn’t exist. In emmeans, this is
`weights = "proportional"`:

``` r

means <- emmeans::emmeans(fit, ~ treatment | visit, weights = "proportional")
diffs <- summary(emmeans::contrast(means, "revpairwise"))
diffs
#> visit = Week 4:
#>  contrast             estimate   SE   df t.ratio p.value
#>  Alirocumab - Placebo    -65.5 1.13 2329 -57.812 <0.0001
#> 
#> visit = Week 8:
#>  contrast             estimate   SE   df t.ratio p.value
#>  Alirocumab - Placebo    -66.4 1.09 2328 -60.782 <0.0001
#> 
#> visit = Week 12:
#>  contrast             estimate   SE   df t.ratio p.value
#>  Alirocumab - Placebo    -65.0 1.11 2328 -58.750 <0.0001
#> 
#> visit = Week 16:
#>  contrast             estimate   SE   df t.ratio p.value
#>  Alirocumab - Placebo    -65.6 1.12 2329 -58.769 <0.0001
#> 
#> visit = Week 24:
#>  contrast             estimate   SE   df t.ratio p.value
#>  Alirocumab - Placebo    -62.5 1.22 2329 -51.071 <0.0001
#> 
#> visit = Week 36:
#>  contrast             estimate   SE   df t.ratio p.value
#>  Alirocumab - Placebo    -60.1 1.20 2329 -50.258 <0.0001
#> 
#> visit = Week 52:
#>  contrast             estimate   SE   df t.ratio p.value
#>  Alirocumab - Placebo    -60.6 1.38 2330 -44.008 <0.0001
#> 
#> Results are averaged over the levels of: hefh, prior_mi_stroke, statin_intensity, region
```

The weights change each arm’s mean, but not the difference between arms,
because the strata have the same effect in both arms.

### The primary endpoint

``` r

diffs[diffs$visit == "Week 24", c("estimate", "SE")]
#>    estimate       SE
#> 5 -62.47284 1.223259
```

There are three numbers to compare it with:

1.  About -62.7: the Figure 7 target, the observed means at Week 24. The
    simulated data has no missing values, so it should land near this.
2.  -62 (95% CI -64 to -59): the sponsor’s published MMRM (FDA review,
    Table 27). The MMRM treats missing values as missing at random, so
    it lands close to the observed means.
3.  -58: the FDA’s preferred analysis (FDA review, Table 14). It assumes
    that subjects who stopped treatment returned to their baseline LDL,
    which shrinks the effect.

## How this study differs from ORION-10

|  | ORION-10 | ODYSSEY LONG TERM |
|----|----|----|
| Randomization | 1:1 | 2:1 |
| Visits in the model | 6, Days 150 to 540 | 7, Weeks 4 to 52 |
| Effect over time | Rises and falls with each dose | Flat |
| Primary endpoint | Day 510 and the average after Day 90 | Week 24 |
| Covariates | Baseline LDL | Baseline LDL and four strata, each by visit |
| Degrees of freedom | Kenward-Roger | Satterthwaite |
| Least-squares mean weights | Equal (no strata) | Proportional |

## What is assumed

1.  The SD of the percent change, derived from standard errors, and the
    same SD in both arms and at every visit.
2.  The correlation between visits.
3.  The split by region.
4.  No effect of the strata on the percent change.
5.  The normal shape and the range of the age distribution.
6.  Every number read by eye from a figure carries some reading error.
