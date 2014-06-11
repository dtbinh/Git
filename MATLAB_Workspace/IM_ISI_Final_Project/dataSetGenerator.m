function dataSetGenerator(markedFramesFile, dataSetFile, nInput)

% Load the marked frames file
F = load(markedFramesFile);

% Important parameters
W = F.W;        % Full neelde mask half width (def = 75, width = 151)
Z = 23;         % Resized needle mask full width
V = 5*Z;        % Cropped needle mask full width
% nInput = 1;     % Number of frames to be used per example

multiplicationFactor = 1;
copyFramesWhenRotating = 1;

nVideo = F.nVideo;

% Calculate the amount of valid examples we have
if(nInput > 0)
    startFrame = nInput;
else
    startFrame = 2;
end

nExample = 0;
for iVideo = 1:nVideo
    for iFrame = 1:(startFrame-1)
        F.selectedFrames{iVideo}(iFrame) = 0;
    end
    nExample = nExample + sum(F.selectedFrames{iVideo});
end

% If the flag copyFramesWhenRotating is set, the number of examples should
% be multiplied by 4
if(copyFramesWhenRotating)
    nExample = nExample * 4;
end

% Multiply the number of examples by the multiplication factor
nExample = nExample * multiplicationFactor;

% Allocate memory for the input and output matrices
if(nInput > 0)
    inputMatrixGroup = cell(1, nInput);
    for i = 1: nInput
        inputMatrixGroup{i} = zeros(Z*Z, nExample);
    end
else
    inputMatrixGroup = cell(1, 2);
    inputMatrixGroup{1} = zeros(Z*Z, nExample);
    inputMatrixGroup{2} = zeros(Z*Z, nExample);
end

outputMatrix = zeros(Z*Z, nExample);

% Iterate for each valid frame of each video
iExample = 1;
for iVideo = 1:nVideo
    
    video = read(mmreader(F.videoFiles{iVideo}));    
    validFrame = F.selectedFrames{iVideo};
    maskSequence = F.maskSequences{iVideo};
    croppPosR = F.croppPositionRow{iVideo};
    croppPosC = F.croppPositionColumn{iVideo};
    nFrame = size(validFrame, 2);
    
    for iFrame = startFrame:nFrame
        if(validFrame(iFrame))
            
            if(copyFramesWhenRotating)
                nFrameRotation = 4;
            else
                nFrameRotation = 1;
            end
            
            for iFrameRotation = 1:nFrameRotation
                
                % Pick a random angle
                if(copyFramesWhenRotating)
                    angle = 90*(iFrameRotation-1);
                else
                    angle = randomAngle();
                end
                
                for iFrameMultiplication = 1:multiplicationFactor
                    
                    % Pick a random displacement
                    sR = round((2*W+1-V)*rand());
                    sC = round((2*W+1-V)*rand());
                    
                    % Add one column to the input matrix
                    ci = round(croppPosR(iFrame));
                    cj = round(croppPosC(iFrame));
                    if(nInput > 0)
                        for i = 1:nInput
                            frame = im2double(rgb2gray(video(:,:,:,iFrame-i+1)));
                            frame = frame(ci-W:ci+W, cj-W:cj+W);
                            frame = imrotate(frame, angle, 'crop');
                            inputMatrixGroup{i}(:,iExample) = reshape(imresize(frame(sR+1:sR+V, sC+1:sC+V), [Z Z]), 1, Z*Z);
                        end
                    else
                        frame = im2double(rgb2gray(video(:,:,:,iFrame)));
                        frame = frame(ci-W:ci+W, cj-W:cj+W);
                        frame = imrotate(frame, angle, 'crop');
                        inputMatrixGroup{1}(:,iExample) = reshape(imresize(frame(sR+1:sR+V, sC+1:sC+V), [Z Z]), 1, Z*Z);
                        
                        framePrev = im2double(rgb2gray(video(:,:,:,iFrame-1)));
                        framePrev = framePrev(ci-W:ci+W, cj-W:cj+W);
                        framePrev = imrotate(framePrev, angle, 'crop');
                        frameDiff = frame-framePrev;
                        inputMatrixGroup{2}(:,iExample) = reshape(imresize(frameDiff(sR+1:sR+V, sC+1:sC+V), [Z Z]), 1, Z*Z);
                    end
                    
                    % Add one column to the output matrix
                    mask = imrotate(maskSequence(:,:,iFrame), angle, 'crop');
                    outputMatrix(:,iExample) = reshape(imresize(mask(sR+1:sR+V, sC+1:sC+V), [Z Z]), 1, Z*Z);
                    
                    % Update the examle counter
                    iExample = iExample + 1;
                end
            end
        end
    end
end

% Combine all input data in a single matrix
if(nInput == 0)
    nInput = 2;
end

inputMatrix = zeros(nInput*Z*Z, nExample);
for i = 1:nInput
    startIndex = (i-1)*Z*Z + 1;
    endIndex = i*Z*Z;
    inputMatrix(startIndex:endIndex, :) = inputMatrixGroup{i};
end

% Save the generated matrices to the dataset file
save(dataSetFile, 'inputMatrix', 'outputMatrix');



function angle = randomAngle()
angleRand = 4*rand();
if(angleRand > 3)       
    angle = 0;
elseif(angleRand > 2)   
    angle = 90;
elseif(angleRand > 1)  
    angle = 180;
else
    angle = 270;
end
