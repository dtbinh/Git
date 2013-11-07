% Visão Computacional - avaliação 2
%   Script para testar as funções implementadas na QUESTÃO 1 da avaliação
%
%   Funções implementadas: houghLines, plotHoughLines
%   Outras funções utilizadas: iread, edge, imshow, imadjust

%  Autor: André Augusto Geraldes
%  E-mail: andregeraldes@lara.unb.br
%  Outubro 2013

close all;
clear all;

%% Carregamento e detecção de bordas das imagens a serem testadas

% Carregamento das 3 imagens, através da função iread (Toolbox Peter Corke)
I1 = iread('houghtest1.bmp');
I2 = iread('traces1.jpg', 'grey', 'double');
I3 = iread('frontpage.jpg', 'grey', 'double');

% Detecção de bordas das imagens I2 e I3, usando o algoritmo de Canny
EI1 = I1;
EI2 = edge(I2, 'canny', [0.1 0.25]);
EI3 = edge(I3, 'canny', [0.0 0.10]);

% Exibição das imagens tratadas
figure;
subplot(231); imshow(I1);  title('Imagem 1'); ylabel('Imagens Originais');
subplot(232); imshow(I2);  title('Imagem 2');
subplot(233); imshow(I3);  title('Imagem 3');
subplot(234); imshow(EI1); title('Bordas 1'); ylabel('Detecção de bordas');
subplot(235); imshow(EI2); title('Bordas 2');
subplot(236); imshow(EI3); title('Bordas 3');

%% Detecção de retas na Imagem 1

% Aplicar a transformada Hough na imagem e identificar as retas mais fortes
[L1 H1 R1 T1] = houghLines(EI1, 'thetaStep', 1, 'rhoStep', 1, 'maxLines', 10);

% Plotar a transformada Hough da imagem para visualização
figure;
imshow(imadjust(mat2gray(H1)),'XData',T1,'YData',R1, 'InitialMagnification','fit');
set(gca,'position',[0 0 1 1],'units','normalized')
title('Transformada Hough da imagem 1');
xlabel('\theta'), ylabel('\rho');
axis on, axis normal, hold on;
colormap(hot);

% Exibir a imagem e desenhar as retas identificadas
plotHoughLines(EI1, L1);

%% Detecção de retas na Imagem 2

% Aplicar a transformada Hough na imagem e identificar as retas mais fortes
[L2 H2 R2 T2] = houghLines(EI2, 'thetaStep', 1, 'roStep', 1, 'maxLines', 10, 'lineThresh', 300, 'NHood', 9);

% Plotar a transformada Hough da imagem para visualização
figure;
imshow(imadjust(mat2gray(H2)),'XData',T2,'YData',R2, 'InitialMagnification','fit');
set(gca,'position',[0 0 1 1],'units','normalized')
title('Transformada Hough da imagem 2');
xlabel('\theta'), ylabel('\rho');
axis on, axis normal, hold on;
colormap(hot);

% Exibir a imagem e desenhar as retas identificadas
plotHoughLines(EI2, L2);

%% Detecção de retas na Imagem 3

% Aplicar a transformada Hough na imagem e identificar as retas mais fortes
[L3 H3 R3 T3] = houghLines(EI3, 'thetaStep', 1, 'roStep', 1, 'maxLines', 20, 'NHood', 7);

% Plotar a transformada Hough da imagem para visualização
figure;
imshow(imadjust(mat2gray(H3)),'XData',T3,'YData',R3, 'InitialMagnification','fit');
set(gca,'position',[0 0 1 1],'units','normalized')
title('Transformada Hough da imagem 3');
xlabel('\theta'), ylabel('\rho');
axis on, axis normal, hold on;
colormap(hot);

% Exibir a imagem e desenhar as retas identificadas
plotHoughLines(EI3, L3);
