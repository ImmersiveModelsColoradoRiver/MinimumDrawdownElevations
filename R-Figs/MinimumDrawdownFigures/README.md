# Historical and Current Colorado River Reservoir Data

This R script downloads from the U.S. Bureau of Reclamation and plots historical and current reservoir data such as inflows, storage, releases, evaporation, etc.

We use data download and aggregate functions in the subfolder **AutoReadUSBRData**.

## Explanation of Contents
1. **HistoricalCurrentReservoirData.R** - R script that reads in raw Lake Powell and Lake Mead Reservoir data and makes plots such as of inflows, storage, release, evaporation, etc.
2. **HistoricalCurrentReservoirData.Rmd** - R markdown script that performs the same tasks as the .R file but additionally 
outputs all plots to the pdf file **HistoricalCurrentReservoirData.pdf**
3. **HistoricalCurrentReservoirData.pdf** - Pdf file with the output plots created when the markdown file **HistoricalCurrentReservoirData.Rmd** is run.
4. **LakeMeadStorageICS.R** - R script that reads in Lake Mead storage data from Reclamation's data portal, Lake Mead Water Conservation (Intentionally Created Surplus) Program file from an Excel file, and makes plots of 1) Water Conservation Account balances over time, deposits and withdraws over time, 
and a plot of Lake Mead storage over time additionally showing the anticipated Lake Mead elevation if the water conservation program did not exist.
5. **LakeMeadStorageICS.Rmd** - R markdown script that performs the same tasks as the .R file but additionally 
outputs all plots to the pdf file **LakeMeadStorageICS**
6. **LakeMeadStorageICS.pdf** - Pdf file with the output plots created when the markdown file **LakeMeadStorageICS** is run.

All of the files use a script with functions in the folder **AutoReadUSBRData** that auto download reservoir data from Reclamation's data portal
and aggregate that data at the appropriate time spacing to prepare for plotting. See the README.md file in that folder for further explanation of its contents and features.

## Directions to Reproduce Results

1. Download and install R and RStudio. See https://rstudio-education.github.io/hopr/starting.html for a tutorial.
2. In your file explorer, open the subfolder (**HistoricalCurrentReservoirData**). Open the file **HistoricalCurrentReservoirData.Rproj**. R studio will open.
3. Select the file tab **HistoricalCurrentReservoirData.Rmd**.
4. Click the **Knit** button (row below the file tabs)
5. R studio will run the blocks of code and markdown and generate the **HistoricalCurrentReservoirData.pdf** file.
6. Alternatively in step 3, select the file tab **HistoricalCurrentReservoirData.r**
7. Select all the code in the file (ctrl-A) and click **Run** (row below the file tabs).
8. R studio will run the code, generate the figures, and store the figures as .png files in the same directory.
9  Repeat stepts #3 to #8 for the corresponding **LakeMeadStorageICS.R** and **LakeMeadStorageICS.Rmd** to generate results for the Lake Mead Water Conservation (Intentionally Created Surplus) program data in the file **LakeMeadStorageICS.pdf**.

## Recommended Citation
David E. Rosenberg (2020). "Historical and Current Colorado River Reservoir Data". Utah State University. Logan, Utah. https://github.com/dzeke/ColoradoRiverCollaborate/tree/main/HistoricalCurrentReservoirData
