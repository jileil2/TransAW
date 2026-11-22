# Li, Cai & Li (2022), Algorithms 1–3 and the real-data choices in §6.1.
# Input data already use study-specific centering and target-training scales.
fit_paper_trans_lasso <- function(dat, seed=20261118L, return_sources=FALSE,
                                  return_stages=FALSE) {
  X0 <- dat$X0
  y0 <- as.numeric(dat$y0)
  Xs <- dat$X_sources
  ys <- lapply(dat$y_sources, as.numeric)
  p <- ncol(X0)
  n <- nrow(X0)
  ns <- vapply(Xs, nrow, integer(1))
  stopifnot(length(ns)>0L, n>=16L, length(y0)==n, all(lengths(ys)==ns))
  hold_n <- round(n / 3)
  top <- min(p, max(1L, round(min(n, ns)^(3/4))))

  # Candidate-specific eightfold CV. The search ranges are the authors' R
  # grids; the paper specifies the fold count but does not specify a grid.
  cv_lasso <- function(x, y, grid_n, folds) {
    grid <- seq(1,.1,length.out=grid_n)*sqrt(2*log(p)/nrow(x))
    fit <- glmnet::cv.glmnet(x,y,lambda=grid,foldid=folds,
                             standardize=FALSE,intercept=FALSE)
    list(beta=as.numeric(coef(fit,s="lambda.min"))[-1],lambda=fit$lambda.min)
  }

  half_fit <- function(hold) {
    x <- X0[-hold,,drop=FALSE]
    y <- y0[-hold]
    score0 <- drop(crossprod(x,y))/nrow(x)
    score <- vapply(seq_along(Xs), function(k) {
      delta <- abs(drop(crossprod(Xs[[k]],ys[[k]]))/ns[k] - score0)
      sum(sort(delta,decreasing=TRUE)[seq_len(top)]^2)
    }, numeric(1))

    # Reuse a shuffled eightfold partition for overlapping observations.
    # Allocate separately within the target and each source.
    foldid <- function(n) sample(rep_len(1:8,n))
    train_folds <- foldid(nrow(x))
    source_folds <- lapply(ns,foldid)
    betas <- list(cv_lasso(x,y,20,train_folds)$beta)
    if (return_stages) initial <- list()
    for (cutoff in sort(unique(score))) {
      k <- which(score<=cutoff)
      xx <- do.call(rbind,c(list(x),Xs[k]))
      yy <- c(y,unlist(ys[k],use.names=FALSE))
      folds <- c(train_folds,unlist(source_folds[k],use.names=FALSE))
      candidate <- cv_lasso(xx,yy,10,folds)
      if (return_stages) initial[[length(betas)]] <- candidate$beta
      lambda_delta <- candidate$lambda * sqrt(sum(ns[k])/nrow(x))
      correction <- glmnet::glmnet(x,y-drop(x %*% candidate$beta),lambda=lambda_delta,
                                    standardize=FALSE,intercept=FALSE)
      betas[[length(betas)+1L]] <- candidate$beta + as.numeric(coef(correction))[-1]
    }
    B <- do.call(cbind,betas)
    # Algorithm 2 of Dai et al. (2018), equations (35)-(36), with the
    # §5.1 settings omega^2=2, nu=0.5, step size 1, uniform prior.
    predictions <- X0[hold,,drop=FALSE] %*% B
    loss <- colSums((predictions-y0[hold])^2)
    beta <- numeric(p)
    for(iteration in seq_len(10000L)) {
      discrepancy <- colSums((predictions-drop(X0[hold,,drop=FALSE] %*% beta))^2)
      log_weights <- -loss/4 + discrepancy/8
      weights <- exp(log_weights-max(log_weights))
      step <- .25*(drop(B %*% (weights/sum(weights)))-beta)
      beta <- beta + step
      if(max(abs(step)) < 1e-10*(1+max(abs(beta)))) {
        if (!return_sources && !return_stages) return(beta)
        cuts <- sort(unique(score))
        membership <- rbind(rep(FALSE,length(ns)),outer(cuts,score,">="))
        result <- list(beta=beta, membership=membership, probability=weights/sum(weights))
        if (return_stages) result$stages <- list(initial=initial, candidates=B, hold=hold)
        return(result)
      }
    }
    stop("GD-BMAX failed to converge with the published step size")
  }
  # Two orientations with first and last thirds held out, following the authors'
  # example. The target training rows are in their saved random order.
  set.seed(seed)
  a <- half_fit(seq_len(hold_n))
  b <- half_fit(seq.int(n-hold_n+1L,n))
  if (return_sources || return_stages) return(list(beta=(a$beta+b$beta)/2,orientations=list(a,b)))
  (a+b)/2
}
