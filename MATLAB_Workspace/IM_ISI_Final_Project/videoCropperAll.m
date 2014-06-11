function videoCropperAll(sourceDirectory, outputFileName)

% Parameters
W = 100;
frameRateDivider = 1;

% Find the content of the targetDirectory
dirInfo = dir(sourceDirectory);

% Remove the '.' and '..' elements from the list
nVideo = size(dirInfo,1);
dirInfo = dirInfo(3:nVideo);
nVideo = nVideo - 2;

% Initialize cell arrays
videoFiles = cell(1, nVideo);
selectedFrames = cell(1, nVideo);
croppPositionRow = cell(1, nVideo);
croppPositionColumn = cell(1, nVideo);

% Run the function imageCropper for each found directory
for iVideo = 1:nVideo
    videoPath = sprintf('%s/%s', sourceDirectory, dirInfo(iVideo).name);
    [selected, pRow, pCol] = videoCropper(videoPath, W, frameRateDivider);
    videoFiles{iVideo} = dirInfo(iVideo).name;
    selectedFrames{iVideo} = selected;
    croppPositionRow{iVideo} = pRow;
    croppPositionColumn{iVideo} = pCol;
end

save(outputFileName, 'videoFiles', 'selectedFrames', 'croppPositionRow', 'croppPositionColumn', 'W', 'frameRateDivider', 'nVideo');