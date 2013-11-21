function plotMap(mapFile)

%
% FUNCTION DESCRIPTION
%

% load the trained map
mapStruct = load(mapFile);

% Build a suitable colormap by setting similar colors to similar shaped
% digits. The chosen similarity order was: 3-5-8-6-9-0-4-2-1-7
colormap = zeros(10,3);
colormap(1+3,:) = [0.0000    0.0000    0.6667];
colormap(1+5,:) = [0.0000    0.0000    1.0000];
colormap(1+8,:) = [0.0000    0.3333    1.0000];
colormap(1+6,:) = [0.0000    0.6667    1.0000];
colormap(1+9,:) = [0.0000    1.0000    1.0000];
colormap(1+0,:) = [0.3333    1.0000    0.6667];
colormap(1+4,:) = [0.6667    1.0000    0.3333];
colormap(1+2,:) = [1.0000    1.0000    0.0000];
colormap(1+1,:) = [1.0000    0.6667    0.0000];
colormap(1+7,:) = [1.0000    0.3333    0.0000];

% Display the map using Peter Corke's function 'idisp'
figure;
idisp(mapStruct.mapLabel, 'plain', 'colormap', colormap, 'bar');