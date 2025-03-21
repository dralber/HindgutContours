function vPosAPAxis = exportDVPoints(embryo, exportdir,name)
% Author: Daniel Alber
% Date: 3/19/2025
% Description: Extracts and normalizes dorsal-ventral (DV) contour positions along
%              the major axis of the embryo and exports them as CSV files.
%              Saves CSV files containing scaled DV positions.
%
% Inputs:
%   embryo    - Cell array of embryo structures containing contour data.
%   exportdir - Directory where output CSV files will be saved.
%   name      - String to include in file name
%
% Outputs:
%   vPosAPAxis - Matrix containing ventral Y positions normalized by the embryo's
%                major axis length.
%
% Usage:
%   vPosAPAxis = exportDVPoints(embryo, 'C:\export\directory\');

vPosAPAxis = [];

for i = 1:length(embryo.contoursResampled)
    dorsaly = squeeze(embryo.contourDVPoints(1,2,:,i));
    ventraly = squeeze(embryo.contourDVPoints(2,2,:,i));

    % Normalize by the ellipsoid center and axes
    dorsaly = (dorsaly - embryo.eCenter(2)) ./ embryo.eAxes(2);
    ventraly = (ventraly - embryo.eCenter(2)) ./ embryo.eAxes(2);

    % Create time-scaled contour data
    contourScaledDVPos = [(0:embryo.tstep:embryo.tstep*(length(dorsaly)-1))', ...
        dorsaly, ventraly];

    writematrix(contourScaledDVPos,fullfile(exportdir,...
        datestr(datetime('today'), 'yymmdd')+"_Embryo" + ...
        name + "Contour" + int2str(i) + ...
        "_DVPointsAlongMajorAxis.csv"))
    vPosAPAxis(:,i) = ventraly;
end
end
