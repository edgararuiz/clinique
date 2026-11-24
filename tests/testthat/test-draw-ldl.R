test_that("draw_baseline() matches the study's mean and SD", {
  withr::local_seed(1)
  for (p in ldl_settings) {
    baseline <- draw_baseline(50000, p)

    expect_true(all(baseline > 0))
    expect_lt(abs(mean(baseline) - p$bl_mean), 1)
    expect_lt(abs(stats::sd(baseline) - p$bl_sd), 1)
  }
})

test_that("draw_log_ratio() hits each visit's target mean percent change", {
  withr::local_seed(1)
  for (p in ldl_settings) {
    arms <- names(p$ratio)
    arm <- rep(arms, each = 20000)
    log_ratio <- draw_log_ratio(arm, p)

    expect_equal(dim(log_ratio), c(length(arm), length(p$day)))
    for (a in arms) {
      pct <- 100 * (exp(log_ratio[arm == a, ]) - 1)
      expect_lt(max(abs(colMeans(pct) - p$targets[a, ])), 1)
    }
  }
})
