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
[constantX constantY] = simulatePlanarTrajectory(U1, U2, constantK);
[gaussianX gaussianY] = simulatePlanarTrajectory(U1, U2, gaussianK);
[stageX stageY] = simulatePlanarTrajectory(U1, U2, stageK);

% Save the generated trajectories to file
pX = constantX;
pY = constantY;
k = constantK;
save('datasets/datasetConstantK.mat', 'U1', 'U2', 'k', 'pX', 'pY');

pX = gaussianX;
pY = gaussianY;
k = gaussianK;
save('datasets/datasetGaussianK.mat', 'U1', 'U2', 'k', 'pX', 'pY');

pX = stageX;
pY = stageY;
k = stageK;
save('datasets/datasetStageK.mat', 'U1', 'U2', 'k', 'pX', 'pY');