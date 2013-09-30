function [meanArray stdArray] = compareGaussianAndRA(N)

% COMPAREGAUSSIANANDRA Gaussian and Repeated Averaging comparison
%    [mean std] = compareGaussianAndRA(N) calls the function gaussianAndRA
%    for all integers between 1 and N and measure the difference between
%    the Gaussian and the repeated averaging filter. This difference is
%    expressed in terms of mean and standard deviation of the difference
%    matrix.
%
%
%  Other m-files required: gaussianAndRA.m, repeatedMeanFilter.m, gaussianKernel.m
%  Subfunctions: none
%  MAT-files required: none
%
% See also: GAUSSIANANDRA, REPEATEDMEANFILTER

% Author: André Augusto Geraldes
% Email: andregeraldes@lara.unb.br
% September 2013; Last revision: 28-September-2013

% Initialize the arrays for storing the differences betweem the computed
% Gaussian and repeated averaging filters
meanArray = zeros(1,N);
stdArray = zeros(1,N);

for i = 1:N

    % Generate a Gaussian and a repeated averaging filter
    [meanFilter gaussianFilter] = gaussianAndRA(i);
    
    % Measure the difference between both filters
    errorMatrix = (gaussianFilter-meanFilter).^2;
    
    % Store the mean and standard deviation of the difference matrix
    meanArray(i) = mean2(errorMatrix);
    stdArray(i) = std2(errorMatrix);
end

% Plot the difference between the filtures using errorbar
errorArray = 3*stdArray;
errorbar(meanArray, errorArray);