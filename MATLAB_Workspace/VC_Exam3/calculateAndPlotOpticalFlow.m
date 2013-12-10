function [imageSequence opticalFlow] = calculateAndPlotOpticalFlow(sourceDir, varargin)

%
% FUNCTION DESCRIPTION
%

% Author: André Augusto Geraldes
% Email: andregeraldes@lara.unb.br
% December 2013; Last revision: 08-December-2013

%% Build the image sequence matrix

% Find all files in the source directory
allFiles = dir(sourceDir);
nFile = size(allFiles, 1);

% Find all jpg images in the source directory
iImage = 1;
for iFile = 1:nFile
    fileName = allFiles(iFile).name;
    length = size(fileName,2);
    if(length > 4)
        
        % For each jpg image found save its name and complete name
        if(strcmp(fileName(length-3:length), '.jpg'))
            imageFileName{iImage} = sprintf('%s/%s',sourceDir, fileName);
            iImage = iImage + 1;
        end
        
    end
end

% Measure the image size and the total amount of images
nImage = iImage - 1;
[imageRow imageColumn] = size(iread(imageFileName{1}, 'grey'));

% Build the image sequence matrix
imageSequence = zeros(imageRow, imageColumn, nImage);
for iImage = 1:nImage
    imageSequence(:,:,iImage) = iread(imageFileName{iImage}, 'grey', 'double');
end

%% Calculate the optical flow
opticalFlow = constantFlow(imageSequence, 1.5, 5, 3);

%% Plot the images and the optical flows
% plotOpticalFlow(imageSequence(:,:,2:nImage), opticalFlow, varargin);
plotOpticalFlow(imageSequence(:,:,1:nImage-1), opticalFlow, varargin);
