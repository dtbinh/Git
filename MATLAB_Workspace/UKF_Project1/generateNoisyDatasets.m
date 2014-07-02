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
% datasetConstantK = load('datasets/datasetConstantK.mat');
datasetGaussianK = load('datasets/datasetGaussianK.mat');
datasetStageK = load('datasets/datasetStageK.mat');

% Corrupt the constantK dataset

% Corrupt the gaussianK dataset
corruptDatasetAndSave(datasetGaussianK, 0.00, 0.00, 'datasetGaussianK-0-0.mat');
corruptDatasetAndSave(datasetGaussianK, 0.00, 0.10, 'datasetGaussianK-0-10.mat');
corruptDatasetAndSave(datasetGaussianK, 0.10, 0.20, 'datasetGaussianK-10-20.mat');
corruptDatasetAndSave(datasetGaussianK, 0.10, 0.50, 'datasetGaussianK-10-50.mat');
corruptDatasetAndSave(datasetGaussianK, 0.20, 0.20, 'datasetGaussianK-20-20.mat');
corruptDatasetAndSave(datasetGaussianK, 0.20, 0.50, 'datasetGaussianK-20-50.mat');
% 
% % Corrupt the stageK dataset
corruptDatasetAndSave(datasetStageK, 0.00, 0.00, 'datasetStageK-0-0.mat');
corruptDatasetAndSave(datasetStageK, 0.00, 0.10, 'datasetStageK-0-10.mat');
corruptDatasetAndSave(datasetStageK, 0.10, 0.20, 'datasetStageK-10-20.mat');
corruptDatasetAndSave(datasetStageK, 0.10, 0.50, 'datasetStageK-10-50.mat');
corruptDatasetAndSave(datasetStageK, 0.20, 0.20, 'datasetStageK-20-20.mat');
corruptDatasetAndSave(datasetStageK, 0.20, 0.50, 'datasetStageK-20-50.mat');

function corruptDatasetAndSave(dataset, uNoise, mNoise, outputFileName)

U2 = dataset.U2;
k = dataset.k;
avgK = dataset.avgK;
pX = dataset.pX;
pY = dataset.pY;
theta = dataset.theta;

U1 = dataset.U1;
if(uNoise > 0)    
    U1var = U1 - mean(U1);
    noiseU1 = awgn(U1var, 1.0/uNoise, 'measured', 'linear') - U1var;
    U1 = U1 + noiseU1;
end

mX = dataset.pX;
mY = dataset.pY;
if(mNoise > 0)
    mXvar = mX - mean(mX);
    mYvar = mY - mean(mY);
    noiseMX = awgn(mXvar, 1.0/mNoise, 'measured', 'linear') - mXvar;
    noiseMY = awgn(mYvar, 1.0/mNoise, 'measured', 'linear') - mYvar;
    if(range(noiseMX) > range(noiseMY))
        noiseMX2 = awgn(mXvar, 1.0/mNoise, 'measured', 'linear') - mXvar;
        mX = mX + noiseMX;
        mY = mY + noiseMX2;
    else
        noiseMY2 = awgn(mYvar, 1.0/mNoise, 'measured', 'linear') - mYvar;
        mY = mY + noiseMY;
        mX = mX + noiseMY2;
    end
end

save(outputFileName, 'U1', 'U2', 'avgK', 'k', 'pX', 'pY', 'theta', 'mX', 'mY');




