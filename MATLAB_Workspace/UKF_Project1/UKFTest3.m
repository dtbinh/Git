close all;
clear all;
clc;

datasetFile = 'datasets/datasetStageK-20-50.mat';

posXInitial = 0;
posYInitial = 0;
posZInitial = 0;
angleR1Initial = 0;
angleR2Initial = 0;
angleR3Initial = 0;

posXUncertainty = 10^-30;
posYUncertainty = 10^-30;
posZUncertainty = 10^-30;
angleR1Uncertainty = 10^-30;
angleR2Uncertainty = 10^-30;
angleR3Uncertainty = 10^-30;

state = [posXInitial posYInitial posZInitial angleR1Initial angleR2Initial angleR3Initial];
uncertainty = [posXUncertainty posYUncertainty posZUncertainty angleR1Uncertainty angleR2Uncertainty angleR3Uncertainty];


u2Noise = -30;

u1Noise = -9;
kNoise = 0;
mNoise = -7;

noise = 10.^[kNoise u1Noise u2Noise mNoise mNoise];

% load('UKFQuaternion_Parameters.mat');
% iParam = 1000;
% noise = 10.^[parametersSorted(iParam, 2) parametersSorted(iParam, 1) u2Noise parametersSorted(iParam, 3) parametersSorted(iParam, 3)];

[e m f] = needleSteeringFilter_AUKF_Offline_Quaternion_ConstantK(datasetFile, state, uncertainty, noise);




% u2Noise = -30;
% u1Noise = -18:-2;
% kNoise = -16:0;
% mNoise = -16:-2;
% nU = length(u1Noise);
% nK = length(kNoise);
% nM = length(mNoise);
% 
% iTest = 1;
% nTest = nU*nK*nM;
% 
% parameters = zeros(nTest, 3);
% filterError = zeros(nTest, 2000);
% 
% for iU = 1:nU
%     for iK = 1:nK
%         for iM = 1:nM
%             
%             fprintf('Running test %d out of %d\n', iTest, nTest);
%             
%             parameters(iTest,1) = u1Noise(iU);
%             parameters(iTest,2) = kNoise(iK);
%             parameters(iTest,3) = mNoise(iM);
%             
%             
%             noise = 10.^[kNoise(iK) u1Noise(iU) u2Noise mNoise(iM) mNoise(iM)];
%             [e m f] = needleSteeringFilter_AUKF_Offline_Quaternion_ConstantK(datasetFile, state, uncertainty, noise);
%             filterError(iTest,:) = f;
%             
%             iTest = iTest+1;
%             
%         end
%     end
% end
% 
% save('UKFQuaternionTest.mat');