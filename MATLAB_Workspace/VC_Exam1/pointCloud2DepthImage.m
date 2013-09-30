function zi = pointCloud2DepthImage(pointCloud, resolution)

% POINTCLOUD2DEPTHIMAGE Convert point cloud into a depth image
%    zi = pointCloud2DepthImage(pointCloud, resolution) is a range image
%    created from the points contained into the pointCloud. The parameter
%    resolution determines the spatial distance between two adjacent pixels
%    in zi. Note that selecting a small value for resolution may generate
%    large images, which can decrease the performance of gradient based
%    algorithms, such as the rangeSurfPatches function.
%
%
%  Other m-files required: none
%  Subfunctions: none
%  MAT-files required: none
%
% See also: RANGESURFPATCHES, MESHGRID, GRIDDATA

% Author: André Augusto Geraldes
% Email: andregeraldes@lara.unb.br
% September 2013; Last revision: 29-September-2013

%% Extract the vectors X, Y and Z from the point cloud

x = pointCloud(:,1);
y = pointCloud(:,2);
z = pointCloud(:,3);

%% Generate range vectors tx and ty based on X, Y and the selected resolution

xMin = floor(min(x)/resolution)*resolution;
xMax = ceil(max(x)/resolution)*resolution;
tx = xMin:resolution:xMax;

yMin = floor(min(y)/resolution)*resolution;
yMax = ceil(max(y)/resolution)*resolution;
ty = yMin:resolution:yMax;

%% Generate the depth image using the functions meshgrid and griddatta

[xi yi] = meshgrid(tx, ty);
zi = griddata(x, y, z, xi, yi);