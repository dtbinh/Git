% Visão Computacional - avaliação 2
%   Script para testar as funções implementadas na QUESTÃO 4 da avaliação
%
%   Funções implementadas: rectifyImages, transformImageAndPoints, (funções
%   implementadas na questão 3)
%   Outras funções utilizadas: iread, idisp,
%   estimateUncalibratedRectification, 

%  Autor: André Augusto Geraldes
%  E-mail: andregeraldes@lara.unb.br
%  Outubro 2013

close all; 
clear all;

%% Imagem 1 - whouse

IL  = iread('whouse_left.png', 'grey', 'double');
IR = iread('whouse_right.png', 'grey', 'double');
P = load('whouse_points.txt');
PL = P(:,1:2);
PR = P(:,3:4);
rectifyImages(IL, IR, PL, PR);

%% Imagem 2 - telephone

IL  = iread('telephone_left.png', 'grey', 'double');
IR = iread('telephone_right.png', 'grey', 'double');
P = load('telephone_points.txt');
PL = P(:,1:2);
PR = P(:,3:4);
rectifyImages(IL, IR, PL, PR);

%% Imagem 3 - toy

IL  = iread('toy_left.png', 'grey', 'double');
IR = iread('toy_right.png', 'grey', 'double');
P = load('toy_points.txt');
PL = P(:,1:2);
PR = P(:,3:4);
rectifyImages(IL, IR, PL, PR);