# cleanup
rm(list=ls())
# dev.off()

# load in required libraries
library(readxl)
library(ggplot2)
library(grid)
# read in excel file
val_sw <- read_excel('sampleFile.xlsx',sheet='Hist')

valswframe <- data.frame(Date=val_sw$Date,CLD1=val_sw$wwe_cld1/1000,
                         CLD2=val_sw$wwe_cld2/1000,CLD3=val_sw$wwe_cld3/1000)
valswframe = rowsum(valswframe[,c("CLD1","CLD2","CLD3")],rep(1:45,each=12))
valswframe$Date = seq(as.Date("1968-06-1"), as.Date("2013-05-31"), by="years")
print(mean(valswframe$CLD1[34:36]))
print(mean(valswframe$CLD2[34:36]))
print(mean(valswframe$CLD3[34:36]))

valswframeimp = valswframe
# plot the data
plot1  <- ggplot() + geom_line(data=valswframe, aes(x=Date,y=CLD1,color="CLD1"),lwd=0.8)
plot1  <- plot1    + geom_line(data=valswframe, aes(x=Date,y=CLD2,color="CLD2"),lwd=0.8,alpha=0.8)
plot1  <- plot1    + geom_line(data=valswframe, aes(x=Date,y=CLD3,color="CLD3"),lwd=0.6,alpha=0.8)
plot1  <- plot1    + scale_color_manual(name = "",values = c("CLD1" = rgb(1,0.5,0),"CLD2" = rgb(0.12,0.47,0.71),"CLD3"=rgb(0.2,0.63,0.17)))
plot1 <- plot1     + ylab(expression(paste('WWE [Bm'^3*']')))  
plot1 <- plot1     + annotate("text", x = as.Date("2005-06-1"), y=14,vjust=-5, size = 6,label="")
plot1 <- plot1     + theme_bw()
plot1 <- plot1     + labs(title='a)') + ylim(0,12.5)
plot1 <- plot1     + theme(axis.text=element_text(size=15),
                           axis.title=element_text(size=18),axis.title.x = element_blank(),
                           axis.text.x = element_blank())
plot1 <- plot1     + theme(plot.margin = unit(c(0,1,-1,1), "lines"),
                           plot.title = element_text(size = 20,vjust = -6,hjust=0.01))
plot1 <- plot1  + theme(legend.position = 'none')
#####################################################################################
valswframe <- data.frame(Date=val_sw$Date,CLD2=11.73-val_sw$gw_cld2,CLD3=11.73-val_sw$gw_cld3)
valswframe$CLD2 = colMeans(matrix(valswframe$CLD2,nrow=12))
valswframe$CLD3 = colMeans(matrix(valswframe$CLD3,nrow=12))
valswframe$Date = seq(as.Date("1968-06-1"), as.Date("2013-05-31"), by="years")
print(11.73-mean(valswframe$CLD2[36:39]))
print(11.73-mean(valswframe$CLD3[36:39]))

# plot the data
plot2  <- ggplot()    + geom_line(data=valswframe, aes(x=Date,y=CLD2,color="CLD2"),lwd=0.8,alpha=0.8)
plot2  <- plot2    + geom_line(data=valswframe, aes(x=Date,y=CLD3,color="CLD3"),lwd=0.6,alpha=0.8)
plot2  <- plot2    + scale_color_manual(name = "",values = c("CLD1" = rgb(1,0.5,0),"CLD2" = rgb(0.12,0.47,0.71),"CLD3"=rgb(0.2,0.63,0.17)))
plot2 <- plot2     + ylab('Depth to GW [m]') + xlab("Time [months]") 
plot2 <- plot2     + theme_bw()+ scale_y_reverse()
plot2 <- plot2     + labs(title='b)') + ylim(8.3,3)
plot2 <- plot2     + theme(axis.text=element_text(size=14),
                           axis.title=element_text(size=18),axis.title.x = element_blank(),
                           axis.text.x = element_blank())
plot2 <- plot2     + theme(plot.margin = unit(c(0,1,-1,1), "lines"),
                           plot.title = element_text(size = 20,vjust = -6,hjust=0.01))
plot2 <- plot2  + theme(legend.position = 'none')
###############################################################################
#####################################################################################
valswframe <- data.frame(Date=val_sw$Date,CLD1=val_sw$def_cld1/1000,CLD2=val_sw$def_cld2/1000,CLD3=val_sw$def_cld3/1000)
valswframe = rowsum(valswframe[,c("CLD1","CLD2","CLD3")],rep(1:45,each=12))
valswframe$Date = seq(as.Date("1968-06-1"), as.Date("2013-05-31"), by="years")
print(mean(valswframe$CLD1[34:36]))
print(mean(valswframe$CLD2[34:36]))
print(mean(valswframe$CLD3[34:36]))
# plot the data
plot3  <- ggplot()    + geom_line(data=valswframe, aes(x=Date,y=CLD1,color="SHM1"),lwd=0.8,alpha=0.8)
plot3  <- plot3    + geom_line(data=valswframe, aes(x=Date,y=CLD2,color="SHM2"),lwd=0.8,alpha=0.8)
plot3  <- plot3    + geom_line(data=valswframe, aes(x=Date,y=CLD3,color="SHM3"),lwd=0.6,alpha=0.8)
plot3  <- plot3    + scale_color_manual(name = "",values = c("SHM1" = rgb(1,0.5,0),"SHM2" = rgb(0.12,0.47,0.71),"SHM3"=rgb(0.2,0.63,0.17)))
plot3 <- plot3     + ylab(expression(paste('Deficit [Bm'^3*']'))) + xlab("Time [months]") 
plot3 <- plot3     + theme_bw()
plot3 <- plot3     + labs(title='c)') + ylim(0, 5)
plot3 <- plot3     + theme(axis.text=element_text(size=15),
                           axis.title=element_text(size=18),axis.title.x = element_blank(),
                           axis.text.x = element_blank())
plot3 <- plot3     + theme(plot.margin = unit(c(0,1,-1,1), "lines"),
                           plot.title = element_text(size = 20,vjust = -6,hjust = 0.01))
plot3 <- plot3  + theme(legend.position = 'none', legend.spacing.y = unit(0, "pt"), legend.title = element_blank())
###############################################################################
#####################################################################################
valswframe <- data.frame(Date=val_sw$Date,CLD1=val_sw$release_cld1/1000,CLD2=val_sw$release_cld2/1000,CLD3=val_sw$release_cld3/1000)
valswframe = rowsum(valswframe[,c("CLD1","CLD2","CLD3")],rep(1:45,each=12))
valswframe$Date = seq(as.Date("1968-06-1"), as.Date("2013-05-31"), by="years")
print(mean(valswframe$CLD1[34:36]))
print(mean(valswframe$CLD2[34:36]))
print(mean(valswframe$CLD3[34:36]))
# plot the data
plot4  <- ggplot()    + geom_line(data=valswframe, aes(x=Date,y=CLD1,color="CLD1"),lwd=0.8,alpha=0.8)
plot4  <- plot4    + geom_line(data=valswframe, aes(x=Date,y=CLD2,color="CLD2"),lwd=0.8,alpha=0.8)
plot4  <- plot4    + geom_line(data=valswframe, aes(x=Date,y=CLD3,color="CLD3"),lwd=0.6,alpha=0.8)
plot4  <- plot4    + scale_color_manual(name = "",values = c("CLD1" = rgb(1,0.5,0),"CLD2" = rgb(0.12,0.47,0.71),"CLD3"=rgb(0.2,0.63,0.17)))
plot4 <- plot4     + ylab(expression(paste('Release [Bm'^3*']'))) + xlab("Time [months]") 
plot4 <- plot4     + theme_bw()
plot4 <- plot4     + labs(title='d)') + ylim(0, 55)
plot4 <- plot4     + theme(axis.text=element_text(size=15),
                           axis.title=element_text(size=18),axis.title.x = element_blank(),
                           axis.text.x = element_blank())
plot4 <- plot4     + theme(plot.margin = unit(c(0,1,-1,1), "lines"),
                           plot.title = element_text(size = 20,vjust = -6,hjust=0.01))
plot4 <- plot4  + theme(legend.position = 'none')
###############################################################################
#####################################################################################
valswframe <- data.frame(Date=val_sw$Date,CLD1=val_sw$mef_cld1,CLD2=val_sw$mef_cld2,CLD3=val_sw$mef_cld3)
valswframe = rowsum(valswframe[,c("CLD1","CLD2","CLD3")],rep(1:45,each=12))
valswframe$CLD1 = valswframe$CLD1/12
valswframe$CLD2 = valswframe$CLD2/12
valswframe$CLD3 = valswframe$CLD3/12
print(mean(valswframe$CLD1[34:36]))
print(mean(valswframe$CLD2[34:36]))
print(mean(valswframe$CLD3[34:36]))
valswframe$Date = seq(as.Date("1968-06-1"), as.Date("2013-05-31"), by="years")
# plot the data
plot5  <- ggplot()    + geom_line(data=valswframe, aes(x=Date,y=CLD1,color="CLD1"),lwd=0.8,alpha=0.8)
plot5  <- plot5    + geom_line(data=valswframe, aes(x=Date,y=CLD2,color="CLD2"),lwd=0.8,alpha=0.8)
plot5  <- plot5    + geom_line(data=valswframe, aes(x=Date,y=CLD3,color="CLD3"),lwd=0.6,alpha=0.8)
plot5  <- plot5    + scale_color_manual(name = "",values = c("CLD1" = rgb(1,0.5,0),"CLD2" = rgb(0.12,0.47,0.71),"CLD3"=rgb(0.2,0.63,0.17)))
plot5 <- plot5     + ylab('MEF') + xlab("Time [Year]") 
plot5 <- plot5     + theme_bw()
plot5 <- plot5     + labs(title='e)') + ylim(0, 0.85)
plot5 <- plot5     + theme(axis.text=element_text(size=15),
                           axis.title=element_text(size=18))
plot5 <- plot5     + theme(axis.title.x = element_text(hjust=0.5),
                           plot.margin = unit(c(0,1,0,1), "lines"),
                           plot.title = element_text(size = 20,vjust = -6,hjust=0.01))
plot5 <- plot5     + theme( legend.position ='none')#c(0.65,-0.22), 
#legend.justification = "left",
#                             legend.direction = 'horizontal',legend.text=element_text(size=16),
#                             legend.box.background=element_rect(fill=NA,color=NA),
#                             legend.margin=margin(t = 0, unit='cm'))
plot3 <- plot3     + theme( legend.position =c(0.04,0.52), legend.justification = "left",
                            legend.direction = 'vertical',legend.text=element_text(size=18),
                            legend.box.background=element_rect(fill=NA,color='black'),
                            )#legend.margin=margin(t = 0, unit='cm')
# Code to override clipping
#gt <- ggplotGrob(plot1)
#gt$layout[grepl("panel", gt$layout$name), ]$clip <- "off"

g1 <- ggplotGrob(plot1)
g2 <- ggplotGrob(plot2)
g3 <- ggplotGrob(plot3)
g4 <- ggplotGrob(plot4)
g5 <- ggplotGrob(plot5)


g11 = rbind(g1, g2,g3,g4,g5, size = "first")
#g12 = rbind(g6, g7,g8,g9,g10, size = "first")
g <- g11 #cbind(g11,g12,size="first")
g$widths <- unit.pmax(g2$widths, g3$widths)
g$layout[grepl("panel", g$layout$name), ]$clip <- "off"

#g$widths[5] = g$widths[5]-unit(1.3,'lines')

# Draw the plot
grid.newpage()
#cairo_pdf(paste('4p58p5.pdf',sep=""),width = 10,height=10)
png(paste('plot.png',sep=""),width = 10,height=10,units='in',type="cairo",res=72*6)
grid.draw(g)
dev.off()
