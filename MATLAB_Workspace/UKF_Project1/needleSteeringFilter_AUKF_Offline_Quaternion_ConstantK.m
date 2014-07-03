function [estimationError measurementError filterError] = needleSteeringFilter_AUKF_Offline_Quaternion_ConstantK(datasetFile, initialState, initialUncertainty, noise)

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

posXUncertainty = initialUncertainty(1);
posYUncertainty = initialUncertainty(2);
posZUncertainty = initialUncertainty(3);
angleR1Uncertainty = initialUncertainty(4);
angleR2Uncertainty = initialUncertainty(5);
angleR3Uncertainty = initialUncertainty(6);

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
                          zeros(5,1)];
    else
        augmentedState = zeros(11,1);
    end
    nextState = processFunction(augmentedState, [avgK U1(iStep) U2(iStep)]);
    
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

posXCovariance = zeros(1,nStep);
posYCovariance = zeros(1,nStep);
posZCovariance = zeros(1,nStep);
angleR1Covariance = zeros(1,nStep);
angleR2Covariance = zeros(1,nStep);
angleR3Covariance = zeros(1,nStep);

% Fill the initial values of all variables
posXFiltered(startStep) = posXInitial;
posYFiltered(startStep) = posYInitial;
posZFiltered(startStep) = posZInitial;
angleR1Filtered(startStep) = angleR1Initial;
angleR2Filtered(startStep) = angleR2Initial;
angleR3Filtered(startStep) = angleR3Initial;

posXCovariance(startStep) = posXUncertainty;
posYCovariance(startStep) = posYUncertainty;
posZCovariance(startStep) = posZUncertainty;
angleR1Covariance(startStep) = angleR1Uncertainty;
angleR2Covariance(startStep) = angleR2Uncertainty;
angleR3Covariance(startStep) = angleR3Uncertainty;


%% Initialize UKF

Q = diag([kNoise; u1Noise; u2Noise]);
R = diag([pXNoise; pYNoise]);
dimX = 6;
dimZ = 2;
ukf = HomMinSymAUKF(@processFunction, avgK, @measurementFunction, [], Q, R, dimX, dimZ);
ukf.x = [posXFiltered(startStep);
         posYFiltered(startStep);
         posZFiltered(startStep);
         angleR1Filtered(startStep);
         angleR2Filtered(startStep);
         angleR3Filtered(startStep)];

Pmatrix = [posXCovariance(startStep);
           posYCovariance(startStep);
           posZCovariance(startStep);
           angleR1Covariance(startStep);
           angleR2Covariance(startStep);
           angleR3Covariance(startStep)];
ukf.P = diag(Pmatrix);       

%% Main Loop

for iStep = 1:stopStep
    
    if(mod(iStep, 20) == 0)
        fprintf('Simulation running: Step %d of %d\n', iStep, stopStep);
    end
    
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
    
    posXCovariance(iStep) = ukf.P(1,1);
    posYCovariance(iStep) = ukf.P(2,2);
    posZCovariance(iStep) = ukf.P(3,3);
    angleR1Covariance(iStep) = ukf.P(4,4);
    angleR2Covariance(iStep) = ukf.P(5,5);
    angleR3Covariance(iStep) = ukf.P(6,6);

end
filterError = ((posXFiltered - pX).^2 + (posYFiltered - pY).^2).^(0.5);

%% Initialize all windows

pathFigure = figure;
set(pathFigure, 'Position', [-1590 185 898 658]);
hold on;

% Debug Figure
debugFigure = figure;
set(debugFigure, 'Position', [-560  45 550 350]);
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

error1 = round(1000 * estimationError(stopStep));
error2 = round(1000 * mean(measurementError(stopStep-20:stopStep)));
error3 = round(1000 * filterError(stopStep));
error4 = round(1000 * max(filterError));
error5 = round(1000 * mean(filterError));
error6 = round(1000 * mean(filterError(stopStep-199:stopStep)));
fprintf('Final Errors (mm): \tEst = %d, \tMes = %d, \tFil = %d\n', error1, error2, error3);
fprintf('Estimation Error (mm): \tEnd = %d, \tMax = %d, \tAvg = %d, \tAvg200 = %d\n', error3, error4, error5, error6);

function processSigmaPoint = processFunction(sigmaPoint, parameter)

nPoint = size(sigmaPoint,2);
processSigmaPoint = zeros(8, nPoint);
N = 1;

for iPoint = 1:nPoint
    
    px = sigmaPoint(1,iPoint);
    py = sigmaPoint(2,iPoint);
    pz = sigmaPoint(3,iPoint);
    r1 = sigmaPoint(4,iPoint);
    r2 = sigmaPoint(5,iPoint);
    r3 = sigmaPoint(6,iPoint);
    k = parameter(1) + sigmaPoint(7,iPoint);
    u1 = parameter(2) + sigmaPoint(8,iPoint);
    u2 = parameter(3) + sigmaPoint(9,iPoint);
    
    if(u1 == 0 && u2 == 0)
        processSigmaPoint(1,iPoint) = px;
        processSigmaPoint(2,iPoint) = py;
        processSigmaPoint(3,iPoint) = pz;
        processSigmaPoint(4,iPoint) = r1;
        processSigmaPoint(5,iPoint) = r2;
        processSigmaPoint(6,iPoint) = r3;
    else
        
        % Convert current state to dual quaternion
        currentTranslation = [zeros(1,N); px; py; pz];
        currentRotation = angle2quat(r1, r2, r3);
        currentPrimary = currentRotation;
        currentDual = 0.5*quatmultiply(currentTranslation', currentRotation);
        
        % Update the current dual quaternion applying the input signals
        phi = sqrt(u2.^2 + (k.^2) .* (u1.^2));
        B = sin(phi/2) ./ phi;
        incTranslation = [zeros(1,N); u1; zeros(2,N)];
        incRotation = [cos(phi/2); B.*u2; zeros(1,N); B.*u1.*k];
        
        
        incPrimary = incRotation';
        incDual = 0.5*quatmultiply(incTranslation', incRotation');
        
        nextPrimary = quatmultiply(currentPrimary, incPrimary);
        nextDual = quatmultiply(currentPrimary, incDual) + quatmultiply(currentDual, incPrimary);
        
                
        % Extract the state components from the obtained dual quaternion
        rotationQuaternion = nextPrimary;
        conjugateMatrix = repmat([1 -1 -1 -1], N, 1);
        translationQuaternion = 2*quatmultiply(nextDual, nextPrimary .* conjugateMatrix);        
        
        [R1 R2 R3] = quat2angle(rotationQuaternion);
        positions = translationQuaternion;
        
        processSigmaPoint(1,iPoint) = positions(:,2)';
        processSigmaPoint(2,iPoint) = positions(:,3)';
        processSigmaPoint(3,iPoint) = positions(:,4)';
        processSigmaPoint(4,iPoint) = R1';
        processSigmaPoint(5,iPoint) = R2';
        processSigmaPoint(6,iPoint) = R3';
    end
    processSigmaPoint(7:8,iPoint) = sigmaPoint(10:11,iPoint);
end




function measurementSigmaPoint = measurementFunction(sigmaPoint, ~)

measurementSigmaPoint(1,:) = sigmaPoint(1,:) + sigmaPoint(7,:);
measurementSigmaPoint(2,:) = sigmaPoint(2,:) + sigmaPoint(8,:);


