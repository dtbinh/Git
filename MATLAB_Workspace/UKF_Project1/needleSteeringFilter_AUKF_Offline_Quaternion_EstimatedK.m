function [estimationError measurementError filterError] = needleSteeringFilter_AUKF_Offline_Quaternion_EstimatedK(datasetFile, initialState, initialUncertainty, noise)

%% Load the simulation dataset

load(datasetFile);
nStep = length(U1);
startStep = 1;
stopStep = 2000;


%% Load the main parameters

posXInitial = initialState(1);
posYInitial = initialState(2);
posZInitial = initialState(3);
angleR1Initial = initialState(4);
angleR2Initial = initialState(5);
angleR3Initial = initialState(6);
kInitial = initialState(7);

posXUncertainty = initialUncertainty(1);
posYUncertainty = initialUncertainty(2);
posZUncertainty = initialUncertainty(3);
angleR1Uncertainty = initialUncertainty(4);
angleR2Uncertainty = initialUncertainty(5);
angleR3Uncertainty = initialUncertainty(6);
kUncertainty = initialUncertainty(7);

kNoise = noise(1);
u1Noise = noise(2);
u2Noise = noise(3);
pXNoise = noise(4);
pYNoise = noise(5);

%% Initialize variables for storing the estimated values

posXEstimate = zeros(1,nStep);
posYEstimate = zeros(1,nStep);
posZEstimate = zeros(1,nStep);
angleR1Estimate = zeros(1,nStep);
angleR2Estimate = zeros(1,nStep);
angleR3Estimate = zeros(1,nStep);

for iStep = 1:stopStep
    if(iStep > 1)
        augmentedState = [posXEstimate(iStep-1); 
                          posYEstimate(iStep-1);
                          posZEstimate(iStep-1);
                          angleR1Estimate(iStep-1);
                          angleR2Estimate(iStep-1);
                          angleR3Estimate(iStep-1);
                          avgK;
                          zeros(5,1)];
    else
        augmentedState = [zeros(6,1); avgK; zeros(5,1)];
    end
    nextState = processFunction(augmentedState, [U1(iStep) U2(iStep)]);
    
    posXEstimate(iStep) = nextState(1);
    posYEstimate(iStep) = nextState(2);
    posZEstimate(iStep) = nextState(3);
    angleR1Estimate(iStep) = nextState(4);
    angleR2Estimate(iStep) = nextState(5);
    angleR3Estimate(iStep) = nextState(6);
    
end
estimationError = ((posXEstimate - pX).^2 + (posYEstimate - pY).^2).^(0.5);

%% Initialize variables for storing the measurements

posXMeasure = mX;
posYMeasure = mY;
measurementError = ((posXMeasure - pX).^2 + (posYMeasure - pY).^2).^(0.5);

%% Initialize variables for storing the filtered values

posXFiltered = zeros(1,nStep);
posYFiltered = zeros(1,nStep);
posZFiltered = zeros(1,nStep);
angleR1Filtered = zeros(1,nStep);
angleR2Filtered = zeros(1,nStep);
angleR3Filtered = zeros(1,nStep);
kFiltered = zeros(1,nStep);

posXCovariance = zeros(1,nStep);
posYCovariance = zeros(1,nStep);
posZCovariance = zeros(1,nStep);
angleR1Covariance = zeros(1,nStep);
angleR2Covariance = zeros(1,nStep);
angleR3Covariance = zeros(1,nStep);
kCovariance = zeros(1,nStep);

% Fill the initial values of all variables
posXFiltered(startStep) = posXInitial;
posYFiltered(startStep) = posYInitial;
posZFiltered(startStep) = posZInitial;
angleR1Filtered(startStep) = angleR1Initial;
angleR2Filtered(startStep) = angleR2Initial;
angleR3Filtered(startStep) = angleR3Initial;
kFiltered(startStep) = kInitial;

posXCovariance(startStep) = posXUncertainty;
posYCovariance(startStep) = posYUncertainty;
posZCovariance(startStep) = posZUncertainty;
angleR1Covariance(startStep) = angleR1Uncertainty;
angleR2Covariance(startStep) = angleR2Uncertainty;
angleR3Covariance(startStep) = angleR3Uncertainty;
kCovariance(startStep) = kUncertainty;

%% Initialize UKF

Q = diag([kNoise; u1Noise; u2Noise]);
R = diag([pXNoise; pYNoise]);
dimX = 7;
dimZ = 2;
ukf = HomMinSymAUKF(@processFunction, [], @measurementFunction, [], Q, R, dimX, dimZ);
ukf.x = [posXFiltered(startStep);
         posYFiltered(startStep);
         posZFiltered(startStep);
         angleR1Filtered(startStep);
         angleR2Filtered(startStep);
         angleR3Filtered(startStep);
         kFiltered(startStep)];

Pmatrix = [posXCovariance(startStep);
           posYCovariance(startStep);
           posZCovariance(startStep);
           angleR1Covariance(startStep);
           angleR2Covariance(startStep);
           angleR3Covariance(startStep);
           kCovariance(startStep)];
ukf.P = diag(Pmatrix);       

%% Main Loop

for iStep = 1:stopStep
    
    % Apply one control input
    u = [U1(iStep); U2(iStep)];
    
    % Perform one measurement
    z = [posXMeasure(iStep) ; posYMeasure(iStep)];
    
    % Update the filter feeding it with one control input and one
    % measurement
    ukf = ukf.update(u, z);
    
    % Store the current state for plotting
    posXFiltered(iStep) = ukf.x(1);
    posYFiltered(iStep) = ukf.x(2);
    posZFiltered(iStep) = ukf.x(3);
    angleR1Filtered(iStep) = ukf.x(4);
    angleR2Filtered(iStep) = ukf.x(5);
    angleR3Filtered(iStep) = ukf.x(6);
    kFiltered(iStep) = ukf.x(7);
    
    posXCovariance(iStep) = ukf.P(1,1);
    posYCovariance(iStep) = ukf.P(2,2);
    posZCovariance(iStep) = ukf.P(3,3);
    angleR1Covariance(iStep) = ukf.P(4,4);
    angleR2Covariance(iStep) = ukf.P(5,5);
    angleR3Covariance(iStep) = ukf.P(6,6);
    kCovariance(iStep) = ukf.P(7,7);    

end
filterError = ((posXFiltered - pX).^2 + (posYFiltered - pY).^2).^(0.5);

%% Initialize all windows

pathFigure = figure;
set(pathFigure, 'Position', [-1590 185 898 658]);
hold on;

debugFigure = figure;
set(debugFigure, 'Position', [-560  45 550 350]);
hold on;

kFigure = figure;
set(kFigure, 'Position', [-560  520 550 350]);
hold on;

%% Display debug information

figure(pathFigure);
plot(pX(startStep:iStep), pY(startStep:iStep), 'kd');
plot(posXEstimate(startStep:iStep), posYEstimate(startStep:iStep), 'g-');
plot(posXMeasure(startStep:iStep), posYMeasure(startStep:iStep), 'bo');
plot(posXFiltered(startStep:iStep), posYFiltered(startStep:iStep), 'r*-');
legend('Ground truth', 'Estimation', 'Measurements', 'Filtered');

figure(debugFigure);
plot(estimationError(startStep:iStep), 'g-');
plot(measurementError(startStep:iStep), 'b-');
plot(filterError(startStep:iStep), 'r-');
legend('Estimation', 'Measurements', 'Filtered');

figure(kFigure);
plot(k, 'r');
plot(kFiltered, 'b');

error1 = round(1000 * estimationError(stopStep));
error2 = round(1000 * mean(measurementError(stopStep-20:stopStep)));
error3 = round(1000 * filterError(stopStep));
error4 = round(1000 * max(filterError));
error5 = round(1000 * mean(filterError));
error6 = round(1000 * mean(filterError(stopStep-199:stopStep)));
fprintf('Final Errors (mm): \tEst = %d, \tMes = %d, \tFil = %d\n', error1, error2, error3);
fprintf('Estimation Error (mm): \tEnd = %d, \tMax = %d, \tAvg = %d, \tAvg200 = %d\n', error3, error4, error5, error6);

function processSigmaPoint = processFunction(sigmaPoint, parameter)

% Count the amount of sigma points
nPoint = size(sigmaPoint,2);

% Decode the sigma point components   
px = sigmaPoint(1,:);
py = sigmaPoint(2,:);
pz = sigmaPoint(3,:);
r1 = sigmaPoint(4,:);
r2 = sigmaPoint(5,:);
r3 = sigmaPoint(6,:);
kState = sigmaPoint(7,:);

k = kState + sigmaPoint(8,:);
u1 = parameter(1) + sigmaPoint(9,:);
u2 = parameter(2) + sigmaPoint(10,:);

% Find out which sigma points correspond to a null movement (for these
% sigma points, the quaternions should not be calculated)
nullMovementPoints = find(abs(u1) + abs(u2) == 0);

% Convert current state to dual quaternion
currentTranslation = [zeros(1,nPoint); px; py; pz];
currentRotation = angle2quat(r1, r2, r3);
currentPrimary = currentRotation;
currentDual = 0.5*quatmultiply(currentTranslation', currentRotation);

% Calculate the dual quaternion corresponding to the input signals
phi = (u2.^2 + (k.^2) .* (u1.^2)).^(0.5);
B = sin(phi/2) ./ phi;
incTranslation = [zeros(1,nPoint); u1; zeros(2,nPoint)];
incRotation = [cos(phi/2); B.*u2; zeros(1,nPoint); B.*u1.*k];
incPrimary = incRotation';
incDual = 0.5*quatmultiply(incTranslation', incRotation');

% Calculate the resulting dual quaternion
nextPrimary = quatmultiply(currentPrimary, incPrimary);
nextDual = quatmultiply(currentPrimary, incDual) + quatmultiply(currentDual, incPrimary);

% Decompose the resulting dual quaternion into the sigma point components
rotationQuaternion = nextPrimary;
conjugateMatrix = repmat([1 -1 -1 -1], nPoint, 1);
translationQuaternion = 2*quatmultiply(nextDual, nextPrimary .* conjugateMatrix);

[R1 R2 R3] = quat2angle(rotationQuaternion);
positions = translationQuaternion;

processSigmaPoint(1,:) = positions(:,2)';
processSigmaPoint(2,:) = positions(:,3)';
processSigmaPoint(3,:) = positions(:,4)';
processSigmaPoint(4,:) = R1';
processSigmaPoint(5,:) = R2';
processSigmaPoint(6,:) = R3';
processSigmaPoint(7,:) = k;

% Adjust the sigma points that correspond to null movement
processSigmaPoint(1,nullMovementPoints) = px(nullMovementPoints);
processSigmaPoint(2,nullMovementPoints) = py(nullMovementPoints);
processSigmaPoint(3,nullMovementPoints) = pz(nullMovementPoints);
processSigmaPoint(4,nullMovementPoints) = r1(nullMovementPoints);
processSigmaPoint(5,nullMovementPoints) = r2(nullMovementPoints);
processSigmaPoint(6,nullMovementPoints) = r3(nullMovementPoints);
processSigmaPoint(7,nullMovementPoints) = kState(nullMovementPoints);

% Copy the measurement noise components to be carried on
processSigmaPoint(8:9,:) = sigmaPoint(11:12,:);




function measurementSigmaPoint = measurementFunction(sigmaPoint, ~)

measurementSigmaPoint(1,:) = sigmaPoint(1,:) + sigmaPoint(8,:);
measurementSigmaPoint(2,:) = sigmaPoint(2,:) + sigmaPoint(9,:);


