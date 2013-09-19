clear all;
close all;

%% Comparing some high-pass filter masks such as Prewitt, Sobel an the DoG

lena = rgb2gray(imread('shapes1.png'));

prewitt = [1 0 -1; 1 0 -1; 1 0 -1]'
sobel = [1 0 -1; 2 0 -2; 1 0 -1]'
dog = [0.05 0 -0.05; 0.34 0 -0.34; 0.05 0 -0.05]'
dog8 = 8*dog;

lenaPrewitt = myFilter(lena, prewitt, 'abs-uint8');
lenaSobel = myFilter(lena, sobel, 'abs-uint8');
lenaDog = myFilter(lena, dog, 'abs-uint8');
lenaDog8 = myFilter(lena, dog8, 'abs-uint8');

figure(1);
subplot(2,2,1); imshow(lenaPrewitt);
subplot(2,2,2); imshow(lenaSobel);
subplot(2,2,3); imshow(lenaDog);
subplot(2,2,4); imshow(lenaDog8);
% From these images, it looks like Sobel is the best and the DoG is
% actually not so good. However the masks have different gains so we should
% better binarize the images before drawing a conclusion

% figure(2);
% subplot(2,2,1); imshow(im2bw(lenaPrewitt, 0.12));
% subplot(2,2,2); imshow(im2bw(lenaSobel, 0.15));
% subplot(2,2,3); imshow(im2bw(lenaDog, 0.018));
% subplot(2,2,4); imshow(im2bw(lenaDog8, 0.14));
% % From these images, it's very hard identify which filter provides better
% % edge detecting. It's safe to affirm then that the choice of one of these
% % filters is not an important parameter in the edge detection problem,
% % specially considering that other parameters provide a much greater impact
% % in the performance such as the threshold value, the non-maximum
% % supression technique, etc.