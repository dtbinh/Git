function gradient = imageGradient(I)

% IMAGEGRADIENT Gradient magnitude of the image (Sobel mask)
%    G = IMAGEGRADIENT(I) calculates the gradient of I using a 3x3 Sobel
%    maks. G is the magnitude of the gradient.
%
%
%    Other m-files required: iconv.m
%    Subfunctions: none
%    MAT-files required: none
%
%    See also: ICONV, EDGE

% Author: André Augusto Geraldes
% Email: andregeraldes@lara.unb.br
% October 2013; Last revision: 30-October-2013

% Generate the 3x3 Sobel matrices
sobelX = [-1 0 1; -2 0 2; -1 0 1];
sobelY = sobelX';

% Calculate the image gradient
sx = iconv(I, sobelX,'same');
sy = iconv(I, sobelY,'same');
gradient = sqrt(sx.^2 + sy.^2);