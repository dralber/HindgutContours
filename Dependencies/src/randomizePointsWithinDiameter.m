function [randX,randY,randZ] = randomizePointsWithinDiameter(diameter,xPoints, yPoints, zPoints, iterations)
% RANDOMIZEPOINTSWITHINDIAMETER Generates random point displacements within a spherical volume.
%
%   [randX, randY, randZ] = RANDOMIZEPOINTSWITHINDIAMETER(diameter, xPoints, yPoints, zPoints, iterations)
%   computes randomized 3D positions around the input coordinates within a spherical region of specified diameter.
%
%   Author: Daniel Alber
%   Date: 11/5/2024
%
%   Description:
%   This function generates new random positions for each input point 
%   (xPoints, yPoints, zPoints) within a spherical volume defined by the 
%   given `diameter` by assuming a uniform distribution
%   of possible points within the sphere.
%
%   Inputs:
%       diameter   - Maximum diameter of the spherical region around each point.
%       xPoints    - Array of x-coordinates of initial points, either 1D or 2D.
%       yPoints    - Array of y-coordinates of initial points, either 1D or 2D.
%       zPoints    - Array of z-coordinates of initial points, either 1D or 2D.
%       iterations - (Optional) Number of random points to generate for each input point. Default is 1000.
%
%   Outputs:
%       randX      - Array of randomized x-coordinates for each input point, with `iterations` random points per original point.
%       randY      - Array of randomized y-coordinates, matching the shape of `xPoints`.
%       randZ      - Array of randomized z-coordinates, matching the shape of `xPoints`.
%
%   Usage Example:
%       % Define parameters
%       diameter = 10;
%       xPoints = [1, 2; 3, 4];
%       yPoints = [5, 6; 7, 8];
%       zPoints = [9, 10; 11, 12];
%       iterations = 500;
%
%       % Generate randomized points
%       [randX, randY, randZ] = randomizePointsWithinDiameter(diameter, xPoints, yPoints, zPoints, iterations);
%
%       % randX, randY, randZ will contain 500 randomized points for each input point,
%       % matching the shape of xPoints, yPoints, and zPoints.
%
%   Note:
%       Assumes that `diameter` defines the maximum spherical diameter around each point.

if isempty(iterations)
    iterations = 1e3;
end

%Linearize if 2D
xMeans = xPoints(:); 
yMeans = yPoints(:); 
zMeans = zPoints(:); 
points = [xMeans, yMeans, zMeans];

% Random directions, [-1,1] for each element
directions = -1 + 2 * rand(size(xMeans,1), 3, iterations);
directions = directions ./ vecnorm(directions, 2, 2);

% Random distances, scaled to max distance of nucDiam
distances = rand(size(xMeans,1), 1, iterations) .* diameter;

dispVecs = directions .* distances;
randPoints = points + dispVecs;

randX = squeeze(randPoints(:, 1, :));
randY = squeeze(randPoints(:, 2, :));
randZ = squeeze(randPoints(:, 3, :));

if ismatrix(xPoints)
    [rows, cols] = size(xPoints); 
    randX = reshape(randX, rows, cols, iterations);
    randY = reshape(randY, rows, cols, iterations);
    randZ = reshape(randZ, rows, cols, iterations);
end

end