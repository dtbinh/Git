%
%   SCRIPT DESCRIPTION
%
    
% Author: André Augusto Geraldes
% Email: andregeraldes@lara.unb.br
% June 2014; Last revision: 24-June-2014

close all;
clear all;
clc;

% Insertion parameters
simT = 0.001;               % Simulation period = 1 ms
Ltotal = 0.2;               % Total insertion length = 20 cm

vm = 0.1;                   % Average insertion speed = 10 cm/s
sf = 2;                     % Insertion speed standard deviation factor
maxVm = 3;                  % Maximum insertion speed factor
minVm = 0;                  % Minimum insertion speed factor

simVm = vm * simT;
nStep = Ltotal / simVm;

% Generate the input vectors
U1 = normrnd(simVm, simVm/sf, 1, nStep);
U1 = sat(U1, minVm*simVm, maxVm*simVm);
U1 = U1 * (Ltotal/sum(U1));
U2 = zeros(1, nStep);

% Display the generate vectors characteristics
vectorFigure = figure;
plot(U1, 'b');
hold on;
plot(U2, 'r');
set(vectorFigure, 'Position', [25 540 560 420]);

histFigure = figure;
hist(U1, 50);
set(histFigure, 'Position', [1065 540 560 420]);

U1cummulated = zeros(1, nStep);
U2cummulated = zeros(1, nStep);
U1cummulated(1) = U1(1) - simVm;
U2cummulated(1) = U2(1);
for iStep = 2:nStep
    U1cummulated(iStep) = U1cummulated(iStep-1) + U1(iStep) - simVm;
    U2cummulated(iStep) = U2cummulated(iStep-1) + U2(iStep);
end

cummulatedfigure = figure;
plot(abs(U1cummulated), 'b');
hold on;
plot(U2cummulated, 'r');
set(cummulatedfigure, 'Position', [515 80 560 420]);

% Save the input vectors to file
save('inputVectors.mat', 'U1', 'U2');