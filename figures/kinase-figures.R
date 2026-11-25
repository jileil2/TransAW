plot_kinase_errors <- function(errors, path) {
  colors <- c("black", "deepskyblue", "indianred1", "magenta")
  open_kinase_plot(path,6.6,2.45)
  par(mar=c(3.0,8.4,.3,.5),mgp=c(1.9,.45,0),tcl=-.22,las=1)
  boxplot(errors[, 1:4],horizontal=TRUE,at=4:1,names=names(errors)[1:4],col="white",border=colors,
          boxlwd=2.4,boxwex=.5,staplewex=.6,outpch=1,outcex=.6,medlwd=2.4,
          xlab="RMSE")
  dev.off()
  compile_plot(path)
}
