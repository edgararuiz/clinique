#' Simulate the ODYSSEY LONG TERM trial
#'
#' Returns simulated, analysis-ready LDL cholesterol data modelled on
#' ODYSSEY LONG TERM, a trial of alirocumab against placebo (NCT01507831).
#' Every subject is made up. The data has one row per subject per scheduled
#' visit, with no missing values, ready for the trial's mixed model for
#' repeated measures (MMRM).
#'
#' The baseline LDL, the mean percent change at each visit, the
#' demographics and the randomization strata follow the trial's published
#' results. `vignette("odyssey-lt", package = "clinique")` explains each
#' number, its source and the assumptions.
#'
#' The data is simulated. It is not affiliated with or endorsed by the
#' trial's sponsors.
#'
#' @param n Number of subjects, randomized 2:1. When `n` is not a multiple
#'   of 3, the extra subjects get alirocumab. ODYSSEY LONG TERM randomized
#'   2,341.
#'
#' @returns A tibble with one row per subject per visit, sorted by subject
#'   and then visit. Columns that aren't numeric are factors:
#'
#'   * `subject_id`: Subject identifier, such as `"001-0001"`.
#'   * `treatment`: `"Placebo"` or `"Alirocumab"`, with placebo as the
#'     reference level.
#'   * `age`: Age in years.
#'   * `sex`: `"Female"` or `"Male"`.
#'   * `race`: `"Black"`, `"Other"` or `"White"`.
#'   * `visit`: Ordered factor, `"Week 4"` to `"Week 52"`. LDL was also
#'     measured at Weeks 64 and 78, but the trial's primary model stops at
#'     Week 52.
#'   * `day`: Nominal study day of the visit, seven times the week.
#'   * `ldl_baseline`: LDL at baseline, in mg/dL.
#'   * `ldl`: LDL at the visit, in mg/dL.
#'   * `ldl_pct_change`: Percent change in LDL from baseline.
#'
#'   The last four columns are the randomization strata, which the trial's
#'   analysis plan adjusts for:
#'
#'   * `hefh`: Heterozygous familial hypercholesterolemia, `"No"` or `"Yes"`.
#'   * `prior_mi_stroke`: Prior heart attack or ischemic stroke, `"No"` or
#'     `"Yes"`.
#'   * `statin_intensity`: `"High"` or `"Low/moderate"`.
#'   * `region`: `"Eastern Europe"`, `"North America"`, `"Rest of World"` or
#'     `"Western Europe"`.
#'
#' @references
#' FDA statistical review:
#' <https://www.accessdata.fda.gov/drugsatfda_docs/nda/2015/125559Orig1s000StatR.pdf>
#'
#' Robinson JG, et al. Efficacy and Safety of Alirocumab in Reducing Lipids
#' and Cardiovascular Events. N Engl J Med 2015;372:1489-1499. Its
#' statistical analysis plan is in the protocol supplement.
#' \doi{10.1056/NEJMoa1501031}
#'
#' @examples
#' set.seed(1)
#' odyssey <- simulate_odyssey_lt(90)
#' head(odyssey)
#' @export
simulate_odyssey_lt <- function(n) {
  simulate_ldl_trial(n, odyssey_lt_settings)
}

odyssey_lt_settings <- list(
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
