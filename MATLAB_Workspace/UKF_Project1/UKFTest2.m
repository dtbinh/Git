close all;
clear all;
clc;

datasetFile = 'datasets/datasetGaussianK-0-200.mat';

posXInitial = 0;
posYInitial = 0;
thetaInitial = 0;

posXUncertainty = 0;
posYUncertainty = 0;
thetaUncertainty = 0;
kUncertainty = 10^-3;

uNoise = 10^-16;
kNoise = 10^-3;
mNoise = 10^-4;

state = [posXInitial posYInitial thetaInitial];
uncertainty = [posXUncertainty posYUncertainty thetaUncertainty kUncertainty];
noise = [kNoise uNoise mNoise mNoise];

needleSteeringFilter_AUKF_Offline_Planar_EstimatedK(datasetFile, state, uncertainty, noise);