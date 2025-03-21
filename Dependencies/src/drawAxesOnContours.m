function drawAxesOnContours(embryo, exportdir, name)
% Author: Daniel Alber
% Date: 3/19/2025
% Description: Visualizes and overlays major and minor axes on 3D contour plots 
%              of the embryo at different time points. Saves the resulting figures.
%
% Inputs:
%   embryo    - Struct containing embryo data with fields:
%       contoursResampled  - Cell array containing resampled contour coordinates
%       contourDVIndices   - Matrix specifying dorsal-ventral (DV) axis indices 
%                            for each contour
%       views              - Predefined 3D view settings
%       rgb_colors         - Colors assigned to each contour for plotting
%   exportdir - String specifying the directory to save output figures
%   name      - String identifier for output file names
%
% Outputs:
%   None (figures are saved as PDF files)
%
% Dependencies:
%   removeMarksFrom3DPlot
%   eucDist
%
% Usage:
%   drawAxesOnContours(embryo{1}, 'output_directory', 'experiment_name');
%
% Notes:
%   - Major (DV) and minor (LR) axes are overlaid on the contour plots.
%   - The function computes DV and LR distances for each time point.
%   - The first and last time points of each contour are displayed.
%   - Each contour visualization is saved as a separate PDF.

DVDists = [];
LRDists = [];
for j = 1:length(embryo.contoursResampled) %Contours
    hFig = figure(gcf); clf;
    hFig.WindowState = 'normal';
    hFig.Position = [50 50 200 200];
    currContour = embryo.contoursResampled{j};
    DVIndices = embryo.contourDVIndices(j,:);
    % Find left and right points, don't assume DV points bisect contour
    contPointsLength = size(currContour{1},1);
    LRIndices(1) = floor(mean(DVIndices));
    midDist = floor((min(DVIndices) + ...
        (contPointsLength - max(DVIndices)))/2);
    if max(DVIndices) + midDist > contPointsLength
        LRIndices(2) = mod(max(DVIndices) + midDist,contPointsLength);
    else
        LRIndices(2) = max(DVIndices) + midDist;
    end

    %Plotting
    removeMarksFrom3DPlot
    hold on;
    view(embryo.views)
    view([130, 26])
    axis equal;
    grid off;
    plot3(embryo.contoursResampled{j}{1}(:,1), ...
        embryo.contoursResampled{j}{1}(:,2), ...
        embryo.contoursResampled{j}{1}(:,3), ...
        'LineWidth',3,'Color', embryo.rgb_colors(j,:))
    plot3(embryo.contoursResampled{j}{end}(:,1), ...
        embryo.contoursResampled{j}{end}(:,2), ...
        embryo.contoursResampled{j}{end}(:,3), ...
        'LineWidth',3,'Color', embryo.rgb_colors(j,:))

    for i = [1,length(currContour)] %Timepoints
        DVDists(j,i) = eucDist(currContour{i}(DVIndices(1),:), ...
            currContour{i}(DVIndices(2),:));
        LRDists(j,i) = eucDist(currContour{i}(LRIndices(1),:), ...
            currContour{i}(LRIndices(2),:));

        % Major axis
        DVPoints = currContour{i}(DVIndices, :);
        plot3(DVPoints(:, 1), DVPoints(:, 2), DVPoints(:,3), '-r', 'LineWidth', 2);
        scatter3(DVPoints(:, 1), DVPoints(:, 2), DVPoints(:,3), 'k');

        % Line for LRIndices
        LRPoints = currContour{i}(LRIndices, :);
        plot3(LRPoints(:, 1), LRPoints(:, 2), LRPoints(:,3), '-b', 'LineWidth', 2);
        scatter3(LRPoints(:, 1), LRPoints(:, 2), LRPoints(:,3), 'k');
    end

    export_fig(fullfile(exportdir,datestr(datetime('today'), 'yymmdd')+ ...
        "_" + name + "_Contour" + int2str(j) + ...
        "_MajorMinorAxesShown"),'-native','-pdf')
end

end