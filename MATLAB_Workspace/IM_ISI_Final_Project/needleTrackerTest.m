function result = needleTrackerTest(networkFile, testFile, controlVariable, varargin)

%
% FUNCTION DESCRIPTION
%

% Parameters

thresholdPercentage = 0.8;
displayAllImages = 0;

% Import data from the input files
netStruct = load(networkFile);
net = netStruct.net;

% Read the training dataset
testDataSet = load(testFile);
testInput = testDataSet.inputMatrix;
testOutput = testDataSet.outputMatrix;

% Test the network
netOutput = net(testInput);

% Calculate the best threshold for the networkResults
nExample = size(netOutput, 2);
imageSize = sqrt(size(netOutput, 1));

nDisplayImage = 0;
if(nargin > 3)
    nDisplayImage = varargin{1};
    updateRate = round(nExample / nDisplayImage);
%     for iArg = 1:nargin-3
%         if(strcmp(varargin{iArg}, 'displayAll'))
%             displayAllImages = 1;
%         end
%     end
end

thresholdList = zeros(1, nExample);
for iExample = 1:nExample
    thresholdList(iExample) = findImageThreshold(reshape(netOutput(:,iExample), imageSize, imageSize), thresholdPercentage);
end
threshold = mean(thresholdList);



threshold = 0.3;




% Compare the netOutput with the testOutput
pixelError = 0;
for iExample = 1:nExample
    [r ~] = find(testOutput(:,iExample) == 1);
    nPixel = length(r);
    for iPixel = 1:nPixel
        if(netOutput(r(iPixel),iExample) <= threshold)
            pixelError = pixelError + 1;
        end
    end
    
    [r ~] = find(testOutput(:,iExample) == 0);
    nPixel = length(r);
    for iPixel = 1:nPixel
        if(netOutput(r(iPixel),iExample) >= threshold)
            pixelError = pixelError + 1;
        end
    end
    
    if(nDisplayImage > 0)
        if(mod(iExample, updateRate) == 0)
            figure;
            subplot(221);
            imshow(reshape(testInput(1:529,iExample), 23, 23));
            subplot(222);
            imshow(reshape(testOutput(:,iExample), 23, 23));
            subplot(223);
            imshow(reshape(netOutput(:,iExample), 23, 23));
            subplot(224);
            imshow(reshape(im2bw(netOutput(:,iExample), threshold), 23, 23));
            
            pause(0.1);
        end
    end
    
end

result = cell(1,2);
result{2} = perform(net, testOutput, net(testInput));
result{3} = pixelError / numel(netOutput);

if(strcmp(controlVariable, 'learningRate'))
    result{1} = netStruct.learningRate;
elseif(strcmp(controlVariable, 'nNeuron'))
    result{1} = netStruct.hiddenLayers(1) + 1000*(netStruct.nLayer/2 - 1);
elseif(strcmp(controlVariable, 'nNeuron1Layer'))
    result{1} = netStruct.hiddenLayers(1);
elseif(strcmp(controlVariable, 'activationFunction'))
    result{1} = 0;
    for iLayer = 1:netStruct.nLayer
        result{1} = result{1} + 10^(iLayer-1)*function2num(net.layers{iLayer}.transferFcn);
    end
end

function num = function2num(functionType)

if(strcmp(functionType, 'logsig'))
    num = 0;
elseif(strcmp(functionType, 'tansig'))
    num = 1;
elseif(strcmp(functionType, 'purelin'))
    num = 2;  
elseif(strcmp(functionType, 'hardlim'))
    num = 3; 
elseif(strcmp(functionType, 'poslin'))
    num = 4;    
elseif(strcmp(functionType, 'satlins'))
    num = 5;    
elseif(strcmp(functionType, 'hardlims'))
    num = 6;
elseif(strcmp(functionType, 'netinv'))
    num = 7;
elseif(strcmp(functionType, 'tribas'))
    num = 8;
else
    num = 9;    
end