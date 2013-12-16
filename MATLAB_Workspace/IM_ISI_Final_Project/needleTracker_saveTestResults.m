function needleTracker_saveTestResults(networkFile, nPlotImage, filename)

%
% FUNCTION DESCRIPTION
%

% Parameters

thresholdPercentage = 0.8;
displayAllImages = 0;

% Import data from the input files
netStruct = load(networkFile);
net = netStruct.net;
testInput = netStruct.dataset.testInput;
testOutput = netStruct.dataset.testOutput;

% Test the network
netOutput = net(testInput);

% Calculate the best threshold for the networkResults
nExample = size(netOutput, 2);
imageSize = sqrt(size(netOutput, 1));

thresholdList = zeros(1, nExample);
for iExample = 1:nExample
    thresholdList(iExample) = findImageThreshold(reshape(netOutput(:,iExample), imageSize, imageSize), thresholdPercentage);
end
threshold = mean(thresholdList);

% Compare the netOutput with the testOutput
for iExample = 1:nPlotImage
    figure('position',[250 300 1500 500]);
    set(gcf,'paperunits','points','papersize',[1500 500])
    subplot('position',[0.02 0 0.30 1]), imshow(reshape(testInput(:,iExample), 23, 23));
    subplot('position',[0.35 0 0.30 1]), imshow(reshape(testOutput(:,iExample), 23, 23));
    subplot('position',[0.68 0 0.30 1]), imshow(reshape(netOutput(:,iExample), 23, 23));
    
%     saveas(gcf, sprintf('%s_%d',filename,iExample),'png');
    pause(0.1);
    
end