clear all;
close all;

lena = rgb2gray(imread('lena_std.png'));
% lena = imread('chess.png');

lena_scale = double(lena - min(min(lena)));
lena_scale = uint8(lena_scale * 255.0 / max(max(lena_scale)));

figure(1);
subplot(2,2,1); imshow(lena_scale);
subplot(2,2,2); imshow(lena_scale);
subplot(2,2,3); imshow(lena_scale);
subplot(2,2,4); imshow(lena_scale);

figure(2);

% Low-pass filter - atenuates noise
% Since this mask has a higher than 1 gain, the filtered image must be
% rescaled, otherwise the resulted image is completely saturated
m1 = [ 1 2 1; 2 4 2; 1 2 1];
lenaM1 = myFilter(lena, m1, 'uint8');
subplot(2,2,1); imshow(lenaM1);

% High-pass filter - edge detection - sobel mask
m2 = [-1 0 1; -2 0 2; -1 0 1];
lenaM2 = myFilter(lena, m2, 'abs-uint8');
subplot(2,2,2); imshow(lenaM2);

% Laplacian of gaussian - aplies the second derivate in x and y - detects
% edges in x and y
% note that the laplacian is multiplie by *-1 (i have no idea why he did
% this)
m3 = [0 -1 0; -1 4 -1; 0 -1 0];
lenaM3 = myFilter(lena, m3, 'abs-uint8');
subplot(2,2,3); imshow(lenaM3);

% this one is the previous maks + a delta mask. This looks like unsharp
% masking but with a very high alpha
m4 = [0 -1 0; -1 5 -1; 0 -1 0];
lenaM4 = myFilter(lena, m4, 'abs-uint8');
subplot(2,2,4); imshow(lenaM4);















