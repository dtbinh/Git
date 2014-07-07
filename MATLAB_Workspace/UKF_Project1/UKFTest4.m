close all;
clear all;
clc;

datasetFile = 'datasets/datasetStageK-0-10.mat';

posXInitial = 0;
posYInitial = 0;
posZInitial = 0;
angleR1Initial = 0;
angleR2Initial = 0;
angleR3Initial = 0;
kInitial = 100;

posXUncertainty = 0;
posYUncertainty = 0;
posZUncertainty = 0;
angleR1Uncertainty = 0;
angleR2Uncertainty = 0;
angleR3Uncertainty = 0;
kUncertainty = 10^-1;

state = [posXInitial posYInitial posZInitial angleR1Initial angleR2Initial angleR3Initial kInitial];
uncertainty = [posXUncertainty posYUncertainty posZUncertainty angleR1Uncertainty angleR2Uncertainty angleR3Uncertainty kUncertainty];

u2Noise = -30;

u1Noise = -9;
kNoise = -3;
mNoise = -6;

noise = 10.^[kNoise u1Noise u2Noise mNoise mNoise];

[e m f] = needleSteeringFilter_AUKF_Offline_Quaternion_EstimatedK(datasetFile, state, uncertainty, noise);