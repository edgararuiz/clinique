# Shared by the tests of the LDL draw helpers and of each LDL study.

ldl_settings <- list(
  orion10 = orion10_settings,
  orion11 = orion11_settings,
  odyssey_lt = odyssey_lt_settings
)

# Checks that a study's settings fit together
expect_ldl_settings <- function(p) {
  arms <- names(p$ratio)
  n_visits <- length(p$visit)

  expect_length(p$day, n_visits)
  expect_equal(dim(p$targets), c(length(arms), n_visits))
  expect_setequal(rownames(p$targets), arms)
  expect_setequal(names(p$arm_sd), arms)
  expect_equal(arms[length(arms)], "Placebo")
  expect_true(all(diff(p$day) > 0))

  probs <- c(list(p$sex_prob, p$race_prob), p$strata)
  for (prob in probs) {
    expect_equal(sum(prob), 1)
  }
}
