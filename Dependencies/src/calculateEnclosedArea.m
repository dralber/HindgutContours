function areaRiemann = calculateEnclosedArea(currPoints, contourDIndex)
% CALCULATEENCLOSEDAREA Calculates the enclosed area of a bilateral contour.
%
%   areaRiemann = CALCULATEENCLOSEDAREA(currPoints, contourDVIndex) computes the 
%   enclosed area between points on a contour by summing the lengths of perpendicular 
%   lines between pairs of mirrored points across the contour's midpoint.
%
%   Author: Daniel Alber
%   Date: 11/5/2024
%
%   Description:
%   This function shifts calculates the area enclosed by a 3D closed space
%   curve using a set point that should be on the midline (dorsalmost point)
%   and selecting pairs of points on either side to be endpoints of a Riemann
%   sum. For each point pair across the midpoint, it calculates the length between the pair
%   and the perpendicular distance between the lines formed by adjacent pairs, ultimately
%   computing a Riemann sum approximation of the enclosed area.
%
%   Inputs:
%       currPoints     - Nx3 matrix representing the coordinates of contour points, where 
%                        N is the number of points and 3 represents the (x, y, z) coordinates.
%       contourDIndex - Index of a L/R midpoint, typically the dorsalmost
%                       point
%       
%   Outputs:
%       areaRiemann    - Scalar value representing the approximated enclosed area based 
%                        on the specified contour points.
%
%   Usage Example:
%       % Define contour points and DV index
%       currPoints = rand(100, 3);  % Example 3D contour with 100 points
%       contourDVIndex = 25;  % Index to align the contour
%
%       % Calculate the enclosed area
%       areaRiemann = calculateEnclosedArea(currPoints, contourDVIndex);
%
%   Note:
%       This function assumes that `eucDist` (Euclidean distance function) is defined 
%       elsewhere in the code base or within MATLAB's library.

    % Shift points to start from the specified dorsalmost point (ideally on
    % the VF midline)
    currPoints = circshift(currPoints, -contourDIndex, 1);

    % Find midpoint of the contour and initialize arrays for line lengths and distances
    midpoint = floor(size(currPoints, 1) / 2);
    currLineLengths = zeros(midpoint, 1);
    currDistBtwLines = zeros(midpoint - 1, 1);

    % Calculate the length of the initial line segment across the midpoint
    currLineLengths(1) = eucDist(currPoints(midpoint + 1, :), currPoints(midpoint - 1, :));

    for k = 2:midpoint - 1
        % Calculate line length between mirrored points
        currLineLengths(k) = eucDist(currPoints(midpoint + k, :), currPoints(midpoint - k, :));
        
        % Calculate perpendicular distance to line segment formed by adjacent points
        point = currPoints(midpoint + k, :);
        linePoint1 = currPoints(midpoint + k - 1, :);
        linePoint2 = currPoints(midpoint - k + 1, :);

        % Perpendicular distance
        lineVec = linePoint2 - linePoint1;
        pointVec = point - linePoint1;
        lineVecNorm = lineVec / norm(lineVec);
        projLength = dot(pointVec, lineVecNorm);
        projVec = projLength * lineVecNorm;
        distVec = pointVec - projVec;
        currDistBtwLines(k - 1) = norm(distVec);
    end
    areaRiemann = sum(currLineLengths(1:end-1) .* currDistBtwLines);

end
