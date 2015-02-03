% Introdução aos Processos Estocásticos
%   Lista de Exercícios 4 - questão 3
%

%  Autor: André Augusto Geraldes
%  E-mail: andregeraldes@lara.unb.br
%  Outubro 2014

close all;
clear all;

%% Geração de pontos uniformemente distribuídos no quadrado de lado 2

nPoint = 1000;
pX = -1 + 2*rand(1, nPoint);
pY = -1 + 2*rand(1, nPoint);

%% Identificação dos pontos que estão contidos no círculo da raio unitário

% Distância do ponto à origem
pointNorm = sqrt(pX.^2 + pY.^2);

% Se pointNorm é menor do que 1, o ponto pertence ao círculo unitário
circlePoint = pointNorm <= 1;

%% Estimação do valor de Pi pela contagem dos pontos dentro do círculo

% Contagem cumulativa da quantidade de pontos dentro do círculo
circlePointCounting = cumsum(circlePoint);

% Estimativa de Pi
allPointCounting = 1:nPoint;
piEstimation = 4 * (circlePointCounting ./ allPointCounting);

%% Visualização das amostras geradas

figure; hold on;
plot([-1 1 1 -1 -1], [-1 -1 1 1 -1],  'k-');
plot(cos(0:0.01:2*pi), sin(0:0.01:2*pi), 'k-');
xaxis([-1.1 1.1]); yaxis([-1.1 1.1]);
for iPoint = 1:nPoint
    if(circlePoint(iPoint))
        plot(pX(iPoint), pY(iPoint), 'b*');
    else
        plot(pX(iPoint), pY(iPoint), 'r*');
    end
end

%% Visualização do erro de estimação

estimationError = pi - piEstimation;
figure; plot(estimationError);
title('Erro de estimação de \pi');
xaxis([-nPoint/20 nPoint]);
xlabel('N'); ylabel('\epsilon(N)');