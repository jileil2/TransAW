# Refit Trans-AW on the simulated data at the source weights saved by the cluster.
library(TransAW)
source("analysis/simulation-design.R")
source("analysis/saved-weights.R")
args <- as.integer(commandArgs(trailingOnly = TRUE))
stopifnot(length(args) >= 4, !anyNA(args))
n <- args[1]
m <- args[2]
h <- args[3]
reps <- args[-(1:3)]
stopifnot(n %in% c(100, 300), m %in% c(5, 10, 15, 20), h %in% c(2, 4, 6), all(reps %in% 1:200))
settings <- list(seed = 20260716L, p = 500L, s0 = 16L, n0 = 150L, n_k = n)
directions <- fixed_sparse_directions(m, settings$p, 6L, settings$seed)
weights <- read_setting_weights(n, m, h)
errors <- read.csv("results/simulation-errors.csv.gz")
errors <- errors[errors$n == n & errors$m == m & errors$h == h & errors$method == "Trans-AW", ]
for (i in reps) {
  dat <- generate_data(i, m, h, settings, directions)
  w <- replication_weights(weights, i, m)
  sources <- Map(function(x, y) list(x = x, y = y), dat$X_sources, dat$y_sources)
  seed <- settings$seed + 1000L * i + 10000000L * m + 10000L * h + 1L
  fit <- TransAW(data = list(x = dat$X0, y = dat$y0), sources = sources,
                 seed = seed, fold_weights = w, coordinates = "log_weights")
  print(data.frame(n = n, m = m, h = h, rep = i,
                   replay = sum((coef(fit) - dat$beta0)^2), archive = errors$coef_error[errors$rep == i]), digits = 12)
}
