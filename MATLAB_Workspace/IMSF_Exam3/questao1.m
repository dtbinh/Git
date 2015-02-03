% Tópicos Especiais em Engenharia Biomédia - avaliação 3
%   Script para resolver a QUESTÃO 1 da avaliação: cálculo simbólico das
%   funções de transferência de malha aberta e malha fechada do sistema

%  Autor: André Augusto Geraldes
%  E-mail: andregeraldes@lara.unb.br
%  Dezembro 2014

close all;
clear all;
clc;

%% Definição das componentes do modelo

% Variáveis simbólicas
syms s B J K Td tau eta beta

% Planta (modelo de músculo)
G = (1 / (s^2*(B*J/K) + s*J + B)) * (1 / s);

% Realimentação (fuso muscular)
H = beta * exp(-s*Td) * ((tau*s+(1/eta)) / (tau*s+1));

% Simplificação (Td = 0)
H = subs(H, Td, 0);

%% Função de transferência em malha aberta

T_MA = G;
fprintf('Função de Transferência em Malha Aberta - T_MA(s):\n');
pretty(simplifyFraction(T_MA, 'Expand', true))
fprintf('\n\n');

%% Função de transferência em malha fechada

T_MF = G / (1 + G*H);
fprintf('Função de Transferência em Malha Fechada - T_MF(s):\n');
pretty(simplifyFraction(T_MF, 'Expand', false))
fprintf('\n\n');


%% Resposta obtida no formato (NUM, DEN) utilizado pela função tf

numMA = [K];
denMA = [B*J J*K B*K 0];

numMF = [K*eta*tau K*eta];
denMF = [eta*B*J*tau 
         eta*J*(B+K*tau) 
         eta*K*(J+B*tau) 
         eta*K*(B+beta*tau) 
         beta*K]';
     