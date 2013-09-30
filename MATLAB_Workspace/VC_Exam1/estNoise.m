function [estimatedNoise sigmaImage] = estNoise(varargin)

% ESTNOISE Algorithm EST_NOISE (E. Trucco, page 32)
%    noise = estNoise(imageList) estimates the noise over a set of similar
%    images by computing the standard deviation matrix varI, so that
%    varI(i,j) is the standard deviation of the pixel (i,j) between all the
%    images in the cell array imageList.
%
%    [noise varI] = estNoise(imageList) returns the standard deviation
%    matrix as well.
%
%    [noise varI] = estNoise() creates the cell array  imageList by loading
%    all available images in the current directory and computes the 
%    standard deviation matrix as described above.
%
%
%  Other m-files required: none
%  Subfunctions: none
%  MAT-files required: none
%
% See also: 

% Author: André Augusto Geraldes
% Email: andregeraldes@lara.unb.br
% September 2013; Last revision: 28-September-2013

%% Decode varargin

% nargin = 0 -> create a cell array and fill it with all the available
% images in the current directory
if(nargin == 0)
    
    % Retrieve the name of all files in the current directory
    allFiles = dir;
    [nFile ~] = size(allFiles);
    
    % Ignore the files '.' and '..'
    nImage = nFile - 2;
    
    % Generate cell array imageList
    imageList = cell(1,nImage);
    for iImage = 1:nImage
        
        % Read image and convert it to gray level
        currentImage = imread(allFiles(iImage+2).name);
        [~, imageDimension] = size(size(currentImage));
        if(imageDimension == 3)
            currentImage = rgb2gray(currentImage);
        end
        imageList{iImage} = currentImage;
    end

% nargin = 1 -> varargin{1} must contain a cell array filled with images
else
    imageList = varargin{1};
    [~, nImage] = size(imageList);
end

%% Calculate the mean image

% Initialize the matrix meanImage
[nRow nColumn] = size(imageList{1});
meanImage = zeros(nRow, nColumn);

for iRow = 1:nRow
    for iColumn = 1:nColumn
        
        % meanImage(i,j) = mean(image(i,j)) for all images in imageList
        for iImage = 1:nImage
            meanImage(iRow, iColumn) =  meanImage(iRow, iColumn) + double(imageList{iImage}(iRow, iColumn));
        end
        meanImage(iRow, iColumn) =  meanImage(iRow, iColumn) / nImage;
        
    end
end

%% Calculate the variance image

% Initialize the matrix sigmaImage
sigmaImage = zeros(nRow, nColumn);

for iRow = 1:nRow
    for iColumn = 1:nColumn
        
        % sigmaImage(i,j) = std(image(i,j)) for all images in imageList
        for iImage = 1:nImage
            sigmaImage(iRow, iColumn) =  sigmaImage(iRow, iColumn) + (meanImage(iRow, iColumn)- double(imageList{iImage}(iRow, iColumn)))^2;
        end
        sigmaImage(iRow, iColumn) =  sqrt(sigmaImage(iRow, iColumn) / (nImage - 1));
        
    end
end

%% Calculate the average of  sigmaImage

estimatedNoise = mean2(sigmaImage);