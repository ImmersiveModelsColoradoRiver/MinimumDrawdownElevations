# MinimumDrawdownFigsR.r
#
# This script harvests Daily, Monthly, and Annual Lake Powell and Lake Mead data
# from the Reclamation data portal and plots in support of the paper Why communicating minimum drawdown elevations ....

# David E. Rosenberg
# October 29, 2026
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

here::i_am("MinimumDrawdownFigures/MinimumDrawdownFigsR.r")
        
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



###########################
## Figure 1. Lake Powell storage/elevation over time in reference to catastrophic elevations
##########################

# Filter the Powell and Mead monthly storages
dfResDataMonthly <- lResData$dfResMonthly
#Filter the Powell and Mead storages
dfResStorage <- dfResDataMonthly %>% filter(ResName %in% c("Lake Powell", "Lake Mead"), FieldName == "Storage")
#Turn narrow into wide so separate columns for Lake Powell and Lake Mead
dfResStorageWide <- pivot_wider(  dfResStorage %>% group_by(ResName, Date, Year, Month) %>% select(ResName, Date, Year, Month, MonthlyValue),   names_from = ResName,   values_from = MonthlyValue)
#Filter to data after 1995
dfResStorageWide1995 <- dfResStorageWide %>% filter(Year >= 1995)


# Calculate volumes from current storage to elevations 3,525, 3,500, and 3490
dfPowellElevations <- dfTemp$dfPowellElevations
dfPowellElevations$CurrentStorage <- dfResElevations %>% filter(FieldName == "Storage", ResName == "Lake Powell") %>% pull(Value) / 1e6
dfPowellElevations$StorageAbove <- dfPowellElevations$CurrentStorage - dfPowellElevations$ActiveStorageMAF
dfPowellElevations$StorageAboveLabel <- paste0(round(dfPowellElevations$StorageAbove, digits = 2), " maf above elev. ", format(dfPowellElevations$`Elevation (feet)`,scientific = FALSE, big.mark = ",", trim = TRUE))

# Create a second data frame with only the consequential rows
dfPowellElevationsConsequence <- dfPowellElevations %>% filter(!is.na(Consequence))

#Recalculate the Label
dfPowellElevationsConsequence$Label <- paste0(dfPowellElevationsConsequence$`Elevation (feet)`, " - ", dfPowellElevationsConsequence$Consequence)


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

### Make the plot
ggplot() +

  geom_line(data = dfResStorageWide, aes(x = DateAsDate, y = `Lake Powell`), size = 1.5) +
  
  geom_text(aes(x = as.Date("2026-01-01"), y = 16.5, label = cCurrent), fontface = "bold", color = "blue") + 
  geom_text(aes(x = as.Date("2026-01-01"), y = 13, label = cPowellElevationsConcat), color = pReds[7]) +
    
    scale_x_date(limits= c(as.Date("1995-01-01"), as.Date("2030-01-01")),
               date_breaks = "5 years", # Major ticks every 10 years
               date_labels = "%Y") +
  
  #Create secondary y axes for Powell Lake Level
   scale_y_continuous(limits = c(0,25), breaks = dfPowellElevationsConsequence$ActiveStorageMAF,labels=round(dfPowellElevationsConsequence$ActiveStorageMAF, digits = 1), sec.axis = sec_axis(~. +0, name = "Powell Elevation (feet) and Consequences", breaks = dfPowellElevationsConsequence$ActiveStorageMAF , labels = dfPowellElevationsConsequence$Label)) +
  
  geom_hline(yintercept = dfPowellElevationsConsequence$ActiveStorageMAF, color = pBlues[5], linetype = "dashed") +
  theme_bw() +
  
  geom_point(data = dfLastDate, aes(x = DateAsDate, y = `Lake Powell`), color = "blue", size = 4 ) +
  
  
  labs(x="", y="Powell Active Storage (MAF)") +
  theme(text = element_text(size=14), legend.position = "none",
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank())

 

###############################
## Figure 2. Lake Mead storage/elevation over time vs catastrophic elevations
###############################

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


######################################
### Figure 4. Lake Powell elevations with buffer and catastrophic elevations
######################################

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


### Figure 4 - Powell history back to 2025 and y axis cut at 3,575 feet

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



##############
### Figure AA. Daily Powell Inflow/Release for current year
#################

dfResDataDaily$DateAsDate <- ymd(dfResDataDaily$Date)

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


########################
#  Figure BB. Powell, Mead, and Combined storage plot
########################


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
