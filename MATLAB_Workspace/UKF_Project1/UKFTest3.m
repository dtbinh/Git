% close all;
clear all;
clc;

datasetFile = 'datasets/datasetGaussianK-0-10.mat';

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

u1Noise = -30;
u2Noise = -30;
kNoise = -3;
mNoise = -12;

noise = 10.^[kNoise u1Noise u2Noise mNoise mNoise];
[e m f] = needleSteeringFilter_AUKF_Offline_Quaternion_ConstantK(datasetFile, state, uncertainty, noise);
