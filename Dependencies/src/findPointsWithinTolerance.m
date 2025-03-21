function indices = findPointsWithinTolerance(x, y, n, tol, varargin)
% Author: Daniel Alber
% Date: 6/19/2024
% Description: Given x coordinates and y coordinates, will draw "n"
% horizontal lines and return indices of the points that are within "tol"
% tolerance of the line

    if ~isempty(varargin)
        yLims = varargin{1};
        if length(yLims) ~= 2
            error('yLim must be a list with two elements: [yMin, yMax]');
        end
        yMin = yLims(1);
        yMax = yLims(2);
    else
        yMin = min(y(~isinf(y)));
        yMax = max(y(~isinf(y)));
    end

    indices = cell(n, 1);

    % Calculate the y values of the lines
    %y_lines = linspace(prctile(y(~isinf(y)),20), prctile(y(~isinf(y)),95), n);
    %y_lines = linspace(min(y(~isinf(y))), max(y(~isinf(y))),n);
    y_lines = linspace(yMin, yMax,n);

    for i = 1:n
        % Calculate the distance from the points to the current line
        dist = abs(y - y_lines(i));

        indices{i} = find(dist <= tol);
    end
end
