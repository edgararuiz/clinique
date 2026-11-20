#' Simulate an LDL cholesterol trial dataset
#'
#' Returns simulated, analysis-ready LDL cholesterol data modelled on a
#' published clinical trial. Every subject is made up. The data has one row
#' per subject per scheduled visit, with no missing values, ready for the
#' trial's mixed model for repeated measures (MMRM).
#'
#' The baseline LDL, the mean percent change at each visit and the
#' demographics follow the trial's published results. The mean percent
#' changes follow the observed means, not the published estimates that
#' account for missing values. Each study's vignette explains every number,
#' its source and the assumptions.
#'
#' The data is simulated. It is not affiliated with or endorsed by either
#' trial's sponsor.
#'
#' @param n Number of subjects. The randomization ratio depends on the
#'   study. Subjects left over after the last full ratio block go to the
#'   active treatment.
#' @param study The trial to model:
#'
#'   * `"orion10"`: ORION-10, inclisiran vs placebo (NCT03399370),
#'     randomized 1:1. The trial randomized 1,561. See
#'     `vignette("orion10", package = "clinique")`.
#'   * `"odyssey_lt"`: ODYSSEY LONG TERM, alirocumab vs placebo
#'     (NCT01507831), randomized 2:1. The trial randomized 2,341. See
#'     `vignette("odyssey-lt", package = "clinique")`.
#'
#' @returns A data frame with one row per subject per visit, sorted by
#'   subject and then visit. Every study has these columns:
#'
#'   * `subject_id`: Subject identifier, such as `"001-0001"`.
#'   * `treatment`: Factor with placebo as the reference level: `"Placebo"`
#'     and `"Inclisiran"` or `"Alirocumab"`.
#'   * `age`: Age in years.
#'   * `sex`: `"Male"` or `"Female"`.
#'   * `race`: `"White"`, `"Black"` or `"Other"`.
#'   * `visit`: Ordered factor: `"Day 150"` to `"Day 540"` for ORION-10,
#'     `"Week 4"` to `"Week 52"` for ODYSSEY LONG TERM.
#'   * `day`: Study day of the visit.
#'   * `ldl_baseline`: LDL at baseline, in mg/dL.
#'   * `ldl`: LDL at the visit, in mg/dL.
#'   * `ldl_pct_change`: Percent change in LDL from baseline.
#'
#'   ODYSSEY LONG TERM adds its randomization strata, which its analysis
#'   plan adjusts for:
#'
#'   * `hefh`: Heterozygous familial hypercholesterolemia, `"Yes"` or
#'     `"No"`.
#'   * `prior_mi_stroke`: Prior heart attack or ischemic stroke, `"Yes"` or
#'     `"No"`.
#'   * `statin_intensity`: `"High"` or `"Low/moderate"`.
#'   * `region`: `"North America"`, `"Western Europe"`, `"Eastern Europe"`
#'     or `"Rest of World"`.
#'
#' @references
#' ORION-10 statistical analysis plan:
#' <https://cdn.clinicaltrials.gov/large-docs/70/NCT03399370/SAP_001.pdf>
#'
#' ORION-10 FDA statistical review:
#' <https://www.accessdata.fda.gov/drugsatfda_docs/nda/2022/214012Orig1s000StatR.pdf>
#'
#' Ray KK, et al. Two Phase 3 Trials of Inclisiran in Patients with Elevated
#' LDL Cholesterol. N Engl J Med 2020;382:1507-1519.
#' \doi{10.1056/NEJMoa1912387}
#'
#' ODYSSEY LONG TERM FDA statistical review:
#' <https://www.accessdata.fda.gov/drugsatfda_docs/nda/2015/125559Orig1s000StatR.pdf>
#'
#' Robinson JG, et al. Efficacy and Safety of Alirocumab in Reducing Lipids
#' and Cardiovascular Events. N Engl J Med 2015;372:1489-1499. Its
#' statistical analysis plan is in the protocol supplement.
#' \doi{10.1056/NEJMoa1501031}
#'
#' @examples
#' set.seed(1)
#' ldl <- simulate_ldl(100)
#' head(ldl)
#'
#' odyssey <- simulate_ldl(90, study = "odyssey_lt")
#' head(odyssey)
#' @importFrom stats rlnorm rnorm
#' @export
simulate_ldl <- function(n, study = c("orion10", "odyssey_lt")) {
  study <- match.arg(study)
  if (!is.numeric(n) || length(n) != 1 || is.na(n) || n < 2 || n != round(n)) {
    stop("`n` must be a whole number of at least 2.", call. = FALSE)
  }
  p <- ldl_studies[[study]]

  subjects <- draw_subjects(n, p)
  ldl_baseline <- draw_baseline(n, p)
  ratio <- exp(draw_log_ratio(subjects$arm, p))

  # One row per subject per visit
  n_visits <- length(p$day)
  each <- rep(seq_len(n), each = n_visits)
  out <- data.frame(
    subject_id = sprintf("001-%04d", each),
    treatment = factor(subjects$arm[each], levels = rev(names(p$ratio))),
    age = subjects$age[each],
    sex = subjects$sex[each],
    race = subjects$race[each],
    visit = factor(rep(p$visit, n), levels = p$visit, ordered = TRUE),
    day = rep(p$day, n),
    ldl_baseline = ldl_baseline[each],
    ldl = as.vector(t(ldl_baseline * ratio)),
    ldl_pct_change = as.vector(t(100 * (ratio - 1)))
  )

  # Study-specific columns go last
  for (s in names(p$strata)) {
    out[[s]] <- subjects[[s]][each]
  }
  out
}
