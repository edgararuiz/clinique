# Settings for each study that `simulate_ldl()` can model. Each study's
# vignette explains every number, its source and the assumptions.
#
# Each entry holds:
#
# 1. `ratio`: randomization ratio by arm. The active arm comes first and
#    placebo last; placebo becomes the reference level of `treatment`.
# 2. `visit`, `day`: visit labels and their study days.
# 3. `targets`: mean percent change by arm (rows) and visit (columns).
# 4. `arm_sd`: SD of log(LDL / baseline) by arm.
# 5. `cor_base`, `cor_days`: correlation between two visits is
#    `cor_base ^ (days apart / cor_days)`.
# 6. `bl_mean`, `bl_sd`: mean and SD of baseline LDL, in mg/dL.
# 7. `age_mean`, `age_sd`, `age_min`, `age_max`: age distribution.
# 8. `sex_prob`, `race_prob`: category probabilities.
# 9. `strata`: randomization strata the SAP adjusts for, as a named list
#    of category probabilities. `NULL` when the SAP has none.
ldl_studies <- list(
  orion10 = list(
    ratio = c(Inclisiran = 1, Placebo = 1),
    visit = paste("Day", c(150, 270, 330, 450, 510, 540)),
    day = c(150, 270, 330, 450, 510, 540),
    # FDA review Figure 2, read by eye
    targets = rbind(
      Inclisiran = c(-59.4, -48.3, -56.0, -46.0, -56.3, -53.8),
      Placebo = c(1.2, 4.8, 5.8, 3.0, 1.4, 1.8)
    ),
    # NEJM appendix Figure S3, Panel B, read by eye
    arm_sd = c(Inclisiran = 0.53, Placebo = 0.21),
    # Assumed
    cor_base = 0.7,
    cor_days = 180,
    # FDA review Table 5
    bl_mean = 104.6,
    bl_sd = 38.3,
    # FDA review Table 5, pooled over both arms
    age_mean = 66.1,
    age_sd = 8.9,
    age_min = 35,
    age_max = 90,
    sex_prob = c(Male = 0.694, Female = 0.306),
    race_prob = c(White = 0.857, Black = 0.126, Other = 0.017),
    strata = NULL
  ),
  odyssey_lt = list(
    ratio = c(Alirocumab = 2, Placebo = 1),
    # SAP Section 2.4.4.1.1: the MMRM uses Weeks 4 to 52
    visit = paste("Week", c(4, 8, 12, 16, 24, 36, 52)),
    day = 7 * c(4, 8, 12, 16, 24, 36, 52),
    # FDA review Figure 7, LONG TERM panel, read by eye
    targets = rbind(
      Alirocumab = c(-64.9, -65.9, -63.8, -64.9, -61.3, -60.5, -57.5),
      Placebo = c(1.6, 1.2, 1.6, 1.2, 1.4, 0.4, 5.1)
    ),
    # Derived: a percent-change SD of 28 in both arms (NEJM appendix Table
    # S2), converted to the log scale at each arm's Week 24 mean
    arm_sd = c(Alirocumab = 0.66, Placebo = 0.27),
    # Assumed: the same rule as ORION-10
    cor_base = 0.7,
    cor_days = 180,
    # ClinicalTrials.gov results
    bl_mean = 122.4,
    bl_sd = 42.2,
    # ClinicalTrials.gov results; the range is assumed
    age_mean = 60.5,
    age_sd = 10.4,
    age_min = 18,
    age_max = 90,
    # ClinicalTrials.gov results
    sex_prob = c(Male = 0.622, Female = 0.378),
    # FDA review Table 12
    race_prob = c(White = 0.93, Black = 0.03, Other = 0.04),
    strata = list(
      # FDA review Table 12
      hefh = c(Yes = 0.178, No = 0.822),
      prior_mi_stroke = c(Yes = 0.481, No = 0.519),
      statin_intensity = c(High = 0.441, `Low/moderate` = 0.559),
      # Assumed, from the US share of subjects and the site count by region
      region = c(
        `North America` = 0.24,
        `Western Europe` = 0.40,
        `Eastern Europe` = 0.21,
        `Rest of World` = 0.15
      )
    )
  )
)
