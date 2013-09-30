function filteredImage = medianFilter(image, maskWidth)

% MEDIANFILTER Applies the median filter to image (E. Trucco, page 62)
%    If = medianFilter(I, N) is the result of applying the median filter
%    (non-linear), using a neighborhood of size N.
%
%  Other m-files required: none
%  Subfunctions: none
%  MAT-files required: none
%
% See also: GAUSSIANFILTER

% Author: André Augusto Geraldes
% Email: andregeraldes@lara.unb.br
% September 2013; Last revision: 28-September-2013

%% Extend the original image by replicating the boundaries

% Generate a Dirac delta maks of size maskWidth x maskWidth
delta = zeros(maskWidth);
center = (maskWidth+1) / 2;
delta(center,center) = 1;  

% Generate the extended image, using the function imfilter
imagePadded = imfilter(image,delta,'symmetric','full','conv');

%% Applies the median filter to the extended image

% Initialize the matrix for storing the filtered image
[nRow nColumn] = size(image);
filteredImage = zeros(nRow, nColumn);
maskValues = zeros(1,maskWidth^2);

for iRow = 1:nRow    
    for iColumn = 1:nColumn
        
        % For each pixel, copy the entire neighborhood into the array
        % maskValues
        index = 1;
        for i = iRow:iRow+maskWidth-1
            for j = iColumn:iColumn+maskWidth-1
                maskValues(index) = imagePadded(i,j);
                index = index + 1;
            end
        end

        % Assign the median of the neighborhood to the filtered image
        filteredImage(iRow,iColumn) = median(maskValues);
    end
end

filteredImage = uint8(filteredImage);