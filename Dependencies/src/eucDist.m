function [distances] = eucDist(centroid1, centroid2)
% Author: Daniel Alber
% Date: 9/20/2023
% Name: eucDist(centroid1, centroid2)
%
% Input: 
%   centroid1: m x n where m is samples and n is dimensions (e.g. m x 3 for
%       3D)
%   centroid2: m x n array of other centroids to compare
%
% Output:
%   distances: m x 1 array of euclidean distances

radicand = 0;
for dim=1:size(centroid1,2)
    radicand = radicand + (centroid2(:,dim) - centroid1(:,dim)).^2;
end
distances = sqrt(radicand);

end