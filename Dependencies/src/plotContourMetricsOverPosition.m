function plotContourMetricsOverPosition(embryo, exportdir, ...
    name, xOffset, xtic, xlims, yticL, ylimsL, yticA, ylimsA, yticR, ylimsR)
% Author: Daniel Alber
% Date: 3/19/2025
% Description: Plots and saves graphs of relative length, area, and roundness 
%              changes over arc-length position for each contour in the embryo dataset.
%              Normalized by their values when they are at the reference position on the
%              embryo.
%
% Inputs:
%   embryo    - Struct containing embryo data with fields:
%       contours      - Cell array of contour points over time
%       arcLengths    - t x n array of arc-length position of ventralmost
%                       point on contour over time
%       contLengthsAL - Matrix of relative contour lengths
%       areasAL       - Matrix of relative contour areas
%       roundnessAL   - Matrix of relative contour roundness values
%       stdSimCirAL   - Standard deviations for contour length
%       stdSimArAL    - Standard deviations for contour area
%       stdSimRoAL    - Standard deviations for contour roundness
%       tstep         - Time step size (for x-axis scaling)
%       rgb_colors    - Colors assigned to each contour for plotting
%   exportdir - String specifying the directory to save the plots
%   name      - String specifying the filename suffix for saving
%   xOffset   - Integer indicating 0-position of arc-length (x translation)
%   xtic      - Array of x-axis tick values (timepoints in minutes)
%   xlims     - Array specifying x-axis limits [xmin, xmax]
%   yticL     - Array of y-axis tick values for length plot
%   ylimsL    - Array specifying y-axis limits for length plot [ymin, ymax]
%   yticA     - Array of y-axis tick values for area plot
%   ylimsA    - Array specifying y-axis limits for area plot [ymin, ymax]
%   yticR     - Array of y-axis tick values for roundness plot
%   ylimsR    - Array specifying y-axis limits for roundness plot [ymin, ymax]
%
% Outputs:
%   None (figures are displayed and saved as PDFs)
%
% Dependencies:
%   shadedErrorBar - from Matlab file exchange
%
% Usage:
%   plotContourMetrics(embryo{1}, './exports', 'SamplePlot', ...
%                      0:10:100, [0 100], 0:0.2:2, [0 2], ...
%                      0:0.2:2, [0 2], 0:0.2:2, [0 2]);

hFig = figure();
hFig.WindowState = 'normal';
hFig.Position = [50 50 500 200];
hold on
for i = 1:length(embryo.contours)
    shadedErrorBar(embryo.arcLengths(:,i) - xOffset, ... 
        embryo.contLengthsAL(i,:), ...
        embryo.stdSimCirAL(i,:),...
        'lineprops',{'Color',embryo.rgb_colors(i,:)});
end

plot([-1e3,1e3],[1 1],'k--')
title("Relative length change over time for each contour")
xlabel('Time (Minutes)')
xticks(xtic)
yticks(yticL)
ylabel('Relative length change')
box on
set(gcf, 'color', [1 1 1]);
ylim(ylimsL)
xlim(xlims)

print(gcf, '-dpdf',fullfile(exportdir, ...
    datestr(datetime('today'), 'yymmdd')+ ...
    "RelLength_arcLength_"+name));

hFig = figure(gcf); clf;
hFig.WindowState = 'normal';
hFig.Position = [50 50 500 200];
hold on
for i = 1:length(embryo.contours)
    shadedErrorBar(embryo.arcLengths(:,i) - xOffset, ...
        embryo.areasAL(i,:), ...
        embryo.stdSimArAL(i,:),...
        'lineprops',{'Color',embryo.rgb_colors(i,:)});
end
plot([-1e3,1e3],[1 1],'k--')
title("Relative area change over time for each contour")
xlabel('Time (Minutes)')
xticks(xtic)
yticks(yticA)
ylim(ylimsA)
ylabel('Relative area change')
box on
set(gcf, 'color', [1 1 1]);
xlim(xlims)
print(gcf, '-dpdf',fullfile(exportdir, ...
    datestr(datetime('today'), 'yymmdd')+ ...
    "RelArea_arcLength_"+name));

hFig = figure(gcf); clf;
hFig.WindowState = 'normal';
hFig.Position = [50 50 500 200];
hold on
for i = 1:length(embryo.contours)
    shadedErrorBar(embryo.arcLengths(:,i) - xOffset, ...
        embryo.roundnessAL(i,:), ...
        embryo.stdSimRoAL(i,:),...
        'lineprops',{'Color',embryo.rgb_colors(i,:)});
end
plot([-1e3,1e3],[1 1],'k--')
title("Relative roundness change over time for each contour")
xlabel('Time (Minutes)')
xticks(xtic)
yticks(yticR)
ylim(ylimsR)
ylabel('Relative roundness change')
box on
set(gcf, 'color', [1 1 1]);
xlim(xlims)

print(gcf, '-dpdf',fullfile(exportdir, ...
    datestr(datetime('today'), 'yymmdd')+ ...
    "RelRoundness_arcLength_"+name));

end