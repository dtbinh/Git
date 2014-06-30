close all;
clear all;
clc;

datasetFile = 'datasets/datasetStageK-0-50.mat';

posXInitial = 0;
posYInitial = 0;
thetaInitial = 0;

posXUncertainty = 0;
posYUncertainty = 0;
thetaUncertainty = 0;

kNoise = 10^-9;
uNoise = 10^-9;
pXNoise = 10^-6;
pYNoise = 10^-6;

state = [posXInitial posYInitial thetaInitial];
uncertainty = [posXUncertainty posYUncertainty thetaUncertainty];
noise = [kNoise uNoise pXNoise pYNoise];

needleSteeringFilter_AUKF_Offline_Planar_ConstantK(datasetFile, state, uncertainty, noise);