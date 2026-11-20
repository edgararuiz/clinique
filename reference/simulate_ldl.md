# Simulate an LDL cholesterol trial dataset

Returns simulated, analysis-ready LDL cholesterol data modelled on a
published clinical trial. Every subject is made up. The data has one row
per subject per scheduled visit, with no missing values, ready for the
trial's mixed model for repeated measures (MMRM).

## Usage

``` r
simulate_ldl(n, study = c("orion10", "odyssey_lt"))
```

## Arguments

- n:

  Number of subjects. The randomization ratio depends on the study.
  Subjects left over after the last full ratio block go to the active
  treatment.

- study:

  The trial to model:

  - `"orion10"`: ORION-10, inclisiran vs placebo (NCT03399370),
    randomized 1:1. The trial randomized 1,561. See
    [`vignette("orion10", package = "clinique")`](https://edgararuiz.github.io/clinique/articles/orion10.md).

  - `"odyssey_lt"`: ODYSSEY LONG TERM, alirocumab vs placebo
    (NCT01507831), randomized 2:1. The trial randomized 2,341. See
    [`vignette("odyssey-lt", package = "clinique")`](https://edgararuiz.github.io/clinique/articles/odyssey-lt.md).

## Value

A data frame with one row per subject per visit, sorted by subject and
then visit. Every study has these columns:

- `subject_id`: Subject identifier, such as `"001-0001"`.

- `treatment`: Factor with placebo as the reference level: `"Placebo"`
  and `"Inclisiran"` or `"Alirocumab"`.

- `age`: Age in years.

- `sex`: `"Male"` or `"Female"`.

- `race`: `"White"`, `"Black"` or `"Other"`.

- `visit`: Ordered factor: `"Day 150"` to `"Day 540"` for ORION-10,
  `"Week 4"` to `"Week 52"` for ODYSSEY LONG TERM.

- `day`: Study day of the visit.

- `ldl_baseline`: LDL at baseline, in mg/dL.

- `ldl`: LDL at the visit, in mg/dL.

- `ldl_pct_change`: Percent change in LDL from baseline.

ODYSSEY LONG TERM adds its randomization strata, which its analysis plan
adjusts for:

- `hefh`: Heterozygous familial hypercholesterolemia, `"Yes"` or `"No"`.

- `prior_mi_stroke`: Prior heart attack or ischemic stroke, `"Yes"` or
  `"No"`.

- `statin_intensity`: `"High"` or `"Low/moderate"`.

- `region`: `"North America"`, `"Western Europe"`, `"Eastern Europe"` or
  `"Rest of World"`.

## Details

The baseline LDL, the mean percent change at each visit and the
demographics follow the trial's published results. The mean percent
changes follow the observed means, not the published estimates that
account for missing values. Each study's vignette explains every number,
its source and the assumptions.

The data is simulated. It is not affiliated with or endorsed by either
trial's sponsor.

## References

ORION-10 statistical analysis plan:
<https://cdn.clinicaltrials.gov/large-docs/70/NCT03399370/SAP_001.pdf>

ORION-10 FDA statistical review:
<https://www.accessdata.fda.gov/drugsatfda_docs/nda/2022/214012Orig1s000StatR.pdf>

Ray KK, et al. Two Phase 3 Trials of Inclisiran in Patients with
Elevated LDL Cholesterol. N Engl J Med 2020;382:1507-1519.
[doi:10.1056/NEJMoa1912387](https://doi.org/10.1056/NEJMoa1912387)

ODYSSEY LONG TERM FDA statistical review:
<https://www.accessdata.fda.gov/drugsatfda_docs/nda/2015/125559Orig1s000StatR.pdf>

Robinson JG, et al. Efficacy and Safety of Alirocumab in Reducing Lipids
and Cardiovascular Events. N Engl J Med 2015;372:1489-1499. Its
statistical analysis plan is in the protocol supplement.
[doi:10.1056/NEJMoa1501031](https://doi.org/10.1056/NEJMoa1501031)

## Examples

``` r
set.seed(1)
ldl <- simulate_ldl(100)
head(ldl)
#>   subject_id treatment age    sex  race   visit day ldl_baseline
#> 1   001-0001   Placebo  70 Female White Day 150 150     89.60336
#> 2   001-0001   Placebo  70 Female White Day 270 270     89.60336
#> 3   001-0001   Placebo  70 Female White Day 330 330     89.60336
#> 4   001-0001   Placebo  70 Female White Day 450 450     89.60336
#> 5   001-0001   Placebo  70 Female White Day 510 510     89.60336
#> 6   001-0001   Placebo  70 Female White Day 540 540     89.60336
#>         ldl ldl_pct_change
#> 1  96.17405       7.333092
#> 2 119.41800      33.274030
#> 3 106.97133      19.383169
#> 4 119.43851      33.296914
#> 5 111.94626      24.935342
#> 6 115.37867      28.766009

odyssey <- simulate_ldl(90, study = "odyssey_lt")
head(odyssey)
#>   subject_id  treatment age  sex  race   visit day ldl_baseline
#> 1   001-0001 Alirocumab  62 Male White  Week 4  28     100.9234
#> 2   001-0001 Alirocumab  62 Male White  Week 8  56     100.9234
#> 3   001-0001 Alirocumab  62 Male White Week 12  84     100.9234
#> 4   001-0001 Alirocumab  62 Male White Week 16 112     100.9234
#> 5   001-0001 Alirocumab  62 Male White Week 24 168     100.9234
#> 6   001-0001 Alirocumab  62 Male White Week 36 252     100.9234
#>        ldl ldl_pct_change hefh prior_mi_stroke statin_intensity
#> 1 30.09524      -70.18011   No             Yes     Low/moderate
#> 2 27.99392      -72.26221   No             Yes     Low/moderate
#> 3 16.72129      -83.43169   No             Yes     Low/moderate
#> 4 16.59908      -83.55279   No             Yes     Low/moderate
#> 5 17.06002      -83.09607   No             Yes     Low/moderate
#> 6 12.75462      -87.36207   No             Yes     Low/moderate
#>          region
#> 1 North America
#> 2 North America
#> 3 North America
#> 4 North America
#> 5 North America
#> 6 North America
```
