library(TransAW)

set.seed(42)
cohort <- function(n, slopes) {
  x <- matrix(rnorm(n * length(slopes)), nrow = n)
  colnames(x) <- paste0("x", seq_along(slopes))
  data.frame(y = as.numeric(x %*% slopes + rnorm(n)), x)
}
target <- cohort(90, c(1, -1, 0, 0))
sources <- list(similar = cohort(100, c(1, -1, 0, 0)),
                shifted = cohort(70, c(-1, 1, 1, 0)))
fit <- TransAW(y ~ . - 1, data = target, sources = sources, seed = 42)
print(summary(fit))
print(coef(fit))
print(predict(fit, newdata = target[1:3, -1]))
plot(fit)
