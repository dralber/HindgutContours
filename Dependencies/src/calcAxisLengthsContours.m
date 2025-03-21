function [embryo] = calcAxisLengthsContours(embryo)
% Author: Daniel Alber
% Date: 3/19/2025
% Description: Computes the major (dorsal-ventral) and minor (left-right) 
%              axis lengths of embryo contours over time. Uses Euclidean 
%              distance to measure distances between predefined contour points.
%
% Inputs:
%   embryo - Struct containing embryo data with fields:
%       contoursResampled - Cell array of resampled contour point sets
%       contourDVIndices  - Indices of dorsal-ventral points for each contour
%
% Outputs:
%   embryo - Updated with fields:
%       majorAxes - Matrix (contours x timepoints) of dorsal-ventral distances
%       minorAxes - Matrix (contours x timepoints) of left-right distances
%
% Dependencies:
%   eucDist
%
% Usage:
%   embryo{1} = calcAxisLengthsContours(embryo{1});

DVDists = [];
LRDists = [];

for j = 1:length(embryo.contoursResampled) %Contours
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

    for i = 1:length(currContour) %Timepoints
        DVDists(j,i) = eucDist(currContour{i}(DVIndices(1),:), ...
            currContour{i}(DVIndices(2),:));
        LRDists(j,i) = eucDist(currContour{i}(LRIndices(1),:), ...
            currContour{i}(LRIndices(2),:));
    end
end

embryo.majorAxes = DVDists;
embryo.minorAxes = LRDists;

end