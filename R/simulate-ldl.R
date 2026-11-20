#' Simulate an LDL cholesterol trial dataset
#'
#' Returns simulated, analysis-ready LDL cholesterol data modelled on a
#' published clinical trial. Every subject is made up. The data has one row
#' per subject per scheduled visit, with no missing values, ready for the
#' trial's mixed model for repeated measures (MMRM).
#'
#' The only study available is ORION-10 (inclisiran vs placebo,
#' NCT03399370). The baseline LDL, the mean percent change at each visit and
#' the demographics follow the trial's published results. The mean percent
#' changes follow the observed means, not the published estimates that
#' fill in missing values, so the treatment effect is a few points larger
#' than the published one. `vignette("orion10", package = "clinique")`
#' explains each number, its source and the assumptions.
#'
#' The data is simulated. It is not affiliated with or endorsed by the
#' trial's sponsor.
#'
#' @param n Number of subjects, randomized 1:1. When `n` is odd, the extra
#'   subject gets the active treatment. ORION-10 randomized 1,561.
#' @param study The trial to model. Only `"orion10"` for now.
#'
#' @returns A data frame with one row per subject per visit, sorted by
#'   subject and then visit, and these columns:
#'
#'   * `subject_id`: Subject identifier, such as `"001-0001"`.
#'   * `treatment`: Factor, `"Placebo"` or `"Inclisiran"`, with placebo as
#'     the reference level.
#'   * `age`: Age in years.
#'   * `sex`: `"Male"` or `"Female"`.
#'   * `race`: `"White"`, `"Black"` or `"Other"`.
#'   * `visit`: Ordered factor, `"Day 150"` to `"Day 540"`.
#'   * `day`: Study day of the visit.
#'   * `ldl_baseline`: LDL at baseline, in mg/dL.
#'   * `ldl`: LDL at the visit, in mg/dL.
#'   * `ldl_pct_change`: Percent change in LDL from baseline.
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
#' ldl <- simulate_ldl(100)
#' head(ldl)
#' @importFrom stats rlnorm rnorm
#' @export
simulate_ldl <- function(n, study = c("orion10")) {
  study <- match.arg(study)
  if (!is.numeric(n) || length(n) != 1 || is.na(n) || n < 2 || n != round(n)) {
    stop("`n` must be a whole number of at least 2.", call. = FALSE)
  }
  p <- ldl_studies[[study]]
  n_visits <- length(p$day)

  # Treatment: 1:1, the extra subject of an odd `n` gets the active arm
  arms <- names(p$arm_sd)
  arm <- sample(rep(arms, length.out = n))

  # Demographics
  age <- round(pmin(pmax(rnorm(n, p$age_mean, p$age_sd), p$age_min), p$age_max))
  sex <- sample(names(p$sex_prob), n, replace = TRUE, prob = p$sex_prob)
  race <- sample(names(p$race_prob), n, replace = TRUE, prob = p$race_prob)

  # Baseline LDL: log-normal with the published mean and SD
  sdlog <- sqrt(log(1 + (p$bl_sd / p$bl_mean)^2))
  meanlog <- log(p$bl_mean) - sdlog^2 / 2
  ldl_baseline <- rlnorm(n, meanlog, sdlog)

  # Log of LDL / baseline: multivariate normal per arm. The means are
  # shifted down by sd^2 / 2 so the expected percent change hits the target.
  r <- p$cor_base^(abs(outer(p$day, p$day, "-")) / p$cor_days)
  mu_log <- log(1 + p$targets / 100) - p$arm_sd^2 / 2
  log_ratio <- matrix(NA_real_, n, n_visits)
  for (a in arms) {
    rows <- arm == a
    log_ratio[rows, ] <- MASS::mvrnorm(
      sum(rows),
      mu = mu_log[a, ],
      Sigma = p$arm_sd[[a]]^2 * r
    )
  }
  ratio <- exp(log_ratio)

  # One row per subject per visit
  each <- rep(seq_len(n), each = n_visits)
  visit_labels <- paste("Day", p$day)
  data.frame(
    subject_id = sprintf("001-%04d", each),
    treatment = factor(arm[each], levels = rev(arms)),
    age = age[each],
    sex = sex[each],
    race = race[each],
    visit = factor(rep(visit_labels, n), levels = visit_labels, ordered = TRUE),
    day = rep(p$day, n),
    ldl_baseline = ldl_baseline[each],
    ldl = as.vector(t(ldl_baseline * ratio)),
    ldl_pct_change = as.vector(t(100 * (ratio - 1)))
  )
}

# Study parameters. Sources and assumptions are explained in
# vignettes/orion10.Rmd.
ldl_studies <- list(
  orion10 = list(
    day = c(150, 270, 330, 450, 510, 540),
    # Mean percent change by arm and visit: FDA review Figure 2, read by eye
    targets = rbind(
      Inclisiran = c(-59.4, -48.3, -56.0, -46.0, -56.3, -53.8),
      Placebo = c(1.2, 4.8, 5.8, 3.0, 1.4, 1.8)
    ),
    # Log-scale SD by arm: NEJM appendix Figure S3, Panel B, read by eye
    arm_sd = c(Inclisiran = 0.53, Placebo = 0.21),
    # Correlation between visits: assumed
    cor_base = 0.7,
    cor_days = 180,
    # Baseline LDL, mg/dL: FDA review Table 5
    bl_mean = 104.6,
    bl_sd = 38.3,
    # Demographics: FDA review Table 5, pooled over both arms
    age_mean = 66.1,
    age_sd = 8.9,
    age_min = 35,
    age_max = 90,
    sex_prob = c(Male = 0.694, Female = 0.306),
    race_prob = c(White = 0.857, Black = 0.126, Other = 0.017)
  )
)
