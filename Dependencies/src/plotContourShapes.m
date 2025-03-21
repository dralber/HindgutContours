function plotContourShapes(embryo,timepoints, views, exportdir, name)
% Author: Daniel Alber
% Date: 3/19/2025
% Description: Generates 3D plots of embryo contours at specified timepoints 
%              from predefined viewpoints. Saves the figure as a PDF.
%
% Inputs:
%   embryo    - Struct containing embryo data with fields:
%       contours  - Cell array of contour point sets over time
%       rgb_colors - Colors assigned to each contour
%       xlims, ylims, zlims - Axis limits for visualization
%   timepoints - Array of time points to visualize
%   views      - Cell array of view angles for each timepoint (e.g., {[-30,30], ...})
%   exportdir  - String specifying the directory to save the figure
%   name       - String specifying the filename suffix for saving
%
% Outputs:
%   None (figure is displayed and saved)
%
% Dependencies:
%   removeMarksFrom3DPlot
%
% Usage:
%   plotContourShapes(embryo{1}, [1,5,10], {[-30,30], [0,90], [45,45]}, './exports', 'SamplePlot');

contours = embryo.contours;
hFig = figure();
hFig.WindowState = 'normal';
hFig.Position = [50 50 1924 500];
set(gcf, 'color', [1 1 1]);
t = tiledlayout('flow');
for j = 1:length(timepoints)
    tp = timepoints(j);
    nexttile
    hold on
    for i=1:length(contours)
        plot3(embryo.contours{i}{tp}(:,1), ...
            embryo.contours{i}{tp}(:,2), ...
            embryo.contours{i}{tp}(:,3), ...
            'LineWidth',3,'Color', embryo.rgb_colors(i,:))
    end
    hold off
    axis equal
    view(views{j})
    xlim(embryo.xlims);
    ylim(embryo.ylims);
    zlim(embryo.zlims);
    removeMarksFrom3DPlot
end

print(gcf, '-dpdf',fullfile(exportdir, ...
        datestr(datetime('today'), 'yymmdd')+ "_" + name + ...
        "_ContourSnapshots"));
end