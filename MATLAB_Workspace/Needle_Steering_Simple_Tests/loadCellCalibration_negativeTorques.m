% Script used for calculating the torque to AD counts conversion ratio,
% based on a calibration experiment performed with the SRI M3223 6-axis
% load cell

% Measurements
experiment1ADCounts = [32800
                       32758
                       32730
                       32708
                       32686
                       32663
                       32640
                       32621
                       32598
                       32576
                       32555
                       32530
                       32509
                       32487
                       32465
                       32444
                       32421]';
                   
experiment2ADCounts = [32800
                       32627
                       32532
                       32445
                       32350
                       32264
                       32176
                       32084
                       31995
                       31906
                       31814]';

% Parameters
R = 35;
D = 34;
L = 10;
barAngle = 0.3;
gravity = 9.8034;

% Calculating the torque imposed by the bar
barWeight = 0.038;
barLength = 402;
barForce = barWeight * gravity * cosd(barAngle);
barTorque = barForce * (barLength/2 - (R + D/2));

% Experiment 1 - lower load (75g)
load1Weight = 0.075;
load1MeasuredPositions = 20:20:320;

load1Positions = load1MeasuredPositions + (D+L)/2;
load1Force = load1Weight * gravity * cosd(barAngle);
load1Torques = load1Force * load1Positions;
experiment1Torques = ([0 load1Torques] + barTorque) * (-1);

figure;
plot(experiment1Torques, experiment1ADCounts, 'b*-');

% Experiment 2 - higher load (303g)
load2Weight = 0.303;
load2MeasuredPositions = 20:20:200;

load2Positions = load2MeasuredPositions + (D+L)/2;
load2Force = load2Weight * gravity * cosd(barAngle);
load2Torques = load2Force * load2Positions;
experiment2Torques = ([0 load2Torques] + barTorque) * (-1);

figure;
plot(experiment2Torques, experiment2ADCounts, 'b*-');


%% Calculate the linear regression coefficients from both experiments

% Experiment 1
experiment1Coefficients = polyfit(experiment1Torques, experiment1ADCounts, 1);
experiment1Slope = experiment1Coefficients(1);
experiment1Offset = experiment1Coefficients(2);

% Experiment 2
experiment2Coefficients = polyfit(experiment2Torques, experiment2ADCounts, 1);
experiment2Slope = experiment2Coefficients(1);
experiment2Offset = experiment2Coefficients(2);

% Combine experiment 1 and 2
negativeTorques = [experiment1Torques experiment2Torques];
negativeMeasurements = [experiment1ADCounts experiment2ADCounts];
negativeCoefficients = polyfit(negativeTorques, negativeMeasurements, 1);
negativeSlope = negativeCoefficients(1);
negativeOffset = negativeCoefficients(2);

figure; 
plot(negativeTorques, negativeMeasurements, 'b*');
hold on;
testTorque = [-720 0];
testMeasurements = testTorque*negativeSlope + negativeOffset;
plot(testTorque, testMeasurements, 'r-');
