close all;
clear all;
clc;

datasetFile = 'datasets/datasetStageK-20-50.mat';

posXInitial = 0;
posYInitial = 0;
thetaInitial = 0;
kInitial = 100;

posXUncertainty = 0;
posYUncertainty = 0;
thetaUncertainty = 0;
kUncertainty = 10^-1;

state = [posXInitial posYInitial thetaInitial kInitial];
uncertainty = [posXUncertainty posYUncertainty thetaUncertainty kUncertainty];

iParam = 1;
uNoise = [-12 -11 -10 -9 -8 -9 -10 -11 -12 -7 -7 -12 -11 -10 -8];
kNoise = [-6 -5 -4 -3 -3 -4 -5 -6 -7 -3 -4 -5 -4 -3 -2];
mNoise = [-7 -6 -5 -4 -4 -5 -6 -7 -8 -4 -4 -7 -6 -5 -4];

noise = 10.^[kNoise(iParam) uNoise(iParam) mNoise(iParam) mNoise(iParam)];
[e m f] = needleSteeringFilter_AUKF_Offline_Planar_EstimatedK(datasetFile, state, uncertainty, noise);

% uNoise = -18;
% kNoise = -6;
% mNoise = -7;
% noise = 10.^[kNoise uNoise mNoise mNoise];
% [e m f] = needleSteeringFilter_AUKF_Offline_Planar_EstimatedK(datasetFile, state, uncertainty, noise);


















% for iParam = 1:15
%     noise = 10.^[kNoise(iParam) uNoise(iParam) mNoise(iParam) mNoise(iParam)];
%     [e m f] = needleSteeringFilter_AUKF_Offline_Planar_EstimatedK(datasetFile, state, uncertainty, noise);
%     
%     fprintf('Test %d: Perf = %d\n', iParam, round(1000*mean(f(1801:2000))));
% end

% uNoise = -12:-3;
% kNoise = -9:0;
% mNoise = -9:0;
% nU = length(uNoise);
% nK = length(kNoise);
% nM = length(mNoise);
% 
% parameters = zeros(nU*nK*nM, 3);
% filterError = zeros(nU*nK*nM, 2000);
% iTest = 1;
% for iU = 1:nU
%     for iK = 1:nK
%         for iM = 1:nM
%             
%             parameters(iTest,1) = uNoise(iU);
%             parameters(iTest,2) = kNoise(iK);
%             parameters(iTest,3) = mNoise(iM);
%             
%             
%             noise = 10.^[kNoise(iK) uNoise(iU) mNoise(iM) mNoise(iM)];
%             [e m f] = needleSteeringFilter_AUKF_Offline_Planar_EstimatedK(datasetFile, state, uncertainty, noise);
%             filterError(iTest,:) = f;
%             
%             iTest = iTest+1;
%             
%         end
%     end
% end
% 
% save('UKFTest.mat');






% 
% noise = 10.^[kNoise uNoise mNoise mNoise];
% [e m f] = needleSteeringFilter_AUKF_Offline_Planar_EstimatedK(datasetFile, state, uncertainty, noise);



% uNoiseVector = -12:1:-3;
% kNoiseVector = -12:1:-3;
% mNoiseVector = -12:1:-3;
% 
% nU = length(uNoiseVector);
% nK = length(kNoiseVector);
% nM = length(mNoiseVector);
% 
% 
% lowestError = 100;
% bestU = 10;
% bestK = 10;
% bestM = 10;
% for iU = 1:nU
%     for iK = 1:nK
%         for iM = 1:nM
%             
%             noise = 10.^[kNoiseVector(iK) uNoiseVector(iU) mNoiseVector(iM) mNoiseVector(iM)];
%             [e m f] = needleSteeringFilter_AUKF_Offline_Planar_EstimatedK(datasetFile, state, uncertainty, noise);
%             
%             if(mean(f(1801:2000)) < lowestError)
%                 lowestError = mean(f(1801:2000));
%                 bestU = uNoiseVector(iU);
%                 bestK = kNoiseVector(iK);
%                 bestM = mNoiseVector(iM);
%             end
%             
%             
%             
%         end
%     end
% end




