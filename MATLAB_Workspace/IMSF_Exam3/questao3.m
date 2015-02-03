% T�picos Especiais em Engenharia Biom�dia - avalia��o 3
%   Script para resolver a QUEST�O 3 da avalia��o: c�lculo num�rico das
%   fun��es de transfer�ncia de malha aberta e malha fechada do sistema,
%   por meio de simula��es usando o Simulink

%  Autor: Andr� Augusto Geraldes
%  E-mail: andregeraldes@lara.unb.br
%  Dezembro 2014

warning off;
questao2

%% Defini��o dos par�metros do sistema

J    = 0.1;
B    = 2.0;
k    = 50;
tau  = 1/300;
eta  = 5;
Td   = 0;

load('pontos_chave.mat');

%% Simula��o em malha aberta

% Sele��o do par�metro beta = 0 para abrir a malha
beta = 0;

% Obten��o das frequ�ncias de interesse do arquivo 'pontos_chave.mat'
f = MA_KeyFrequency;
nF = length(f);

% Inicializa��o dos vetores para armazenar os resultados da simula��o
MA_SimMagnitude = zeros(1, nF);
MA_SimPhase = zeros(1, nF);

% Simula��es do sistema em malha aberta
for iF = 1:nF
    
    % Sele��o da frequ�ncia do sinal de entrada
    Wmx = 2*pi*f(iF);
    
    % Execu��o da simula��o
    sim('nmreflex');
    
    % Importa��o dos resultados da simula��o para o workspace
    load('nmrflx.mat');
    
    % Extra��o da por��o final dos sinais de Mx e theta
    timeStep = result(1,2) - result(1,1);
    samples4period = round(4/(timeStep*f(iF)));
    finalMx = result(2,end-samples4period+1:end);
    finalTheta = result(3,end-samples4period+1:end);
    
    % C�lculo da magnitude e fase da fun��o de transfer�ncia
    MA_SimMagnitude(iF) = range(finalTheta) / range(finalMx);
    MA_SimPhase(iF) = phaseDiff(finalMx, finalTheta);
end

%% Simula��o em malha fechada

% Sele��o do par�metro beta = 100 para fechar novamente a malha
beta = 100;

% Obten��o das frequ�ncias de interesse do arquivo 'pontos_chave.mat'
f = MF_KeyFrequency;
nF = length(f);

% Inicializa��o dos vetores para armazenar os resultados da simula��o
MF_SimMagnitude = zeros(1, nF);
MF_SimPhase = zeros(1, nF);

% Simula��es do sistema em malha fechada
for iF = 1:nF
    
    % Sele��o da frequ�ncia do sinal de entrada
    Wmx = 2*pi*f(iF);
    
    % Execu��o da simula��o
    sim('nmreflex');
    
    % Importa��o dos resultados da simula��o para o workspace
    load('nmrflx.mat');
    
    % Extra��o da por��o final dos sinais de Mx e theta
    timeStep = result(1,2) - result(1,1);
    samples4period = round(4/(timeStep*f(iF)));
    finalMx = result(2,end-samples4period+1:end);
    finalTheta = result(3,end-samples4period+1:end);
    
    % C�lculo da magnitude e fase da fun��o de transfer�ncia
    MF_SimMagnitude(iF) = range(finalTheta) / range(finalMx);
    MF_SimPhase(iF) = phaseDiff(finalMx, finalTheta);
end

%% Exibi��o dos resultados simulados sobre os resultados anal�ticos

% Diagrama de magnitude de malha aberta
figure(1); subplot(211); hold on;
plot(MA_KeyFrequency, MA_SimMagnitude, 'ro');
legend('Fun��o anal�tica', 'Frequ�ncias selecionadas', 'Resultados simulados');

% Diagrama de fase de malha aberta
figure(1); subplot(212); hold on;
plot(MA_KeyFrequency, MA_SimPhase, 'ro');
legend('Fun��o anal�tica', 'Frequ�ncias selecionadas', 'Resultados simulados');

% Diagrama de magnitude de malha fechada
figure(2); subplot(211); hold on;
plot(MF_KeyFrequency, MF_SimMagnitude, 'ro');
legend('Fun��o anal�tica', 'Frequ�ncias selecionadas', 'Resultados simulados');

% Diagrama de fase de malha fechada
figure(2); subplot(212); hold on;
plot(MF_KeyFrequency, MF_SimPhase, 'ro');
legend('Fun��o anal�tica', 'Frequ�ncias selecionadas', 'Resultados simulados'); 

%% Compara��o entre as fun��es de transfer�ncia de malha aberta e malha fechada

figure;
subplot(211); plot(fValue, magnitude_MA, 'b');
hold on; plot(fValue, magnitude_MF, 'r');
title('Compara��o entre a resposta em frequ�ncia de malha aberta T_{MA}(f) e de malha fechada T_{MF}(f)');
ylabel('Magnitude(f)');
legend('Malha aberta', 'Malha fechada');

subplot(212); plot(fValue, phase_MA, 'b');
hold on; plot(fValue, phase_MF, 'r');
ylabel('Fase(f)');
xlabel('f (Hz)');
legend('Malha aberta', 'Malha fechada');