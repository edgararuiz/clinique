# Shared by the tests of the LDL engine and of each LDL study.

ldl_settings <- list(
  orion10 = orion10_settings,
  orion11 = orion11_settings,
  odyssey_lt = odyssey_lt_settings
)

ldl_core_columns <- c(
  "subject_id",
  "treatment",
  "age",
  "sex",
  "race",
  "visit",
  "day",
  "ldl_baseline",
  "ldl",
  "ldl_pct_change"
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

# Checks the shape of a study's output for `n` subjects
expect_ldl_output <- function(ldl, p, n) {
  expect_s3_class(ldl, "tbl_df")
  expect_named(ldl, c(ldl_core_columns, names(p$strata)))
  # Every column that isn't numeric is a factor
  other <- Filter(function(x) !is.numeric(x) && !is.factor(x), ldl)
  expect_length(other, 0)
  expect_equal(nrow(ldl), n * length(p$visit))
  expect_false(anyNA(ldl))
  expect_equal(levels(ldl$treatment), rev(names(p$ratio)))
  expect_true(is.ordered(ldl$visit))
  expect_equal(levels(ldl$visit), p$visit)
  expect_equal(
    ldl$ldl_pct_change,
    100 * (ldl$ldl / ldl$ldl_baseline - 1)
  )
}
