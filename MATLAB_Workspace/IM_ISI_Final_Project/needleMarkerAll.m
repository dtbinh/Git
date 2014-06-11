function needleMarkerAll(croppedFramesFile, markedFramesFile)

croppedFrames = load(croppedFramesFile);
nVideo = croppedFrames.nVideo;
videoFiles = croppedFrames.videoFiles;
oldSelectedFrames = croppedFrames.selectedFrames;
croppPositionRow = croppedFrames.croppPositionRow;
croppPositionColumn = croppedFrames.croppPositionColumn;
W = croppedFrames.W;
frameRateDivider = croppedFrames.frameRateDivider;

selectedFrames = cell(1, nVideo);
maskSequences = cell(1, nVideo);

for i = 1:nVideo
    [mask, selected, brushSize, brushSigma] = needleMarker(videoFiles{i}, oldSelectedFrames{i}, croppPositionRow{i}, croppPositionColumn{i}, W);
    selectedFrames{i} = selected;
    maskSequences{i} = mask;
end

save(markedFramesFile, 'nVideo', 'videoFiles', 'selectedFrames', 'croppPositionRow', 'croppPositionColumn', 'maskSequences', 'W', 'frameRateDivider', 'brushSize', 'brushSigma');