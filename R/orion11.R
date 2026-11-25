#' Simulate the ORION-11 trial
#'
#' Returns simulated, analysis-ready LDL cholesterol data modelled on
#' ORION-11, a trial of inclisiran against placebo (NCT03400800). ORION-11
#' is ORION-10's sister trial: the same drug, doses and visits, in a
#' population from Europe and South Africa. Every subject is made up. The
#' data has one row per subject per scheduled visit, with no missing
#' values, ready for the trial's mixed model for repeated measures (MMRM).
#'
#' The baseline LDL, the mean percent change at each visit and the
#' demographics follow the trial's published results. The mean percent
#' changes follow the observed means, not the published estimates that
#' account for missing values, so the treatment effect is a few points
#' larger than the published one. `vignette("orion11", package = "clinique")`
#' explains each number, its source and the assumptions.
#'
#' The data is simulated. It is not affiliated with or endorsed by the
#' trial's sponsor.
#'
#' @param n Number of subjects, at least 2. Subjects are randomized 1:1;
#'   when `n` is odd, the extra subject gets inclisiran. ORION-11
#'   randomized 1,617.
#'
#' @returns A tibble with one row per subject per visit, sorted by subject
#'   and then visit. Columns that aren't numeric are factors:
#'
#'   * `subject_id`: Subject identifier, such as `"001-0001"`.
#'   * `treatment`: `"Placebo"` or `"Inclisiran"`, with placebo as the
#'     reference level.
#'   * `age`: Age in years.
#'   * `sex`: `"Female"` or `"Male"`.
#'   * `race`: `"Black"`, `"Other"` or `"White"`.
#'   * `visit`: Ordered factor, `"Day 90"` to `"Day 540"`. Unlike
#'     ORION-10's, the ORION-11 analysis plan keeps Day 90 in the model.
#'   * `day`: Study day of the visit.
#'   * `ldl_baseline`: LDL at baseline, in mg/dL.
#'   * `ldl`: LDL at the visit, in mg/dL.
#'   * `ldl_pct_change`: Percent change in LDL from baseline.
#'   * `statin_use`: `"No"` or `"Yes"`, current use of statins or other
#'     lipid-lowering therapy. A randomization stratum, which the trial's
#'     analysis plan adjusts for.
#'
#' @section Reproducibility:
#' Call [set.seed()] first to get the same data each time. The same seed
#' gives the same data on every operating system. The correlated values
#' at each visit are drawn with base R's [chol()], which returns the one
#' upper-triangular Cholesky factor of the covariance matrix. Methods
#' based on [eigen()], such as `MASS::mvrnorm()`, can return different
#' factors on different systems, and so different data for the same seed.
#'
#' @references
#' Statistical analysis plan:
#' <https://cdn.clinicaltrials.gov/large-docs/00/NCT03400800/SAP_001.pdf>
#'
#' FDA statistical review:
#' <https://www.accessdata.fda.gov/drugsatfda_docs/nda/2022/214012Orig1s000StatR.pdf>
#'
#' Ray KK, et al. Two Phase 3 Trials of Inclisiran in Patients with Elevated
#' LDL Cholesterol. N Engl J Med 2020;382:1507-1519.
#' \doi{10.1056/NEJMoa1912387}
#'
#' @examples
#' set.seed(1)
#' orion11 <- simulate_orion11(100)
#' head(orion11)
#' @export
simulate_orion11 <- function(n) {
  simulate_ldl_trial(n, orion11_settings)
}

orion11_settings <- list(
  ratio = c(Inclisiran = 1, Placebo = 1),
  # SAP Appendix 1: unlike ORION-10, Day 90 stays in the model
  visit = paste("Day", c(90, 150, 270, 330, 450, 510, 540)),
  day = c(90, 150, 270, 330, 450, 510, 540),
  # FDA review Figure 2, ORION-11 panel, measured from the figure
  targets = rbind(
    Inclisiran = c(-46.8, -51.2, -42.3, -51.8, -39.7, -49.4, -47.7),
    Placebo = c(1.8, 3.2, 3.8, 2.8, 3.4, 4.2, 3.4)
  ),
  # NEJM appendix Figure S3, Panel D, measured from the figure
  arm_sd = c(Inclisiran = 0.44, Placebo = 0.23),
  # Assumed: the same rule as ORION-10
  cor_base = 0.7,
  cor_days = 180,
  # Derived: FDA review Table 6, pooled over both arms
  bl_mean = 105.4,
  bl_sd = 39.2,
  # ClinicalTrials.gov results; the range is from FDA review Table 6
  age_mean = 64.8,
  age_sd = 8.5,
  age_min = 20,
  age_max = 88,
  # ClinicalTrials.gov results, as counts of 1,617
  sex_prob = c(Male = 1160, Female = 457) / 1617,
  race_prob = c(White = 1587, Black = 20, Other = 10) / 1617,
  strata = list(
    # FDA review Table 6, as counts of 1,617
    statin_use = c(Yes = 1555, No = 62) / 1617
  )
)
