clear all;
close all;

% lena = rgb2gray(imread('woman.png'));
lena = imread('woman.png');

gaus = [0.01 0.08 0.01; 0.08 0.64 0.08; 0.01 0.08 0.01];
mean = 1.0/9.0 * [1 1 1; 1 1 1; 1 1 1];

alpha = 0.15;

lenaGaus = myFilter(lena, gaus, 'uint8');
lenaMean = myFilter(lena, mean, 'uint8');

unsharpMaskGaus = (1+alpha)*lena + alpha*lenaGaus;
unsharpMaskMean = (1+alpha)*lena + alpha*lenaMean;

figure(1);
subplot(1,3,1); imshow(lena);
subplot(1,3,2); imshow(unsharpMaskGaus);
subplot(1,3,3); imshow(unsharpMaskMean);