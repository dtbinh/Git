function [newPoints T] = normalizePoints(points)

% NORMALIZEPOINTS Normalize a set of 2D points
%    [NP T] = NORMALIZEPOINTS(P) normalizes the points in P so that the
%    centroid of the points is located at (0,0) and the average distance to
%    the origin is sqrt(2). NP is the set of normalized points and T is the
%    homogeneous transform used for normalizing.
%
%
%    Other m-files required: none
%    Subfunctions: none
%    MAT-files required: none
%
%    See also: EIGHTPOINT

% Author: André Augusto Geraldes
% Email: andregeraldes@lara.unb.br
% October 2013; Last revision: 02-November-2013


%% Find the centroid of the points
centroid = mean(points(:,1:2));

%% Calculate the scale factor based on the average distance of the points to the centroid
distances = sqrt((points(:,1)-centroid(1)).^2 + (points(:,2)-centroid(2)).^2);
scale = sqrt(2)/mean(distances);

%% Build the translation and scaling components of T
Tscale = [scale 0; 0 scale];
Ttranslation = -scale*centroid';

%% Build the complete T
T = [Tscale Ttranslation; 0 0 1];

%% Transform the points using T
newPoints = (T*points')';


