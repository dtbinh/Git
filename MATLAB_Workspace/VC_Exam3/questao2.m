% Visão Computacional - avaliação 3
%   Script para testar as funções implementadas na QUESTÃO 2 da avaliação
%
%   Funções implementadas: createCuboid, plotCuboid, rotateCuboid,
%   rotationMatrix
%   Outras funções utilizadas: sym, subs, view, quiver3, fill3, scatter3

%  Autor: André Augusto Geraldes
%  E-mail: andregeraldes@lara.unb.br
%  Dezembro 2013

close all;
clear all;

%% PARTE 1 - ANÁLISE SIMBÓLICA

symbolicRotationMatrix

%% PARTE 2 - ROTAÇÃO DE UM CUBÓIDE

% Criar um cubóide centrado fora da origem
cuboid = createCuboid(1,1,1,5,4,3);
plotCuboid(cuboid);

% Girar o objeto de dois ângulos grandes em ordens diferentes
yAngle = 45;
zAngle = 60;
cuboidZY = rotateCuboid(rotateCuboid(cuboid,  [0 0 1], zAngle), [0 1 0], yAngle);
cuboidYZ = rotateCuboid(rotateCuboid(cuboid,  [0 1 0], yAngle), [0 0 1], zAngle);
plotCuboid(cuboidZY);
plotCuboid(cuboidYZ);

% Mostrar os objetos girados em diferentes vistas
plotCuboid(cuboidZY); view(0,0);
plotCuboid(cuboidZY); view(90,0);
plotCuboid(cuboidZY); view(0,90);

plotCuboid(cuboidYZ); view(0,0);
plotCuboid(cuboidYZ); view(90,0);
plotCuboid(cuboidYZ); view(0,90);

% Girar o objeto de dois ângulos pequenos em ordens diferentes
yAngle = 1;
zAngle = 2;
cuboidZY = rotateCuboid(rotateCuboid(cuboid,  [0 0 1], zAngle), [0 1 0], yAngle);
cuboidYZ = rotateCuboid(rotateCuboid(cuboid,  [0 1 0], yAngle), [0 0 1], zAngle);
plotCuboid(cuboidZY);
plotCuboid(cuboidYZ);

% Mostrar os objetos girados em diferentes vistas
plotCuboid(cuboidZY); view(0,0);
plotCuboid(cuboidZY); view(90,0);
plotCuboid(cuboidZY); view(0,90);

plotCuboid(cuboidYZ); view(0,0);
plotCuboid(cuboidYZ); view(90,0);
plotCuboid(cuboidYZ); view(0,90);
