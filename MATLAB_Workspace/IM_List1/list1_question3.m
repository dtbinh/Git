clear all;
close all;

%% Comparing the difference between 2 Laplacian masks

lena = rgb2gray(imread('lena_std.png'));

laplacian1 = [0 1 0; 1 -4 1; 0 1 0];
laplacian2 = [1 1 1; 1 -8 1; 1 1 1];

lenaL1 = myFilter(lena, laplacian1, 'abs-uint8');
lenaL2 = myFilter(lena, laplacian2, 'abs-uint8');

figure(1); imshow(lena);

figure(2);
subplot(1,2,1); imshow(lenaL1);
subplot(1,2,2); imshow(lenaL2);

diffLaplacian = abs(lenaL1 - lenaL2);
diffLaplacian = double(diffLaplacian - min(min(diffLaplacian)));
diffLaplacian = uint8(diffLaplacian * 255.0 / max(max(diffLaplacian)));
figure(3); imshow(diffLaplacian);
% In Lena, the greatest difference between the two Laplacian masks happens
% on her hair, but it's still insignificant

%% Testing what happens when you subtract two gaussians

gaus1 = gaussianKernel(0.1,3);
gaus2 = gaussianKernel(0.5,3);
gaus3 = gaussianKernel(1.0,3);
gaus4 = gaussianKernel(1.5,3);
gaus5 = gaussianKernel(5.0,3);

lena51 = myFilter(lena, gaus5 - gaus1, 'abs-uint8');

figure(4); imshow(lena51);


