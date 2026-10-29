# MinimumDrawdownFigsR.r
#
# This script harvests Daily, Monthly, and Annual Lake Powell and Lake Mead data
# from the Reclamation data portal and plots a variety of historical
# and current reservoir data.

# David E. Rosenberg
# January 13, 2026
# Utah State University
# david.rosenberg@usu.edu

rm(list = ls())  #Clear history

# Load required libraries in 1 go
# List of packages
load.lib <- c("tidyverse", "readxl", "RColorBrewer", "dplyr", "expss", "reshape2", "pracma", "lubridate", "directlabels", "plyr", "stringr", "ggplot2", "ggpubr", "ggrepel", "zoo", "here")
# Then we select only the packages that aren't currently installed.
install.lib <- load.lib[!load.lib %in% installed.packages()]
# And finally we install the missing packages, including their dependency.
for(lib in install.lib) install.packages(lib,dependencies=TRUE)
# After the installation process completes, we load all packages.
sapply(load.lib,require,character=TRUE)

here::i_am("HistoricalCurrentReservoirData/HistoricalCurrentReservoirData.r")
        
## Read in functions to:
#     Auto load USBR data
#     Interpolate with NAs
#     Load Reservoir Bathymetry and Critical Elevations
source("../AutoReadUSBRData/AutoReadUSBRData.r")

dYesterday <- today() - 1

sYesterdayDate <- paste(month.name[month(dYesterday)], day(dYesterday),",",year(dYesterday))
print(paste0("This report was generated on: ", sYesterdayDate))

# Read in the Reclamation Hydro Data
#lResData <- fReadReclamationHydroData(FromHydroData = TRUE)
lResData <- fReadReclamationHydroData(FromHydroData = FALSE)


# Read in the Reservoir Bathymetry and Critical Elevations
dfTemp <- ReadBathymetryCritialElevations()

# Let's try plotting the annuall Lake Powell Release
dfResDataAnnual <- lResData$dfResAnnual

#Filter the Powell Release Volume
dfPowellAnnual <- dfResDataAnnual %>% filter(ResName == "Lake Powell",FieldName == "Release volume")

#10-year total release
dfPowellAnnual$TenYearRelease <- rollapply(dfPowellAnnual$AnnualValue, 10,sum, fill=NA, align="right")

#7.48 and 8.23 MAF annual targets
dfPowellAnnual$OneYearTarget <- 7.48  # Paria flow (0.02 maf per year adds 0.2 maf over 10 years)
dfPowellAnnual$OneYearTarget82 <- dfPowellAnnual$OneYearTarget + 0.75
dfPowellAnnual$TenYearTarget <- dfPowellAnnual$OneYearTarget * 10  # Paria flow (0.02 maf per year adds 0.2 maf over 10 years)
dfPowellAnnual$TenYearTarget82 <- dfPowellAnnual$TenYearTarget + 10*0.75



#Get the blue color bar
pBlues <- brewer.pal(9,"Blues")
pReds <- brewer.pal(9,"Reds")

#### Figure 1. Annual Powell Release compared to 7.5 and 8.23 targets
#Pivot the Wide format to Longer for Plotting with different colors
dfPowellAnnualLong <- pivot_longer(data = dfPowellAnnual, cols = c(AnnualValue, OneYearTarget, OneYearTarget82), names_to = "DataType", values_to = "Flow")
dfPowellAnnualLong$DataTypeFactor <- factor(dfPowellAnnualLong$DataType, levels = c("AnnualValue", "OneYearTarget82", "OneYearTarget") )

ggplot(data = dfPowellAnnualLong %>% filter(WaterYear >= 1995), aes(x = WaterYear, y = Flow , color = DataTypeFactor, linetype = DataTypeFactor)) +
  #Powell release 
  geom_line(size=2) +
  
  scale_color_manual(labels = c("Annual Release", "8.23 Target", "7.48 Target"), values = c("AnnualValue" = pBlues[8], "OneYearTarget82" =  pReds[7], "OneYearTarget" = pReds[4])) +
  scale_linetype_manual(labels = c("Annual Release", "8.23 Target", "7.48 Target"), values = c("AnnualValue" = "solid", "OneYearTarget82" =  "dashed", "OneYearTarget" = "twodash")) +
  scale_x_continuous(breaks = seq(1970,2026,5)) +
  theme_bw() +
  #coord_fixed() +
  labs(x="", y="Powell Release\n(million acre-feet per year)") +
  theme(text = element_text(size=20), legend.title=element_blank(), legend.text=element_text(size=18))
#theme(text = element_text(size=20), legend.text=element_text(size=16)

ggsave("PowellAnnualRelease.png", width=9, height = 6.5, units="in")


#### Figure 2. Ten-Year Powell Release compared to 10-year targets

#Pivot the Wide format to Longer for Plotting with different colors
dfPowellTenYearLong <- pivot_longer(data = dfPowellAnnual, cols = c(TenYearRelease, TenYearTarget, TenYearTarget82), names_to = "DataType", values_to = "Flow")
dfPowellTenYearLong$DataTypeFactor <- factor(dfPowellTenYearLong$DataType, levels = c("TenYearRelease", "TenYearTarget82", "TenYearTarget") )

ggplot(data = dfPowellTenYearLong %>% filter(WaterYear >= 1995), aes(x = WaterYear, y = Flow , color = DataTypeFactor, linetype = DataTypeFactor)) +
  #Powell release 
  geom_line(size=2) +
  
  scale_color_manual(labels = c("10-Year Release", "82.3 Target", "74.8 Target"), values = c("TenYearRelease" = pBlues[8], "TenYearTarget82" =  pReds[7], "TenYearTarget" = pReds[4])) +
  scale_linetype_manual(labels = c("10-Year Release", "82.3 Target", "74.8 Target"), values = c("TenYearRelease" = "solid", "TenYearTarget82" =  "dashed", "TenYearTarget" = "twodash")) +
  scale_x_continuous(breaks = seq(1970,2026,5)) +
  theme_bw() +
  #coord_fixed() +
  labs(x="", y="Powell Release\n(million acre-feet per year)") +
  theme(text = element_text(size=20), legend.title=element_blank(), legend.text=element_text(size=18))
#theme(text = element_text(size=20), legend.text=element_text(size=16)

ggsave("PowellTenYearRelease.png", width=9, height = 6.5, units="in")

#Export to CSV
write.csv(dfPowellAnnual,"dfPowellAnnual.csv" )

#### Spit out the most recent Lake Powell and Lake Mead Pool elevations
dfResDataDaily <- lResData$dfResDaily

#filter to values for yesterday 
dYesterday <- today() - 1

dMaxDay <- as.character(as.Date(max(dfResDataDaily$DateValue)) - 1)
#dfResElevations <- dfResDataDaily %>% filter(FieldName %in% c("Pool Elevation","Storage"), DateValue == dYesterday) %>% select(ResName, FieldName, Value)
dfResElevations <- dfResDataDaily %>% filter(FieldName %in% c("Pool Elevation","Storage"), DateValue == dMaxDay) %>% select(ResName, FieldName, Value)


# Make the Table easy to Read
dfResValues <- pivot_wider(  dfResElevations %>% group_by(ResName),  names_from = FieldName,   values_from = Value)
# Convert storage to million acre-feet
dfResValues$Storage <- dfResValues$Storage / 1e6

print(paste("Reservoir Data on: ", dMaxDay))
print(paste("Reservoir Data on:",month.name[month(dMaxDay)],day(dMaxDay),",",year(dMaxDay)))
print(dfResValues)

################
#  Figure 3. Powell, Mead, and Combined storage plot
#

# Combined, Powell, and Mead on one plot

# Filter the Powell and Mead monthly storages
dfResDataMonthly <- lResData$dfResMonthly
#Filter the Powell and Mead storages
dfResStorage <- dfResDataMonthly %>% filter(ResName %in% c("Lake Powell", "Lake Mead"), FieldName == "Storage")
#Turn narrow into wide so separate columns for Lake Powell and Lake Mead
dfResStorageWide <- pivot_wider(  dfResStorage %>% group_by(ResName, Date, Year, Month) %>% select(ResName, Date, Year, Month, MonthlyValue),   names_from = ResName,   values_from = MonthlyValue)
#Filter to data after 1995
dfResStorageWide1995 <- dfResStorageWide %>% filter(Year >= 1995)

ggplot() +
  #Powell storage
  geom_line(data=dfResStorageWide1995 ,aes(x=as.Date(Date), y=`Lake Powell`, color="Powell"), size=2) +
  #Mead Storage
  geom_line(data=dfResStorageWide1995 ,aes(x=as.Date(Date), y=`Lake Mead`, color="Mead"), size=2) +
  #Combined Storage
  geom_line(data=dfResStorageWide1995,aes(x=as.Date(Date), y=`Lake Powell` + `Lake Mead`, color="Combined"), size=2) +
  scale_color_manual(values = c("purple","red","blue"), breaks=c("Combined", "Powell", "Mead")) +
  #geom_area(data=dfPlotData,aes(x=month,y=stor_maf, fill = variable), position='stack') +
  scale_y_continuous(breaks = seq(0,50,by=10),labels=seq(0,50,by=10)) +
  scale_x_date(limits= c(as.Date("1995-01-01"), as.Date("2030-01-01")),
               date_breaks = "5 years", # Major ticks every 10 years
               date_labels = "%Y") +
  
  
  #    scale_y_continuous(breaks = c(0,5.98,9.6,12.2,dfMaxStor[2,2]),labels=c(0,5.98,9.6,12.2,dfMaxStor[2,2]),  sec.axis = sec_axis(~. +0, name = "Mead Level (feet)", breaks = c(0,5.98,9.6,12.2,dfMaxStor[2,2]), labels = c(895,1025,1075,1105,1218.8))) +
  #scale_x_discrete(breaks=cMonths, labels= cMonthsLabels) +
  #scale_x_continuous(breaks=seq(1960,2020,by=10), labels= seq(1960,2020,by=10)) +
  
  
  #scale_fill_manual(breaks=c(1:6),values = palBlues[2:7]) + #,labels = variable) + 
  theme_bw() +
  #coord_fixed() +
  labs(x="", y="Active Storage (MAF)", color = "Reservoir") +
  theme(text = element_text(size=20), legend.title=element_blank(), legend.text=element_text(size=18))
#theme(text = element_text(size=20), legend.text=element_text(size=16)


################
# Figure 4. Powell on X and Mead on Y with 1:1

#Filter out a narrow set of Powell Critical elevations

dfPowellElevationsFiltered <- dfTemp$dfPowellElevations %>% filter(`Elevation (feet)` %in% c(3370, 3490, 3525, 3600, 3700))

ggplot() +
  # Plot a 1:1 line to total storage
  geom_abline(intercept = 0, slope = 1, color="1:1 line (by volume)", size=2, linetype="longdash", show.legend = FALSE) +
    #Label the 1:1 line
  geom_text(aes(x=3.5,y=4.2,label="1:1 line"), color="black", angle = 45, size =6, show.legend = FALSE) +

  #Overplot Mead-Powell historical storage -- January of each year
  #Before guidelines in place in Red
  geom_path(data = dfResStorageWide %>% filter(Month == 1, Year < 2007), aes(x = `Lake Powell`, y = `Lake Mead`, color="Before Guidelines"), size=1.5, linetype=1, show.legend = TRUE) +
  #After guidelines in place in purple
  geom_path(data = dfResStorageWide %>% filter(Month == 1, Year >=  2007), aes(x = `Lake Powell`, y = `Lake Mead`, color="After Guidelines"), size=1.5, linetype=1, show.legend = TRUE) +

  #Label each January with it's year
  #geom_text_repel(data=dfResStorageWide %>% filter(Month == 1, Year %% 4 == 0), point.padding = NA, aes(x = `Lake Powell`, y = `Lake Mead`, label = Year, angle = 0, size = 2)) +
  #geom_text_repel(data=dfResStorageWide %>% filter(Month == 1, Year %% 4 == 0), aes(x = `Lake Powell`, y = `Lake Mead`, label = Year, angle = 0, size = 2)) +

  # All years in black
  #geom_text(data = dfResStorageWide %>% filter(Month == 1, Year %% 2 == 0), aes(x = `Lake Powell`, y = `Lake Mead`, label = Year, angle = 0, size = 1)) +
  
  #Before guidelines
  geom_text(data = dfResStorageWide %>% filter(Month == 1, Year %% 2 == 0, Year < 2007), aes(x = `Lake Powell`, y = `Lake Mead`, label = Year, angle = 0, size = 1, color = "Before Guidelines")) +
  # After guidelines
  geom_text(data = dfResStorageWide %>% filter(Month == 1, Year %% 2 == 0, Year >= 2007), aes(x = `Lake Powell`, y = `Lake Mead`, label = Year, angle = 0, size = 1, color = "After Guidelines")) +
  
  
    # Before guidelines
  #geom_text_repel(data=dfResStorageWide %>% filter(Month == 1, Year < 2007), point.padding = NA, aes(x = `Lake Powell`, y = `Lake Mead`, label = Year, color="Before Guidelines", angle = 0, size = 2, check_overlap = TRUE)) +
  # After guidelines
  #geom_text_repel(data=dfResStorageWide %>% filter(Month == 1, Year >= 2007), point.padding = NA, aes(x = `Lake Powell`, y = `Lake Mead`, label = Year, color="After Guidelines", angle = 0, size = 2, check_overlap = TRUE)) +
  
  
  
   #set colors for lines

   scale_color_manual(breaks = c("Before Guidelines", "After Guidelines"),
                          #All years in Black 
                          # values= c(pBlues[8], pBlues[5], "black"),
                            values= c(pBlues[6], pReds[6]),
                            labels = c("Before Guidelines", "With Guidelines")) +
  
  #Create secondary y axes for Mead Lake Level
  scale_y_continuous(limits = c(0,25), breaks = c(0,5,10,15,20,25),labels=c(0,5,10,15, 20,25),  sec.axis = sec_axis(~. +0, name = "Mead Level (feet)", breaks = dfTemp$dfMeadElevations$ActiveStorageMAF, labels = dfTemp$dfMeadElevations$Label)) +
  #Create secondary x axes for Powell Lake Level
  scale_x_continuous(limits = c(0,25), breaks = c(0,5,10,15,20,25),labels=c(0,5,10,15, 20,25), sec.axis = sec_axis(~. +0, name = "Powell Level (feet)", breaks = dfPowellElevationsFiltered$ActiveStorageMAF , labels = dfPowellElevationsFiltered$`Elevation (feet)`)) +
  
  theme_bw() +
  coord_fixed() +
  
  #guides(size = "none", colour = guide_legend("Historical volumes (year)"), fill="none") +
  guides(size = "none", colour = guide_legend(""), fill="none") +
  
  labs(x="Powell Active Storage (MAF)", y="Mead Active Storage (MAF)") +

       # theme(text = element_text(size=14), legend.text=element_text(size=10),
       #  panel.border = element_rect(colour = "black", fill="NA"),
       #  legend.background = element_blank(),
       #  legend.box.background = element_rect(colour = "black", fill="grey"),
       #  legend.position = c(1.13,0.620))
  theme(text = element_text(size=14))  # legend.position = "none")


##########
## Figure 5. Lake Powell storage/elevation over time

# Calculate volumes from current storage to elevations 3,525, 3,500, and 3490
dfPowellElevations <- dfTemp$dfPowellElevations
dfPowellElevations$CurrentStorage <- dfResElevations %>% filter(FieldName == "Storage", ResName == "Lake Powell") %>% pull(Value) / 1e6
dfPowellElevations$StorageAbove <- dfPowellElevations$CurrentStorage - dfPowellElevations$ActiveStorageMAF
dfPowellElevations$StorageAboveLabel <- paste0(round(dfPowellElevations$StorageAbove, digits = 2), " maf above elev. ", format(dfPowellElevations$`Elevation (feet)`,scientific = FALSE, big.mark = ",", trim = TRUE))

# Filter out the last (most recent entry)
dfResStorageWide$DateAsDate <- as.Date(dfResStorageWide$Date)
dfLastDate <- dfResStorageWide %>% arrange(DateAsDate)
dfLastDate <- dfLastDate[nrow(dfLastDate),] 

# Combine all the current storage above critical elevations to one character string separated by newlines

cPowellElevationsConcat <- dfPowellElevations %>%
     arrange(desc(`Elevation (feet)`)) %>%  
     filter(`Elevation (feet)` >= 3490, `Elevation (feet)` <= 3525) %>%
    
    select(StorageAboveLabel) %>%
    summarise(all_text = str_c(as.character(unlist(.)), collapse = "\n"))

#Format current storage and elevation for listing

cRes <- "Lake Powell"
nStorage <- round(dfResValues %>% filter(ResName == cRes) %>% pull(Storage), digits = 2)
nElevation <- round(dfResValues %>% filter(ResName == cRes) %>% pull(`Pool Elevation`), digits = 1)

cCurrent <- paste0("Active storage on ", sYesterdayDate, ":\n", nStorage, " maf (", nElevation," feet)")

dEndDate <- as.Date("2027-01-01")

### Plot 5 - Full Powell history back to 1995
ggplot() +

  geom_line(data = dfResStorageWide, aes(x = DateAsDate, y = `Lake Powell`), size = 1.5) +
  
  geom_text(aes(x = as.Date("2026-01-01"), y = 16.5, label = cCurrent), fontface = "bold", color = "blue") + 
  geom_text(aes(x = as.Date("2026-01-01"), y = 13, label = cPowellElevationsConcat), color = pReds[7]) +
    
    scale_x_date(limits= c(as.Date("1995-01-01"), as.Date("2030-01-01")),
               date_breaks = "5 years", # Major ticks every 10 years
               date_labels = "%Y") +
  
  #Create secondary y axes for Powell Lake Level
   scale_y_continuous(limits = c(0,25), breaks = dfPowellElevations$ActiveStorageMAF,labels=round(dfPowellElevations$ActiveStorageMAF, digits = 1), sec.axis = sec_axis(~. +0, name = "Powell Elevation (feet)", breaks = dfPowellElevations$ActiveStorageMAF , labels = dfPowellElevations$Label)) +
  
  geom_hline(yintercept = dfPowellElevations$ActiveStorageMAF, color = pBlues[5], linetype = "dashed") +
  theme_bw() +
  
  geom_point(data = dfLastDate, aes(x = DateAsDate, y = `Lake Powell`), color = "blue", size = 4 ) +
  
  
  labs(x="", y="Powell Active Storage (MAF)") +
  theme(text = element_text(size=14), legend.position = "none",
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank())

 
### Plot 5B - Powell history back to 2025 and y axis cut at 3,575 feet

# Combine all the current storage above critical elevations to one character string separated by newlines

#Recalculate elevations above for narrower time window
cPowellElevationsConcatNarrow <- dfPowellElevations %>%
  arrange(desc(`Elevation (feet)`)) %>%  
  filter(`Elevation (feet)` >= 3525, `Elevation (feet)` <= 3525) %>%
  
  select(StorageAboveLabel) %>%
  summarise(all_text = str_c(as.character(unlist(.)), collapse = "\n"))

nCatastrophicVolume <- dfPowellElevations %>% filter(`Elevation (feet)`  == 3514) %>% pull(ActiveStorageMAF)

dfPowellElevations2 <- dfPowellElevations %>% filter(`Elevation (feet)` %in% c(3514, 3525))

# Calculate storage above catastrophy elevation
dfPowellElevations2$CatastrophyVolume <- nCatastrophicVolume
dfPowellElevations2$VolumeAboveCatastraphy <- dfPowellElevations2$ActiveStorageMAF - dfPowellElevations2$CatastrophyVolume
dfPowellElevations2$PoolLabel <- paste0("Minimum Drawdown Elevation\n(Buffer: ", round(dfPowellElevations2$VolumeAboveCatastraphy, digits = 1)," maf)")
dfPowellElevations2$PoolLabel[1] <- "Catastrophic Elevation\n(No Hydropower - Vorticies)"

dfPowellElevations2$DateOffset <- c(270, 0)

dfPowellElevations2$VerticalAdjustLabel <- c(-0.2, 0.2)
dfPowellElevations2$LabelColor <- c(7, 9)
nTextSize <- 5
lFontSize <- 16
lFontSizeReduction <- 2

# ggplot() +
#   
#   geom_line(data = dfResStorageWide, aes(x = DateAsDate, y = `Lake Powell`), size = 1.5) +
#   
#   geom_text(aes(x = as.Date("2026-04-01"), y = 7.8, label = cCurrent), fontface = "bold", color = "blue", size = nTextSize) + 
#   geom_text(aes(x = as.Date("2026-04-01"), y = 7.0, label = cPowellElevationsConcatNarrow), color = pReds[5], size = nTextSize) +
# 
#   scale_x_date(limits= c(as.Date("2025-03-01"), dEndDate),
#                date_breaks = "6 months", # Major ticks every 10 years
#                date_labels = "%b\n%Y") +
#   
#   #Create secondary y axes for Powell Lake Level
#   scale_y_continuous(limits = c(0,10), breaks = dfPowellElevations$ActiveStorageMAF,labels=round(dfPowellElevations$ActiveStorageMAF, digits = 1), sec.axis = sec_axis(~. +0, name = "Powell Elevation (feet)", breaks = dfPowellElevations$ActiveStorageMAF , labels = dfPowellElevations$Label)) +
#   
#   geom_hline(yintercept = dfPowellElevations2$ActiveStorageMAF, color = pReds[3], linetype = "dashed", size =1.5) +
# 
#   geom_point(data = dfLastDate, aes(x = DateAsDate, y = `Lake Powell`), color = "blue", size = 4 ) +
#   
#   
#     # Add a label for Minimum Drawdown and Catastropy Elevations
#   geom_text(data = dfPowellElevations2, aes(x = as.Date("2026-10-01"), y = ActiveStorageMAF + VerticalAdjustLabel, label = PoolLabel), color = pReds[9], size = 6) +
#   
#   theme_bw() +
#   
#   labs(x="", y="Powell Active Storage (MAF)") +
#   theme(text = element_text(size=lFontSize), legend.position = "none",
#         panel.grid.major = element_blank(),
#         panel.grid.minor = element_blank())


### Plot 5C - Powell history back to 2025 and y axis cut at 3,575 feet

dStartDate <- as.Date("2024-01-01")

dfResDataDaily <- lResData$dfResDaily
#Filter the Powell and Mead storages
dfResStorageDaily <- dfResDataDaily %>% filter(ResName %in% c("Lake Powell", "Lake Mead"), FieldName == "Storage")

# Convert to million acre-feet
dfResStorageDaily$Value <- dfResStorageDaily$Value / 1e6

#Turn narrow into wide so separate columns for Lake Powell and Lake Mead
dfResStorageDailyWide <- pivot_wider(  dfResStorageDaily %>% group_by(ResName, DateValue, Year, Month) %>% select(ResName, DateValue, Year, Month, Value),   names_from = ResName,   values_from = Value)
#Filter to data after 1995
#dfResStorageWide1995 <- dfResStorageWide %>% filter(Year >= 1995)

# Filter out the last (most recent entry)
dfResStorageDailyWide$DateAsDate <- as.Date(dfResStorageDailyWide$DateValue)
dfResStorageDailyWide <- dfResStorageDailyWide %>% filter(DateAsDate >= dStartDate)
dfLastDateDaily <- dfResStorageDailyWide %>% arrange(DateAsDate)
dfLastDateDaily <- dfLastDateDaily[nrow(dfLastDateDaily),] 

dEndDate <- as.Date("2027-01-01")

ggplot() +
  
  geom_line(data = dfResStorageDailyWide, aes(x = DateAsDate, y = `Lake Powell`), size = 1.5) +
  
  geom_text(aes(x = as.Date("2026-02-01"), y = 9, label = cCurrent), fontface = "bold", color = "blue", size = nTextSize) + 
  geom_text(aes(x = as.Date("2026-02-01"), y = 8.5, label = cPowellElevationsConcatNarrow), color = pReds[5], size = nTextSize) +
  
  scale_x_date(limits= c(dStartDate, dEndDate),
               date_breaks = "6 months", # Major ticks every 10 years
               date_labels = "%b\n%Y") +
  
  #Create secondary y axes for Powell Lake Level
  scale_y_continuous(limits = c(3,10), breaks = dfPowellElevations$ActiveStorageMAF,labels=round(dfPowellElevations$ActiveStorageMAF, digits = 1), sec.axis = sec_axis(~. +0, name = "Elevation (feet)", breaks = dfPowellElevations$ActiveStorageMAF , labels = dfPowellElevations$Label)) +
  
  geom_hline(yintercept = dfPowellElevations2$ActiveStorageMAF, color = pReds[4], linetype = "dashed", size =1.5) +
  
  geom_point(data = dfLastDateDaily, aes(x = DateAsDate, y = `Lake Powell`), color = "blue", size = nTextSize - 1 ) +
  
  
  # Add a label for Minimum Drawdown and Catastropy Elevations
  geom_text(data = dfPowellElevations2, aes(x = as.Date("2024-12-01") + DateOffset, y = ActiveStorageMAF + VerticalAdjustLabel, label = PoolLabel), color = "red", size = nTextSize, fontface = "bold" ) +
  
  theme_bw() +
  
  labs(x="", y="Active Storage (maf)") +
  
  theme(text = element_text(size=lFontSize), legend.position = "none",
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        axis.text.y.right = element_text(size = lFontSize - lFontSizeReduction))


##########
## Figure 5C - Calculating average change of Powell storage per day and per week (slope)

# Date of recent maximum to start
dLocalMaxDay <- as.Date("2026-06-03")

# Pull storage for local max and end date
dLocalMaxStorage <- dfResStorageDailyWide %>% filter(DateAsDate == dLocalMaxDay) %>% pull(`Lake Powell`)
dCurrStorage <- dfResValues %>% filter(ResName == "Lake Powell") %>% pull(Storage)

dStorageChangePerDay <- (dLocalMaxStorage - dCurrStorage) / as.numeric(dYesterday - dLocalMaxDay)
dStorageChangePerWeek <- dStorageChangePerDay * 7

#Number of Days until 3514

dfPowellElevations$DaysUntilVolume <- round(dfPowellElevations$StorageAbove / dStorageChangePerDay, digits = 0)
dfPowellElevations$WeeksUntilVolume <- round(dfPowellElevations$StorageAbove / dStorageChangePerWeek, digits = 0)

print(dfPowellElevations %>% select(Label, ActiveStorageMAF, DaysUntilVolume, WeeksUntilVolume))


##########
## Figure 6. Lake Mead storage/elevation over time

dfMeadElevations <- dfTemp$dfMeadElevations
dfMeadElevations$CurrentStorage <- dfResElevations %>% filter(FieldName == "Storage", ResName == "Lake Mead") %>% pull(Value) / 1e6
dfMeadElevations$StorageAbove <- dfMeadElevations$CurrentStorage - dfMeadElevations$ActiveStorageMAF
dfMeadElevations$StorageAboveLabel <- paste0(round(dfMeadElevations$StorageAbove, digits = 1), " maf above elev. ", format(dfMeadElevations$`Elevation (feet)`,scientific = FALSE, big.mark = ",", trim = TRUE))

# Combine all the current storage above critical elevations to one character string separated by newlines
cMeadElevationsConcat <- dfMeadElevations %>%
  arrange(desc(`Elevation (feet)`)) %>%  
  filter(`Elevation (feet)` >= 955, `Elevation (feet)` <= 1020) %>%
  
  select(StorageAboveLabel) %>%
  summarise(all_text = str_c(as.character(unlist(.)), collapse = "\n"))

cRes <- "Lake Mead"
nStorage <- round(dfResValues %>% filter(ResName == cRes) %>% pull(Storage), digits = 2)
nElevation <- round(dfResValues %>% filter(ResName == cRes) %>% pull(`Pool Elevation`), digits = 1)

cCurrent <- paste0("Current storage is:\n", nStorage, " maf (", nElevation," feet)")


ggplot() +
  
  geom_line(data = dfResStorageWide, aes(x = as.Date(Date), y = `Lake Mead`), size = 1.5) +
  geom_point(data = dfLastDate, aes(x = DateAsDate, y = `Lake Mead`), color = pReds[7], size = 4 ) +
  
  geom_text(aes(x = as.Date("2026-01-01"), y = 21, label = cCurrent), fontface = "bold", color = "blue") + 
  
  geom_text(aes(x = as.Date("2026-01-01"), y = 16.5, label = cMeadElevationsConcat), color = pReds[7]) +
  
  
    
  scale_x_date(limits= c(as.Date("1995-01-01"), as.Date("2030-01-01")),
               date_breaks = "5 years", # Major ticks every 10 years
               date_labels = "%Y") +
  
  #Create secondary y axes for Mead Lake Level
  scale_y_continuous(limits = c(0,25), breaks = dfMeadElevations$ActiveStorageMAF,labels=round(dfMeadElevations$ActiveStorageMAF, digits = 1), sec.axis = sec_axis(~. +0, name = "Mead Elevation (feet)", breaks = dfMeadElevations$ActiveStorageMAF , labels = dfMeadElevations$Label)) +
  
  geom_hline(yintercept = dfMeadElevations$ActiveStorageMAF, color = pBlues[5], linetype = "dashed") +
  theme_bw() +
  
  labs(x="", y="Mead Active Storage (MAF)") +
  theme(text = element_text(size=14), legend.position = "none",
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank())


##################
## Figure 7

#Histogram -- frequency of annual Release volumes
ggplot(dfResDataAnnual %>% filter(ResName == "Lake Powell", FieldName == "Release volume"), aes(x=AnnualValue)) +
  geom_histogram(color="darkmagenta", fill="magenta", binwidth = 2) +
  
  scale_x_continuous(limits = c(2,22), breaks = seq(2,22,by=2)) +
  #scale_y_continuous(breaks = seq(0,11,by=2)) +
  
  labs(x="Powell Release\n(million acre feet per year)", y="Frequency\n(number of years)") +
  theme(text = element_text(size=20), legend.title=element_blank(), legend.text=element_text(size=18),
        legend.key = element_blank())


#################
# Figure 8. Histogram -- frequency of annual release volumes
ggplot(dfResDataAnnual %>% filter(ResName == "Lake Powell", FieldName == "Inflow Volume"), aes(x=AnnualValue)) +
  geom_histogram(color="darkmagenta", fill="magenta", binwidth = 2) +
  
  scale_x_continuous(limits = c(2,22), breaks = seq(2,22,by=2)) +
  #scale_y_continuous(breaks = seq(0,11,by=2)) +
  
  labs(x="Powell Inflow\n(million acre feet per year)", y="Frequency\n(number of years)") +
  theme(text = element_text(size=20), legend.title=element_blank(), legend.text=element_text(size=18),
        legend.key = element_blank())

##############
### Figure 9. As mixed bar (inflow) line (release) plot

ggplot() +
  #Bar graph of Powell Inflow
  geom_bar(data = dfResDataAnnual %>% filter(ResName == "Lake Powell", FieldName == "Inflow Volume"), aes(x = WaterYear, y=AnnualValue, fill = "Inflow"), stat="identity") +
  #Line graph of Powell Release
  geom_line(data = dfResDataAnnual %>% filter(ResName == "Lake Powell", FieldName == "Release volume"), aes(x = WaterYear, y=AnnualValue, group = 1, color="Release"), size=2) +
  scale_color_manual(" ", values = c("Inflow" = "grey50", "Release" = "blue")) +
  scale_fill_manual("", values="grey50") +
  labs(x="", y="Water Volume\n(million acre-feet per year)") +  
  
  theme(text = element_text(size=20), legend.title=element_blank(), legend.text=element_text(size=18),
        panel.background = element_blank(), 
        legend.key = element_blank(),
        axis.line = element_line(colour = "black"))

########  

dfResDataDaily$DateAsDate <- ymd(dfResDataDaily$Date)
##############
### Figure 9B. Daily Powell Inflow/Release for current year

## Sum inflow and release volumes to date from the start of the water yesr.
dfCurrentYear <- dfResDataDaily %>% filter(ResName == "Lake Powell", WaterYear >= max(WaterYear), FieldName %in% c("Release volume", "Inflow Volume"))

dfYearToDateVolume <- dfCurrentYear %>% select(FieldName, Value) %>% group_by(FieldName) %>% dplyr::summarize(Total = sum(Value)/1e6)
# Calculate the labels
dfYearToDateVolume$FieldNameShort <- word(dfYearToDateVolume$FieldName,1)
dfYearToDateVolume$Label <- paste0(dfYearToDateVolume$FieldNameShort, "\n(", round(dfYearToDateVolume$Total,digits = 1), " maf)")

ggplot() +
  #Line graph of Powell Release
  geom_line(data = dfResDataDaily %>% filter(ResName == "Lake Powell", FieldName == "Release volume", WaterYear >= max(WaterYear) - 1) , aes(x = DateAsDate, y=Value, group = 1, color="Release"), size=1) +
  geom_line(data = dfResDataDaily %>% filter(ResName == "Lake Powell", FieldName == "Inflow Volume", WaterYear >= max(WaterYear) - 1), aes(x = DateAsDate, y=Value, group = 1, color="Inflow"), size=1) +
  
    scale_color_manual(" ", labels = c(dfYearToDateVolume$Label[1],dfYearToDateVolume$Label[2] ), values = c("Inflow" = pBlues[7], "Release" = pReds[7])) +
  scale_x_date( date_breaks = "1 month", date_labels = "%b\n%Y") +
 
  #Create secondary y axes for flow in cfs
  scale_y_continuous(labels = scales::label_comma(), sec.axis = sec_axis(transform = ~ . * 0.504, name = "Average Daily Flow\n(Cubic feet per second)", labels = scales::label_comma())) +
  
     labs(x="", y="Water Volume\n(Acre-feet per day)") +  
  
  theme(text = element_text(size=20), legend.title=element_blank(), legend.text=element_text(size=18),
        panel.background = element_blank(), 
        legend.key = element_blank(),
        axis.line = element_line(colour = "black"))



#### Figure 10. Powell Annual Evaporation
ggplot(data = dfResDataAnnual %>% filter(ResName == "Lake Powell", FieldName == "Evaporation")) +
  geom_line(aes(x=WaterYear, y=`AnnualValue`, color=pBlues[7]), size=2) +

  #geom_area(data=dfPlotData,aes(x=month,y=stor_maf, fill = variable), position='stack') +
  #scale_y_continuous(breaks = seq(0,50,by=10),labels=seq(0,50,by=10)) +
  #scale_x_date(limits= c(as.Date("1995-01-01"), as.Date("2030-01-01")),
  #             date_breaks = "5 years", # Major ticks every 10 years
  #             date_labels = "%Y") +
  
  #scale_fill_manual(breaks=c(1:6),values = palBlues[2:7]) + #,labels = variable) + 
  theme_bw() +
  #coord_fixed() +
  labs(x="", y="Lake Powell Evaporation\n(MAF per year)") +
  theme(text = element_text(size=20), legend.position = "none")

