# Figure 4. Observed inhibition, with compounds clustered across ten assays.
source("figures/plot-device.R")
panel <- read.csv("data/kinase-panel.csv.gz", check.names = FALSE)
folder <- file.path(Sys.getenv("TRANSAW_WORKDIR", "results"), "Main-Figure-4")
dir.create(folder, recursive = TRUE, showWarnings = FALSE)
kinases <- c("P38alpha", "P38beta", "MAPKAPK3", "P38gamma", "P38delta", "FYN", "YES", "LCK", "Aurora-A", "AKT1")
row_labels <- c("p38$\\alpha$ (target)", "p38$\\beta$", "MK3", "p38$\\gamma$", "p38$\\delta$", "FYN", "YES", "LCK", "Aurora A", "AKT1")
y <- as.matrix(panel[kinases])
clustering <- hclust(dist(y, method = "euclidean"), method = "complete")
ord <- clustering$order
write.csv(data.frame(compound = panel$compound[ord], y[ord, ], check.names = FALSE),
          file.path(folder, "ordered-inhibition.csv"), row.names = FALSE)
inhibition_color <- function(z, limits, palette) {
 stopifnot(all(is.finite(z)),all(z>=limits[1]),all(z<=limits[2]))
 palette[1L+round((length(palette)-1)*(z-limits[1])/diff(limits))]
}
draw_color_bar <- function(x0, y0, width, height, limits, palette, ticks, label, cex = .72) {
 n<-length(palette)
 rect(x0+(0:(n-1))*width/n,y0,x0+(1:n)*width/n,y0+height,col=palette,border=NA)
 rect(x0,y0,x0+width,y0+height,border='grey35',lwd=.5)
 tx<-x0+(ticks-limits[1])/diff(limits)*width
 segments(tx,y0,tx,y0-.12,lwd=.6)
 text(tx,y0-.22,format(ticks,trim=TRUE),cex=cex,adj=c(.5,1))
 text(x0+width/2,y0+height+.15,label,cex=cex,adj=c(.5,0))
}
inhibition_colors <- colorRampPalette(c('#FFFFFF','#FEE8C8','#FDBB84','#E34A33','#7F0000'))(201)
limits <- c(-25, 100)
path <- file.path(folder, 'Main-Figure-4.tex')
open_kinase_plot(path,7.2,3.7)
par(mar=rep(.15,4),xaxs = 'i', yaxs = 'i')
plot.new()
plot.window(xlim=c(-64,369),ylim=c(-3.5,11.2))
for (k in 1:10) {
 rect(0:363,10-k,1:364,11-k,col=inhibition_color(y[ord,k],limits,inhibition_colors),border=NA)
 text(-7,10.5-k,row_labels[k],adj=1,cex=.77)
}
rect(0,0,364,10,border='grey40',lwd=.6)
segments(0,9,364,9,col='grey20',lwd=1.1)
text(182,10.65,'Observed kinase inhibition',cex=.9)
text(182,-.45,'364 compounds (hierarchically clustered)',cex=.77)
draw_color_bar(70,-2.35,224,.35,limits,inhibition_colors,c(-25,0,25,50,75,100),'Observed inhibition (\\%)')
dev.off()
compile_plot(path)
