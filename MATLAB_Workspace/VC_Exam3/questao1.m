% Visão Computacional - avaliação 3
%   Script para testar as funções implementadas na QUESTÃO 1 da avaliação
%
%   Funções implementadas: imageGradient, constantFlow, plotOpticalFlow,
%   calculateAndPlotOpticalFlow, featurePointMatch
%   Outras funções utilizadas: iconv, idisp, iread, conv, dir, rcond,
%   repmat, reshape, ssd, quiver, fspecial, imfilter, imhist, interp2, 
%   meshgrid, ndgrid

%  Autor: André Augusto Geraldes
%  E-mail: andregeraldes@lara.unb.br
%  Dezembro 2013

close all;
clear all;

%% constantFlow

% Sequência 1
[images1 flow1] = calculateAndPlotOpticalFlow('Seq1', 'vZero', 0.01, 'vSat', 1);

% Sequência 2
[images2 flow2] = calculateAndPlotOpticalFlow('Seq2', 'vZero', 0.4);

% Sequência 3
[images3 flow3] = calculateAndPlotOpticalFlow('Seq3', 'arrowSize', 10, 'pixelDist', 5, 'vZero', 0.5);

% Sequência 4
[images4 flow4] = calculateAndPlotOpticalFlow('Seq4', 'pixelDist', 3, 'vZero', 0.2);

% Sequência 5
[images5 flow5] = calculateAndPlotOpticalFlow('Seq5', 'pixelDist', 5);

% Sequência 6
[images6 flow6] = calculateAndPlotOpticalFlow('Seq6', 'arrowSize', 10, 'vSat', 1);

%% featurePointMatch

% Imagens tiradas da sequência 4
featurePointMatch('Seq4/VCBOX_A1.jpg', 'Seq4/VCBOX_A2.jpg', 'points-VCBOX_A1-VCBOX_A2.txt');

% Imagens tiradas da sequência 5
featurePointMatch('Seq5/BLOCKS_3.jpg', 'Seq5/BLOCKS_4.jpg', 'points-BLOCKS_3-BLOCKS_4.txt');

% Imagens tiradas da sequência 6
featurePointMatch('Seq6/SIMPLE02.jpg', 'Seq6/SIMPLE03.jpg', 'points-SIMPLE02-SIMPLE03.txt');