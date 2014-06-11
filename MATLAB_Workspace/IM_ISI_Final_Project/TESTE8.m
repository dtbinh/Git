function TESTE8()

% close all;
% clear all;

%% Basic Parameters

global windowSize net thresholdPercentage netFrame
global tipRMeasure tipCMeasure tipErrorMeasure
global posRReal posCReal

% thresholdPercentage = 0.8;

% thresholdPercentage = 0.3;
netFrame = 1;
windowSize = 5*23;
% windowSize = 151;

% Prediction Uncertainty: determines how fast the uncertainty grows in the
% absence of usefull data. It shouldn't be very high.
predictionUncertainty = 10^2;


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
velRError = 0; velCError = 0; velUncertainty = 10^3;

% TEST5 [Medium]  - We have only guessed one velocity right
% velRError = 0; velCError = 0.1; velUncertainty = 10^3;

% TEST6 [Hard]    - We have only guessed the right direction
% velRError = 0.1; velCError = 0.1; velUncertainty = 10^3;

% TEST7 [Hard]    - Our magnitude guess is very poor
% velRError = 0.50; velCError = 0.50; velUncertainty = 10^3;

% TEST8 [Hardest] - We don't know the initial velocity
% velRError = 1.0; velCError = 1.0; velUncertainty = 10^3;

%% Measurement Uncertainty Function

% This function must be adjusted so that good measurements are incorporated
% in the state estimation and bad measurements are rejected

% OBS: measureError will always be normalized
%      0: the measurement is completely certain
%      1: the measure can't be trusted at all

% Function: uncertainty = k * (measureError^lambda)
k = 10^0;
lambda = 1;


%% Load video and network and groundthruth

% Read the video file

% videoFile = '12-30-18.mpg';
% GTFile = '12-30-18_measurements.mat';

videoFile = '12-38-33.mpg';
GTFile = '12-38-33_measurements.mat';

% videoFile = '12-27-06.mpg';
% GTFile = '12-27-06_measurements.mat';

video = read(mmreader(videoFile));
GT = load(GTFile);

% Load the trained network
networkFile = '20140227T153448.mat';
netStruct = load(networkFile);
net = netStruct.net;

%% Initialize variables for storing the measurements

% startR = 160; startC = 600;
startFrame = 4;
nFrame = size(video, 4);
posRMeasure = zeros(1, nFrame);
posCMeasure = zeros(1, nFrame);
measurementError = zeros(1, nFrame);
measurementUncertainty = zeros(1, nFrame);

tipRMeasure = zeros(1, nFrame);
tipCMeasure = zeros(1, nFrame);
tipErrorMeasure = zeros(1, nFrame);

%% Generate the ground truth

% Read the predefined measurements from file
posRReal = GT.posR(1:nFrame);
posCReal = GT.posC(1:nFrame);
velRReal = posRReal(2:nFrame) - posRReal(1:nFrame-1);
velCReal = posCReal(2:nFrame) - posCReal(1:nFrame-1);
velRReal = [velRReal(1) velRReal];
velCReal = [velCReal(1) velCReal];

posRMeasure(startFrame) = posRReal(startFrame);
posCMeasure(startFrame) = posCReal(startFrame);

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
posREstimate(startFrame) = posRReal(startFrame);
posCEstimate(startFrame) = posCReal(startFrame);
velREstimate(startFrame) = velRReal(startFrame) * (1 - velRError);
velCEstimate(startFrame) = velCReal(startFrame) * (1 - velCError);

posRCovariance(startFrame) = 0;
posCCovariance(startFrame) = 0;
velRCovariance(startFrame) = velUncertainty;
velCCovariance(startFrame) = velUncertainty;

%% Initialize debug variables for analyzing the algorithm performance
estimationError = zeros(1, nFrame);

%% Build Kalman Filter
F = [1 0 1 0; 0 1 0 1; 0 0 1 0; 0 0 0 1];
G = [0 ; 0 ; 0 ; 0];
H = [1 0 0 0 ; 0 1 0 0];
Q = eye(4) * predictionUncertainty;
R = eye(2);
kf = KalmanFilter(F, G, H, Q, R);
kf.x = [posREstimate(startFrame) ; posCEstimate(startFrame) ; velREstimate(startFrame); velCEstimate(startFrame)];
kf.P = diag([posRCovariance(startFrame) posCCovariance(startFrame) velRCovariance(startFrame) velCCovariance(startFrame)]);       

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
for iFrame = startFrame+1:nFrame
    
    % Read the current frame
    frame4 = im2double(rgb2gray(video(:,:,:,iFrame)));
    frame3 = im2double(rgb2gray(video(:,:,:,iFrame-1)));
    frame2 = im2double(rgb2gray(video(:,:,:,iFrame-2)));
    frame1 = im2double(rgb2gray(video(:,:,:,iFrame-3)));
    
    % Perform one measurement
    [posRM posCM error] = performMeasurement(frame4, frame3, frame2, frame1, kf.x, iFrame);
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
    estimationError(iFrame) = sqrt((posREstimate(iFrame)-posRReal(iFrame))^2+(posCEstimate(iFrame)-posCReal(iFrame))^2);
    
    figure(stateFigure);
    subplot(411); plot(posREstimate(startFrame:iFrame), 'ro-'); plot(posRReal(startFrame:iFrame), 'go-');
    subplot(412); plot(posCEstimate(startFrame:iFrame), 'ro-'); plot(posCReal(startFrame:iFrame), 'go-');
    subplot(413); plot(velREstimate(startFrame:iFrame), 'ro-'); plot(velRReal(startFrame:iFrame), 'go-');
    subplot(414); plot(velCEstimate(startFrame:iFrame), 'ro-'); plot(velCReal(startFrame:iFrame), 'go-');
    
    figure(covarianceFigure);
    subplot(411); plot(posRCovariance(startFrame:iFrame), 'ro-');
    subplot(412); plot(posCCovariance(startFrame:iFrame), 'ro-');
    subplot(413); plot(velRCovariance(startFrame:iFrame), 'ro-');
    subplot(414); plot(velCCovariance(startFrame:iFrame), 'ro-');
    
    figure(pathFigure);
    plot(posCReal(startFrame:iFrame), posRReal(startFrame:iFrame), 'go-');
    plot(posCEstimate(startFrame:iFrame), posREstimate(startFrame:iFrame), 'ro-');
    plot(posCMeasure(startFrame:iFrame), posRMeasure(startFrame:iFrame), 'b*'); 
    
    figure(frameFigure);
    idisp(frame4, 'plain');
    set(gca,'position',[0 0 1 1],'units','normalized')
    hold on;
%     plot(posCReal(startFrame:iFrame), posRReal(startFrame:iFrame), 'g*');
%     plot(posCMeasure(startFrame:iFrame), posRMeasure(startFrame:iFrame), 'b*');
    plot(posCEstimate(startFrame:iFrame), posREstimate(startFrame:iFrame), 'r*');
    
    figure(debugFigure);
    plot(estimationError(1:iFrame), 'ro-');    
    
%     pause();
   
end

save('measurements.dat', 'posRMeasure', 'posCMeasure');


function [posR posC error] = performMeasurement(frame4, frame3, frame2, frame1, state, iFrame)

global windowSize net thresholdPercentage netFrame
global tipRMeasure tipCMeasure tipErrorMeasure
global posRReal posCReal

threshold = 0.3;
W = 151; Z = 23; V = 5*Z;
sR = round((2*W+1-V)*0.5);
sC = round((2*W+1-V)*0.5);
ci = round(state(1));
cj = round(state(2));

frame4 = frame4(ci-W+sR:ci-W+sR+V-1, cj-W+sC:cj-W+sC+V-1);
inputData4 = reshape(imresize(frame4, [Z Z]), Z*Z, 1);

frame3 = frame3(ci-W+sR:ci-W+sR+V-1, cj-W+sC:cj-W+sC+V-1);
inputData3 = reshape(imresize(frame3, [Z Z]), Z*Z, 1);

frame2 = frame2(ci-W+sR:ci-W+sR+V-1, cj-W+sC:cj-W+sC+V-1);
inputData2 = reshape(imresize(frame2, [Z Z]), Z*Z, 1);

frame1 = frame1(ci-W+sR:ci-W+sR+V-1, cj-W+sC:cj-W+sC+V-1);
inputData1 = reshape(imresize(frame1, [Z Z]), Z*Z, 1);

if(netFrame == 1)
    netOutput = net(inputData4);
elseif(netFrame == 2)
    netOutput = net([inputData4 ; inputData3]);
else
    netOutput = net([inputData4 ; inputData3 ; inputData2 ; inputData1]);
end

deltaRGT = round((V+1)/2 + (posRReal(iFrame) - state(1)) * (V / V));
deltaCGT = round((V+1)/2 + (posCReal(iFrame) - state(2)) * (V / V));
[deltaR deltaC error] = needleTipFinder_manual2(imresize(reshape(inputData4, Z, Z), [V V]), imresize(reshape(im2bw(netOutput, threshold), Z, Z), [V V]), [deltaRGT deltaCGT]);
% [deltaR deltaC error] = needleTipFinder_manual2(imresize(reshape(inputData4, Z, Z), [V V]), imresize(reshape(im2bw(netOutput, threshold), Z, Z), [V V]));
posR = state(1) + deltaR * (V / V);
posC = state(2) + deltaC * (V / V);


