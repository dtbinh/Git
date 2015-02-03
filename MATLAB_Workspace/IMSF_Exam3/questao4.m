% Tópicos Especiais em Engenharia Biomédia - avaliação 3
%   Script para resolver a QUESTÃO 4 da avaliação: cálculo simbólico da
%   função de transferência de malha (loop transfer function) do sistema

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

%% Função de transferência de malha (loop transfer function)

T_Loop = G*H;
fprintf('Função de Transferência de malha - T_Loop(s):\n');
pretty(simplifyFraction(T_Loop, 'Expand', false))
fprintf('\n\n');

%% Substituição de s por j*(2*pi*f)

syms f;
T_Loop_f = subs(T_Loop, s, 1i*(2*pi*f));

%% Substituição dos parâmetros pelos seus valores numéricos

T_Loop_num = subs(T_Loop_f, {J, B, K, tau, eta}, {0.1, 2, 50, 1/300, 5});

fprintf('Função de Transferência de malha - T_Loop(f):\n');
pretty(simplifyFraction(T_Loop_num, 'Expand', false))
fprintf('\n\n');

%% Resposta obtida no formato (NUM, DEN) utilizado pela função tf

numLoop = [beta*K*eta*tau
           beta*K]';

denLoop = [eta*B*J*tau
           eta*J*(B+tau*K)
           eta*K*(J+tau*B)
           eta*K*B
           0]';
