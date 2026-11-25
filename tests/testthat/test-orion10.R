test_that("the ORION-10 settings fit together", {
  expect_ldl_settings(orion10_settings)
})

# With seed 1, the trial-sized dataset from this function was checked once
# against the SAP's MMRM; the study's vignette repeats that fit. The output
# for a given seed is fixed, so a small snapshot is enough to show the
# output hasn't changed since.
test_that("simulate_orion10() output is unchanged", {
  withr::local_seed(1)
  expect_snapshot_value(
    simulate_orion10(11),
    style = "deparse",
    tolerance = 1e-6
  )
})
