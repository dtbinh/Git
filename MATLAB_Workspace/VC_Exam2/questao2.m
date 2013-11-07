% Visão Computacional - avaliação 2
%   Script para testar as funções implementadas na QUESTÃO 2 da avaliação
%
%   Funções implementadas: snake, imageGradient, range2
%   Outras funções utilizadas: iread, idisp

%  Autor: André Augusto Geraldes
%  E-mail: andregeraldes@lara.unb.br
%  Outubro 2013

close all;
clear all;

%% Carregamento das imagens a serem testadas

% Carregamento das 3 imagens, através da função iread (Toolbox Peter Corke)
I1 = iread('cup2.jpg', 'grey', 'double');
I2 = iread('wallet.jpg', 'grey', 'double');

%% Detecção do contorno da imagem 1

% Testes com diferentes valores de pesos
C1 = snake(I1, 'weights', [1 1 1.2], 'nPoint', 60);
C2 = snake(I1, 'weights', [1 1 2.0], 'nPoint', 60, 'tolerance', 0);
C3 = snake(I1, 'weights', [1 1 4.0], 'nPoint', 60, 'tolerance', 0);
C4 = snake(I1, 'weights', [1 1 8.0], 'nPoint', 60, 'tolerance', 0);
C5 = snake(I1, 'weights', [1 2.0 8.0], 'nPoint', 60, 'tolerance', 0);
C6 = snake(I1, 'weights', [1 4.0 8.0], 'nPoint', 60, 'tolerance', 0);

% Exibição do melhor resultado obtido
figure;
idisp(I1, 'plain');
hold on;
plot(C3{2}, C3{1}, 'r-');
set(gca,'position',[0 0 1 1],'units','normalized')

%% Detecção do contorno da imagem 2

W1 = snake(I2, 'weights', [1 1 1.2]);
W2 = snake(I2, 'weights', [1 1 2.0], 'tolerance', 0);
W3 = snake(I2, 'weights', [1 1 2.5], 'tolerance', 0);
W4 = snake(I2, 'weights', [1 1 2.5], 'tolerance', 0, 'curvThresh', 9);

% Exibição do melhor resultado obtido
figure;
idisp(I2, 'plain');
hold on;
plot(W4{2}, W4{1}, 'r-');
set(gca,'position',[0 0 1 1],'units','normalized')
