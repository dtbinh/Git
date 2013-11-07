% Vis�o Computacional - avalia��o 2
%   Script para testar as fun��es implementadas na QUEST�O 4 da avalia��o
%
%   Fun��es implementadas: rectifyImages, transformImageAndPoints, (fun��es
%   implementadas na quest�o 3)
%   Outras fun��es utilizadas: iread, idisp,
%   estimateUncalibratedRectification, 

%  Autor: Andr� Augusto Geraldes
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