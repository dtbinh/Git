function cornerArray = corners(image, varargin)

% CORNERS Algorithm CORNERS (E. Trucco, page 84)
%    C = corners(image, N, tau) detect corners in the given image an
%    returns an array of structs describing the location and intensity of
%    each corner. The parameter N determines the size of the neighbourhood
%    in which the algorithm will calculate the corners. The parameter tau
%    is a threshold parameter for discarding weak corners.
%
%    C = corners(image, N) selects the best value of tau using the function
%    cornerTau. 
%
%
%  Other m-files required: fullLambda2Map.m, cornerTau.m
%  Subfunctions: none
%  MAT-files required: none
%
% See also: FULLLAMBDA2MAP, CORNERTAU, PLOTCORNERS

% Author: André Augusto Geraldes
% Email: andregeraldes@lara.unb.br
% September 2013; Last revision: 29-September-2013

%% Calculate the values of lambda2 for all pixels in the image 
% (lambda2 represents the smaller eigenvalue of the gradient of the image
% at a given pixel. The larger the value of lamba2, more likely it is that
% the pixel corresponds to a corner).

N = varargin{1};
[nRow nColumn] = size(image);
fullLambdaMatrix = fullLambda2Map(image,N);

%% Threshold the lambda2 matrix

% nargin == 3 -> Use the user specified value of tau
if(nargin == 3)
    tau = varargin{2};

% nargin == 2 -> Calculate the best value of tau using cornerTau    
else
    % [hard-coded parameter] the percentage of the corners that should not
    % be discarded (See help cornerTau for more information)
    cornerPercentage = 0.2;
    tau = cornerTau(fullLambdaMatrix, cornerPercentage);
end

%% Supress corners identified within the same neighbourhood of size (2N+1)x(2N+1)

iCorner = 1;
maxLambda = max(max(fullLambdaMatrix));
while(maxLambda > tau)
    
    % Find the highest value of lambda2 and add it to the corner array
    [r c] = find(fullLambdaMatrix == maxLambda);
    cornerArray(iCorner) = struct('lambda',maxLambda, 'i',r(1), 'j',c(1));
    iCorner = iCorner + 1;
    
    % Suppres all values of lambda2 in the neighbourhood of the added
    % corner
    rmin = max(1   , r(1)-2*N);
    rmax = min(nRow, r(1)+2*N);
    for i = rmin:rmax
        
        cmin = max(1      , c(1)-2*N);
        cmax = min(nColumn, c(1)+2*N);
        for j = cmin:cmax
            fullLambdaMatrix(i,j) = 0;
        end
    end
    
    % Find the next highest value of lambda2 to proceed with the algorithm
    maxLambda = max(max(fullLambdaMatrix));
end