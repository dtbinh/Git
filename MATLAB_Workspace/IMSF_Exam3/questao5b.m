% T�picos Especiais em Engenharia Biom�dia - avalia��o 3
%   Script para resolver a QUEST�O 5b da avalia��o: determina��o
%   experimental dos limites de estabilidade do sistema, com base nos
%   par�metros beta e Td, por meio de simula��es usando o Simulink

%  Autor: Andr� Augusto Geraldes
%  E-mail: andregeraldes@lara.unb.br
%  Dezembro 2014

close all;
clear all;
clc;

%% Defini��o dos par�metros do sistema

J    = 0.1;
B    = 2.0;
k    = 50;
tau  = 1/300;
eta  = 5;

% Valores de atraso Td a serem utilizados
dValues = [0 0.01 0.02 0.04];
nD = length(dValues);

%% Simula��es em malha fechada

% Inicializa��o do vetor para armazenar os valores de beta calculados
betaValues = zeros(1,nD);

% Executar um conjunto de simula��es para cada valor de atraso Td
for iD = 1:nD
    
    % Sele��o de um valor de atraso 
    Td = dValues(iD);
    
    % Simula��es para determinar as centenas do par�metro beta
    for iBeta=100:100:1000
        beta = iBeta;
        simulateAndEvaluateStability;
        if(rangeRatio >= 1)
            break;
        end
    end
    
    % Simula��es para determinar as dezenas do par�metro beta
    for iBeta=beta-100:10:beta
        beta = iBeta;
        simulateAndEvaluateStability;
        if(rangeRatio >= 1)
            break;
        end
    end
    
    % Simula��es para determinar as unidades do par�metro beta
    for iBeta=beta-10:1:beta
        beta = iBeta;
        simulateAndEvaluateStability;
        if(rangeRatio >= 1)
            break;
        end
    end
    
    % Armazenamento do valor encontrado para beta
    betaValues(iD) = beta;
end