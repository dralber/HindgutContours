function [embryo] = findDVPoints(embryo)
% Author: Daniel Alber
% Date: 3/19/2025
% Description: Identifies the dorsalmost and ventralmost points at the
%              initial timepoint for each contour and stores their indices, positions,
%              and euclidean distance between the D and V points at each timepoint
%
% Inputs: embryo - struct containing contoursResampled
% Outputs: embryo updated with:
%                contourDVPoints - 2x3xtxn array of dorsal, ventral x 3 dim
%                                  x timepoints x contour positions of points
%                contourDVIndices - 2xn array of indices of D and V points
%                relEucDists - txn array of euc dist between D and V point
% Dependencies:
%   - eucDist
% Usage:
%   embryo{1} = findDVPoints(embryo{1});
%
%
contourDVPoints = []; %dorsal, ventral x 3 dimensions x timepoints x contour
contourDVIndices = [];
eucDists = []; %timepoints x contours
for i = 1:length(embryo.contoursResampled)
    currContour = embryo.contoursResampled{i};
    contVIndex = find(currContour{1}(:,3)==min(currContour{1}(:,3)));
    contDIndex = find(currContour{1}(:,3)==max(currContour{1}(:,3)));
    contourDVIndices(i,:) = [contDIndex,contVIndex];
    for j = 1:length(currContour)
        currContourPoints = currContour{j};
        %scatter3(currContourPoints(:,1),currContourPoints(:,2),currContourPoints(:,3))
        contourDVPoints(2,:,j,i) = currContourPoints(contVIndex,:);
        contourDVPoints(1,:,j,i) = currContourPoints(contDIndex,:);
        eucDists(j,i) = eucDist(contourDVPoints(1,:,j,i), contourDVPoints(2,:,j,i));
    end
end
relEucDists = eucDists./eucDists(1,:);
embryo.contourDVPoints = contourDVPoints;
embryo.contourDVIndices = contourDVIndices;
embryo.relEucDists = relEucDists;
end