%
%   SCRIPT DESCRIPTION
%
    
% Author: Andr� Augusto Geraldes
% Email: andregeraldes@lara.unb.br
% June 2014; Last revision: 24-June-2014

close all;
clear all;
clc;

% Tissue parameters
radius = 0.20;               % Average curvature radius of 20cm
sf = 1.8;                    % Gaussian curvature standard deviation factor
maxR = 10;                   % Maximum curvature factor
minR = 0.05;                 % Minimum curvature factor
w      = [0.20 0.35 0.45];   % Stage width fractions
speedF = [0.75 1.00 1.75];   % Stage speed factors

avgK = 1/radius;

% Load the input vectors from file
uFile = load('datasets/inputVectors.mat');
U1 = uFile.U1;
U2 = uFile.U2;
nStep = length(U1);

% Caclulate the steps for dividing the tissue with respect to U1 values
nStage = length(w);
n = zeros(1, nStage);
U1cum = cumsum(U1);
for iStage = 1:nStage - 1
    index = find(U1cum > w(iStage) * U1cum(end));
    n(iStage) = index(1);
end
n(nStage) = nStep - sum(n);

index = find(U2 > 0);
rotationPoint = U1cum(ceil(mean([index(1) index(end)])));


% Generate curvature vectors
constantK = avgK * ones(1, nStep);

gaussianRadius = normrnd(radius, radius/sf, 1, nStep);
gaussianRadius = sat(gaussianRadius, minR*radius, maxR*radius);
gaussianK = 1 ./ gaussianRadius;

stageK1 = speedF(1) * avgK * ones(1, n(1));
stageK2 = speedF(2) * avgK * ones(1, n(2));
stageK3 = speedF(3) * avgK * ones(1, n(3));
stageK = [stageK1 stageK2 stageK3];

% Save the generated curvature vectors to file
save('constantK.mat', 'constantK');
save('gaussianK.mat', 'gaussianK');
save('stageK.mat', 'stageK');

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
plot([rotationPoint rotationPoint], ylim, 'b--');
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

EM1 = 1000*gaussianError(end)
EM2 = 1000*stageError(end)