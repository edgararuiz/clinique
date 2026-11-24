# The engine behind each LDL study's `simulate_<study>()` function. `p` is
# that study's settings, a list defined next to its function. Each study's
# vignette explains every number, its source and the assumptions.
#
# The settings hold:
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

#' @importFrom stats rlnorm rnorm
#' @noRd
simulate_ldl_trial <- function(n, p) {
  if (!is.numeric(n) || length(n) != 1 || is.na(n) || n < 2 || n != round(n)) {
    stop("`n` must be a whole number of at least 2.", call. = FALSE)
  }

  subjects <- draw_subjects(n, p)
  ldl_baseline <- draw_baseline(n, p)
  ratio <- exp(draw_log_ratio(subjects$arm, p))

  # One row per subject per visit
  n_visits <- length(p$day)
  each <- rep(seq_len(n), each = n_visits)
  subject_id <- sprintf("001-%04d", seq_len(n))
  # Computed before tibble(), which would read `ldl_baseline` as the
  # repeated column instead of one value per subject
  ldl <- as.vector(t(ldl_baseline * ratio))
  ldl_pct_change <- as.vector(t(100 * (ratio - 1)))
  out <- tibble::tibble(
    subject_id = factor(subject_id[each], levels = subject_id),
    treatment = factor(subjects$arm[each], levels = rev(names(p$ratio))),
    age = subjects$age[each],
    sex = subjects$sex[each],
    race = subjects$race[each],
    visit = factor(rep(p$visit, n), levels = p$visit, ordered = TRUE),
    day = rep(p$day, n),
    ldl_baseline = ldl_baseline[each],
    ldl = ldl,
    ldl_pct_change = ldl_pct_change
  )

  # Study-specific columns go last
  for (s in names(p$strata)) {
    out[[s]] <- subjects[[s]][each]
  }
  out
}
