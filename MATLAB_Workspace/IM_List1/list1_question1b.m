clear all;
close all;

shapes = rgb2gray(imread('shapes1.png'));

sobel = [1 0 -1; 2 0 -2; 1 0 -1];

edges0 = edgeDirection(shapes, sobel, 0);
edges45 = edgeDirection(shapes, sobel, 45);
edges90 = edgeDirection(shapes, sobel, 90);
edges135 = edgeDirection(shapes, sobel, -45);

figure(1);
subplot(2,2,1); imshow(edges0);
subplot(2,2,2); imshow(edges45);
subplot(2,2,3); imshow(edges90);
subplot(2,2,4); imshow(edges135);

threshold = 0.9;
edges0 = im2bw(edges0, threshold);
edges45 = im2bw(edges45, threshold);
edges90 = im2bw(edges90, threshold);
edges135 = im2bw(edges135, threshold);

figure(2);
subplot(2,2,1); imshow(edges0);
subplot(2,2,2); imshow(edges45);
subplot(2,2,3); imshow(edges90);
subplot(2,2,4); imshow(edges135);
