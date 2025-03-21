function [embryo] = reparamContByArcLength(embryo)
% Author: Daniel Alber
% Date: 3/19/2025
% Description: Reparameterizes embryo contours by arc length along the major axis.
%              Computes angles and arc lengths of ventral (V) points, assuming:
%              - Ventral middle is at -pi/2, dorsal middle at pi/2.
%              - Posterior pole is at 0.
%              - Position along the major axis is scaled.
%              Uses an elliptical integral for calculations.
%
% Inputs:
%   embryo - Struct containing embryo data with fields:
%       eAxes            - Ellipse axis lengths
%       eCenter          - Center coordinates of the embryo
%       contoursResampled - Resampled contour data
%       contourDVPoints   - Dorsal-ventral contour points
%
% Outputs:
%   embryo - Updated with fields:
%       vPosAPAxis - Scaled anterior-posterior positions
%       vPosDVAxis - Scaled dorsal-ventral positions
%       vAngles    - Angles of ventral points relative to the major axis
%       arcLengths - Arc lengths from ventral midline (-pi/2) to each point
%
% Usage:
%   embryo{1} = reparamContByArcLength(embryo{1});

vAngles = []; %0 at ventral midline and pi/2 at dorsal midline
arcLengths = []; %0 at ventral midline and max at dorsal midline

% Normalized ellipse axis length assumes y is long axis and ratio is b:a:b
% with a > b. For a typical 2.5:1 embryonic geometry, a=1, b=1/2.5=0.4
a = 1;
b = embryo.eAxes(3)./embryo.eAxes(2);
eccentricity = sqrt(a^2-b^2)/a;
ellipticArcLengthFun = @(x) sqrt(1-eccentricity^2*cos(x).^2);

% Sanity check: quarter-ellipse
if abs(4*integral(ellipticArcLengthFun,-pi/2,0) - pi*(a+b)) > 0.5
    disp('Something is wrong with the arc length calculation')
end
for i = 1:length(embryo.contoursResampled)
    ventraly = squeeze(embryo.contourDVPoints(2,2,:,i));
    ventraly = (ventraly - embryo.eCenter(2))./embryo.eAxes(2);
    ventralz = squeeze(embryo.contourDVPoints(2,3,:,i));
    ventralz = (ventralz - embryo.eCenter(3))./embryo.eAxes(2);
    ventralAngle = atan(ventralz ./ ventraly);
    % Make an array where positions are translated such that the max y
    % position (corresponding to going over the posterior pole) is 1
    %ventraly = ventraly ./ max(ventraly);
    vPosAPAxis(:,i) = ventraly;
    vPosDVAxis(:,i) = ventralz;

    vAngles(:,i) = ventralAngle;
    for j = 1:length(ventralAngle)
        arcLengths(j,i) = integral(ellipticArcLengthFun, -pi/2, ventralAngle(j));
    end
    % arcLengths(:,i) = arrayfun(@(upperLimit)integral(ellipticArcLengthFun,-pi/2,upperLimit),vAngles(:,i));
end
embryo.vPosAPAxis = vPosAPAxis;
embryo.vPosDVAxis = vPosDVAxis;
embryo.vAngles = vAngles;
embryo.arcLengths = arcLengths;

end