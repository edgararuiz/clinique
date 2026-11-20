test_that("each study's settings fit together", {
  for (study in names(ldl_studies)) {
    p <- ldl_studies[[study]]
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
})
