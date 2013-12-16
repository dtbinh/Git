function opticalFlow = constantFlow(imageSequence, varargin)

% CONSTANTFLOW Estimate the optical flow (E. Trucco, page 197) 
%    F = CONSTANTFLOW(I) calculates the optical flow between each pair of
%    images in the 3D array I. For each pair of pixels I(i,j,N) and
%    I(i,j,N+1), the velocity v = F(i,j,N) is calculated. v is a struct
%    containing x and y components.
%
%    F = CONSTANTFLOW(I, param1, value1, param2, value2, ...) allows
%    changing the default parameters of the constantFlow algorithm. The 
%    available parameters are:
%
%        sigma      - the variance of the gaussians used to filter the
%                     image sequence spatially and temporally
%        filterSize - the size of the temporal and spatial filters
%        patchSize  - the width of the square region, whithin which the
%                     optical flow is assumed to be constant
%
%    Other m-files required: imageGradient.m
%    Subfunctions: none
%    MAT-files required: none
%
%    See also: PLOTOPTICALFLOW, IMAGEGRADIENT, FEATUREPOINTMATCH

% Author: André Augusto Geraldes
% Email: andregeraldes@lara.unb.br
% December 2013; Last revision: 09-December-2013

%% Parameter setting

gaussianSigma = 1.5;
patchSize = 5;
filterSize = 3;

if(nargin > 1 && mod(nargin-1,2) == 0)
    for iArgin = 1:(nargin-1)/2
        if(strcmp(varargin{2*iArgin-1}, 'sigma'))
            gaussianSigma = varargin{2*iArgin};
        elseif(strcmp(varargin{2*iArgin-1}, 'patchSize'))
            patchSize = varargin{2*iArgin};
        elseif(strcmp(varargin{2*iArgin-1}, 'filterSize'))
            filterSize = varargin{2*iArgin};
        end
    end
end

%% Filter the images

% Measure the image size and the amount of images
[nRow nColumn nImage] = size(imageSequence);

% Generate the Gaussian filters
gaussianFilter2D = fspecial('gaussian', filterSize, gaussianSigma);
gaussianFilter1D = gaussianFilter2D(ceil(filterSize/2),:);
gaussianFilter1D = gaussianFilter1D / sum(gaussianFilter1D);

% Filter images along each spatial dimension
for iImage = 1:nImage
    imageSequence(:,:,iImage) = imfilter(imageSequence(:,:,iImage), gaussianFilter2D, 'symmetric', 'same', 'conv');
end

% Filter images along the temporal dimension
for iRow = 1:nRow
    for iColumn = 1:nColumn
        filteredPixel = conv(reshape(imageSequence(iRow, iColumn,:), 1, nImage), gaussianFilter1D, 'same');
        for iImage = 1:floor(filterSize/2)
            filteredPixel(iImage) = imageSequence(iRow, iColumn, 1);
            filteredPixel(nImage-iImage+1) = imageSequence(iRow, iColumn, nImage);
        end
        imageSequence(iRow, iColumn, :) = filteredPixel;
    end
end

%% Calculate the optical flows

% Create a dummy vector
v.x = 0;
v.y = 0;

% Initialize the matrix for storing the nImage-1 optical flows
opticalFlow = repmat(v, [nRow nColumn nImage-1]);
N = floor(patchSize / 2.0);

% For each image in the sequence (except the first one):
for iImage = 1:nImage-1
    
    fprintf('Calculating the optical flow for the image: %d\n', iImage);
    
    % Calculate the spatial gradients Gx and Gy
    [Gx Gy] = imageGradient(imageSequence(:,:,iImage), 'xy');
    
    % Calculate the partial temporal derivative of the image
    Gt = imageSequence(:,:,iImage+1) - imageSequence(:,:,iImage);
    
    % For each pixel of the image:
    for iRow = 1+N:nRow-N
        for iColumn = 1+N:nColumn-N          
            
            % Read the patch of size patchSize centered at (iRow, iColumn)
            % and build the A and b matrices
            Ax = reshape(Gx(iRow-N:iRow+N, iColumn-N:iColumn+N), patchSize^2, 1);
            Ay = reshape(Gy(iRow-N:iRow+N, iColumn-N:iColumn+N), patchSize^2, 1);
            b = reshape(-Gt(iRow-N:iRow+N, iColumn-N:iColumn+N), patchSize^2, 1);
            A = [Ax Ay];
            
            % Calculate the optical flow associated to the current patch
            structureTensor = A'*A;
            nCond = rcond(structureTensor);
            if(nCond < 1e-12)
                v.x = 0;
                v.y = 0;
            else
                velocity = structureTensor \ (A'*b);
                v.x = velocity(1);
                v.y = velocity(2);
            end
            
            % Assign the calculated optical flow to the current pixel
            opticalFlow(iRow, iColumn, iImage) = v;
            
            % Assign the calculated optical flow to the pixels at the
            % border of the image (if necessary)
            if    (iRow == 1+N    && iColumn == 1+N      )
                for x = 1:N
                    for y = 1:N
                        opticalFlow(x, y, iImage) = v;
                    end
                end
            elseif(iRow == 1+N    && iColumn == nColumn-N)
                for x = 1:N
                    for y = nColumn-N+1:nColumn
                        opticalFlow(x, y, iImage) = v;
                    end
                end
            elseif(iRow == nRow-N && iColumn == 1+N      )
                for x = nRow-N+1:nRow
                    for y = 1:N
                        opticalFlow(x, y, iImage) = v;
                    end
                end
            elseif(iRow == nRow-N && iColumn == nColumn-N)
                for x = nRow-N+1:nRow
                    for y = nColumn-N+1:nColumn
                        opticalFlow(x, y, iImage) = v;
                    end
                end
            elseif(iRow    == 1+N      )
                for x = 1:N
                    opticalFlow(x, iColumn, iImage) = v;
                end
            elseif(iRow    == nRow-N   )
                for x = nRow-N+1:nRow
                    opticalFlow(x, iColumn, iImage) = v;
                end
            elseif(iColumn == 1+N      )
                for y = 1:N
                    opticalFlow(iRow, y, iImage) = v;
                end
            elseif(iColumn == nColumn-N)    
                for y = nColumn-N+1:nColumn
                    opticalFlow(iRow, y, iImage) = v;
                end
            end
        end
    end
end
