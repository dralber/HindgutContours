function [embryo] = calcContourMetrics(embryo)
% Author: Daniel Alber
% Date: 3/19/2025
% Description: Calculates length, area, curvature, and roundness
%
% Inputs:
%   embryo   - Struct containing embryo data with contoursResampled and
%              DVIndices
%
% Outputs:
%   embryo - Updated with fields:
%            contLengths    - nxt array of circumference of each contour through time
%            relContLengths - contLengths normalized by initial timepoint
%            areas          - nxt array of areas of each contour through
%                             time
%            areasNorm      - areas normalized by initial timepoint
%            roundness      - area divided by length^2
%            roundnessNorm  - roundness divided by initial timepoint
%
% Dependencies:
%   progressbar
%   calculateEnclosedArea
%
% Usage:
%   embryo{1} = calcContourMetrics(embryo{1});

%Calculate total arc length for each contour at each timepoint
contLengths = [];
relContLengths = [];
for i = 1:length(embryo.contoursResampled) %for each contour
    hold on
    currContour = embryo.contoursResampled{i};
    t = 1:1:length(currContour);

    for j = 1:length(currContour)
        contLengths(i,j) = max(cumsum(sqrt(sum(diff(currContour{j}).^2, 2))));
        relContLengths(i,j) = contLengths(i,j)./contLengths(i,1);
    end
end
embryo.relContLengths = relContLengths;
embryo.contLengths = contLengths;

% Areas
progressbar
iteration = 0;
areas = []; % contours x timepoints
for i = 1:length(embryo.contoursResampled)
    currContour = embryo.contoursResampled{i};
    for j = 1:length(currContour)
        iteration = iteration + 1;
        progressbar(iteration/(length(embryo.contoursResampled)*length(currContour)))
        currPoints = currContour{j};
        areaRiemann = calculateEnclosedArea(currPoints,embryo.contourDVIndices(i,1));
        areas(i,j) = areaRiemann;
    end
end
areasNorm = areas ./ areas(:,1);
embryo.areas = areas;
embryo.areasNorm = areasNorm;

% Roundness

embryo.roundness = areas ./ contLengths.^2;
embryo.roundnessNorm = embryo.roundness ./ embryo.roundness(:,1);

end