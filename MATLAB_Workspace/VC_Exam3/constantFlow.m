function opticalFlow = constantFlow(imageSequence, gaussianSigma, patchSize, filterSize)

%
% FUNCTION DESCRIPTION
%

% Author: André Augusto Geraldes
% Email: andregeraldes@lara.unb.br
% December 2013; Last revision: 08-December-2013

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
    
    fprintf('Calculating the optical flow for the image: %d\n', iImage+1);
    
    % Calculate the spatial gradients Gx and Gy
    [Gx Gy] = imageGradient(imageSequence(:,:,iImage+1), 'xy');
    
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
%                 tensorInv = inv(structureTensor);
%                 AB = (A'*b);
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
