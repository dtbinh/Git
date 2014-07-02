%
%   SCRIPT DESCRIPTION
%
    
% Author: André Augusto Geraldes
% Email: andregeraldes@lara.unb.br
% June 2014; Last revision: 24-June-2014

close all;
clear all;
clc;

% Tissue parameters
radius = 0.20;               % Average curvature radius of 20cm
sf = 3;                      % Gaussian curvature standard deviation factor
maxR = 10;                   % Maximum curvature factor
minR = 0.1;                  % Minimum curvature factor
w      = [0.20 0.35 0.45];   % Stage width fractions
speedF = [0.75 1.00 2.50];   % Stage speed factors

avgK = 1/radius;

% Load the input vectors from file
uFile = load('datasets/inputVectors.mat');
U1 = uFile.U1;
U2 = uFile.U2;
nStep = length(U1);

% Generate curvature vectors
% constantK = avgK * ones(1, nStep);
% 
% gaussianRadius = normrnd(radius, radius/sf, 1, nStep);
% gaussianRadius = sat(gaussianRadius, minR*radius, maxR*radius);
% gaussianK = 1 ./ gaussianRadius;
% 
n = floor(nStep*w/sum(w));
n(3) = nStep - sum(n(1:2));
% stageK1 = speedF(1) * avgK * ones(1, n(1));
% stageK2 = speedF(2) * avgK * ones(1, n(2));
% stageK3 = speedF(3) * avgK * ones(1, n(3));
% stageK = [stageK1 stageK2 stageK3];
% 
% % Save the generated curvature vectors to file
% save('constantK.mat', 'constantK');
% save('gaussianK.mat', 'gaussianK');
% save('stageK.mat', 'stageK');
constantFile = load('datasets/constantK.mat');
constantK = constantFile.constantK;
gaussianFile = load('datasets/gaussianK.mat');
gaussianK = gaussianFile.gaussianK;
stageFile = load('datasets/stageK.mat');
stageK = stageFile.stageK;

% Test the generated curvatures by simulating the planar trajectory
[constantX constantY] = simulatePlanarTrajectory(U1, U2, constantK);
[gaussianX gaussianY] = simulatePlanarTrajectory(U1, U2, gaussianK);
[stageX stageY] = simulatePlanarTrajectory(U1, U2, stageK);

pathFigure = figure;
hold on;
plot(constantX, constantY, 'b');
plot(gaussianX, gaussianY, 'r');
plot(stageX, stageY, 'g');
axis equal;
plot([stageX(n(1)) stageX(n(1))], ylim, 'k--');
plot([stageX(n(1)+n(2)) stageX(n(1)+n(2))], ylim, 'k--');
set(pathFigure, 'Position', [25 540 560 420]);

gaussianError = ((gaussianX-constantX).^2 + (gaussianY-constantY).^2).^0.5;
stageError = ((stageX-constantX).^2 + (stageY-constantY).^2).^0.5;

errorFigure = figure;
hold on;
plot(gaussianError, 'r');
plot(stageError, 'g');
set(errorFigure, 'Position', [1065 540 560 420]);

histFigure = figure;
hist(gaussianK, 50);
set(histFigure, 'Position', [25 80 560 420]);

EM = 100*max(gaussianError)