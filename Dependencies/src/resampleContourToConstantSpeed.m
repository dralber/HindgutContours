function resampledPoints = resampleContourToConstantSpeed(contPoints, numPoints)
% RESAMPLECONTOURTOCONSTANTSPEED Resamples contour points to create equally spaced points along a curve.
%
%   resampledPoints = RESAMPLECONTOURTOCONSTANTSPEED(contPoints, numPoints) generates a specified 
%   number of equally spaced points along a contour and appends the first few points to close the loop, 
%   creating a smooth closed contour.
%
%   Author: Daniel Alber
%   Date: 11/5/2024
%
%   Description:
%   This function takes a set of contour points, calculates cumulative distances along the curve, 
%   and interpolates points at equal intervals along the curve using a cubic spline interpolation. 
%   The function then appends the first two points to the end to ensure a closed loop.
%
%   Inputs:
%       contPoints - NxD matrix of contour points, where N is the number of points and D is the 
%                    number of dimensions (typically 2 or 3).
%       numPoints  - Number of equally spaced points to generate along the contour.
%
%   Outputs:
%       resampledPoints - MxD matrix of the resampled points, where M = numPoints + 2, including 
%                         two appended points to ensure a closed loop.
%
%   Usage Example:
%       % Define contour points
%       contPoints = rand(100, 3);  % Example 3D contour with 100 points
%       numPoints = 50;  % Number of equally spaced points to generate
%
%       % Generate resampled contour points with constant spacing
%       resampledPoints = resampleContourToConstantSpeed(contPoints, numPoints);
%
%       % resampledPoints will contain 52 points, with the first two points repeated at the end
%       % to form a closed loop.
%
%   Note:
%       Ensure that contPoints represents a continuous contour. This function uses cubic spline 
%       interpolation for generating resampled points.

    % Calculate cumulative distance along the curve
    cumulative_dist = [0; cumsum(sqrt(sum(diff(contPoints).^2, 2)))];

    % Create a cubic spline interpolation function based on cumulative distances
    curve_interpolation = @(t) interp1(cumulative_dist, contPoints, t, 'spline');

    % Generate equally spaced points
    equal_dist_points = linspace(0, cumulative_dist(end), numPoints)';

    % Resample the curve at these points
    resampledPoints = curve_interpolation(equal_dist_points);

    % Close the loop
    resampledPoints = [resampledPoints; resampledPoints(2:3, :)];

end
