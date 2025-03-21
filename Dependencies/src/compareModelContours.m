function compareModelContours(embryo, mlengths, mareas, exportdir, name, timepoints, xtic, xlims, yticL, ylimsL, yticA, ylimsA, yticR, ylimsR)
% Author: Daniel Alber
% Date: 3/19/2025
% Description: Compares the embryo contour 
%              length and area changes with a model. Normalizes data 
%              by initial values and generates plots for comparison.
%
% Inputs:
%   embryo    - Cell array containing embryo data structures with fields:
%       contLengths - Matrix (contours x timepoints) of contour lengths
%       areas       - Matrix (contours x timepoints) of contour areas
%       tstep       - Time step size (for x-axis scaling)
%   mlengths  - matrix of model predicted lengths through time
%   mareas    - matrix of model predicted areas through time
%   exportdir - String specifying the directory to save output figures
%   name      - String specifying the filename suffix for saving
%   timepoints- Array of timepoints to use
%   xtic      - Array of x-axis tick values (timepoints in minutes)
%   xlims     - Array specifying x-axis limits [xmin, xmax]
%   yticL     - Array of y-axis tick values for length plot
%   ylimsL    - Array specifying y-axis limits for length plot [ymin, ymax]
%   yticA     - Array of y-axis tick values for area plot
%   ylimsA    - Array specifying y-axis limits for area plot [ymin, ymax]
%   yticR     - Array of y-axis tick values for roundness plot
%   ylimsR    - Array specifying y-axis limits for roundness plot [ymin, ymax]
%
% Usagee:
%   compareModelContours(embryo{1}, mlengths, mareas, exportdir, embryoName, modelComparisonTimepoints, ...
%    xtic, xlims, yticL, ylimsL, yticA, ylimsA, yticR, ylimsR)

modelLengths = mlengths;

modelAreas = mareas; 

normByInitLengths = embryo.contLengths ./ embryo.contLengths(:,1);
normByInitAreas = embryo.areas ./ embryo.areas(:,1);

% Length Plot
hFig = figure();
hFig.WindowState = 'normal';
nameModifier = "_" + name + "normByInitLength_ModelOnly";
hFig.Position = [50 50 200 200];
tCompRange = timepoints;
hold on
for i = 1:2:5
    plot(tCompRange.*embryo.tstep ./ 60, ...
        modelLengths(:,1+ceil(i./2)), '--', 'Color', embryo.rgb_colors(i,:));
end
xticks(xtic)
yticks(yticL)
box on
set(gcf, 'color', [1 1 1]);
ylim(ylimsL)
xlim(xlims)
print(gcf, '-dpdf', fullfile(exportdir, ...
    datestr(datetime('today'), 'yymmdd')+"_"+name+ ...
    "_RelArea"+nameModifier));

% Area Plot
nameModifier = "_" + name + "_normByInitialArea_DataOnly";
hFig = figure();
hFig.WindowState = 'normal';
hFig.Position = [50 50 200 200];
hold on
for i = 1:2:5
    plot(tCompRange.*embryo.tstep ./ 60, ...
            modelAreas(:,1+ceil(i./2)), '--', 'Color', embryo.rgb_colors(i,:));
end
xticks(xtic)
yticks(yticA)
ylim(ylimsA)
box on
set(gcf, 'color', [1 1 1]);
xlim(xlims)
print(gcf, '-dpdf', fullfile(exportdir, ...
    datestr(datetime('today'), 'yymmdd')+"_"+name+ ...
    "_RelArea"+nameModifier));
end