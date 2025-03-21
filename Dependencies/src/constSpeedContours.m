function [embryo] = constSpeedContours(embryo, numPoints)
% Author: Daniel Alber
% Date: 3/19/2025
% Description: Resamples contours to generate knots that are equidistant
%              from each other (i.e. constant-speed)
%
% Inputs:
%   embryo   - Struct containing embryo data with 'contours' field
%   numPoints- Number of points to resample to (number of knots)
%
% Outputs:
%   embryo - Updated with "contoursResampled" field
%            contoursResampled - 1xt cell array containing (numPoints+2)x3 
%                                positions of new knots now equidistant
%                                from each other
%
% Dependencies:
%   resampleContourToConstantSpeed
%
% Usage:
%   embryo{1} = constSpeedContours(embryo{1},500);
contours = embryo.contours;
contoursResampled = {};
for i = 1:length(contours)
    for j = 1:length(contours{i})
        contPoints = contours{i}{j};
        resampled_points = resampleContourToConstantSpeed(contPoints,numPoints);
        contoursResampled{i}{j} = resampled_points;
    end
end
embryo.contoursResampled = contoursResampled;

end