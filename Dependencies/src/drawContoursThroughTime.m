function drawContoursThroughTime(embryo, exportdir, name, colorScale, timepoints)
% Author: Daniel Alber
% Date: 3/19/2025
% Description: Visualizes 3D contours of the embryo at different time points, 
%              overlaying them with color-coded changes in contour length and area. 
%              Saves the figures and corresponding colormaps.
%
% Inputs:
%   embryo    - Struct containing embryo data with fields:
%       contoursResampled  - Cell array of resampled contour coordinates
%       contours           - Cell array of original contour coordinates
%       contourDVIndices   - Matrix specifying dorsal-ventral (DV) axis indices
%                            for each contour
%       ylims              - Y-axis limits for consistent visualization
%       rgb_colors         - Colors assigned to each contour for plotting
%       contLengths        - Matrix (contours x timepoints) of contour lengths
%       areas              - Matrix (contours x timepoints) of contour areas
%   exportdir - String specifying the directory to save output figures
%   name      - String identifier for output file names
%   colorScale - 2-element vector controlling color scaling for length/area changes
%   timepoints - Array specifying which time points to visualize
%
% Outputs:
%   None (figures and colormaps are saved as PDF files)
%
% Dependencies:
%   removeMarksFrom3DPlot
%
% Usage:
%   drawContoursThroughTime(embryo{1}, 'output_directory', 'experiment_name', [1.5, 1.5], [1, 10, 20]);
%
% Notes:
%   - Contours are plotted at specified time points, color-coded based on 
%     their normalized length or area changes.
%   - Two sets of visualizations are generated:
%       1. Contours colored based on normalized length changes
%       2. Contours colored based on normalized area changes
%   - A separate colorbar legend is generated and saved for each contour.

normByInitLengths = embryo.contLengths ./ embryo.contLengths(:,1);
normByInitAreas = embryo.areas ./ embryo.areas(:,1);
for k = 1:2
    if k == 1
        metric = "Length";
    else
        metric = "Area";
    end
    for i = 1:size(normByInitAreas,1)
        hFig = figure(gcf); clf;
        hFig.WindowState = 'normal';
        hFig.Position = [50 50 1000 1000];
        set(gcf, 'color', [1 1 1]);
        hold on
        for j = 1:length(timepoints)
            tp = timepoints(j);

            if k == 1
                minValue = min(normByInitLengths(i,:));
                maxValue = max(normByInitLengths(i,:));
                value = normByInitLengths(i, tp);
            else
                minValue = min(normByInitAreas(i,:));
                maxValue = max(normByInitAreas(i,:));
                value = normByInitAreas(i, tp);
            end

            % Compute the color based on the value
            if value < 1
                % Blend with white to make it lighter
                weight = (1 - value) / ((1 - minValue) * colorScale(1));
                line_color = (1 - weight) * embryo.rgb_colors(i, :) + weight * [0, 0, 0];
            else
                % Blend with black to make it darker
                if value == 1
                    line_color = embryo.rgb_colors(i,:);
                else
                    weight = (value - 1) / ((maxValue - 1) * colorScale(2));
                    line_color = (1 - weight) * embryo.rgb_colors(i, :) + weight * [1, 1, 1];
                end
            end

            plot3(embryo.contours{i}{tp}(:,1), ...
                embryo.contours{i}{tp}(:,2), ...
                embryo.contours{i}{tp}(:,3), ...
                'LineWidth', 3, 'Color', line_color);
        end

        hold off
        axis equal
        view([105 11])
        removeMarksFrom3DPlot
        ylim(embryo.ylims + [-10, 5])
        export_fig(fullfile(exportdir, ...
            datestr(datetime('today'), 'yymmdd')+"_" + name + ...
            "_Contour" + int2str(i) + metric + "ThroughTimeNoEmbryo"),'-native','-transparent','-pdf')

        % Create a figure and display the colormap
        % Colorbar
        % Define a fine grid of values for color interpolation
        values = linspace(minValue, maxValue, 1000);

        % Preallocate for the colormap
        colormapColors = zeros(length(values), 3);

        % Generate the colormap
        for idx = 1:length(values)
            value = values(idx);
            if value < 1
                % Blend with white to make it lighter
                weight = (1 - value) / ((1 - minValue) * colorScale(1));
                colormapColors(idx, :) = (1-weight) * embryo.rgb_colors(i, :) + (weight) * [0,0,0];
            else
                % Blend with black to make it darker
                weight = (value - 1) / ((maxValue - 1) * colorScale(2));
                colormapColors(idx, :) = (1-weight) * embryo.rgb_colors(i, :) + (weight) * [1, 1, 1];
            end
        end

        figure(gcf); clf;
        colormap(colormapColors);
        colorbarHandle = colorbar;

        % Label the colorbar
        caxis([minValue, maxValue]);
        colorbarHandle.Label.String = 'Value';
        if maxValue==1
            colorbarHandle.Ticks = [minValue, 1]; % Customize ticks as needed
            colorbarHandle.TickLabels = {num2str(minValue), '1'};
        else
            colorbarHandle.Ticks = [minValue, 1, maxValue]; % Customize ticks as needed
            colorbarHandle.TickLabels = {num2str(minValue), '1', num2str(maxValue)};
        end
        axis off

        export_fig(fullfile(exportdir, ...
            datestr(datetime('today'), 'yymmdd')+"_" + name + ...
            "Contour" + int2str(i) + metric + "ThroughTimeColorbar"),'-native','-transparent','-pdf')
    end
end
end


