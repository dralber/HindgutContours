function [embryo] = fitContours(embryo, n, tol, ylims, exportdir, varargin)
% Author: Daniel Alber
% Date: 3/15/2025
% Description: Bins 2D points and assigns them to a contour. Fits contours
%              using 'csaps' which update at each timepoint. Constructs
%              plots of the mapping, binning, and a movie of contours
%              moving through time. Exports an updated structure with
%              contours and contour indices (indices of thetas, zs which
%              belong to each contour).
%
% Inputs:
%   embryo   - Struct containing embryo data (fields: thetas, zs, views, xlims, ylims, zlims, rgb_colors)
%   n        - Number of bins for contour processing
%   tol      - Tolerance value for contour extraction
%   exportdir- Export directory
%   ylims    - 2x1 array of limits on y (usually cylindrical axial
%              coordinate) to use to bin nuclei
%   varargin - Optional arguments (toggles):
%              'plotPoints', true/false - Plot scatter points
%              'plotContours', true/false    - Plot fitted contours
%              'saveMovie'   - Save a movie of contour fitting
%              'name'        - String to include in output filenames
%
% Outputs:
%   embryo - Updated with "contours" and "contourIndices" fields
%            contours       - 1xn cell array containing (n+1)x3 positions of knots at
%                             each timepoint
%            contourIndices - nx1 cell array containing indices of
%                             thetas/zs that belong to each contour
%
% Dependencies:
%   - findPointsWithinTolerance
%   - createSmoothCurve
%   - extractClosedContour
%   - removeMarksFrom3DPlot
%   - csaps from Curve Fitting Toolbox
%
% Usage:
%   embryo{1} = fitContours(embryo{1}, 5, 0.1, [-0.25, 0.38], exportdir, 'plotPoints', true, 'plotContours', true, 'saveMovie', true, 'name', "Embryo 1")
%

p = inputParser;
p.addParameter('plotPoints', false, @islogical);
p.addParameter('plotContours', false, @islogical);
p.addParameter('saveMovie', false, @islogical);
p.addParameter('name', "", @isstring);
p.parse(varargin{:});
opts = p.Results;

xTri = embryo.thetas;
yTri = embryo.zs;
contourIndices = findPointsWithinTolerance(xTri, yTri, n, tol, ylims);

if opts.plotPoints || opts.plotContours
    hFig = figure();
    hFig.WindowState = 'normal';
    hFig.Position = [50 50 1924 500];
    set(gcf, 'color', [1 1 1]);
    t = tiledlayout(1,3);
end

if opts.plotPoints
    %2D mapping
    nexttile(1)
    scatter(xTri, yTri, 'k.')
    title("2D Mapping")
    hold on
    box on
    xticks(-pi:pi:pi)
    xticklabels(["-\pi","0","\pi"]);
    yticks([min(yTri),mean([min(yTri), max(yTri)]),max(yTri)])
    yticklabels(["Posterior", "Midline", "Anterior"])
    ax=gca;
    ax.FontSize = 14;
    xlabel('\theta', 'FontSize', 14);
    ylabel('Width', 'FontSize', 14);
    %3D initial positions colored by bin
    nexttile(2)
    scatter3(embryo.smoothXAll(:,1), embryo.smoothYAll(:,1), ...
        embryo.smoothZAll(:,1), 'k.')
    title("Initial Positions")
    axis equal
    hold on
    view(embryo.views)
    % 3D final position colored by bin
    nexttile(3)
    scatter3(embryo.smoothXAll(end,1), embryo.smoothYAll(end,1), ...
        embryo.smoothZAll(end,1), 'k.')
    title("Final Positions")
    axis equal
    hold on
    view(embryo.views)
end

if opts.plotContours
    for i = 1:length(contourIndices)
        nexttile(1)
        scatter(xTri(contourIndices{i}), yTri(contourIndices{i}),'filled', ...
            'MarkerFaceColor',embryo.rgb_colors(i,:,:))
        nexttile(2)
        scatter3(embryo.smoothXAll(contourIndices{i},1), ...
            embryo.smoothYAll(contourIndices{i},1), ...
            embryo.smoothZAll(contourIndices{i},1), ...
            'filled', 'MarkerFaceColor',embryo.rgb_colors(i,:,:))
        removeMarksFrom3DPlot
        axis equal
        nexttile(3)
        scatter3(embryo.smoothXAll(contourIndices{i},end), ...
            embryo.smoothYAll(contourIndices{i},end), ...
            embryo.smoothZAll(contourIndices{i},end), ...
            'filled', 'MarkerFaceColor',embryo.rgb_colors(i,:,:))
        removeMarksFrom3DPlot
        axis equal
    end

    print(gcf, '-dpdf',fullfile(exportdir, ...
        datestr(datetime('today'), 'yymmdd')+ "_" + opts.name + ...
        "_MappedContourPoints"));
end

if opts.saveMovie
    hFig = figure();
    hFig.WindowState = 'normal';
    hFig.Position = [50 50 800 800];
    movieframes = {};
end

% Fitting contours
contours = {};
for j = 1:size(embryo.smoothXAll, 2)
    if opts.saveMovie
        figure(gcf); clf;
        hold on
    end

    for i = 1:length(contourIndices) %for each contour
        currIndices = contourIndices{i};
        [~, order] = sort(xTri(currIndices));
        contourPoints = [embryo.smoothXAll(currIndices,j), ...
            embryo.smoothYAll(currIndices,j), ...
            embryo.smoothZAll(currIndices,j)];
        contourPointsSorted = contourPoints(order,:);
        fit3 = createSmoothCurve(contourPointsSorted, 0.01, 3);
        tolerance = 5; %tolerance for closing the contour
        fit3 = extractClosedContour(fit3, tolerance);

        if opts.saveMovie
            if opts.plotPoints
                scatter3(contourPointsSorted(:,1), ...
                    contourPointsSorted(:,2), ...
                    contourPointsSorted(:,3), ...
                    8,'filled', 'MarkerFaceColor', embryo.rgb_colors(i,:))
                hold on
            end
            if opts.plotContours
                plot3(fit3(1,:), fit3(2,:), fit3(3,:), 'LineWidth', 4,...
                    'Color', embryo.rgb_colors(i,:))
            end
            axis equal
            view(embryo.views)
            xlim(embryo.xlims);
            ylim(embryo.ylims);
            zlim(embryo.zlims);
            removeMarksFrom3DPlot
            set(gcf, 'color', [1 1 1])
            movieframes{j} = getframe(gcf);
        end
        contours{i}{j} = fit3';
    end
end

if opts.saveMovie
    frames2movie(movieframes,fullfile(exportdir, ...
        datestr(datetime('today'), 'yymmdd')+ "_" + opts.name + ...
        "_ContoursNoPoints.mp4"),24);
end

embryo.contours = contours;
embryo.contourIndices = contourIndices;

end
