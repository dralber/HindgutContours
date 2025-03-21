function closedContour = extractClosedContour(fit3, tolerance)
% EXTRACTCLOSEDCONTOUR Extracts a closed contour from a 3D spline.
%
%   closedContour = EXTRACTCLOSEDCONTOUR(fit3, tolerance) extracts a closed
%   contour from the middle of the input 3D spline by moving outwards from
%   the midpoint until it reaches the starting point within the specified tolerance.
%
%   Author: Daniel Alber
%   Date: 3/18/2025
%
%   Description:
%   This function takes a 3D spline (fit3) and finds a closed contour by iterating
%   from the center point of the spline outward until reaching a starting point 
%   within the specified tolerance. The result is a single contour with a doubled 
%   first point to ensure a closed curve.
%
%   Inputs:
%       fit3      - 3xN matrix representing the 3D spline coordinates.
%       tolerance - Tolerance value for stopping when returning to the initial point.
%
%   Outputs:
%       closedContour - 3xM matrix of the extracted closed contour, where M ≤ N.
%                       The first point is repeated at the end to form a closed loop.
%
%   Usage Example:
%       % Define input spline
%       fit3 = rand(3, 100);  % Example 3D spline with 100 points
%       tolerance = 5;
%
%       % Extract closed contour
%       closedContour = extractClosedContour(fit3, tolerance);
%
%       % closedContour will contain the points for the closed contour from fit3.
%
%   Note:
%       The function assumes that fit3 is a continuous 3D spline. The input tolerance 
%       defines the Euclidean distance within which the contour will be considered closed.

    initPoint = fit3(:, round(end/2));  % Starting point at the midpoint of fit3
    startInd = round(size(fit3, 2) / 2 - 1);  % Starting index moving backward
    tol = inf;

    % Move backward from midpoint to find start of closed contour
    while tol > tolerance
        tol = eucDist(fit3(:, startInd - 2)', initPoint');
        startInd = startInd - 1;
    end

    % Reset tolerance and move forward to find end of closed contour
    stopInd = round(size(fit3, 2) / 2 + 1);
    while tol > tolerance
        tol = eucDist(fit3(:, stopInd + 2)', initPoint');
        stopInd = stopInd + 1;
    end

    closedContour = fit3(:, startInd:stopInd);
    closedContour(:, end + 1) = closedContour(:, 1);

end
