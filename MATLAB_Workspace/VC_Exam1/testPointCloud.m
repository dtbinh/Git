% Read the point cloud from text file
cloud = load('nuvemdepontos.txt');

% Generate the depth image
depth = pointCloud2DepthImage(cloud, 1);

% Apply the H-K segmentation
shapes = rangeSurfPatches(depth);

% Plot the results
figure;
mesh(depth);

figure;
idisp(depth, 'plain');

figure;
colormap = [1 1 1; 0.5 0.5 0.5; 0 1 1; 1 1 0; 1 0.5 0; 0 0 1; 1 0 0];
idisp(shapes, 'plain', 'colormap', colormap, 'bar');