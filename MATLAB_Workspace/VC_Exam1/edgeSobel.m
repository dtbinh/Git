function edges = edgeSobel(image, threshold)

% EDGESOBEL Detect edges using the Sobel methods
%    edges = edgeSobel(image, threshold) applies the Sobel method for
%    edge detection. Use the threshold to distinguish between strong and
%    weak edges.
%
%
%  Other m-files required: gaussianFilter.m, iconv.m
%  Subfunctions: none
%  MAT-files required: none
%
% See also: EDGEROBERTS, EDGEPREWITT

% Author: André Augusto Geraldes
% Email: andregeraldes@lara.unb.br
% September 2013; Last revision: 28-September-2013

% Smooth the image before start detecting edges
filteredImage = gaussianFilter(image, 0.5, 5);

% Generate the 3x3 Sobel matrices
sobelX = [-1 0 1; -2 0 2; -1 0 1];
sobelY = sobelX';

% Calculate the image gradient
sx = iconv(filteredImage, sobelX,'same');
sy = iconv(filteredImage, sobelY,'same');
gradient = sqrt(sx.^2 + sy.^2);

% Identify edges by thresholding the image gradient
edges = logical(zeros(size(gradient)));
edges(gradient > threshold * max(max(gradient))) = 1;