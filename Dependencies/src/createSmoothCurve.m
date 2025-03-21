function smoothedCurve = createSmoothCurve(contourPointsSorted, smoothingParam, repetitions)
%  CREATESMOOTHCURVE Repeats and smooths contour points to create a closed curve.
%
%   smoothedCurve = CREATESMOOTHCURVE(contourPointsSorted, smoothingParam, repetitions)
%   generates a smooth, closed curve by repeating the contour points and applying a 
%   smoothing spline fit.
%
%   Author: Daniel Alber
%   Date: 11/5/2024
%
%   Description:
%   This function takes a set of contour points, repeats them a specified number of times 
%   to make the curve closed and continuous, and then applies a smoothing spline fit to 
%   each dimension of the contour points. The result is a smoothed, closed curve.
%
%   Inputs:
%       contourPointsSorted - NxD matrix of sorted contour points, where N is the number 
%                             of points and D is the number of dimensions (typically 2 or 3).
%       smoothingParam      - Smoothing parameter for the spline fit (recommended between 0 and 1).
%       repetitions         - Number of times to repeat the contour points for smooth closure.
%
%   Outputs:
%       smoothedCurve       - DxM matrix of the smoothed contour points, where D is the number 
%                             of dimensions, and M is the total number of smoothed points.
%
%   Usage Example:
%       % Define contour points
%       contourPointsSorted = rand(100, 3);  % Example sorted 3D contour with 100 points
%       smoothingParam = 0.01;
%       repetitions = 3;
%
%       % Generate smoothed closed curve
%       smoothedCurve = createSmoothCurve(contourPointsSorted, smoothingParam, repetitions);
%
%       % smoothedCurve will contain the points for the smoothed closed contour.
%
%   Note:
%       This function uses cubic smoothing splines via `csaps` for smoothing each dimension.

    % Repeat contour points to create a smooth closed curve
    repeatedPoints = repmat(contourPointsSorted, repetitions, 1);

    [numPoints, numDims] = size(repeatedPoints);
    smoothedCurve = zeros(numDims, numPoints);

    % Apply cubic smoothing spline to each dimension
    for dim = 1:numDims
        smoothedCurve(dim, :) = csaps(1:numPoints, repeatedPoints(:, dim)', smoothingParam, 1:numPoints);
    end
end
