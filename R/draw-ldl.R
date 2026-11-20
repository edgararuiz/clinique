# Draws baseline LDL: log-normal with the study's published mean and SD.
draw_baseline <- function(n, p) {
  sdlog <- sqrt(log(1 + (p$bl_sd / p$bl_mean)^2))
  meanlog <- log(p$bl_mean) - sdlog^2 / 2
  rlnorm(n, meanlog, sdlog)
}

# Draws log(LDL / baseline) for each subject (rows) and visit (columns):
# multivariate normal per arm. The means are shifted down by sd^2 / 2 so
# the expected percent change equals the target.
draw_log_ratio <- function(arm, p) {
  r <- p$cor_base^(abs(outer(p$day, p$day, "-")) / p$cor_days)
  mu_log <- log(1 + p$targets / 100) - p$arm_sd^2 / 2
  log_ratio <- matrix(NA_real_, length(arm), length(p$day))
  for (a in names(p$ratio)) {
    rows <- arm == a
    log_ratio[rows, ] <- MASS::mvrnorm(
      sum(rows),
      mu = mu_log[a, ],
      Sigma = p$arm_sd[[a]]^2 * r
    )
  }
  log_ratio
}
