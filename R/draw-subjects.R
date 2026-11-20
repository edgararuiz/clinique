# Draws one row per subject: treatment arm, demographics and any
# randomization strata. `p` is one entry of `ldl_studies`.
draw_subjects <- function(n, p) {
  # Treatment: repeat the ratio pattern, then shuffle. For 2:1 the pattern
  # is active, active, placebo, so leftover subjects go to the active arm.
  pattern <- rep(names(p$ratio), times = p$ratio)
  arm <- sample(rep(pattern, length.out = n))

  subjects <- data.frame(
    arm = arm,
    age = round(pmin(
      pmax(rnorm(n, p$age_mean, p$age_sd), p$age_min),
      p$age_max
    )),
    sex = sample(names(p$sex_prob), n, replace = TRUE, prob = p$sex_prob),
    race = sample(names(p$race_prob), n, replace = TRUE, prob = p$race_prob)
  )

  for (s in names(p$strata)) {
    prob <- p$strata[[s]]
    subjects[[s]] <- sample(names(prob), n, replace = TRUE, prob = prob)
  }
  subjects
}
