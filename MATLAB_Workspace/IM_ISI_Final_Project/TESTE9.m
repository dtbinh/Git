% function TESTE9(videoNumber, Aexp, Kexp, lambda)
function TESTE9()

close all;
clear all;

global net posRReal posCReal nRow nColumn uncertaintyScale debugMode mode4Frame


mode4Frame = 1;

debugMode = 0;
startFrame = 11;
stopFrame = 1000;

% videoNumber = 1;
% Aexp = 2;
% Kexp = 5;
% lambda = 4;
% uncertaintyScale = 0.003;
% stopFrame = 172;

videoNumber = 2;
Aexp = 2;
Kexp = 5;
lambda = 4;
uncertaintyScale = 0.001;

% videoNumber = 4;
% Aexp = 2;
% Kexp = 5;
% lambda = 4;
% uncertaintyScale = 0.003;
% nFrame = 265;

% CONCLUSOES: Os resultados não estão tão ruins, mas o tracker está tendo
% muita dificuldade de passar por umas situações especificas (atravessar
% uma mancha grande, inserção próxima à borda da imagem). Provavelmente
% isso ocorre porque haviam poucos exemplos desse tipo.

%% Basic Parameters



% Prediction Uncertainty: determines how fast the uncertainty grows in the
% absence of usefull data. It shouldn't be very high.
predictionUncertainty = 10^(1);

% Parameters for judging bad measurements
A = 10^Aexp;
k = 10^Kexp;

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
posRError = 0.0; posCError = 0.0; posUncertainty = 10^3;

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

userPresent = 0;
if(videoNumber == 1)
    videoFile = '12-30-18.mpg';
    GTFile = '12-30-18_measurements.mat';
    userFile = '12-30-18_luiza.mat';
    userPresent = 1;
elseif(videoNumber == 2)
    videoFile = '12-38-33.mpg';
    GTFile = '12-38-33_measurements.mat';
    userFile = '12-38-33_luiza.mat';
    userPresent = 1;
elseif(videoNumber == 3)
    videoFile = '12-27-06.mpg';
    GTFile = '12-27-06_measurements.mat';
    userFile = '12-27-06_luiza.mat';
    userPresent = 1;

    
    
else
    videoFile = '12-20-41.mpg';
    GTFile = '12-20-41_measurements.mat';
end
userPresent = 0;

video = read(mmreader(videoFile));
GT = load(GTFile);

% Load the trained network
if(mode4Frame)
    networkFile = 'bestNet_4Frame.mat';
else
    networkFile = 'bestNet_DiffFrame.mat';
end

netStruct = load(networkFile);
net = netStruct.net;

% Pre-process the video frames
nRow = size(video, 1);
nColumn = size(video, 2);
nFrame = size(video, 4);
videoFrames = zeros(nRow, nColumn, nFrame);
for iFrame = 1:nFrame
    videoFrames(:,:,iFrame) = im2double(rgb2gray(video(:,:,:,iFrame)));
end

%% Initialize variables for storing the measurements

% startFrame = 11;
% startFrame = 167;

posRMeasure = zeros(1, nFrame);
posCMeasure = zeros(1, nFrame);
measurementError = zeros(1, nFrame);
measurementUncertainty = zeros(1, nFrame);

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

%% Initialize the user data

if(userPresent)
    userStruct = load(userFile);
    posRUser = userStruct.posR;
    posCUser = userStruct.posC;
    userError = sqrt((posRUser-posRReal).^2+(posCUser-posCReal).^2);
end

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
posREstimate(startFrame) = posRReal(startFrame) * (1 + 2*posRError*rand() - posRError);
posCEstimate(startFrame) = posCReal(startFrame) * (1 + 2*posCError*rand() - posCError);
velREstimate(startFrame) = velRReal(startFrame) * (1 - velRError);
velCEstimate(startFrame) = velCReal(startFrame) * (1 - velCError);

posRCovariance(startFrame) = posUncertainty;
posCCovariance(startFrame) = posUncertainty;
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

% laraFigureDimensions = [    9  49 824 788;
%                           849  49 824 788;
%                         -1590 235 898 658;
%                          -560 536 550 350;
%                          -560  95 550 350];

laraFigureDimensions = [9  49 824 788;
849  49 824 788;
-1590 87 752 733;
-698   402   685   490;
 -560  95 550 350];
                 
homeFigureDimensions = [    9  49 667 531;
                      692  49 667 531;
                    -1590 185 898 658;
                     -560 486 550 350;
                     -560  45 550 350];         
                 
% figureDimensions = homeFigureDimensions;
figureDimensions = laraFigureDimensions;
                     

% State Estimation Figure
% stateFigure = figure;
% set(stateFigure, 'Position', figureDimensions(1,:));
% subplot(411); hold on; ylabel('POSITION R');
% subplot(412); hold on; ylabel('POSITION C');
% subplot(413); hold on; ylabel('VELOCITY R');
% subplot(414); hold on; ylabel('VELOCITY C');
% 
% % State Covariance Figure
% covarianceFigure = figure;
% set(covarianceFigure, 'Position', figureDimensions(2,:));
% subplot(411); hold on;
% subplot(412); hold on;
% subplot(413); hold on;
% subplot(414); hold on;

% Path Figure
pathFigure = figure;
set(pathFigure, 'Position', figureDimensions(3,:));
hold on;
set(gca,'YDir','reverse');
% set(gca,'position',[0 0 1 1],'units','normalized')
xaxis([0 90]);
yaxis([0 75]);
xlabel('X Position (mm)');
ylabel('Y Position (mm)');
set(gca, 'fontsize', 16);
xlhand = get(gca,'xlabel');
set(xlhand,'string','X Position (mm)','fontsize',20);
ylhand = get(gca,'ylabel');
set(ylhand,'string','Y Position (mm)','fontsize',20);

% Frame Figure
frameFigure = figure;
set(frameFigure, 'Position', figureDimensions(4,:));

% Debug Figure
debugFigure = figure;
set(debugFigure, 'Position', figureDimensions(5,:));
hold on; ylabel('Estimation Error'); yaxis(0, 150);

%% Iterate for each frame of the video
% OBS: frame 1 is used to generate the initial values for the variables and
% cannot be used, because there is no frame 0 to compare with


% lastGoodFrame = nFrame;
nFrame = min(nFrame, stopFrame);
for iFrame = startFrame+1:nFrame
%     fprintf('Frame: %d/%d\n', iFrame, nFrame)
    
    % Read the current frame
    frame4 = videoFrames(:,:,iFrame);
    frame3 = videoFrames(:,:,iFrame-1);
    frame2 = videoFrames(:,:,iFrame-2);
    frame1 = videoFrames(:,:,iFrame-3);
    
    % Perform one measurement
    maxUncertainty = max(abs(kf.P(1,1)), abs(kf.P(2,2)));
    [posRM posCM error] = performMeasurement(iFrame, frame4, frame3, frame2, frame1, kf.x, maxUncertainty);
    posRMeasure(iFrame) = posRM;
    posCMeasure(iFrame) = posCM;
    measurementError(iFrame) = error;
    
    % Calculate the uncertainty associated to the current measurement
    measurementUncertainty(iFrame) = A + k * (error^lambda);
    
    % Update the kalman filter
    kf.R = eye(2) * measurementUncertainty(iFrame);
    kf = kf.update(0, [posRM ; posCM]);    
    
    % Store the current state for plotting
    posREstimate(iFrame) = kf.x(1);      posCEstimate(iFrame) = kf.x(2); 
    velREstimate(iFrame) = kf.x(3);      velCEstimate(iFrame) = kf.x(4);
    posRCovariance(iFrame) = kf.P(1,1);  posCCovariance(iFrame) = kf.P(2,2);
    velRCovariance(iFrame) = kf.P(3,3);  velCCovariance(iFrame) = kf.P(4,4);    

    % DEBUG: Plot usefull information
    estimationError(iFrame) = pixel2mm(sqrt((posREstimate(iFrame)-posRReal(iFrame))^2+(posCEstimate(iFrame)-posCReal(iFrame))^2));
%     if(estimationError(iFrame) > 50)
%         lastGoodFrame = iFrame - 1;
%     end
    
%     figure(stateFigure);
%     subplot(411); plot(posREstimate(startFrame:iFrame), 'ro-'); plot(posRReal(startFrame:iFrame), 'go-');
%     subplot(412); plot(posCEstimate(startFrame:iFrame), 'ro-'); plot(posCReal(startFrame:iFrame), 'go-');
%     subplot(413); plot(velREstimate(startFrame:iFrame), 'ro-'); plot(velRReal(startFrame:iFrame), 'go-');
%     subplot(414); plot(velCEstimate(startFrame:iFrame), 'ro-'); plot(velCReal(startFrame:iFrame), 'go-');
%     
%     figure(covarianceFigure);
%     subplot(411); plot(posRCovariance(1:iFrame), 'ro-');
%     subplot(412); plot(posCCovariance(1:iFrame), 'ro-');
%     subplot(413); plot(velRCovariance(1:iFrame), 'ro-');
%     subplot(414); plot(velCCovariance(1:iFrame), 'ro-');
    
    figure(pathFigure);
    plot(pixel2mm(posCReal(startFrame:iFrame)), pixel2mm(posRReal(startFrame:iFrame)), 'gd-');
    plot(pixel2mm(posCEstimate(startFrame:iFrame)), pixel2mm(posREstimate(startFrame:iFrame)), 'b*-');
    plot(pixel2mm(posCMeasure(startFrame:iFrame)), pixel2mm(posRMeasure(startFrame:iFrame)), 'ro'); 
    legend('Ground truth', 'Estimation', 'Measurements');
%     if(userPresent)
%         plot(posCUser(startFrame:iFrame), posRUser(startFrame:iFrame), 'bo-');
%     end
    
    figure(frameFigure);
    idisp(frame4, 'plain');
%     set(gca,'position',[0 0 1 1],'units','normalized')
    hold on;
    plot(posCReal(startFrame:iFrame), posRReal(startFrame:iFrame), 'gd');
    plot(posCEstimate(startFrame:iFrame), posREstimate(startFrame:iFrame), 'b*');
    
    figure(debugFigure);
    hold off;
    plot(estimationError(startFrame:iFrame), 'r-');    
%     if(userPresent)
%         hold on;
%         plot(userError(1:iFrame), 'bo-');
%     end

%     pause(0.1);
   
end

% finalEstimationError = estimationError(nFrame);
% outputFileName = sprintf('tests/video%d/%s.mat', videoNumber, datestr(now,30));
% save(outputFileName, 'lastGoodFrame', 'finalEstimationError', 'estimationError', 'videoNumber', 'Aexp', 'Kexp', 'lambda');


function [posRM posCM error] = performMeasurement(iFrame, frame4, frame3, frame2, frame1, state, currentUncertainty)

% Global variables
global net posRReal posCReal nRow nColumn uncertaintyScale debugMode mode4Frame

% Global parameters
defaultThreshold = 0.3;
Z = 23; V = 5*Z; HV = (V-1)/2;

% Parameters specific to this function
offsetStep = 10;
maxCroppOffset = 1*offsetStep;

croppOffset = uncertaintyScale * currentUncertainty;
croppOffset = min(croppOffset, maxCroppOffset);
M = floor(croppOffset / offsetStep);

posRArray = zeros(1, 2*M+1);
posCArray = zeros(1, 2*M+1);
errorArray = zeros(1, 2*M+1);
iOffset = 1;

if(M > 0 && debugMode)
    fprintf('Hang on! Things are getting confusing. Performing %d measurements in a row\n', (2*M+1)^2);
end

for rowOffset = -M:M
    for columnOffset = -M:M
        
        % Calculate the current cropping point
        ci = round(state(1)) + rowOffset * offsetStep;
        cj = round(state(2)) + columnOffset * offsetStep;
        ci = max(ci, HV+1);
        ci = min(ci, nRow-HV);
        cj = max(cj, HV+1);
        cj = min(cj, nColumn-HV);
        
        % Cropp the provided frames
        frame4Cropped = frame4(ci-HV:ci+HV, cj-HV:cj+HV);
        frame3Cropped = frame3(ci-HV:ci+HV, cj-HV:cj+HV);
        frame2Cropped = frame2(ci-HV:ci+HV, cj-HV:cj+HV);
        frame1Cropped = frame1(ci-HV:ci+HV, cj-HV:cj+HV);
        frameDiff = frame4Cropped - frame3Cropped;
        
        % Feed the cropped frames into the neural network
        inputData4 = reshape(imresize(frame4Cropped, [Z Z]), Z*Z, 1);
        inputData3 = reshape(imresize(frame3Cropped, [Z Z]), Z*Z, 1);
        inputData2 = reshape(imresize(frame2Cropped, [Z Z]), Z*Z, 1);
        inputData1 = reshape(imresize(frame1Cropped, [Z Z]), Z*Z, 1);
        inputDataDiff = reshape(imresize(frameDiff, [Z Z]), Z*Z, 1);
        
        if(mode4Frame)
            netOutput = net([inputData4 ; inputData3 ; inputData2 ; inputData1]);
        else
            netOutput = net([inputData4 ; inputDataDiff]);
        end
        
        [H HC] = imhist(reshape(netOutput, Z, Z));
        ind = find(H > 0);
        threshold = defaultThreshold * HC(ind(length(ind)));
        
        if(debugMode)
            [deltaR deltaC error1] = needleTipFinder(imresize(reshape(im2bw(netOutput, threshold), Z, Z), [V V]), atan(state(3)/state(4)), 'debug');
            deltaRGT = round((V+1)/2 + (posRReal(iFrame) - ci));
            deltaCGT = round((V+1)/2 + (posCReal(iFrame) - cj));
            deltaRM = round((V+1)/2 + deltaR);
            deltaCM = round((V+1)/2 + deltaC);
            error2 = measurementEvaluator(imresize(reshape(inputData4, Z, Z), [V V]), imresize(reshape(im2bw(netOutput, threshold), Z, Z), [V V]), [deltaRGT deltaCGT], [deltaRM deltaCM]);
        else
            [deltaR deltaC error1] = needleTipFinder(imresize(reshape(im2bw(netOutput, threshold), Z, Z), [V V]), atan(state(3)/state(4)));
        end
        
        posRArray(iOffset) = ci + deltaR;
        posCArray(iOffset) = cj + deltaC;
        errorArray(iOffset) = error1;
        iOffset = iOffset + 1;
        
    end
end

[error, index] = min(errorArray);
posRM = posRArray(index);
posCM = posCArray(index);

if(M > 0 && debugMode)
    fprintf('The winning measurement was measurement no %d, with an uncertainty of %f\n', index, error);
end

function mmValue = pixel2mm(pixelValue)

mmValue = (pixelValue*70.0)/526;