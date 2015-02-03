% Tópicos Especiais em Engenharia Biomédia - avaliação 3
%   Script para resolver a QUESTÃO 3 da avaliação: cálculo numérico das
%   funções de transferência de malha aberta e malha fechada do sistema,
%   por meio de simulações usando o Simulink

%  Autor: André Augusto Geraldes
%  E-mail: andregeraldes@lara.unb.br
%  Dezembro 2014

warning off;
questao2

%% Definição dos parâmetros do sistema

J    = 0.1;
B    = 2.0;
k    = 50;
tau  = 1/300;
eta  = 5;
Td   = 0;

load('pontos_chave.mat');

%% Simulação em malha aberta

% Seleção do parâmetro beta = 0 para abrir a malha
beta = 0;

% Obtenção das frequências de interesse do arquivo 'pontos_chave.mat'
f = MA_KeyFrequency;
nF = length(f);

% Inicialização dos vetores para armazenar os resultados da simulação
MA_SimMagnitude = zeros(1, nF);
MA_SimPhase = zeros(1, nF);

% Simulações do sistema em malha aberta
for iF = 1:nF
    
    % Seleção da frequência do sinal de entrada
    Wmx = 2*pi*f(iF);
    
    % Execução da simulação
    sim('nmreflex');
    
    % Importação dos resultados da simulação para o workspace
    load('nmrflx.mat');
    
    % Extração da porção final dos sinais de Mx e theta
    timeStep = result(1,2) - result(1,1);
    samples4period = round(4/(timeStep*f(iF)));
    finalMx = result(2,end-samples4period+1:end);
    finalTheta = result(3,end-samples4period+1:end);
    
    % Cálculo da magnitude e fase da função de transferência
    MA_SimMagnitude(iF) = range(finalTheta) / range(finalMx);
    MA_SimPhase(iF) = phaseDiff(finalMx, finalTheta);
end

%% Simulação em malha fechada

% Seleção do parâmetro beta = 100 para fechar novamente a malha
beta = 100;

% Obtenção das frequências de interesse do arquivo 'pontos_chave.mat'
f = MF_KeyFrequency;
nF = length(f);

% Inicialização dos vetores para armazenar os resultados da simulação
MF_SimMagnitude = zeros(1, nF);
MF_SimPhase = zeros(1, nF);

% Simulações do sistema em malha fechada
for iF = 1:nF
    
    % Seleção da frequência do sinal de entrada
    Wmx = 2*pi*f(iF);
    
    % Execução da simulação
    sim('nmreflex');
    
    % Importação dos resultados da simulação para o workspace
    load('nmrflx.mat');
    
    % Extração da porção final dos sinais de Mx e theta
    timeStep = result(1,2) - result(1,1);
    samples4period = round(4/(timeStep*f(iF)));
    finalMx = result(2,end-samples4period+1:end);
    finalTheta = result(3,end-samples4period+1:end);
    
    % Cálculo da magnitude e fase da função de transferência
    MF_SimMagnitude(iF) = range(finalTheta) / range(finalMx);
    MF_SimPhase(iF) = phaseDiff(finalMx, finalTheta);
end

%% Exibição dos resultados simulados sobre os resultados analíticos

% Diagrama de magnitude de malha aberta
figure(1); subplot(211); hold on;
plot(MA_KeyFrequency, MA_SimMagnitude, 'ro');
legend('Função analítica', 'Frequências selecionadas', 'Resultados simulados');

% Diagrama de fase de malha aberta
figure(1); subplot(212); hold on;
plot(MA_KeyFrequency, MA_SimPhase, 'ro');
legend('Função analítica', 'Frequências selecionadas', 'Resultados simulados');

% Diagrama de magnitude de malha fechada
figure(2); subplot(211); hold on;
plot(MF_KeyFrequency, MF_SimMagnitude, 'ro');
legend('Função analítica', 'Frequências selecionadas', 'Resultados simulados');

% Diagrama de fase de malha fechada
figure(2); subplot(212); hold on;
plot(MF_KeyFrequency, MF_SimPhase, 'ro');
legend('Função analítica', 'Frequências selecionadas', 'Resultados simulados'); 

%% Comparação entre as funções de transferência de malha aberta e malha fechada

figure;
subplot(211); plot(fValue, magnitude_MA, 'b');
hold on; plot(fValue, magnitude_MF, 'r');
title('Comparação entre a resposta em frequência de malha aberta T_{MA}(f) e de malha fechada T_{MF}(f)');
ylabel('Magnitude(f)');
legend('Malha aberta', 'Malha fechada');

subplot(212); plot(fValue, phase_MA, 'b');
hold on; plot(fValue, phase_MF, 'r');
ylabel('Fase(f)');
xlabel('f (Hz)');
legend('Malha aberta', 'Malha fechada');