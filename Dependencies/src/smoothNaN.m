function smoothedArray = smoothNaN(smoothedArray, interpArray, smoothingMethod, windowSize)
% Function Name: smoothNaN
% Author: Daniel Alber
% Date: 3/22/2024
%
% Description:
%   This function takes as input two arrays, smoothedArray and interpArray, 
%   along with a smoothing format and windowSize and modifies smoothedArray 
%   by replacing sequences of non-NaN values with smoothed values from 
%   interpArray. Partial NaN rows of interpArray usually cause full rows
%   of NaN after movavg(). It does not change NaN to 0 or nearest-neighbor but rather
%   shortens the length of the sequence to the largest non-NaN sequence and
%   runs movavg() on it.
%
% Inputs:
%   smoothedArray: A numeric array that may contain NaN values. This array 
%                  is modified in-place by the function.
%   interpArray: A numeric array of the same size as smoothedArray. This 
%                array is used to provide replacement values for NaN values 
%                in smoothedArray.
%   smoothingMethod: A char array for movavg smoothing method.
%   windowSize: An integer for windowSize for movavg.
%
% Outputs:
%   smoothedArray: The modified version of the input smoothedArray, with 
%                  sequences of NaN values replaced by smoothed values from 
%                  interpArray.
%
% Usage:
%   smoothedArray = smoothNaN(smoothedArray, interpArray,'exponential',10);
%
% Note:
%   This function uses the movavg function from the Financial Toolbox to 
%   perform the smoothing.

    [nRows, ~] = size(smoothedArray);

    for i = 1:nRows
        nanIndices = find(isnan(smoothedArray(i,:)));

        if isempty(nanIndices)
            continue;
        end

        nonNaNIndices = find(~isnan(interpArray(i,:)));

        if isempty(nonNaNIndices)
            continue;
        end

        % Find the largest consecutive sequence of non-NaN values
        diffIndices = diff(nonNaNIndices);
        breaks = find(diffIndices > 1);
        if isempty(breaks)
            % If all NaN values are consecutive, use all of them
            sequenceIndices = nonNaNIndices;
        else
            % If there are breaks in the sequence, find the largest one
            sequenceLengths = [breaks(1), diff(breaks), numel(nanIndices) - breaks(end)];
            [~, maxIdx] = max(sequenceLengths);
            if maxIdx == 1
                sequenceIndices = nonNaNIndices(1:breaks(1));
            else
                sequenceIndices = nonNaNIndices((breaks(maxIdx-1)+1):breaks(maxIdx));
            end
        end

        tempRow = interpArray(i, sequenceIndices);

        % Check that there are enough values to apply smoothing
        if length(tempRow) > windowSize
            tempRowSmoothed = movavg(tempRow',smoothingMethod,windowSize);
    
            smoothedArray(i, sequenceIndices) = tempRowSmoothed';
        end
    end
end
