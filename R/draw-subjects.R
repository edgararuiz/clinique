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
  # Levels are alphabetical, the order R uses when it turns text into a
  # factor. This keeps the model's reference levels as they were when these
  # columns were text: "Female", "Black", "No", "High", "Eastern Europe".
  subjects$sex <- factor(subjects$sex, levels = sort(names(p$sex_prob)))
  subjects$race <- factor(subjects$race, levels = sort(names(p$race_prob)))

  for (s in names(p$strata)) {
    prob <- p$strata[[s]]
    drawn <- sample(names(prob), n, replace = TRUE, prob = prob)
    subjects[[s]] <- factor(drawn, levels = sort(names(prob)))
  }
  subjects
}
