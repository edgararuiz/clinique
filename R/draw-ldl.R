# Draws baseline LDL: log-normal with the study's published mean and SD.
draw_baseline <- function(n, p) {
  sdlog <- sqrt(log(1 + (p$bl_sd / p$bl_mean)^2))
  meanlog <- log(p$bl_mean) - sdlog^2 / 2
  rlnorm(n, meanlog, sdlog)
}

# Draws log(LDL / baseline) for each subject (rows) and visit (columns):
# multivariate normal per arm. The means are shifted down by sd^2 / 2 so
# the expected percent change equals the target.
#
# The correlated draws use base R's `chol()`, not `MASS::mvrnorm()`.
# `mvrnorm()` decomposes the covariance with `eigen()`, and the signs of
# eigenvectors are arbitrary: different operating systems pick different
# ones, so the same seed gave different data. The Cholesky factor from
# `chol()` is unique, so the same seed gives the same data everywhere.
draw_log_ratio <- function(arm, p) {
  r <- p$cor_base^(abs(outer(p$day, p$day, "-")) / p$cor_days)
  mu_log <- log(1 + p$targets / 100) - p$arm_sd^2 / 2
  n_visits <- length(p$day)
  log_ratio <- matrix(NA_real_, length(arm), n_visits)
  for (a in names(p$ratio)) {
    rows <- arm == a
    # Upper-triangular U with t(U) %*% U equal to the covariance
    u <- chol(p$arm_sd[[a]]^2 * r)
    z <- matrix(rnorm(sum(rows) * n_visits), ncol = n_visits)
    log_ratio[rows, ] <- sweep(z %*% u, 2, mu_log[a, ], "+")
  }
  log_ratio
}
