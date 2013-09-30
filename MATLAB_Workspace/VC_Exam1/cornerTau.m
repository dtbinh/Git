function tau = cornerTau(fullLambdaMatrix, p)

% CORNERTAU Calculate the best threshold for the 'corners' function
%    tau = cornerTau(L, p) calculates the most appropriate value tau for
%    thresholding the matrix L. This value is calculated so that the area
%    of the histogram of L corresponding to values greater then tau is at
%    least at fraction 'p' of the total area of the histogram.
%
%
%  Other m-files required: none
%  Subfunctions: none
%  MAT-files required: none
%
% See also: FULLLAMBDA2MAP, CORNERS

% Author: André Augusto Geraldes
% Email: andregeraldes@lara.unb.br
% September 2013; Last revision: 29-September-2013

% Convert the fullLambdaMatrix to uint8 so that the function imhist can be
% applied to it
imageFactor = 255 / max(max(fullLambdaMatrix));
lambdaImage = uint8(fullLambdaMatrix * imageFactor);

% Generate the histogram of the fullLambdaMatrix
lambdaHist = imhist(lambdaImage);

% Integrate and normalize the histogram of fullLambdaMatrix
lambdaHistIntegral = cumsum(lambdaHist);
lambdaHistIntegral = (lambdaHistIntegral / sum(lambdaHist))';

% Find the value that divides the histogram area in 'p'
% Area(Histogram(L)) <= 1-p for the values smaller than tauNorm(1)
% Area(Histogram(L)) >= p for the values greater than tauNorm(1)
tauNorm = find(lambdaHistIntegral > 1-p);

% Return the absolute threshold value tau
tau = tauNorm(1) / imageFactor;