function interpolatedArray = interpPositions(inputPositions,inTimes, outTimes)
% Linearly interpolates on inputPositions array (mxn) using given inputTimes (1xn) to
% create an output array with uniformly spaced times from min(inputTimes)
% to max(inputTimes) with spacing of 1.
% Author: Daniel Alber
% Date: 3/12/2024
% Name: 
% Typical usage: 
% Dependencies: 
% Input: inputPositions: m x n where rows are samples and n are positions
%           at each time step
%        inTimes: 1xn array of times to which timepoints correspond
%        outTimes: 1xp array of times to which positions should be
%        interpolated

% Output: 

if length(inTimes) ~= size(inputPositions,2)
    disp('Time array does not have correct dimensions')
end

% Preallocate the interpolated array
interpolatedArray = zeros(size(inputPositions, 1), length(outTimes));

% Interpolate each row of the values array
for i = 1:size(inputPositions, 1)
    interpolatedArray(i, :) = interp1(inTimes, inputPositions(i, :), outTimes);
end

end