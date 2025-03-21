function [embryo] = normByArcLength(embryo, refTimepoints)
% Author: [Your Name]
% Date: 3/19/2025
% Description: Normalizes contour length, area, and roundness by arc length.
%              Uses reference time points where the ventralmost point of
%              the contour is at the reference position. Normalization
%              is performed relative to the values at these reference points.
%
% Inputs:
%   embryo        - Struct containing embryo data with fields:
%       relContLengths - Relative contour lengths over time
%       areasNorm      - Normalized areas over time
%       roundness      - Roundness values over time
%       vPosAPAxis     - Anterior-posterior positions of ventralmost points
%       stdSimCir      - Std. dev. of simulated circumferences over time
%       stdSimAr       - Std. dev. of simulated areas over time
%       stdSimRo       - Std. dev. of simulated roundnesses over time
%   refTimepoints - nx1 array of time points where the ventralmost
%                   point of the contour is at the reference position
%
% Outputs:
%   embryo - Updated with fields:
%       contLengthsAL - Contour lengths normalized by value at reference position
%       areasAL      - Areas normalized by reference position
%       roundnessAL      - Roundness normalized by reference position
%       stdSimCirAL  - Std. dev. of circumference normalized by reference position
%       stdSimArAL  - " for area "
%       stdSimRoAL  - " for roundness "
%
% Usage:
%   embryo{1} = normByArcALength(embryo{1}, [1,31,28,40,69]);

embryo.contLengthsAL = embryo.contLengths ./ diag(embryo.contLengths(:,refTimepoints));
embryo.areasAL = embryo.areas ./ diag(embryo.areas(:,refTimepoints));
embryo.roundnessAL = embryo.roundness ./ diag(embryo.roundness(:,refTimepoints));
embryo.stdSimCirAL = embryo.stdSimCir ./ diag(embryo.contLengths(:,refTimepoints));
embryo.stdSimArAL = embryo.stdSimAr ./ diag(embryo.areas(:,refTimepoints));
embryo.stdSimRoAL = embryo.stdSimRo ./ diag(embryo.roundness(:,refTimepoints));


end