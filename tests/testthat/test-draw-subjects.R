test_that("draw_subjects() follows each study's randomization ratio", {
  withr::local_seed(1)
  orion <- draw_subjects(11, ldl_studies$orion10)
  expect_equal(sum(orion$arm == "Inclisiran"), 6)
  expect_equal(sum(orion$arm == "Placebo"), 5)

  odyssey <- draw_subjects(11, ldl_studies$odyssey_lt)
  expect_equal(sum(odyssey$arm == "Alirocumab"), 8)
  expect_equal(sum(odyssey$arm == "Placebo"), 3)
})

test_that("draw_subjects() draws demographics and strata from their levels", {
  withr::local_seed(1)
  p <- ldl_studies$odyssey_lt
  subjects <- draw_subjects(500, p)

  expect_named(
    subjects,
    c("arm", "age", "sex", "race", names(p$strata))
  )
  expect_true(all(subjects$age >= p$age_min & subjects$age <= p$age_max))
  expect_true(all(subjects$age == round(subjects$age)))
  expect_true(all(subjects$sex %in% names(p$sex_prob)))
  expect_true(all(subjects$race %in% names(p$race_prob)))
  for (s in names(p$strata)) {
    expect_true(all(subjects[[s]] %in% names(p$strata[[s]])))
  }
})

test_that("draw_subjects() adds no strata when a study has none", {
  withr::local_seed(1)
  subjects <- draw_subjects(5, ldl_studies$orion10)
  expect_named(subjects, c("arm", "age", "sex", "race"))
})
