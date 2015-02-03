% Introdução aos Processos Estocásticos
%   Lista de Exercícios 4 - questão 1
%

%  Autor: André Augusto Geraldes
%  E-mail: andregeraldes@lara.unb.br
%  Outubro 2014

clear all;
close all;

%% Parâmetros globais

nSample = 100000;
nBin = 100;

%% Geração das amostras de uma FDP exponencial pelo método da inversa generalizada

u = rand(1, nSample);
y = -log(1 - u);

%% Comparação entre FDP teórica e a amostrada de y

% Geração da FDP analítica para Y ~ EXP(1)
ySample = 0:0.001:12;
yFPD = exp(-ySample);

% Normalização do histograma de Yb
[histY, binY] = hist(y, nBin);
histY = histY / trapz(binY, histY, 2);
barWidth = 1.16*(binY(2)-binY(1));

% Exibição da diferença entre a FDP teórica e amostrada
figure;
bar(binY, histY, 1);
xaxis([binY(1)-barWidth/2 binY(end)+barWidth/2]);
hold on;
plot(ySample, yFPD, 'r-');
title('FDP analítica (exponencial) e estimada por histograma para Y = -ln(X)');
legend('Histograma Normalizado de Y', 'p_y(y) = e^{-y}');
xlabel('Y');

%% Medição da média e da variância amostrais

meanY = mean(y)
varY = std(y)^2
