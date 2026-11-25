test_that("simulate_ldl_trial() keeps each subject's values fixed across visits", {
  withr::local_seed(1)
  ldl <- simulate_ldl_trial(11, odyssey_lt_settings)
  fixed <- c("treatment", "age", "sex", "race", "ldl_baseline", "hefh")
  per_subject <- unique(ldl[c("subject_id", fixed)])
  expect_equal(nrow(per_subject), 11)
  expect_equal(levels(ldl$subject_id), sprintf("001-%04d", 1:11))
})

test_that("simulate_ldl_trial() checks `n`", {
  p <- orion10_settings
  expect_error(simulate_ldl_trial(1, p), "whole number")
  expect_error(simulate_ldl_trial(10.5, p), "whole number")
  expect_error(simulate_ldl_trial("10", p), "whole number")
  expect_error(simulate_ldl_trial(NA, p), "whole number")
})

test_that("simulate_ldl_trial() needs one subject per arm at least", {
  # 2:1 needs 3 subjects
  expect_error(
    simulate_ldl_trial(2, odyssey_lt_settings),
    "at least 3"
  )
  withr::local_seed(1)
  ldl <- simulate_ldl_trial(3, odyssey_lt_settings)
  expect_equal(nlevels(droplevels(ldl$treatment)), 2)
})
