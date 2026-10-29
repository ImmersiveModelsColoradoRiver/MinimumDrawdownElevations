# cleanup
rm(list=ls())
# dev.off()

# load in required libraries
library(readxl)
library(ggplot2)
library(grid)
library(lubridate)

# read in excel file
 val_sw <- read_excel('sampleFile.xlsx',sheet='Validation_GW')
# # Normalize the variables
# val_sw$CLD2 <- (val_sw$CLD2-min(val_sw$CLD2))/(max(val_sw$CLD2)-min(val_sw$CLD2))
# val_sw$CLD3 <- (val_sw$CLD3-min(val_sw$CLD3))/(max(val_sw$CLD3)-min(val_sw$CLD3))
# val_sw$Observed <- (val_sw$Observed-min(val_sw$Observed))/(max(val_sw$Observed)-min(val_sw$Observed))

valswframe <- data.frame(Date=val_sw$Date,Observed=val_sw$Observed,
                         CLD2=11.73-val_sw$CLD2,CLD3=11.73-val_sw$CLD3)
valswframe$Date <- ymd(valswframe$Date)

# plot the data
plot1  <- ggplot() + geom_line(data=valswframe, aes(x=Date,y=CLD2,color="SHM2"),lwd=1.5)
plot1  <- plot1    + geom_line(data=valswframe, aes(x=Date,y=CLD3,color="SHM3"),lwd=1,alpha=0.7)
plot1  <- plot1    + geom_point(data=valswframe, aes(x=Date,y=Observed),color=rgb(0,0,0),lwd=2,lty=1)
plot1  <- plot1    + scale_color_manual(name = "",values = c("SHM2" = rgb(0.12,0.47,0.71),"SHM3"=rgb(0.2,0.63,0.17)))
plot1 <- plot1     + ylab('Depth to GW [m]') + xlab("Time [months]") 
plot1 <- plot1     + theme_bw() + scale_y_reverse()
plot1 <- plot1 + scale_x_date(date_breaks = "6 months",date_labels = "%b\n%Y") 
plot1 <- plot1     + labs(title='a.') + ylim(9, 2)
plot1 <- plot1     + theme(axis.text=element_text(size=14),
                           axis.title=element_text(size=18))
plot1 <- plot1     + theme(axis.title.x = element_text(hjust=0.3),
                           plot.margin = unit(c(1,1.5,3,1), "lines"),
                           plot.title = element_text(size = 20))
plot1 <- plot1  + theme(legend.position = 'none')

# plot1 <- plot1   +  labs(tag = "Observed") 
# plot1 <- plot1   +  theme(plot.tag.position = c(0.80, -0.095),
#                           plot.tag=element_text(size=16))
# plot1 <- plot1  +  coord_cartesian(ylim=c(0, max(valswframe$Observed)))
# plot1 <- plot1  +  geom_point(aes(x=valswframe$Date[117],y=-3000), size =4)
# Code to override clipping
gt <- ggplotGrob(plot1)
gt$layout[grepl("panel", gt$layout$name), ]$clip <- "off"

# Draw the plot
grid.newpage()
cairo_pdf(paste('GW_Level_c.pdf',sep=""),width = 10,height=4)
grid.draw(gt)
dev.off()
