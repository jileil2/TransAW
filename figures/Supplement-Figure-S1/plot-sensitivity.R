library(ggplot2)
library(tikzDevice)

summarize_errors <- function(x) {
  n <- nrow(x)
  stopifnot(n == 200L)
  average <- mean(x$error)
  mcse <- sd(x$error) / sqrt(n)
  margin <- qt(.975, n-1) * mcse
  data.frame(replications=n, mean_error=average, mcse=mcse,
             lower=average-margin, upper=average+margin)
}

plot_sensitivity <- function(records, size, path) {
  grid <- c(0, 0.0025, 0.005, 0.01, 0.02, 0.05, 0.1)
  fits <- records$fits
  target <- records$target
  keys <- c("n_k", "m", "h", "rep")
  expected <- expand.grid(n_k=size, m=c(5,10,15,20), h=c(2,4,6), rep=1:200)
  stopifnot(nrow(fits)==16800L, nrow(target)==2400L,
            !anyDuplicated(fits[c(keys,"multiplier")]), !anyDuplicated(target[keys]),
            all(is.finite(fits$error)), all(is.finite(target$error)),
            nrow(merge(expected,target,by=keys))==2400L,
            nrow(merge(merge(expected,data.frame(multiplier=grid)),fits,
                       by=c(keys,"multiplier")))==16800L)
  observations <- rbind(
    data.frame(fits[c(keys,"multiplier","error")], method="Trans-AW"),
    data.frame(target[keys], multiplier=NA_real_, error=target$error, method="Target-only LASSO")
  )
  observations$series <- ifelse(is.na(observations$multiplier), "Target-only LASSO",
                                paste0("c=",observations$multiplier))
  groups <- split(observations, interaction(observations$n_k,observations$m,
                                           observations$h,observations$series,drop=TRUE))
  summary <- do.call(rbind,lapply(groups,function(x) {
    cbind(x[1,c("n_k","m","h","method","multiplier")],summarize_errors(x))
  }))
  summary <- summary[with(summary,order(n_k,m,h,method,multiplier)),]
  write.csv(summary, sub("[.]tex$", ".csv", path), row.names=FALSE)
  rows <- subset(summary,n_k==size)
  rows$m <- factor(rows$m,levels=c(5,10,15,20),labels=paste0("$m=",c(5,10,15,20),"$"))
  rows$h <- factor(rows$h,levels=c(2,4,6),labels=paste0("$h=",c(2,4,6),"$"))
  aw <- subset(rows,method=="Trans-AW")
  aw$x <- match(aw$multiplier,grid)
  reference <- subset(rows,method=="Target-only LASSO")
  plot <- ggplot() +
    geom_rect(data=reference,aes(xmin=.6,xmax=7.4,ymin=lower,ymax=upper),
              fill="grey90") +
    geom_hline(data=reference,aes(yintercept=mean_error,color=method,linetype=method),
               linewidth=.55) +
    geom_line(data=aw,aes(x=x,y=mean_error,color=method,linetype=method),linewidth=.6) +
    geom_errorbar(data=aw,aes(x=x,ymin=lower,ymax=upper),
                  width=.26,linewidth=.65,color="grey25") +
    geom_point(data=aw,aes(x=x,y=mean_error,color=method),size=.9) +
    facet_grid(m ~ h) +
    scale_x_continuous(breaks=seq_along(grid),labels=format(grid,trim=TRUE,scientific=FALSE),
                       limits=c(.6,7.4),expand=c(0,0)) +
    scale_y_continuous(limits=c(0,max(rows$upper)*1.06),expand=c(0,0)) +
    scale_color_manual(values=c("Trans-AW"="magenta","Target-only LASSO"="grey25"),name=NULL) +
    scale_linetype_manual(values=c("Trans-AW"="solid","Target-only LASSO"="dashed"),name=NULL) +
    labs(title=sprintf("$n_k=%d$",size), x="$c_\\gamma$",
         y="$\\|\\widehat{\\boldsymbol{\\beta}}-\\boldsymbol{\\beta}_0\\|_2^2$") +
    theme_bw(base_size=11) +
    theme(legend.position="bottom", panel.grid.minor=element_blank(),
          panel.grid.major.x=element_blank(),panel.grid.major.y=element_line(linewidth=.2,color="grey92"),
          axis.text.x=element_text(size=8),strip.background=element_rect(fill="grey96"),
          plot.title=element_text(hjust=.5),panel.spacing=grid::unit(.65,"lines"))
  body <- tempfile(fileext=".tex")
  packages <- c(getOption("tikzLatexPackages"),"\\usepackage{amsmath}","\\usepackage{mathpazo}")
  tikzDevice::tikz(body,standAlone=FALSE,width=9,height=8,pointsize=11,
                   sanitize=FALSE,timestamp=FALSE,packages=packages)
  print(plot)
  dev.off()
  writeLines(c("\\documentclass[tikz,border=2pt]{standalone}",
               "\\usepackage{amsmath,mathpazo}","\\begin{document}",
               readLines(body),"\\end{document}"),path)
  compile_plot(path)
}
