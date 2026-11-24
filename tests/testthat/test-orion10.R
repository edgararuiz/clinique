test_that("the ORION-10 settings fit together", {
  expect_ldl_settings(orion10_settings)
})

test_that("simulate_orion10() returns ORION-10 shaped data", {
  withr::local_seed(1)
  ldl <- simulate_orion10(11)
  expect_ldl_output(ldl, orion10_settings, 11)
  expect_equal(levels(ldl$treatment), c("Placebo", "Inclisiran"))
  expect_equal(nlevels(ldl$visit), 6)
})

test_that("simulate_orion10() checks `n`", {
  expect_error(simulate_orion10(1), "whole number")
})

test_that("the SAP's MMRM recovers the ORION-10 treatment differences", {
  skip_if_not_installed("mmrm")
  skip_if_not_installed("emmeans")
  withr::local_seed(1)
  ldl <- simulate_orion10(1561)

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
