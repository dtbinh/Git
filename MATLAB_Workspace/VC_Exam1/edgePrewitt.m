function edges = edgePrewitt(image, threshold)

% EDGEPREWITT Detect edges using the Prewitt methods
%    edges = edgePrewitt(image, threshold) applies the Prewitt method for
%    edge detection. Use the threshold to distinguish between strong and
%    weak edges.
%
%
%  Other m-files required: gaussianFilter.m, iconv.m
%  Subfunctions: none
%  MAT-files required: none
%
% See also: EDGEROBERTS, EDGESOBEL

% Author: André Augusto Geraldes
% Email: andregeraldes@lara.unb.br
% September 2013; Last revision: 28-September-2013

% Smooth the image before start detecting edges
filteredImage = gaussianFilter(image, 0.5, 5);

% Generate the 3x3 Prewitt matrices
prewittX = [-1 0 1; -1 0 1; -1 0 1];
prewittY = prewittX';

% Calculate the image gradient
px = iconv(filteredImage, prewittX,'same');
py = iconv(filteredImage, prewittY,'same');
gradient = sqrt(px.^2 + py.^2);

% Identify edges by thresholding the image gradient
edges = logical(zeros(size(gradient)));
edges(gradient > threshold * max(max(gradient))) = 1;