% Vis�o Computacional - avalia��o 2
%   Script para testar as fun��es implementadas na QUEST�O 3 da avalia��o
%
%   Fun��es implementadas: eightPoint, epipolesLocation,
%   generateEpipolarLines, normalizePoints, findAndPlotEpipolarLines,
%   plotImagePointsAndEpipolarLines
%   Outras fun��es utilizadas: iread, idisp, e2h, h2e, reshape, svd, 

%  Autor: Andr� Augusto Geraldes
%  E-mail: andregeraldes@lara.unb.br
%  Outubro 2013

close all;
clear all;

%% Imagem 1 - whouse

imageLeft  = iread('whouse_left.png', 'grey', 'double');
imageRight = iread('whouse_right.png', 'grey', 'double');
points = load('whouse_points.txt');
pointsLeft  = points(:, 1:2);
pointsRight = points(:, 3:4);
findAndPlotEpipolarLines(imageLeft, imageRight, pointsLeft, pointsRight);

%% Imagem 2 - telephone

imageLeft  = iread('telephone_left.png', 'grey', 'double');
imageRight = iread('telephone_right.png', 'grey', 'double');
points = load('telephone_points.txt');
pointsLeft  = points(:, 1:2);
pointsRight = points(:, 3:4);
findAndPlotEpipolarLines(imageLeft, imageRight, pointsLeft, pointsRight);

%% Imagem 3 - toy

imageLeft  = iread('toy_left.png', 'grey', 'double');
imageRight = iread('toy_right.png', 'grey', 'double');
points = load('toy_points.txt');
pointsLeft  = points(:, 1:2);
pointsRight = points(:, 3:4);
findAndPlotEpipolarLines(imageLeft, imageRight, pointsLeft, pointsRight);