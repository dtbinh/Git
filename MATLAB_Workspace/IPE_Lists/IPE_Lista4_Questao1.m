% Introdu��o aos Processos Estoc�sticos
%   Lista de Exerc�cios 4 - quest�o 1
%

%  Autor: Andr� Augusto Geraldes
%  E-mail: andregeraldes@lara.unb.br
%  Outubro 2014

clear all;
close all;

%% Par�metros globais

nSample = 100000;
nBin = 100;

%% Gera��o das amostras de uma FDP exponencial pelo m�todo da inversa generalizada

u = rand(1, nSample);
y = -log(1 - u);

%% Compara��o entre FDP te�rica e a amostrada de y

% Gera��o da FDP anal�tica para Y ~ EXP(1)
ySample = 0:0.001:12;
yFPD = exp(-ySample);

% Normaliza��o do histograma de Yb
[histY, binY] = hist(y, nBin);
histY = histY / trapz(binY, histY, 2);
barWidth = 1.16*(binY(2)-binY(1));

% Exibi��o da diferen�a entre a FDP te�rica e amostrada
figure;
bar(binY, histY, 1);
xaxis([binY(1)-barWidth/2 binY(end)+barWidth/2]);
hold on;
plot(ySample, yFPD, 'r-');
title('FDP anal�tica (exponencial) e estimada por histograma para Y = -ln(X)');
legend('Histograma Normalizado de Y', 'p_y(y) = e^{-y}');
xlabel('Y');

%% Medi��o da m�dia e da vari�ncia amostrais

meanY = mean(y)
varY = std(y)^2
