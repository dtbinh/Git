function autocovarianceMatrix = autocovariance(varargin)

% AUTOCOVARIANCE Algorithm AUTO_COVARIANCE (E. Trucco, page 33)
%    autocovar = autocovariance(image) computes the autocovariance matrix
%    of a square region in the center of the image. The size of this region
%    is determined by a hard-coded parameter 'percentage'.
%
%    autocovar = autocovariance() computes the autocovariance matrices for
%    all the available images in the current directory. autocovar is the
%    average of all the computed matrices.
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

% nargin = 0 -> compute the autocovariance matrix for all the available
% images in the current directory and average them.
if(nargin == 0)
    
    % Retrieve the name of all files in the current directory
    allFiles = dir;
    [nFile ~] = size(allFiles);
    
    % Ignore the files '.' and '..'
    nImage = nFile - 2;
    
    % Generate cell array to store the covariance matrices
    autocovarianceMatrices = cell(1,nImage);
    for iImage = 1:nImage
        
        % Read image and convert it to gray level
        currentImage = imread(allFiles(iImage+2).name);
        [~, imageDimension] = size(size(currentImage));
        if(imageDimension == 3)
            currentImage = rgb2gray(currentImage);
        end
        
        % Compute the autocovariance matrix
        autocovarianceMatrices{iImage} = autocovariance(currentImage);
        fprintf('Finished computing the autocovariance matrix number %d\n',iImage);
    end
    
    % Compute the average autocovariance matrix using mean(:,3)
    [r c] = size(autocovarianceMatrices{1});
    autocovarianceMatrix3 = zeros(r,c,nImage);
    for iImage = 1:nImage
        autocovarianceMatrix3(:,:,iImage) = autocovarianceMatrices{iImage};
    end
    
    autocovarianceMatrix = mean(autocovarianceMatrix3,3);
    
% nargin = 1 -> compute the autocovariance matrix for a single image 
else
    image = varargin{1};
    
    %% Extract a square region in the center of the image
    
    % [hard-coded parameter] the intended portion of the image the must be used
    % to calculate the autocovariance
    percentage = 0.5;
    
    % Locate the center of the image
    [nRow nColumn] = size(image);
    centerRow = round(nRow/2);
    centerColumn = round(nColumn/2);
    
    % Extract a square around the center of the image
    halfWidth = round(min(nRow, nColumn)*percentage/2);
    image2 = double(image(centerRow-halfWidth+1:centerRow+halfWidth-1,centerColumn-halfWidth+1:centerColumn+halfWidth-1));
    [nRow2 nColumn2] = size(image2);
    
    % Calculate the mean of the extracted image
    mu = mean2(image2);
    
    %% Calculate the autocovariance matrix
    
    autocovarianceMatrix = zeros(nRow2,nColumn2);
    for iRow = 0:nRow2-1
        for iColumn = 0:nColumn2-1
            
            c = 0;
            for i = 0:nRow2-iRow-1
                for j = 0:nColumn2-iColumn-1
                    c = c + (image2(1+ i,1+ j)-mu)*(image2(1+ i+iRow,1+ j+iColumn)-mu);
                end
            end
            autocovarianceMatrix(1+ iRow,1+ iColumn) = c / (nRow2 * nColumn2);
            
        end
    end
end