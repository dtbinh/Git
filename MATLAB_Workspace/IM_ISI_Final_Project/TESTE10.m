function TESTE10()

close all;
clear all;

%% Basic Parameters

global windowSize net thresholdPercentage netFrame
global tipRMeasure tipCMeasure tipErrorMeasure
global posRReal posCReal nRow nColumn

netFrame = 1;
windowSize = 5*23;

uncertaintyThreshold = 10^2;
uncertaintyLimit = 5*10^3;

% Prediction Uncertainty: determines how fast the uncertainty grows in the
% absence of usefull data. It shouldn't be very high.
predictionUncertainty = 10^(2.2);





% Parameters for when we are lost
uncertaintyScale = 0.008;

% Parameters for judging bad measurements
k = 10^9;
lambda = 9;




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
% k = 10^9;
% lambda = 8;


%% Load video and network and groundthruth

% Read the video file

videoFile = '12-30-18.mpg';
GTFile = '12-30-18_measurements.mat';

% videoFile = '12-38-33.mpg';
% GTFile = '12-38-33_measurements.mat';

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
startFrame = 11;
nRow = size(video, 1);
nColumn = size(video, 2);
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
nFrame = 100;
for iFrame = startFrame+1:nFrame
    fprintf('Frame: %d/%d\n', iFrame, nFrame)
    
    % Read the current frame
    frame4 = im2double(rgb2gray(video(:,:,:,iFrame)));
%     frame3 = im2double(rgb2gray(video(:,:,:,iFrame-1)));
%     frame2 = im2double(rgb2gray(video(:,:,:,iFrame-2)));
%     frame1 = im2double(rgb2gray(video(:,:,:,iFrame-3)));
    
    % Perform one measurement
    maxUncertainty = max(kf.P(1,1), kf.P(2,2));
    if(maxUncertainty < uncertaintyThreshold)
        [posRM posCM error] = performMeasurement(frame4, kf.x, iFrame);
    else
        fprintf('Hang on! Things are getting cofusing around here\n');
        M = uncertaintyScale * min(maxUncertainty, uncertaintyLimit);
        posRMVector = zeros(1,5); posCMVector = zeros(1,4); errorVector = zeros(1,4);
        [posRMVector(1) posCMVector(1) errorVector(1)] = performMeasurement(frame4, [kf.x(1)-M kf.x(2)-M kf.x(3) kf.x(4)], iFrame);
        [posRMVector(2) posCMVector(2) errorVector(2)] = performMeasurement(frame4, [kf.x(1)-M kf.x(2)+M kf.x(3) kf.x(4)], iFrame);
        [posRMVector(3) posCMVector(3) errorVector(3)] = performMeasurement(frame4, [kf.x(1)+M kf.x(2)+M kf.x(3) kf.x(4)], iFrame);
        [posRMVector(4) posCMVector(4) errorVector(4)] = performMeasurement(frame4, [kf.x(1)+M kf.x(2)-M kf.x(3) kf.x(4)], iFrame);
        [posRMVector(5) posCMVector(5) errorVector(5)] = performMeasurement(frame4, [kf.x(1)   kf.x(2)   kf.x(3) kf.x(4)], iFrame);
        
        [error, index] = min(errorVector);
        posRM = posRMVector(index);
        posCM = posCMVector(index);
    end
    
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
%     if(estimationError(iFrame) > 50)
%         fprintf('ERROR TOO HIGH: %f\n', estimationError(iFrame));
%         break;
%     end
    
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
    plot(posCReal(startFrame:iFrame), posRReal(startFrame:iFrame), 'g*');
%     plot(posCMeasure(startFrame:iFrame), posRMeasure(startFrame:iFrame), 'b*');
    plot(posCEstimate(startFrame:iFrame), posREstimate(startFrame:iFrame), 'r*');
    
    figure(debugFigure);
    plot(estimationError(1:iFrame), 'ro-');    
    
%     pause();
   
end

% fprintf('TEST FINISHED - ERROR = %d\n', estimationError(nFrame));
% figure; plot(estimationError(1:iFrame), 'ro-');
% measurementUncertainty = min(measurementUncertainty, 10^3);
% figure; plot(measurementUncertainty(1:iFrame), 'bo-');


% function [posR posC error] = performMeasurement(frame4, frame3, frame2, frame1, state, iFrame)
function [posR posC error] = performMeasurement(frame4, state, iFrame)

global windowSize net thresholdPercentage netFrame
global tipRMeasure tipCMeasure tipErrorMeasure
global posRReal posCReal nRow nColumn

threshold = 0.3;
W = 151; Z = 23; V = 5*Z; HV = (V-1)/2;
ci = round(state(1));
cj = round(state(2));

ci = max(ci, HV+1);
ci = min(ci, nRow-HV);
cj = max(cj, HV+1);
cj = min(cj, nColumn-HV);


frame4 = frame4(ci-HV:ci+HV, cj-HV:cj+HV);
inputData4 = reshape(imresize(frame4, [Z Z]), Z*Z, 1);
netOutput = net(inputData4);

deltaRGT = round((V+1)/2 + (posRReal(iFrame) - ci));
deltaCGT = round((V+1)/2 + (posCReal(iFrame) - cj));
[deltaR deltaC error] = needleTipFinder(imresize(reshape(im2bw(netOutput, threshold), Z, Z), [V V]), atan(state(3)/state(4)));

deltaRM = round((V+1)/2 + deltaR);
deltaCM = round((V+1)/2 + deltaC);
error2 = measurementEvaluator(imresize(reshape(inputData4, Z, Z), [V V]), imresize(reshape(im2bw(netOutput, threshold), Z, Z), [V V]), [deltaRGT deltaCGT], [deltaRM deltaCM]);
% pause();

posR = ci + deltaR;
posC = cj + deltaC;



