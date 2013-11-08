function plotMap(mapFile)

%
% FUNCTION DESCRIPTION
%

mapStruct = load(mapFile);

figure;
idisp(mapStruct.mapLabel);