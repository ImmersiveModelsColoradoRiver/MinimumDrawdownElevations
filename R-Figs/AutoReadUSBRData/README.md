# Auto-Read USBR Data from the HydroData Web protal

This script provides 3 functions that automate the process to load common Colorado River resservoir and supporting data for analyses used in
in other folders in the repository.

1. **fReadReclamationHydroData()** - Auto reads USBR Lake Powell and Lake Mead storage, elevation, inflow, evaporation, etc. data from Reclamation's HydroData Web portal
 https://www.usbr.gov/uc/water/hydrodata/reservoir_data/site_map.html. The function returns data frames at the daily, monthly, and annual timesteps. See full documentation below.
1. **ReadBathymetryCritialElevations()** - Loads Bathymetry data for:
    A. Lake Powell from Bradley, D., and Collins, K. (2022). "Lake Powell 2017 Area and Capacity Tables." ENV-2021-98, Reclamation. https://doi.org/10.5066/P9O3IPG3.
		See also the folder **LakePowellNewBathymetry** for the digitized data.
    B. Lake Mead from the Lake Mead object in the Colorado River System Simulation (CRSS) model. Bathymetry data for Lake Powell is taken from 

	The function also loads critical elevations for the two reservoirs from the Excel file **ReservoirElevationDefinitions.xlsx**.
   This file contains selected elevations for the two reservoirs such as dead pool, hydropower penstock intakes, protection elevations, etc. The script calculates corresponding storage volumes for each elevation.
   
1. **fReadICSDataLoads()** - Load Lake Mead Water Conservation Program Data (Account balances) from digitized
versions of Reclamation's annual water accounting reports for the Lower Colorado River Basin. The digitized data is
collated in the Excel file **IntentionallyCreatedSurplus-Summary.xlsx**. The data are from: USBR. (2026). "Boulder Canyon Operations Office - Program and Activities: Water Accounting Reports." U.S. Bureau of Reclamation. https://www.usbr.gov/lc/region/g4000/wtracct.html.

## More about fReadReclamationHydroData() - 

This function auto reads USBR Reservoir data from Reclamation's HydroData Web portal
https://www.usbr.gov/uc/water/hydrodata/reservoir_data/site_map.html

The script auto reads all available data fields for reservoirs specified in the Excel file **USBRWebPortalMetaData.xlsx**.

At present, this data is:
- Lake Powell (919) and field (code)
  - Storage - 17
  - Evaporation - 25
  - Inflow - 29
  - Inflow volume - 30
  - Unregulated inflow - 33
  - Unregulated inflow volume - 34
  - Total Release - 42
  - Release volume - 43
  - Area - 89
  - Pool elevation - 49
- Lake Mead (921)
  - Storage - 17
  - Total Release - 42
  - Pool elevation - 49
  - Release volume - 43

The auto read URL command is:
  'https://www.usbr.gov/uc/water/hydrodata/reservoir_data/RESID/csv/FIELDID.csv'

The function takes the arguement FromHydroData (Boolean)

If FromHydroData == TRUE, the script downloads the latest data from the webportal.

The function outputs 3 data frames that aggregate data at three different time stpes:

1. **dfResDataAnnual** - Annual by Water Year
1. **dfResDataMonthly** - Monthly
1. **dfResDataDaily** - Daily

The 3 data frames are also written to 3 csv files in the same working directory.

1. **dfResDataAnnual.csv** - The annual data by Water 
1. **dfResDataMonthly.csv** - Monthly
1. **dfResDataDaily.csv** - Daily

If FromHydroData == FALSE, the script reads in csv files created from the most recent run of the function.

## Use of the function
Include the commands at the top of your script so R knows the correct relative paths for the function with respect to the code you are running.

`library(here)`

`here::i_am("PATH/RCODEFILENAME.R")`

Reference the function in the script

`source("../AutoReadUSBRData/AutoReadUSBRData.r")`

**Read the most recently saved csv files**

`lResData <- fReadReclamationHydroData(FromHydroData = FALSE)`

**Downloaded the data from HydroData**

`lResData <- fReadReclamationHydroData(FromHydroData = TRUE)`

## Explanation of Contents
1. **AutoReadUSBRData.r** - The R script with the 3 functions.
1. **USBRWebPortalMetaData.xlsx** - Excel file with the reservoir and field codes to use in the download function **fReadReclamationHydroData()**.
1. **dfResDataAnnual.csv** - Data aggregated to Water Year in comma seperated values (CSV) form.
1. **dfResDataMonthly.csv** - Data aggregated to Monthly in comma seperated values (CSV) form.
1. **dfResDataDaily.csv** - Daily Data in comma seperated values (CSV) form.
1. **IntentionallyCreatedSurplus-Summary.xlsx**. Excel file containing Mead Water Conservation Program Data (Account balances) from digitized
versions of Reclamation's annual water accounting reports for the Lower Colorado River Basin. Used in the function **fReadICSDataLoads()**
1. **Bathymetry.xlsx** - Excel file with the reservoir bathmytry - elevation, storage, area -- data for Lake Powell and Lake Mead. Used by the function **ReadBathymetryCritialElevations()**.
1. **ReservoirElevationsDefinitions.xlsx** - The Excel file with critical elevations for Lake Powell and Lake Mead such as dead pool, hydropower penstock intakes, protection elevations, etc. The script calculates corresponding storage volumes for each elevation. Used by the function **ReadBathymetryCritialElevations()**.
 
## Recommended Citation

David E. Rosenberg (2026). "Auto-Read Reservoir Data from Reclamation HydroData Portal". Utah State University. Logan, Utah. https://github.com/dzeke/ColoradoRiverCollaborate/tree/main/AutoReadUSBRData.
