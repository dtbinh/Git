close all;
clear all;
clc;
warning('off', 'all');

datasetFile = 'datasets/datasetStageK-20-20-50.mat';

posXInitial = 0;
posYInitial = 0;
posZInitial = 0;
angleR1Initial = 0;
angleR2Initial = 0;
angleR3Initial = 0;
kInitial = 5;

posXUncertainty = 0;
posYUncertainty = 0;
posZUncertainty = 0;
angleR1Uncertainty = 0;
angleR2Uncertainty = 0;
angleR3Uncertainty = 0;
kUncertainty = 10^-1;

state = [posXInitial posYInitial posZInitial angleR1Initial angleR2Initial angleR3Initial kInitial];
uncertainty = [posXUncertainty posYUncertainty posZUncertainty angleR1Uncertainty angleR2Uncertainty angleR3Uncertainty kUncertainty];

uNoise = -20;
kNoise = -20;
mNoise = -20;

noise = 10.^[kNoise uNoise uNoise mNoise mNoise];
[e m f] = needleSteeringFilter_AUKF_Offline_Quaternion_EstimatedK(datasetFile, state, uncertainty, noise);


% uNoise = -20:1;
% kNoise = -20:1;
% mNoise = -20:1;
% nU = length(uNoise);
% nK = length(kNoise);
% nM = length(mNoise);
% 
% nTest = nU*nK*nM;
% 
% parameters = zeros(nTest, 3);
% filterError = zeros(nTest, 2200);
% 
% for iU = 1:nU
%     for iK = 1:nK
%         for iM = 1:nM
% 
%             iTest = iM + (iK-1)*nM + (iU-1)*nM*nK;
%             fprintf('Running test %d out of %d\n', iTest, nTest);
%             
%             parameters(iTest,1) = uNoise(iU);
%             parameters(iTest,2) = kNoise(iK);
%             parameters(iTest,3) = mNoise(iM);
%             
%             
%             noise = 10.^[kNoise(iK) uNoise(iU) uNoise(iU) mNoise(iM) mNoise(iM)];
%             
%             try
%                 [e m f] = needleSteeringFilter_AUKF_Offline_Quaternion_EstimatedK(datasetFile, state, uncertainty, noise);
%             catch exception
%                 f = 9999*ones(1,2200);
%             end
%             
%             filterError(iTest,:) = f;
%         end
%     end
% end
% 
% save('UKFQuaternionTest2.mat');