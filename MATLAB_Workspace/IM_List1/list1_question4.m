clear all;
close all;

woman = imread('woman.png');

unsharp = [-1/8 -2/8 -1/8 ; -2/8 20/8 -2/8 ; -1/8 -2/8 -1/8];

womanUnsharp = myFilter(woman, unsharp, 'uint8');

figure(1);
subplot(1,2,1); imshow(woman);
subplot(1,2,2); imshow(womanUnsharp);

