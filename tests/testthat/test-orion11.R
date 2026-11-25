test_that("the ORION-11 settings fit together", {
  expect_ldl_settings(orion11_settings)
})

test_that("simulate_orion11() returns ORION-11 shaped data", {
  withr::local_seed(1)
  ldl <- simulate_orion11(11)
  expect_ldl_output(ldl, orion11_settings, 11)
  expect_equal(levels(ldl$treatment), c("Placebo", "Inclisiran"))
  expect_equal(levels(ldl$visit)[1], "Day 90")
  expect_equal(nlevels(ldl$visit), 7)
  expect_equal(levels(ldl$statin_use), c("No", "Yes"))
})

test_that("simulate_orion11() checks `n`", {
  expect_error(simulate_orion11(1), "whole number")
})

test_that("the SAP's MMRM recovers the ORION-11 treatment differences", {
  skip_if_not_installed("mmrm")
  skip_if_not_installed("emmeans")
  withr::local_seed(1)
  ldl <- simulate_orion11(1617)

  fit <- mmrm::mmrm(
    ldl_pct_change ~ treatment *
      visit +
      statin_use +
      ldl_baseline +
      us(visit | subject_id),
    data = ldl,
    reml = TRUE,
    method = "Kenward-Roger"
  )
  means <- emmeans::emmeans(fit, ~ treatment | visit)
  diffs <- summary(emmeans::contrast(means, "revpairwise"))

  # Targets: FDA review Figure 2, measured from the figure. Day 90 is in
  # the model but not in the time-adjusted average.
  after_day_90 <- diffs$visit != "Day 90"
  expect_lt(abs(mean(diffs$estimate[after_day_90]) - -50.5), 3)
  expect_lt(abs(diffs$estimate[diffs$visit == "Day 510"] - -53.6), 3)
})
