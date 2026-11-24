test_that("the ODYSSEY LONG TERM settings fit together", {
  expect_ldl_settings(odyssey_lt_settings)
})

test_that("simulate_odyssey_lt() returns ODYSSEY LONG TERM shaped data", {
  withr::local_seed(1)
  ldl <- simulate_odyssey_lt(11)
  expect_ldl_output(ldl, odyssey_lt_settings, 11)
  expect_equal(levels(ldl$treatment), c("Placebo", "Alirocumab"))
  expect_equal(nlevels(ldl$visit), 7)
  expect_equal(levels(ldl$hefh), c("No", "Yes"))
  expect_equal(
    levels(ldl$region),
    c("Eastern Europe", "North America", "Rest of World", "Western Europe")
  )
})

test_that("simulate_odyssey_lt() checks `n`", {
  expect_error(simulate_odyssey_lt(1), "whole number")
})

test_that("the SAP's MMRM recovers the ODYSSEY LONG TERM Week 24 difference", {
  skip_if_not_installed("mmrm")
  skip_if_not_installed("emmeans")
  withr::local_seed(1)
  ldl <- simulate_odyssey_lt(2341)

  fit <- mmrm::mmrm(
    ldl_pct_change ~ treatment *
      visit +
      hefh * visit +
      prior_mi_stroke * visit +
      statin_intensity * visit +
      region * visit +
      ldl_baseline * visit +
      us(visit | subject_id),
    data = ldl,
    reml = TRUE,
    method = "Satterthwaite"
  )
  means <- emmeans::emmeans(
    fit,
    ~ treatment | visit,
    weights = "proportional"
  )
  diffs <- summary(emmeans::contrast(means, "revpairwise"))

  # Target: FDA review Figure 7, read by eye. The SE is about 1.3.
  expect_lt(abs(diffs$estimate[diffs$visit == "Week 24"] - -62.7), 3)
})
