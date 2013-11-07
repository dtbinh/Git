% % Read the point cloud from text file
% cloud = load('nuvemdepontos.txt');
% 
% % Generate the depth image
% depth = pointCloud2DepthImage(cloud, 1);
% 
% % Apply the H-K segmentation
% shapes = rangeSurfPatches(depth);
% 
% % Plot the results
% figure;
% mesh(depth);
% 
% figure;
% idisp(depth, 'plain');
% 
% figure;
% colormap = [1 1 1; 0.5 0.5 0.5; 0 1 1; 1 1 0; 1 0.5 0; 0 0 1; 1 0 0];
% idisp(shapes, 'plain', 'colormap', colormap, 'bar');

close all;
clear all;

cloud = load('nuvemdepontos.txt');

%% cloud1

x1 = cloud(:,1);
y1 = cloud(:,2);
z1 = cloud(:,3);

figure;
plot3(x1, y1, z1, 'r*');

[xi1 yi1] = meshgrid(min(x1):max(x1), min(y1):max(y1));
zi1 = griddata(x1, y1, z1, xi1, yi1, 'cubic');

figure;
plot3(x1, y1, z1, 'r*');
hold on;
mesh(xi1, yi1, zi1);


%% cloud2

x1 = cloud(:,1);
y1 = cloud(:,3);
z1 = cloud(:,2);

[xi1 yi1] = meshgrid(min(x1):max(x1), min(y1):max(y1));
zi1 = griddata(x1, y1, z1, xi1, yi1, 'cubic');

figure;
plot3(x1, y1, z1, 'r*');
hold on;
mesh(xi1, yi1, zi1);



