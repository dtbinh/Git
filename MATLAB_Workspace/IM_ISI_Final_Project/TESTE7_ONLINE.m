function TESTE7_ONLINE()

close all;
clear all;

%% Basic Parameters

global windowSize net thresholdPercentage

thresholdPercentage = 0.8;
windowSize = 129;

% Prediction Uncertainty: determines how fast the uncertainty grows in the
% absence of usefull data. It shouldn't be very high.
predictionUncertainty = 10^1;


%% Starting conditions

% velUncertainty is the uncertainty associated to the initial velocities.
  % In a realistic scenario it should be very high, but for making things
  % easier we can set it to a low value at first.
% velRError determines how wrong is our initial guess for the initial
  % R-velocity. It should be 1, but we can start testing with 0
% velCError determines how wrong is our initial guess for the initial
  % C-velocity. It should be 1, but we can start testing with 0  

% TEST1 [Easiest] - We know everything
% velRError = 0; velCError = 0; velUncertainty = 0;

% TEST2 [Easy]    - We know everything, but we are not sure
% velRError = 0; velCError = 0; velUncertainty = 10^1;

% TEST3 [Easy]    - We think we know everything 
% velRError = 0; velCError = 0; velUncertainty = 10^2;

% TEST4 [Medium]  - We have a good guess, but is only a guess
% velRError = 0; velCError = 0; velUncertainty = 10^3;

% TEST5 [Medium]  - We have only guessed one velocity right
% velRError = 0; velCError = 0.1; velUncertainty = 10^3;

% TEST6 [Hard]    - We have only guessed the right direction
% velRError = 0.1; velCError = 0.1; velUncertainty = 10^3;

% TEST7 [Hard]    - Our magnitude guess is very poor
% velRError = 0.50; velCError = 0.50; velUncertainty = 10^3;

% TEST8 [Hardest] - We don't know the initial velocity
velRError = 1.0; velCError = 1.0; velUncertainty = 10^3;

%% Measurement Uncertainty Function

% This function must be adjusted so that good measurements are incorporated
% in the state estimation and bad measurements are rejected

% OBS: measureError will always be normalized
%      0: the measurement is completely certain
%      1: the measure can't be trusted at all

% Function: uncertainty = k * (measureError^lambda)
k = 10^6;
lambda = 1;


%% Load video and network

% Read the video file
videoFile = '12-39-08.mpg';
video = read(mmreader(videoFile));

% Load the trained network
networkFile = 'networks/bestNetwork.mat';
netStruct = load(networkFile);
net = netStruct.net;

%% Initialize variables for storing the measurements

nFrame = 50;
posRMeasure = zeros(1, nFrame);
posCMeasure = zeros(1, nFrame);
measurementError = zeros(1, nFrame);
measurementUncertainty = zeros(1, nFrame);


%% Generate the ground truth
frameOffset = 20;   startR = 174; startC = 631;
                    endR   = 296; endC   = 470;

posRReal = linspace(startR, endR, nFrame);
posCReal = linspace(startC, endC, nFrame);

velRReal = posRReal(2:nFrame) - posRReal(1:nFrame-1);
velCReal = posCReal(2:nFrame) - posCReal(1:nFrame-1);
velRReal = [velRReal(1) velRReal];
velCReal = [velCReal(1) velCReal];
























%% Initialize variables for storing the estimated values
posREstimate = zeros(1,nFrame);
posCEstimate = zeros(1,nFrame);
velREstimate = zeros(1,nFrame);
velCEstimate = zeros(1,nFrame);

posRCovariance = zeros(1,nFrame);
posCCovariance = zeros(1,nFrame);
velRCovariance = zeros(1,nFrame);
velCCovariance = zeros(1,nFrame);

% Fill the initial values of all variables
posREstimate(1) = posRReal(1);
posCEstimate(1) = posCReal(1);
velREstimate(1) = velRReal(1) * (1 - velRError);
velCEstimate(1) = velCReal(1) * (1 - velCError);

posRCovariance(1) = 0;
posCCovariance(1) = 0;
velRCovariance(1) = velUncertainty;
velCCovariance(1) = velUncertainty;

%% Initialize debug variables for analyzing the algorithm performance
estimationError = zeros(1, nFrame);

%% Build Kalman Filter
F = [1 0 1 0; 0 1 0 1; 0 0 1 0; 0 0 0 1];
G = [0 ; 0 ; 0 ; 0];
H = [1 0 0 0 ; 0 1 0 0];
Q = eye(4) * predictionUncertainty;
R = eye(2);
kf = KalmanFilter(F, G, H, Q, R);
kf.x = [posREstimate(1) ; posCEstimate(1) ; velREstimate(1); velCEstimate(1)];
kf.P = diag([posRCovariance(1) posCCovariance(1) velRCovariance(1) velCCovariance(1)]);       

%% Initialize all windows

% State Estimation Figure
stateFigure = figure;
set(stateFigure, 'Position', [9 49 824 788]);
subplot(411); hold on; ylabel('POSITION R');
subplot(412); hold on; ylabel('POSITION C');
subplot(413); hold on; ylabel('VELOCITY R');
subplot(414); hold on; ylabel('VELOCITY C');

% State Covariance Figure
covarianceFigure = figure;
set(covarianceFigure, 'Position', [849 49 824 788]);
subplot(411); hold on;
subplot(412); hold on;
subplot(413); hold on;
subplot(414); hold on;

% Path Figure
pathFigure = figure;
set(pathFigure, 'Position', [ -1590 235 898 658]);
hold on;
set(gca,'YDir','reverse');
set(gca,'position',[0 0 1 1],'units','normalized')

% Frame Figure
frameFigure = figure;
set(frameFigure, 'Position', [ -560 536 550 350]);

% Debug Figure
debugFigure = figure;
set(debugFigure, 'Position', [ -560 95 550 350]);
hold on; ylabel('Estimation Error'); yaxis(0, 50);

%% Iterate for each frame of the video
% OBS: frame 1 is used to generate the initial values for the variables and
% cannot be used, because there is no frame 0 to compare with
for iFrame = 2:nFrame
    
    % Read the current frame
    frame = im2double(rgb2gray(video(:,:,:,iFrame+frameOffset)));
    
    % Perform one measurement
    [posRM posCM error] = performMeasurement(frame, kf.x);
    posRMeasure(iFrame) = posRM;
    posCMeasure(iFrame) = posCM;
    measurementError(iFrame) = error;
    
    % Calculate the uncertainty associated to the current measurement
    measurementUncertainty(iFrame) = k * (error^lambda);
    
    % Update the kalman filter
    kf.R = eye(2) * measurementUncertainty(iFrame);
    kf = kf.update(0, [posRM ; posCM]);    
    
    % Store the current state for plotting
    posREstimate(iFrame) = kf.x(1);      posCEstimate(iFrame) = kf.x(2); 
    velREstimate(iFrame) = kf.x(3);      velCEstimate(iFrame) = kf.x(4);
    posRCovariance(iFrame) = kf.P(1,1);  posCCovariance(iFrame) = kf.P(2,2);
    velRCovariance(iFrame) = kf.P(3,3);  velCCovariance(iFrame) = kf.P(4,4);    

    % DEBUG: Plot usefull information
    figure(stateFigure);
    subplot(411); plot(posREstimate(1:iFrame), 'ro-'); plot(posRReal(1:iFrame), 'go-');
    subplot(412); plot(posCEstimate(1:iFrame), 'ro-'); plot(posCReal(1:iFrame), 'go-');
    subplot(413); plot(velREstimate(1:iFrame), 'ro-'); plot(velRReal(1:iFrame), 'go-');
    subplot(414); plot(velCEstimate(1:iFrame), 'ro-'); plot(velCReal(1:iFrame), 'go-');
    
    figure(covarianceFigure);
    subplot(411); plot(posRCovariance(1:iFrame), 'ro-');
    subplot(412); plot(posCCovariance(1:iFrame), 'ro-');
    subplot(413); plot(velRCovariance(1:iFrame), 'ro-');
    subplot(414); plot(velCCovariance(1:iFrame), 'ro-');
    
    figure(pathFigure);
    plot(posCReal(2:iFrame), posRReal(2:iFrame), 'go-');
    plot(posCEstimate(2:iFrame), posREstimate(2:iFrame), 'ro-');
    plot(posCMeasure(2:iFrame), posRMeasure(2:iFrame), 'b*'); 
    
    figure(frameFigure);
    idisp(frame, 'plain');
    set(gca,'position',[0 0 1 1],'units','normalized')
    hold on;
%     plot(posCReal(2:iFrame), posRReal(2:iFrame), 'g*');
%     plot(posCMeasure(2:iFrame), posRMeasure(2:iFrame), 'b*');
    plot(posCEstimate(1:iFrame), posREstimate(1:iFrame), 'r*');
    
    figure(debugFigure);
    plot(estimationError(1:iFrame), 'ro-');    
    
%     pause();
   
end


function [posR posC error] = performMeasurement(frame, state)

global windowSize net thresholdPercentage

cropWindow = imageCropper(frame, [state(1) state(2)], windowSize);
netOutput = net(reshape(cropWindow, 23^2, 1));
outputImage = reshape(netOutput, 23, 23);
thresh = findImageThreshold(outputImage, thresholdPercentage);
% thresh = defaultThresh;
needleMask = im2bw(outputImage, thresh);


[deltaR deltaC error] = needleTipFinder(needleMask, atan(state(3)/state(4)));
posR = state(1) + deltaR;
posC = state(2) + deltaC;

