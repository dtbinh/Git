function edges = edgeRoberts(image, threshold)

% EDGEROBERTS Detect edges using the Roberts methods
%    edges = edgeRoberts(image, threshold) applies the Roberts method for
%    edge detection. Use the threshold to distinguish between strong and
%    weak edges.
%
%
%  Other m-files required: gaussianFilter.m, iconv.m
%  Subfunctions: none
%  MAT-files required: none
%
% See also: EDGEPREWITT, EDGESOBEL

% Author: André Augusto Geraldes
% Email: andregeraldes@lara.unb.br
% September 2013; Last revision: 28-September-2013

% Smooth the image before start detecting edges
filteredImage = gaussianFilter(image, 0.5, 5);

% Generate the 2x2 Roberts matrices
robertsX = [1 -1; -1 1];
robertsY = [0 1; -1 0];

% Calculate the image gradient
rx = iconv(filteredImage, robertsX,'same');
ry = iconv(filteredImage, robertsY,'same');
gradient = sqrt(rx.^2 + ry.^2);

% Identify edges by thresholding the image gradient
edges = logical(zeros(size(gradient)));
edges(gradient > threshold * max(max(gradient))) = 1;