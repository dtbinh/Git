%
%   SCRIPT DESCRIPTION
%
    
% Author: André Augusto Geraldes
% Email: andregeraldes@lara.unb.br
% June 2014; Last revision: 24-June-2014

close all;
clear all;
clc;

% Load the input vectors from file
uFile = load('datasets/inputVectors.mat');
U1 = uFile.U1;
U2 = uFile.U2;

% Load the curvature vectors from file
constantFile = load('datasets/constantK.mat');
constantK = constantFile.constantK;
gaussianFile = load('datasets/gaussianK.mat');
gaussianK = gaussianFile.gaussianK;
stageFile = load('datasets/stageK.mat');
stageK = stageFile.stageK;

% Generate the simulated trajectories
[constantX constantY constantTheta] = simulatePlanarTrajectory(U1, U2, constantK);
[gaussianX gaussianY gaussianTheta] = simulatePlanarTrajectory(U1, U2, gaussianK);
[stageX stageY stageTheta] = simulatePlanarTrajectory(U1, U2, stageK);

% Save the generated trajectories to file
pX = constantX;
pY = constantY;
theta = constantTheta;
k = constantK;
avgK = mean(constantK);
save('datasetConstantK.mat', 'U1', 'U2', 'avgK', 'k', 'pX', 'pY', 'theta');

pX = gaussianX;
pY = gaussianY;
theta = gaussianTheta;
k = gaussianK;
save('datasetGaussianK.mat', 'U1', 'U2', 'avgK', 'k', 'pX', 'pY', 'theta');

pX = stageX;
pY = stageY;
theta = stageTheta;
k = stageK;
save('datasetStageK.mat', 'U1', 'U2', 'avgK', 'k', 'pX', 'pY', 'theta');