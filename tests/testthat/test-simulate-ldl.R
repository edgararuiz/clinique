test_that("simulate_ldl() returns one row per subject per visit", {
  withr::local_seed(1)
  ldl <- simulate_ldl(11)

  expect_s3_class(ldl, "data.frame")
  expect_named(
    ldl,
    c(
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
  )
  expect_equal(nrow(ldl), 11 * 6)
  expect_false(anyNA(ldl))
  expect_equal(levels(ldl$treatment), c("Placebo", "Inclisiran"))
  expect_true(is.ordered(ldl$visit))

  per_subject <- ldl[ldl$visit == "Day 150", ]
  expect_equal(sum(per_subject$treatment == "Inclisiran"), 6)
  expect_true(all(ldl$ldl > 0))
  expect_equal(
    ldl$ldl_pct_change,
    100 * (ldl$ldl / ldl$ldl_baseline - 1)
  )
})

test_that("simulate_ldl() checks its arguments", {
  expect_error(simulate_ldl(1), "whole number")
  expect_error(simulate_ldl(10.5), "whole number")
  expect_error(simulate_ldl("10"), "whole number")
  expect_error(simulate_ldl(10, study = "other"))
})

test_that("the SAP's MMRM recovers the ORION-10 treatment differences", {
  skip_if_not_installed("mmrm")
  skip_if_not_installed("emmeans")
  withr::local_seed(1)
  ldl <- simulate_ldl(1561)
  ldl$subject_id <- factor(ldl$subject_id)

  fit <- mmrm::mmrm(
    ldl_pct_change ~ treatment * visit + ldl_baseline + us(visit | subject_id),
    data = ldl,
    reml = TRUE,
    method = "Kenward-Roger"
  )
  means <- emmeans::emmeans(fit, ~ treatment | visit)
  diffs <- summary(emmeans::contrast(means, "revpairwise"))

  # Targets: FDA review Figure 2, read by eye. Each visit's SE is about 1.2.
  expect_lt(abs(mean(diffs$estimate) - -56.3), 3)
  expect_lt(abs(diffs$estimate[diffs$visit == "Day 510"] - -57.7), 3)
})
