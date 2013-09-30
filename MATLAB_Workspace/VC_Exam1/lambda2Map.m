function lambdaMatrix = lambda2Map(image, N, tau)

% LAMBDA2MAP Calculate corner intensities for the given image
%    L = lambda2Map(image, N) is a map describing the pixels of the image
%    that are the most likely to be corners. It uses the function 
%    fullLambda2Map to calculate the entire lambdaMap of the image and
%    threshold it with the value tau. If two values of the lambdaMap are
%    greater than tau, but are in the same neighbourhood window of size
%    (2N+1) the smaller value is supressed.
%
%
%  Other m-files required: fullLambda2Map.m
%  Subfunctions: none
%  MAT-files required: none
%
% See also: FULLLAMBDA2MAP, CORNERS

% Author: André Augusto Geraldes
% Email: andregeraldes@lara.unb.br
% September 2013; Last revision: 29-September-2013

% Generate the entire lambdaMap of the image
fullLambdaMatrix = fullLambda2Map(image,N);

% Initialize the matrix to store the resulting lambdaMatrix 
lambdaMatrix = zeros(size(fullLambdaMatrix));

maxLambda = max(max(fullLambdaMatrix));
while(maxLambda > tau)
    
    % Find the highest value of lambda2 and copy it to the lambdaMatrix
    [r c] = find(fullLambdaMatrix == maxLambda);
    lambdaMatrix(r(1),c(1)) = maxLambda;
    
    % Suppres all values of lambda2 in the neighbourhood of the added value
    for i = r(1)-N:r(1)+N
        for j = c(1)-N:c(1)+N
            fullLambdaMatrix(i,j) = 0;
        end
    end
    
    % Find the next highest value of lambda2 to proceed with the algorithm
    maxLambda = max(max(fullLambdaMatrix));
end