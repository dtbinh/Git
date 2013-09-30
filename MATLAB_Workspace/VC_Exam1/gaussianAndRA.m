function [meanResult gaussianResult] = gaussianAndRA(varargin)

% GAUSSIANANDRA Gaussian and Repeated Averaging comparison
%    [M G] = gaussianAndRA(N) produces two equivalent filters M and G. M is
%    a mask obtained by convolving the average filter with itself N times.
%    G is the Gaussian filter that best approximates M.
%
%    [MI GI] = gaussianAndRA(N, image) filters the image with a Gaussian
%    filter and a repeated averaging method. The Gaussian filter used is
%    the same as G, but the repeated averaging method convolves the image
%    with a 3x3 average mask N times, instead of using M.
%
%  Other m-files required: repeatedMeanFilter.m, gaussianKernel.m
%  Subfunctions: none
%  MAT-files required: none
%
% See also: REPEATEDMEANFILTER, COMPAREGAUSSIANANDRA

% Author: André Augusto Geraldes
% Email: andregeraldes@lara.unb.br
% September 2013; Last revision: 28-September-2013

%% Generate base filters

% Obtain N from varargin
N = varargin{1};

% Generate the repeated averaging filter
meanFilterN = repeatedMeanFilter(N);

% Generate the equivalent gaussian filter
gaussianFilter = gaussianKernel(sqrt(N),3+2*N);

%% Decode varargin

% nargin == 1 -> return the generated filters for comparison
if(nargin == 1)
    meanResult = meanFilterN;
    gaussianResult = gaussianFilter;

% nargin == 2 -> apply the generated Gaussian filter to a given image. Then
% apply a mean filter to the same image N+1 times. Return the filtered
% images.
else
    
    % Obtain the image from varargin
    image = varargin{2};
    meanFilter = ones(3) / 9.0;
    
    % Average the image N+1 times
    meanFilterImage = image;
    for i = 1:N+1
        meanFilterImage = iconv(meanFilterImage, meanFilter, 'same'); 
    end
    
    % Filter the image with the generated Gaussian filter
    gaussianFilterImage = iconv(image, gaussianFilter, 'same');
    
    % Return the filtered images for comparison
    meanResult = meanFilterImage;
    gaussianResult = gaussianFilterImage;
end