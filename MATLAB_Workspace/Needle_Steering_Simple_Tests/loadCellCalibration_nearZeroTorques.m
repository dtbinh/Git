% Script used for calculating the torque to AD counts conversion ratio,
% based on a calibration experiment performed with the SRI M3223 6-axis
% load cell

% Parameters
barAngle = 17.5;
Dmax = 38;
Dmin = 30;
D = mean([Dmax Dmin]);
weightLow = 0.075;
weightHigh = 0.303;

torqueLow = weightLow * gravity * cosd(barAngle) * D/2;
torqueHigh = weightHigh * gravity * cosd(barAngle) * D/2;

torques = [-torqueHigh -torqueLow 0 torqueLow torqueHigh];
adCounts = [32933 32989 33006 33024 33077];

coef = polyfit(torques, adCounts, 1);
zeroSlope = coef(1);
zeroOffset = coef(2);

figure; 
plot(torques, adCounts, 'k*');
hold on;
testTorque = [-50 50];
testMeasurements = testTorque*zeroSlope + zeroOffset;
plot(testTorque, testMeasurements, 'g-');

