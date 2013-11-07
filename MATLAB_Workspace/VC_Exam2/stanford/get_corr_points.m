function get_corr_points()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This function is used to collect the corresponding points on two image
% and save it in variables: left_image_points, right_image_points.
%
% Currently it takes 20 points. One can chnge this value in the code.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

left_image  = double(rgb2gray(imread('rodin0020.jpg')));
right_image = double(rgb2gray(imread('rodin0021.jpg')));

[m n] = size(left_image);

figure, imagesc(left_image); colormap(gray); title('Click a point on this left image'); axis image; 
figure, imagesc(right_image);colormap(gray); title('Click the corresponding point on this right image'); axis image;

% It takes 20 points

for i=1:20
   
    figure(1);
    [left_x left_y] = ginput(1);
    hold on; plot(left_x, left_y,'rx'); 

	figure(2);
    [right_x right_y] = ginput(1);
    hold on; plot(right_x, right_y,'rx');
	
    left_image_points(i,1) = left_x;
    left_image_points(i,2) = left_y;
    right_image_points(i,1)= right_x;
    right_image_points(i,2)= right_y;
    
    save left_image_points;
    save right_image_points;
    
end
