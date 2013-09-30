function lambdaMatrix = fullLambda2Map(image, N)

% FULLLAMBDA2MAP Calculate corner intensities for the given image
%    L = fullLambda2Map(image, N) is a map describing the likelyhood of
%    each pixel of the image to be a corner. The higher the value of L(i,j)
%    the more likely it is that image(i,j) represents a corner. The values
%    lambda2 of L are calculated using the formula described in E. Trucco 
%    page 82. The parameter N describes the size of the neighbourhood used 
%    for calculating the values lambda.
%
%
%  Other m-files required: iconv.m
%  Subfunctions: none
%  MAT-files required: none
%
% See also: CORNERS

% Author: André Augusto Geraldes
% Email: andregeraldes@lara.unb.br
% September 2013; Last revision: 29-September-2013

%% Calculate the image gradient

prewitt = [1 1 1; 0 0 0; -1 -1 -1];
gradientX = iconv(double(image), double(prewitt'),'same');
gradientY = iconv(double(image), double(prewitt),'same');

%% Calculate the fullLambda2Map 

% Initialize the matrix for storing the values of lambda
[nRow nColumn] = size(image);
lambdaMatrix = zeros(nRow, nColumn);
windowSize = (2*N+1)^2;

% Iterate through the entire image, except the borders
for iRow = 1+N:nRow-N
    for iColumn = 1+N:nColumn-N
        
        % Compute the values of Exx, Exy and Eyy for the beighbourhood of
        % the pixel (iRow, iColumn)
        Exx = 0; Eyy = 0; Exy = 0;
        for i = iRow-N:iRow+N
            for j = iColumn-N:iColumn+N
                Exx = Exx + gradientX(i,j)^2;
                Eyy = Eyy + gradientY(i,j)^2;
                Exy = Exy + gradientX(i,j)*gradientY(i,j);
            end
        end
        
        % Calculate the matrix C (OBS: It has been normalized to minimize
        % the impact of windowSize in the total gain of the lambdaMatrix
        C = [Exx Exy ; Exy Eyy] / windowSize;
        
        % Assign to lambdaMatrix(iRow,iColumn) the sammler eingenvalue of C
        lambdaMatrix(iRow,iColumn) = min(eig(C));
    end
end