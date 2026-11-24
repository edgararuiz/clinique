core_columns <- c(
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

test_that("simulate_ldl() returns one row per subject per visit", {
  withr::local_seed(1)
  for (study in names(ldl_studies)) {
    p <- ldl_studies[[study]]
    ldl <- simulate_ldl(11, study)

    expect_s3_class(ldl, "tbl_df")
    expect_named(ldl, c(core_columns, names(p$strata)))
    # Every column that isn't numeric is a factor
    other <- Filter(function(x) !is.numeric(x) && !is.factor(x), ldl)
    expect_length(other, 0)
    expect_equal(nrow(ldl), 11 * length(p$visit))
    expect_false(anyNA(ldl))
    expect_equal(levels(ldl$treatment), rev(names(p$ratio)))
    expect_true(is.ordered(ldl$visit))
    expect_equal(levels(ldl$visit), p$visit)
    expect_equal(
      ldl$ldl_pct_change,
      100 * (ldl$ldl / ldl$ldl_baseline - 1)
    )
  }
})

test_that("simulate_ldl() keeps each subject's values fixed across visits", {
  withr::local_seed(1)
  ldl <- simulate_ldl(11, "odyssey_lt")
  fixed <- c("treatment", "age", "sex", "race", "ldl_baseline", "hefh")
  per_subject <- unique(ldl[c("subject_id", fixed)])
  expect_equal(nrow(per_subject), 11)
  expect_equal(levels(ldl$subject_id), sprintf("001-%04d", 1:11))
})

test_that("simulate_ldl() defaults to ORION-10", {
  withr::local_seed(1)
  ldl <- simulate_ldl(11)
  expect_equal(levels(ldl$treatment), c("Placebo", "Inclisiran"))
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
  ldl <- simulate_ldl(1561, "orion10")

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

test_that("the SAP's MMRM recovers the ODYSSEY LONG TERM Week 24 difference", {
  skip_if_not_installed("mmrm")
  skip_if_not_installed("emmeans")
  withr::local_seed(1)
  ldl <- simulate_ldl(2341, "odyssey_lt")

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
