close all;

% Set up an input coordinate system so that the input image 
% fills the unit square with vertices (0 0),(1 0),(1 1),(0 1).
I = rgb2gray(imread('Motor1_pos1.jpg'));
udata = [0 1];  vdata = [0 1];

% % Transform to a quadrilateral with vertices (-4 2),(-8 3),
% % (-3 -5),(6 3).
% tform = maketform('projective',[ 0 0;  1  0;  1  1; 0 1],...
%                                [-4 2; -8 -3; -3 -5; 6 3]);
                           
% Transform to a quadrilateral with vertices (0 0),(1 0), (1 1),(0 1).
tform = maketform('projective',[ 0 0;  1  0;  1  1; 0 1],...
                               [ 0 0;  1.0/(0.4)  0;  1.0/(0.4)  1; 0 1]);                           

% Fill with gray and use bicubic interpolation. 
% Make the output size the same as the input size.

[B,xdata,ydata] = imtransform(I, tform, 'bicubic', ...
                              'udata', udata,...
                              'vdata', vdata,...
                              'size', size(I),...
                              'fill', 128);
subplot(1,2,1), imshow(I,'XData',udata,'YData',vdata), ...
   axis on 
subplot(1,2,2), imshow(B,'XData',xdata,'YData',ydata), ...
   axis on 