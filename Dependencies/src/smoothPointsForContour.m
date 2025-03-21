function [smoothX, smoothY, smoothZ] = smoothPointsForContour(interpX,interpY,interpZ)
%   Author: Daniel Alber
%   Date: 3/5/2024
%
%   Description:
%       This function smooths input position data for 
%       contour processing using an exponential moving average.
%
%   Inputs:
%       interpX    - (n x 3) matrix of X position data
%       interpY    - (n x 3) matrix of Y position data
%       interpZ    - (n x 3) matrix of Z position data
%
%   Outputs:
%       smoothX - (m x 3) matrix of smoothed X position data after interpolation and filtering
%       smoothY - (m x 3) matrix of smoothed Y position data after interpolation and filtering
%       smoothZ - (m x 3) matrix of smoothed Z position data after interpolation and filtering
%
%   Dependencies:
%       movavg.m           - Function for computing an exponential moving average
%       smoothNaN.m        - Function for handling NaN values in smoothed data
%

%Smoothing: exponential moving average on manually tracked data. 
windowSize = 10;
smoothX = (movavg(interpX','exponential',windowSize))';
smoothY = (movavg(interpY','exponential',windowSize))';
smoothZ = (movavg(interpZ','exponential',windowSize))';

%Fix partial NaN rows
smoothX = smoothNaN(smoothX,interpX,'exponential',windowSize);
smoothY = smoothNaN(smoothY, interpY, 'exponential', windowSize);
smoothZ = smoothNaN(smoothZ, interpZ, 'exponential', windowSize);
end