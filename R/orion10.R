#' Simulate the ORION-10 trial
#'
#' Returns simulated, analysis-ready LDL cholesterol data modelled on
#' ORION-10, a trial of inclisiran against placebo (NCT03399370). Every
#' subject is made up. The data has one row per subject per scheduled
#' visit, with no missing values, ready for the trial's mixed model for
#' repeated measures (MMRM).
#'
#' The baseline LDL, the mean percent change at each visit and the
#' demographics follow the trial's published results. The mean percent
#' changes follow the observed means, not the published estimates that
#' account for missing values, so the treatment effect is a few points
#' larger than the published one. `vignette("orion10", package = "clinique")`
#' explains each number, its source and the assumptions.
#'
#' The data is simulated. It is not affiliated with or endorsed by the
#' trial's sponsor.
#'
#' @param n Number of subjects, at least 2. Subjects are randomized 1:1;
#'   when `n` is odd, the extra subject gets inclisiran. ORION-10
#'   randomized 1,561.
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
#'   * `visit`: Ordered factor, `"Day 150"` to `"Day 540"`. LDL was also
#'     measured on Day 90, but the trial's analysis plan leaves it out of
#'     the model.
#'   * `day`: Study day of the visit.
#'   * `ldl_baseline`: LDL at baseline, in mg/dL.
#'   * `ldl`: LDL at the visit, in mg/dL.
#'   * `ldl_pct_change`: Percent change in LDL from baseline.
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
#' <https://cdn.clinicaltrials.gov/large-docs/70/NCT03399370/SAP_001.pdf>
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
#' orion10 <- simulate_orion10(100)
#' head(orion10)
#' @export
simulate_orion10 <- function(n) {
  simulate_ldl_trial(n, orion10_settings)
}

orion10_settings <- list(
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
)
