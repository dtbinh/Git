% Tópicos Especiais em Engenharia Biomédia - avaliação 3
%   Script para resolver a QUESTÃO 5b da avaliação: determinação
%   experimental dos limites de estabilidade do sistema, com base nos
%   parâmetros beta e Td, por meio de simulações usando o Simulink

%  Autor: André Augusto Geraldes
%  E-mail: andregeraldes@lara.unb.br
%  Dezembro 2014

close all;
clear all;
clc;

%% Definição dos parâmetros do sistema

J    = 0.1;
B    = 2.0;
k    = 50;
tau  = 1/300;
eta  = 5;

% Valores de atraso Td a serem utilizados
dValues = [0 0.01 0.02 0.04];
nD = length(dValues);

%% Simulações em malha fechada

% Inicialização do vetor para armazenar os valores de beta calculados
betaValues = zeros(1,nD);

% Executar um conjunto de simulações para cada valor de atraso Td
for iD = 1:nD
    
    % Seleção de um valor de atraso 
    Td = dValues(iD);
    
    % Simulações para determinar as centenas do parâmetro beta
    for iBeta=100:100:1000
        beta = iBeta;
        simulateAndEvaluateStability;
        if(rangeRatio >= 1)
            break;
        end
    end
    
    % Simulações para determinar as dezenas do parâmetro beta
    for iBeta=beta-100:10:beta
        beta = iBeta;
        simulateAndEvaluateStability;
        if(rangeRatio >= 1)
            break;
        end
    end
    
    % Simulações para determinar as unidades do parâmetro beta
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