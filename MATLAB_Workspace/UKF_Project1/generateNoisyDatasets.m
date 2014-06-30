function generateNoisyDatasets

%
%   SCRIPT DESCRIPTION
%
    
% Author: André Augusto Geraldes
% Email: andregeraldes@lara.unb.br
% June 2014; Last revision: 24-June-2014

close all;
clear all;
clc;


% Load the original datasets
datasetConstantK = load('datasets/datasetConstantK.mat');
datasetGaussianK = load('datasets/datasetGaussianK.mat');
datasetStageK = load('datasets/datasetStageK.mat');

% Corrupt the constantK dataset
corruptDatasetAndSave(datasetConstantK, 0, 0.10, 'datasetConstantK-0-10.mat');
corruptDatasetAndSave(datasetConstantK, 0, 0.20, 'datasetConstantK-0-20.mat');
corruptDatasetAndSave(datasetConstantK, 0, 0.50, 'datasetConstantK-0-50.mat');

% Corrupt the gaussianK dataset
corruptDatasetAndSave(datasetGaussianK, 0, 0.10, 'datasetGaussianK-0-10.mat');
corruptDatasetAndSave(datasetGaussianK, 0, 0.20, 'datasetGaussianK-0-20.mat');
corruptDatasetAndSave(datasetGaussianK, 0, 0.50, 'datasetGaussianK-0-50.mat');

% Corrupt the stageK dataset
corruptDatasetAndSave(datasetStageK, 0, 0.10, 'datasetStageK-0-10.mat');
corruptDatasetAndSave(datasetStageK, 0, 0.20, 'datasetStageK-0-20.mat');
corruptDatasetAndSave(datasetStageK, 0, 0.50, 'datasetStageK-0-50.mat');



function corruptDatasetAndSave(dataset, uVarFactor, mVarFactor, outputFileName)

rangeFactor = 2;

nStep = length(dataset.U1);
uRange = range(dataset.U1)/(2 * rangeFactor);
mRangeX = range(dataset.pX)/(2 * rangeFactor);
mRangeY = range(dataset.pY)/(2 * rangeFactor);
mRange = max(mRangeX, mRangeY);



U1 = dataset.U1 + normrnd(0, uVarFactor*uRange, 1, nStep);
U2 = dataset.U2;
k = dataset.k;
avgK = dataset.avgK;
pX = dataset.pX;
pY = dataset.pY;
theta = dataset.theta;
mX = pX + normrnd(0, mVarFactor*mRange, 1, nStep);
mY = pY + normrnd(0, mVarFactor*mRange, 1, nStep);
save(outputFileName, 'U1', 'U2', 'avgK', 'k', 'pX', 'pY', 'theta', 'mX', 'mY');




