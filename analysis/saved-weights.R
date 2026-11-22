read_setting_weights <- function(size, sources, heterogeneity) {
  weights <- read.csv("results/simulation-fold-weights.csv.gz")
  weights[weights$n == size & weights$m == sources & weights$h == heterogeneity, ]
}

replication_weights <- function(weights, i, m) {
  rows <- weights[weights$rep == i, ]
  rows <- rows[order(rows$direction, rows$source), ]
  directions <- c("A_to_B", "B_to_A")
  stopifnot(identical(rows$source, rep(seq_len(m), 2)),
            identical(rows$direction, rep(directions, each = m)))
  matrix(rows$weight, 2, m, byrow = TRUE,
         dimnames = list(directions, paste("Source", seq_len(m))))
}
