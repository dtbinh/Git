% Script used for calculating the torque to AD counts conversion ratio,
% based on a calibration experiment performed with the SRI M3223 6-axis
% load cell

% Measurements
experiment3ADCounts = [33154
                       33198
                       33222
                       33244
                       33265
                       33288
                       33309
                       33331
                       33354
                       33375
                       33397
                       33417
                       33441
                       33464
                       33486
                       33510
                       33530]';
                   
experiment4ADCounts = [33170
                       33344
                       33438
                       33520
                       33612
                       33701
                       33788
                       33876
                       33961
                       34050
                       34141]';

% Parameters
R = 35;
D = 34;
L = 10;
barAngle = -0.1;
gravity = 9.8034;

% Calculating the torque imposed by the bar
barWeight = 0.038;
barLength = 402;
barForce = barWeight * gravity * cosd(barAngle);
barTorque = barForce * (barLength/2 - (R + D/2));

% Experiment 3 - lower load (75g)
load3Weight = 0.075;
load3MeasuredPositions = 20:20:320;

load3Positions = load3MeasuredPositions + (D+L)/2;
load3Force = load3Weight * gravity * cosd(barAngle);
load3Torques = load3Force * load3Positions;
experiment3Torques = ([0 load3Torques] + barTorque);

figure;
plot(experiment3Torques, experiment3ADCounts, 'b*-');

% Experiment 2 - higher load (303g)
load4Weight = 0.303;
load4MeasuredPositions = 20:20:200;

load4Positions = load4MeasuredPositions + (D+L)/2;
load4Force = load4Weight * gravity * cosd(barAngle);
load4Torques = load4Force * load4Positions;
experiment4Torques = ([0 load4Torques] + barTorque);

figure;
plot(experiment4Torques, experiment4ADCounts, 'b*-');


%% Calculate the linear regression coefficients from both experiments

% Experiment 3
experiment3Coefficients = polyfit(experiment3Torques, experiment3ADCounts, 1);
experiment3Slope = experiment3Coefficients(1);
experiment3Offset = experiment3Coefficients(2);

% Experiment 4
experiment4Coefficients = polyfit(experiment4Torques, experiment4ADCounts, 1);
experiment4Slope = experiment4Coefficients(1);
experiment4Offset = experiment4Coefficients(2);

% Combine experiment 1 and 2
positiveTorques = [experiment3Torques experiment4Torques];
positiveMeasurements = [experiment3ADCounts experiment4ADCounts];
positiveCoefficients = polyfit(positiveTorques, positiveMeasurements, 1);
positiveSlope = positiveCoefficients(1);
positiveOffset = positiveCoefficients(2);

figure; 
plot(positiveTorques, positiveMeasurements, 'b*');
hold on;
testTorque = [0 720];
testMeasurements = testTorque*positiveSlope + positiveOffset;
plot(testTorque, testMeasurements, 'r-');
