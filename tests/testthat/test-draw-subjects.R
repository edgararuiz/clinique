test_that("draw_subjects() follows each study's randomization ratio", {
  withr::local_seed(1)
  orion <- draw_subjects(11, orion10_settings)
  expect_equal(sum(orion$arm == "Inclisiran"), 6)
  expect_equal(sum(orion$arm == "Placebo"), 5)

  odyssey <- draw_subjects(11, odyssey_lt_settings)
  expect_equal(sum(odyssey$arm == "Alirocumab"), 8)
  expect_equal(sum(odyssey$arm == "Placebo"), 3)
})

test_that("draw_subjects() draws demographics and strata from their levels", {
  withr::local_seed(1)
  p <- odyssey_lt_settings
  subjects <- draw_subjects(500, p)

  expect_named(
    subjects,
    c("arm", "age", "sex", "race", names(p$strata))
  )
  expect_true(all(subjects$age >= p$age_min & subjects$age <= p$age_max))
  expect_true(all(subjects$age == round(subjects$age)))
  expect_equal(levels(subjects$sex), sort(names(p$sex_prob)))
  expect_equal(levels(subjects$race), sort(names(p$race_prob)))
  for (s in names(p$strata)) {
    expect_equal(levels(subjects[[s]]), sort(names(p$strata[[s]])))
  }
})

test_that("draw_subjects() adds no strata when a study has none", {
  withr::local_seed(1)
  subjects <- draw_subjects(5, orion10_settings)
  expect_named(subjects, c("arm", "age", "sex", "race"))
})
