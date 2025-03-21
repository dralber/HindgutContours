function plotDistBtwContours(embryo, exportdir, name)
% Author: Daniel Alber
% Date: 3/19/2025
% Description: Plots the distance between middle-outer and middle-inner 
%               contours over time. 
%
% Inputs:
%   embryo - Struct containing embryo data with fields:
%       meanDistBtwContours - Matrix (contours x timepoints) of mean distances 
%                             between successive contours
%       tstep               - Time step size (for x-axis scaling)
%       rgb_colors          - Colors assigned to each contour for plotting
%   exportdir - String specifying the directory to save the plots
%   name      - String specifying the filename suffix for saving
%
% Outputs:
%   None (a figure is displayed showing distance trends)
%
% Usage:
%   plotDistBtwContours(embryo);
%
% Notes:
%   - The function plots the sum of distances between the first two 
%     and middle two contours to highlight spatial changes over time.
%   - Time is converted to minutes using tstep.


figure()
timesteps = 1:1:size(embryo.meanDistBtwContours,2);
hold on
plot(timesteps.*embryo.tstep ./ 60, sum(embryo.meanDistBtwContours(1:2,:)),'color',embryo.rgb_colors(1,:))
plot(timesteps.*embryo.tstep ./ 60, sum(embryo.meanDistBtwContours(2:4,:)),'color',embryo.rgb_colors(end,:))
box on
title('Distance between edge and middle contours over time')
print(gcf, '-dpdf',fullfile(exportdir, ...
    datestr(datetime('today'), 'yymmdd')+ ...
    "distbtwcontours_"+name));
end