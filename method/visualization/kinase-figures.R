plot_kinase_errors <- function(errors, path) {
  colors <- c("black", "deepskyblue", "indianred1", "magenta")
  open_kinase_plot(path,6.6,2.55)
  par(mar=c(3.4,8.4,.5,.9),mgp=c(1.9,.45,0),tcl=-.22,las=1)
  boxplot(errors[, 1:4],horizontal=TRUE,at=4:1,names=names(errors)[1:4],col="white",border=colors,
          boxlwd=3,boxwex=.48,staplewex=.6,outpch=1,outcex=.7,medlwd=2,
          xlab="Test MAE (percentage points of inhibition)")
  dev.off()
  compile_plot(path)
}

plot_kinase_weights <- function(weights, path) {
  open_kinase_plot(path,8.4,4)
  layout(matrix(1:3,nrow=1),widths=c(3.25,2.7,2.8))
  at <- rev(seq_along(weights))
  par(mgp=c(1.65,.35,0),tcl=-.2,las=1,mar=c(3.2,4.2,1.75,.6))
  boxes <- function(column,color) {
    boxplot(lapply(weights,function(g) 100*na.omit(g[[column]])),horizontal=TRUE,at=at,axes=FALSE,
            ylim=c(0,100),col="white",border=color,boxlwd=3,medlwd=3,
            boxwex=.43,outpch=1,outcex=.47)
    box(col="grey55")
    axis(1,at=seq(0,100,25))
  }
  boxes("trans_aw","magenta")
  axis(2,at=at,labels=source_labels,tick=FALSE)
  title(main="Trans-AW",xlab="Source weights (\\%)",cex.main=1,cex.lab=.95)
  par(mar=c(3.2,.6,1.75,.6))
  boxes("trans_lasso","deepskyblue")
  title(main="Trans-LASSO",xlab="Source weights (\\%)",cex.main=1,cex.lab=.95)
  boxes("riw","indianred1")
  title(main="RIW-TL",xlab="Source weights (\\%)",cex.main=1,cex.lab=.95)
  dev.off()
  compile_plot(path)
}
