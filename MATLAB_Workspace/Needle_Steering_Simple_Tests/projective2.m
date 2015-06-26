close all;
clear all;

% Set up an input coordinate system so that the input image 
% fills the unit square with vertices (0 0),(1 0),(1 1),(0 1).
I = imread('Motor1_pos1.jpg');

moving  = [ 374  341;
            460 2169;
           1982 1893;
           1976  445];
            
% fixed  = [ 26  110;
%            18 2439;
%          3246 2427;
%          3258   34];            
     
% fixed  = [  0    0;
%             0 2440;
%          2440 2440;
%          2440    0];      
     
fixed  = [  0    0;
            0 1;
         1 1;
         1    0];      

scale = 5000;     
     
tform2 = fitgeotrans(moving, scale*fixed,'projective');
J2 = imwarp(I,tform2);

% x0 = 1;
% y0 = 1;
% l = 4000;
% Jsquare = J2(x0:x0+l, y0:y0+l, :);

subplot(1,2,1), imshow(I);
subplot(1,2,2), imshow(J2);