% Introdu��o aos Processos Estoc�sticos
%   Lista de Exerc�cios 4 - quest�o 3
%

%  Autor: Andr� Augusto Geraldes
%  E-mail: andregeraldes@lara.unb.br
%  Outubro 2014

close all;
clear all;

%% Constru��o da FDP anal�tica

% Escolha dos par�metros das 5 gaussianas a serem combinadas
gMean = [0 1 3 6 10];
gVar = [0.6 0.3 0.8 1.2 0.9];
gW = [1.8 2.2 0.5 1 2.5];
gW = gW / sum(gW);

% Gera��o das FDPs das 5 gaussianas especificadas
xStep = 0.01;
xRange = 30;
x = -xRange:xStep:xRange;
gFDP = zeros(5, length(x));
for iGauss = 1:5
    gFDP(iGauss, :) = gaussmf(x, [gVar(iGauss), gMean(iGauss)]);
end

% Soma ponderada das 5 gaussianas para gerar a FDP de X
gFDP = gFDP .* repmat(gW', 1, length(x));
xFDP = sum(gFDP);

% Visualiza��o das fun��es geradas
figure; hold on;
plot(x, gFDP(1,:), 'b-');
plot(x, gFDP(2,:), 'g-');
plot(x, gFDP(3,:), 'r-');
plot(x, gFDP(4,:), 'c-');
plot(x, gFDP(5,:), 'm-');
plot(x, xFDP, 'k-');
xaxis([-5 15]);
title('FDP anal�tica gerada pela soma de 5 Gaussianas');
xlabel('X'); ylabel('p_x(x)');
legend(sprintf('N(%d,%0.1f) * %0.3f',gMean(1), gVar(1), gW(1)), ...
       sprintf('N(%d,%0.1f) * %0.3f',gMean(2), gVar(2), gW(2)), ...
       sprintf('N(%d,%0.1f) * %0.3f',gMean(3), gVar(3), gW(3)), ...
       sprintf('N(%d,%0.1f) * %0.3f',gMean(4), gVar(4), gW(4)), ...
       sprintf('N(%d,%0.1f) * %0.3f',gMean(5), gVar(5), gW(5)), ...
       'Soma das Gaussianas');

% Normaliza��o da FDP anal�tica (em rela��o � resolu��o das amostras)
xFDP = xFDP / (sum(xFDP) * xStep);

%% M�todo de aceita��o/rejei��o

% C�lculo do valor m�ximo da FDP de interesse
maxGaussianValue = max(xFDP);

% Inicializa��o do vetor para armazenar as amostras aceitas
nSampleAccept = 10^5;
acceptFDP = zeros(1, nSampleAccept);
iSample = 1;

% Iterar at� que uma quantidade suficiente de amostras seja aceita
while iSample <= nSampleAccept
    
    % Gerar uma amostra e localiza-la no vetor x
    xSample = -xRange + 2*xRange*rand();
    xIndex = find(x > xSample);
    
    % Gerar uma amostra uniforme e decidir se a amostra de x vai ser aceita
    uSample = rand();
    if(uSample <= xFDP(xIndex(1)) / maxGaussianValue)
        acceptFDP(iSample) = xSample;
        iSample = iSample + 1;
    end
end

% Normaliza��o do histograma de acceptFDP
nBinAccept = 100;
[histAccept, binAccept] = hist(acceptFDP, nBinAccept);
histAccept = histAccept / trapz(binAccept, histAccept, 2);

% Visualiza��o da FDP gerada e compara��o com a FDP anal�tica
figure;
bar(binAccept, histAccept, 1);
hold on;
plot(x, xFDP, 'r-');
xaxis([-5 15]);
title('FDP anal�tica e estimada pelo m�todo de aceita��o/rejei��o (100000 amostras)');
legend('Histograma das amostras obtidas por aceita��o/rejei��o', 'FDP anal�tica');
xlabel('X'); ylabel('p_x(x)');

%% M�todo da mistura

% C�lculo do vetor de pesos cumulados
cumulativeGW = cumsum(gW);

% Inicializa��o do vetor para armazenar as amostras misturadas
nSampleMixture = 10^6;
mixtureFDP = zeros(1, nSampleMixture);

for iSample = 1:nSampleMixture
    
    % Gerar uma amostra uniforme
    u = rand();
    
    % Decidir qual gaussiana ser� utilizada (com base nos pesos)
    index = find(cumulativeGW > u);
    
    % Gerar uma amostra gaussiana e inclui-la na FDP misturada
    mixtureFDP(iSample) = normrnd(gMean(index(1)), gVar(index(1)));
end

% Normaliza��o do histograma de mixtureFDP
nBinMixture = 100;
[histMixture, binMixture] = hist(mixtureFDP, nBinMixture);
histMixture = histMixture / trapz(binMixture, histMixture, 2);

% Visualiza��o da FDP gerada e compara��o com a FDP anal�tica
figure;
bar(binMixture, histMixture, 1);
hold on;
plot(x, xFDP, 'r-');
xaxis([-5 15]);
title('FDP anal�tica e estimada pelo m�todo da mistura (1000000 amostras)');
legend('Histograma das amostras obtidas por mistura', 'FDP anal�tica');
xlabel('X'); ylabel('p_x(x)');