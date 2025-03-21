%   Author: Daniel Alber
%   Date: 3/5/2024
%
%   Description: Script to run contour analysis for "A model for
%   boundary-driven morphogenesis." Comments contain new fields added by
%   the corresponding line of code. 
%
%   Dependencies:
%       calcAxisLengthsContours
%       calcContourMetrics
%       calcSimError
%       calculateEnclosedArea
%       compareModelContours
%       constSpeedContours
%       createSmoothCurve
%       drawAxesOnContours
%       drawContoursThroughTime
%       eucDist
%       exportDVPoints
%       extractClosedContour
%       findDVPoints
%       findPointsWithinTolerance
%       fitContours
%       frames2movie
%       interpPositions
%       map3DToCylindrical
%       normByArcLength
%       plotContAxisLengths
%       plotContourMetrics
%       plotContourMetricsOverPosition
%       plotContourShapes
%       plotDistBtwContours
%       removeMarksFrom3DPlot
%       reparamContByArcLength
%       resampleContourToConstantSpeed
%       smoothNaN
%       smoothPointsForContour
%       structToVars
%
%   Dependencies written by others (see headers for source):
%       shadedErrorBar
%       violinplot 
%       movavg
%       progressbar
%
%   Toolboxes:
%       Statistics and Machine Learning
%           KDTreeSearcher
%           knnsearch
%       Curve Fitting
%           csaps

%% User-set parameters
exportdir = "Output";
dependencyPath = "Dependencies";
dataPath = fullfile("Data","interpPointPositionsWithMapping.mat"); %Contains filtered/gap-filled x,y,z post-interpolation and mapped coordinates of the first timepoint
tstep = 8.86; %seconds
colors = ["#FCB03C","#F07229", "#BE1E2D", "#6B2D5D", "#322F6B"]';
embryoName = "Embryo230418";
% Manually fit ellipsoid from Fiji 
ellipsoidCenter = [94,130,-86];
ellipsoidAxes = [92.5, 2.5*92.5, 92.5];
modelLengthsFilepath = fullfile("Data","AreaRatioModel_InMidOut_t0t80_230418embryo_250123.csv");
modelAreasFilepath = fullfile("Data","LengthRatioModel_InMidOut_t0t80_230418embryo_250123.csv");
modelComparisonTimepoints = 1:81; %Compare first stage: 80 timepoints
%% Smoothing and filtering
addpath(genpath(dependencyPath))
load(dataPath);
[smoothX,smoothY,smoothZ] = smoothPointsForContour(interpX,interpY,interpZ);
smoothX = rmmissing(smoothX,1);
smoothY = rmmissing(smoothY,1);
smoothZ = rmmissing(smoothZ,1);

%% Packaging
embryo = struct();
embryo.zs = zs(:,1);
embryo.thetas = thetas(:,1);
embryo.smoothXAll = smoothX;
embryo.smoothYAll = smoothY;
embryo.smoothZAll = -smoothZ;
embryo.xlims = [min(embryo.smoothXAll,[],"all"), max(embryo.smoothXAll,[],"all")];
embryo.ylims = [min(embryo.smoothYAll,[],"all"), max(embryo.smoothYAll,[],"all")];
embryo.zlims = [min(embryo.smoothZAll,[],"all"), max(embryo.smoothZAll,[],"all")];
embryo.views = [168 31];
embryo.tstep = tstep; %seconds
embryo.rgb_colors = hex2RGB(colors);
embryo.eCenter = ellipsoidCenter;
embryo.eAxes = ellipsoidAxes;
em = embryo;
clear("embryo")
embryo{1} = em;

%% Fit contours
embryo{1} = fitContours(embryo{1}, 5, 0.1, [-0.25, 0.38], exportdir, ...
    'plotPoints', true, 'plotContours', true, ...
    'saveMovie', true,'name',embryoName); %contours, contourIndices

%% Calculate metrics of contours
% Resample to equidistant knots (constant-speed)
embryo{1} = constSpeedContours(embryo{1},500); %contoursResampled
% Find dorsalmost and ventralmost points on contours
embryo{1} = findDVPoints(embryo{1}); %contourDVPoints, contourDVIndices, relEucDists
% Calculate length, area, and roundness
embryo{1} = calcContourMetrics(embryo{1}); %contLengths, relContLengths, areas, areasNorm, roundness, roundnessNorm
% Calculate distance between neighboring contours
embryo{1} = calcDistBtwContours(embryo{1}); %meanDistBtwContours, errDistBtwContours
% Calculate major/minor axis lengths of contours
embryo{1} = calcAxisLengthsContours(embryo{1}); %majorAxes, minorAxes

%% Calculate error bars - takes a long time, about a second per iteration
%1e3 iterations, returns meanSimCir, meanSimAr, meanSimRo, 
% stdSimCir, stdSimAr, stdSimRo, normStdSimCir, normStdSimAr, normStdSimRo
embryo{1} = calcSimError(embryo{1}, exportdir, embryoName, 1e3); 

%% Reparameterizing by arc length
exportDVPoints(embryo{1},exportdir,embryoName);
embryo{1} = reparamContByArcLength(embryo{1}); %vPosAPAxis, vPosDVAxis, vAngles, arcLengths

% refTimePoints is nx1 array of timepoints at which the ventralmost point 
%   of the contour is at the reference position. Use embryo{1}.vPosAPaxis to find
%   where the position of the ventralmost point is equal to the reference,
%   which is the position of contour 1's ventralmost point at t=1 here.
refTimepoints = [1,31,28,40,69];
embryo{1} = normByArcLength(embryo{1}, refTimepoints); %contLengthsAL, areasNormAL, roundnessAL, stdSimCirAL, stdSimArAL, stdSimRoAL

% Now, contLengthsAL, areasNormAL, and roundnessAL are normalized by their
%   values when they are at their reference timepoints, selected above as the 
%   timepoint at which their ventralmost point reaches a reference position
%   (here, the initial position of the innermost/posteriormost contour's 
%   ventralmost point). relContLengths, areasNorm, and roundnessNorm are 
%   normalized by their values when they are at the initial timepoint. 

%% Draw contours at selected timepoints
timepoints = [1 50 100 120 134];
views = repmat({embryo{1}.views},1,5);
plotContourShapes(embryo{1}, timepoints, views, exportdir, embryoName)
%% Plot contour metrics over time
xtic = 0:2:20; % Time tics (minutes)
xlims = [0, 20]; % Time limits (minutes)
yticL = 0.8:0.2:1.2; % Length ticks
ylimsL = [0.7, 1.2]; % Length limts
yticA = 0.6:0.4:1.4; % Area ticks
ylimsA = [0.4, 1.4]; % Area limits
yticR = 0.6:0.2:1;   % Roundness ticks
ylimsR = [0.6, 1.1]; % Roundness limits
plotContourMetrics(embryo{1}, exportdir, embryoName, ...
    xtic, xlims, yticL, ylimsL, yticA, ylimsA, yticR, ylimsR)
%% Plot contour metrics over position on embryo
xtic = -0.2:0.1:0.1; % Arc-length tics
xlims = [-0.2, 0.1]; % Arc-length limits
xOffset = 1.15; % Distance to pole (an x-translation in plotting)
plotContourMetricsOverPosition(embryo{1}, exportdir, embryoName, xOffset, ...
    xtic, xlims, yticL, ylimsL, yticA, ylimsA, yticR, ylimsR)
%% Plot distance between contours over time
plotDistBtwContours(embryo{1}, exportdir, embryoName)

%% Plot major/minor axis lengths over time
% Will export .csv files of normalized axis lengths over time and a figure
plotContAxisLengths(embryo{1}, exportdir, embryoName)

%% Draw major/minor axes on contours through time
drawAxesOnContours(embryo{1}, exportdir, embryoName)

%% Plot coupled-ring model metrics
xtic = 0:2:20; % Time tics (minutes)
xlims = [0, 12]; % Time limits (minutes)
yticL = 0.8:0.2:1.2; % Length ticks
ylimsL = [0.7, 1.2]; % Length limts
yticA = 0.6:0.4:1.4; % Area ticks
ylimsA = [0.4, 1.4]; % Area limits
yticR = 0.6:0.2:1;   % Roundness ticks
ylimsR = [0.6, 1.1]; % Roundness limits
mlengths = readmatrix(modelLengthsFilepath);
mareas = readmatrix(modelAreasFilepath);

compareModelContours(embryo{1}, mlengths, mareas, exportdir, embryoName, modelComparisonTimepoints, ...
    xtic, xlims, yticL, ylimsL, yticA, ylimsA, yticR, ylimsR)
%% Draw a contour through time colored by length and area
% Note: these are normalized by their initial timepoint, not by the value
% at a given reference timepoint
colorScale = [1.5, 1.5]; %scaling, lower compresses color space more
timepoints = 1:10:size(embryo{1}.areas,2);
drawContoursThroughTime(embryo{1}, exportdir, embryoName, colorScale, timepoints)

