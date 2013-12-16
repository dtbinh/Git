% Vis�o Computacional - avalia��o 3
%   Script para testar as fun��es implementadas na QUEST�O 1 da avalia��o
%
%   Fun��es implementadas: imageGradient, constantFlow, plotOpticalFlow,
%   calculateAndPlotOpticalFlow, featurePointMatch
%   Outras fun��es utilizadas: iconv, idisp, iread, conv, dir, rcond,
%   repmat, reshape, ssd, quiver, fspecial, imfilter, imhist, interp2, 
%   meshgrid, ndgrid

%  Autor: Andr� Augusto Geraldes
%  E-mail: andregeraldes@lara.unb.br
%  Dezembro 2013

close all;
clear all;

%% constantFlow

% Sequ�ncia 1
[images1 flow1] = calculateAndPlotOpticalFlow('Seq1', 'vZero', 0.01, 'vSat', 1);

% Sequ�ncia 2
[images2 flow2] = calculateAndPlotOpticalFlow('Seq2', 'vZero', 0.4);

% Sequ�ncia 3
[images3 flow3] = calculateAndPlotOpticalFlow('Seq3', 'arrowSize', 10, 'pixelDist', 5, 'vZero', 0.5);

% Sequ�ncia 4
[images4 flow4] = calculateAndPlotOpticalFlow('Seq4', 'pixelDist', 3, 'vZero', 0.2);

% Sequ�ncia 5
[images5 flow5] = calculateAndPlotOpticalFlow('Seq5', 'pixelDist', 5);

% Sequ�ncia 6
[images6 flow6] = calculateAndPlotOpticalFlow('Seq6', 'arrowSize', 10, 'vSat', 1);

%% featurePointMatch

% Imagens tiradas da sequ�ncia 4
featurePointMatch('Seq4/VCBOX_A1.jpg', 'Seq4/VCBOX_A2.jpg', 'points-VCBOX_A1-VCBOX_A2.txt');

% Imagens tiradas da sequ�ncia 5
featurePointMatch('Seq5/BLOCKS_3.jpg', 'Seq5/BLOCKS_4.jpg', 'points-BLOCKS_3-BLOCKS_4.txt');

% Imagens tiradas da sequ�ncia 6
featurePointMatch('Seq6/SIMPLE02.jpg', 'Seq6/SIMPLE03.jpg', 'points-SIMPLE02-SIMPLE03.txt');