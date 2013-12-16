function [imageSequence opticalFlow] = calculateAndPlotOpticalFlow(sourceDir, varargin)

% CALCULATEANDPLOTOPTICALFLOW 
%    [I F] = CALCULATEANDPLOTOPTICALFLOW(sourceDir) finds all image files
%    in the directory 'sourceDir' and calculate the optical flow between
%    each pair of images using the constantFlow function. After that, each
%    of the calculated flows is plotted using the function plotOpticalFlow.
%    At the end of the program, I is a 3D array containing all read images
%    and F is a 3D array of structs, where v = F(i,j,N) is the velocity of
%    the pixel (i,j) between the frames N and N+1, given in x and y
%    components.
%
%    [I F] = CALCULATEANDPLOTOPTICALFLOW(sourceDir, param1, value1, param2, value2, ...)
%    allows setting some plotting options. For more details see help plotOpticalFlow.
%
%    Other m-files required: constantFlow.m, plotOpticalFlow.m
%    Subfunctions: none
%    MAT-files required: none
%
%    See also: CONSTANTFLOW, PLOTOPTICALFLOW

% Author: André Augusto Geraldes
% Email: andregeraldes@lara.unb.br
% December 2013; Last revision: 09-December-2013

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
        
        % Save the name of each jpg image
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
opticalFlow = constantFlow(imageSequence);

%% Plot the images and the optical flows
plotOpticalFlow(imageSequence(:,:,1:nImage-1), opticalFlow, varargin{:});
