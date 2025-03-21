function [z,theta,rho] = map3DToCylindrical(X,Y,Z)
%   Author: Daniel Alber
%   Date: 3/5/2024
%
%   Description:
%       This function converts 3D Cartesian coordinates (X, Y, Z) into cylindrical 
%       coordinates (z, theta, rho). The transformation is performed relative to a 
%       principal component eigenspace, which is determined based on the first 
%       time point. Adjustments are made to theta and z to align anatomical landmarks.
%
%   Inputs:
%       X - (n x t) matrix of X coordinates over time
%       Y - (n x t) matrix of Y coordinates over time
%       Z - (n x t) matrix of Z coordinates over time
%           where n is the number of tracked points, and t is the number of time frames.
%
%   Outputs:
%       z     - (n x t) matrix of height/axial values in cylindrical coordinates
%       theta - (n x t) matrix of angular positions (radians) in cylindrical coordinates
%       rho   - (n x t) matrix of radial distances in cylindrical coordinates

eigPoints = [];
thetas = zeros(size(X)); rhos = thetas; zs = thetas;
firstFramePoints = [X(:,1)'; Y(:,1)'; Z(:,1)']';
%Normalize points
firstFramePointsNorm = (firstFramePoints - mean(firstFramePoints));
firstFramePointsNorm = firstFramePointsNorm./max(abs(firstFramePointsNorm),[],'all');

%First timepoint defines eigenspace
corrmat = cov(firstFramePointsNorm);
[eigV, eigD] = eig(corrmat);
[~, ind] = sort(diag(eigD),'descend');
eigD = eigD(ind,ind);
eigV = eigV(:,ind);
    
eigPoints(:,:,1) = (firstFramePointsNorm * eigV);
    
%Convert to cylindrical coordinates, 
[theta, rho, z] = cart2pol(eigPoints(:,1,1), eigPoints(:,2,1), eigPoints(:,3,1));
thetas(:,1) = theta;
rhos(:,1) = rho;
zs(:,1) = z;
end