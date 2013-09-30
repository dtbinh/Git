function filteredImage = gaussianFilter(image, sigma, maskWidth)

% GAUSSIANFILTER Applies Gaussian smoothing to image
%    If = gaussianFilter(I, sigma, N) is the result of smoohting the image
%    'I' with the NxN discrete Gaussian kernel of standard deviation
%    'sigma'.
%
%  Other m-files required: gaussianKernel.m, iconv.m
%  Subfunctions: none
%  MAT-files required: none
%
% See also: GAUSSIANKERNEL, MEDIANFILTER

% Author: André Augusto Geraldes
% Email: andregeraldes@lara.unb.br
% September 2013; Last revision: 28-September-2013

% Generate Gaussian kernel
gaussian = gaussianKernel(sigma, maskWidth);

% Smooth the image using the Gaussian kernel
filteredImage = iconv(double(image), gaussian, 'same');