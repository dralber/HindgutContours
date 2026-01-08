function [embryo] = calcDistBtwContours(embryo)
% Author: Daniel Alber
% Date: 3/19/2025
% Description: Calculates the distance between neighboring contours 
%              over time. Uses a k-d tree search to determine the closest 
%              points between successive contours. Stores mean and standard 
%              deviations of distances at each time point for each contour.
%
% Inputs:
%   embryo - Struct containing embryo data with fields:
%       contoursResampled - Cell array of resampled contour point sets 
%
% Outputs:
%   embryo - Updated with fields:
%       meanDistBtwContours - Matrix (contours x timepoints) of mean distances 
%                             between successive contours
%       errDistBtwContours  - Matrix (contours x timepoints) of standard 
%                             deviations of distances between contours
%
% Dependencies:
%   KDTreeSearcher (Statistics and Machine Learning Toolbox)
%   knnsearch (Statistics and Machine Learning Toolbox)
%
% Usage:
%   embryo = calcDistBtwContours(embryo);
contoursResampled = embryo.contoursResampled;
distBtwContours = cell(1, length(contoursResampled));

for i = 1:length(contoursResampled) - 1
    distBtwContours{i} = cell(1, 135);

    for t = 1:length(contoursResampled{i})
        % Get the points for the current and next contour at the current timepoint
        points1 = contoursResampled{i}{t};
        points2 = contoursResampled{i+1}{t};

        % Find the closest point on the next contour for each point in the current contour
        kdTree = KDTreeSearcher(points2);
        min_distances = zeros(size(points1, 1), 1);

        for p1 = 1:size(points1, 1)
            [~, dist] = knnsearch(kdTree, points1(p1, :));
            min_distances(p1) = dist;
        end

        distBtwContours{i}{t} = min_distances;
    end
end

% Handle the last contour separately (no next contour to compare)
distBtwContours{end} = cell(1, 135);
for t = 1:length(contoursResampled{end})
    distBtwContours{end}{t} = zeros(size(contoursResampled{end}{t}, 1), 1);
end

meanDistBtwContours = zeros(length(contoursResampled),length(contoursResampled{1})); %contours x timepoints
errDistBtwContours = zeros(length(contoursResampled),length(contoursResampled{1})); %contours x timepoints

for i = 1:length(distBtwContours)
    currContour = distBtwContours{i};
    for j = 1:length(currContour)
        meanDistBtwContours(i,j) = mean(currContour{j});
        errDistBtwContours(i,j) = std(currContour{j});
    end
end
embryo.meanDistBtwContours = meanDistBtwContours;
embryo.errDistBtwContours = errDistBtwContours;

end