## Overview
This repository contains MATLAB scripts and data for processing and analyzing contour shapes in embryos. The main script executes on continuous tracks of points in 3D along with their 2D mapping (here, in cylindrical coordinates). 

## Main Script
- **`pointsToContoursProcessingScript.m`**: The primary script to run the contour processing and analysis workflow.

## Processed Data Output
- **`processedEmbryoStruct.mat`**: Contains the `embryo` struct, which stores all processed data at the end of the script execution.

## Data Files
The `Data` folder includes:
- **`AreaRatioModel_InMidOut_t0t80_230418embryo_250123.csv`**: Coupled-ring model area ratios over time.
- **`LengthRatioModel_InMidOut_t0t80_230418embryo_250123.csv`**: Coupled-ring model length ratios over time.
- **`interpPointPositionsWithMapping.mat`**: Tracked positions of nuclei within the ring along with cylindrical mapping coordinates.
- **`FileList_Embryo230418.xlsx`**: Description of the light sheet imaging data used.

## Requirements
- **MATLAB 2024**
- The following MATLAB toolboxes:
  - **Statistics and Machine Learning**: Functions used: `KDTreeSearcher`, `knnsearch`
  - **Curve Fitting**: Functions used: `csaps`

## Dependencies
### Internal (`src` directory)
The following custom MATLAB functions are required:
- `calcAxisLengthsContours`
- `calcContourMetrics`
- `calcSimError`
- `calculateEnclosedArea`
- `compareModelContours`
- `constSpeedContours`
- `createSmoothCurve`
- `drawAxesOnContours`
- `drawContoursThroughTime`
- `eucDist`
- `exportDVPoints`
- `extractClosedContour`
- `findDVPoints`
- `findPointsWithinTolerance`
- `fitContours`
- `interpPositions`
- `map3DToCylindrical`
- `normByArcLength`
- `plotContAxisLengths`
- `plotContourMetrics`
- `plotContourMetricsOverPosition`
- `plotContourShapes`
- `plotDistBtwContours`
- `removeMarksFrom3DPlot`
- `reparamContByArcLength`
- `resampleContourToConstantSpeed`
- `smoothNaN`
- `smoothPointsForContour`
- `structToVars`

### External Dependencies
These external MATLAB functions are required:
- `movavg`
- `progressbar`
- `shadedErrorBar`
- `violinplot`

## Usage
1. Clone or download the repository.
2. Ensure MATLAB 2024 and required toolboxes are installed.
3. Run `pointsToContoursProcessingScript.m` to execute the full processing pipeline.

