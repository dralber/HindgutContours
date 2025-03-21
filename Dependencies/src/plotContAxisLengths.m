function plotContAxisLengths(embryo, exportdir, name)
% Author: Daniel Alber
% Date: 3/19/2025
% Description: Plots the major and minor axis lengths of contours over time, 
%              normalized to the initial minor axis length. Saves the plots 
%              and normalized data as CSV files.
%
% Inputs:
%   embryo    - Struct containing embryo data with fields:
%       majorAxes  - Matrix (contours x timepoints) of major axis lengths
%       minorAxes  - Matrix (contours x timepoints) of minor axis lengths
%       tstep      - Time step size (for x-axis scaling)
%       rgb_colors - Colors assigned to each contour for plotting
%   exportdir - String specifying the directory to save output files
%   name      - String identifier for the output file names
%
% Outputs:
%   figures and CSV files
%
% Usage:
%   plotContAxisLengths(embryo{1}, 'output_directory', 'experiment_name');
%
% Notes:
%   - Major and minor axes are normalized to the initial minor axis length.
%   - Two plots are generated and saved as PDFs:
%       1. Major axes over time
%       2. Minor axes over time
%   - The normalized data is saved as CSV files for further analysis.

timesteps = 1:size(embryo.majorAxes,2);
normMajor = embryo.majorAxes ./ embryo.minorAxes(:,1);
normMinor = embryo.minorAxes ./ embryo.minorAxes(:,1);
t = tiledlayout('flow');
nexttile
hold on
title("Major Axes (normalized to initial minor axis)")
xlabel("Time (min)")
for j = 1:size(normMajor,1)
    plot(timesteps.*embryo.tstep ./ 60,normMajor(j,:), ...
        "Color",embryo.rgb_colors(j,:),'LineWidth',3)
end
nexttile
hold on
title("Minor Axes (normalized to initial minor axis)")
xlabel("Time (min")
for j = 1:size(normMajor,1)
    plot(timesteps.*embryo.tstep ./ 60,normMinor(j,:), ...
        "Color",embryo.rgb_colors(j,:),'LineWidth',3)
end
print(gcf, '-dpdf',fullfile(exportdir, ...
    datestr(datetime('today'), 'yymmdd')+ ...
    "MajorMinorAxesLengths_"+name));
writematrix(normMajor,fullfile(exportdir,...
    datestr(datetime('today'), 'yymmdd')+ "_" + name...
    + "_NormalizedMajorAxisLength_notProjected.csv"))
writematrix(normMinor,fullfile(exportdir,...
    datestr(datetime('today'), 'yymmdd')+"_" + name + ...
    "_NormalizedMinorAxisLength_notProjected.csv"))

end