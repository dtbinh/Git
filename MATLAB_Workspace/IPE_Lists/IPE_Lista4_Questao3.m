% Introdu��o aos Processos Estoc�sticos
%   Lista de Exerc�cios 4 - quest�o 3
%

%  Autor: Andr� Augusto Geraldes
%  E-mail: andregeraldes@lara.unb.br
%  Outubro 2014

close all;
clear all;

%% Gera��o de pontos uniformemente distribu�dos no quadrado de lado 2

nPoint = 1000;
pX = -1 + 2*rand(1, nPoint);
pY = -1 + 2*rand(1, nPoint);

%% Identifica��o dos pontos que est�o contidos no c�rculo da raio unit�rio

% Dist�ncia do ponto � origem
pointNorm = sqrt(pX.^2 + pY.^2);

% Se pointNorm � menor do que 1, o ponto pertence ao c�rculo unit�rio
circlePoint = pointNorm <= 1;

%% Estima��o do valor de Pi pela contagem dos pontos dentro do c�rculo

% Contagem cumulativa da quantidade de pontos dentro do c�rculo
circlePointCounting = cumsum(circlePoint);

% Estimativa de Pi
allPointCounting = 1:nPoint;
piEstimation = 4 * (circlePointCounting ./ allPointCounting);

%% Visualiza��o das amostras geradas

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

%% Visualiza��o do erro de estima��o

estimationError = pi - piEstimation;
figure; plot(estimationError);
title('Erro de estima��o de \pi');
xaxis([-nPoint/20 nPoint]);
xlabel('N'); ylabel('\epsilon(N)');