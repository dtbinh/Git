% T�picos Especiais em Engenharia Biom�dia - avalia��o 3
%   Script para resolver a QUEST�O 4 da avalia��o: c�lculo simb�lico da
%   fun��o de transfer�ncia de malha (loop transfer function) do sistema

%  Autor: Andr� Augusto Geraldes
%  E-mail: andregeraldes@lara.unb.br
%  Dezembro 2014

close all;
clear all;
clc;

%% Defini��o das componentes do modelo

% Vari�veis simb�licas
syms s B J K Td tau eta beta

% Planta (modelo de m�sculo)
G = (1 / (s^2*(B*J/K) + s*J + B)) * (1 / s);

% Realimenta��o (fuso muscular)
H = beta * exp(-s*Td) * ((tau*s+(1/eta)) / (tau*s+1));

%% Fun��o de transfer�ncia de malha (loop transfer function)

T_Loop = G*H;
fprintf('Fun��o de Transfer�ncia de malha - T_Loop(s):\n');
pretty(simplifyFraction(T_Loop, 'Expand', false))
fprintf('\n\n');

%% Substitui��o de s por j*(2*pi*f)

syms f;
T_Loop_f = subs(T_Loop, s, 1i*(2*pi*f));

%% Substitui��o dos par�metros pelos seus valores num�ricos

T_Loop_num = subs(T_Loop_f, {J, B, K, tau, eta}, {0.1, 2, 50, 1/300, 5});

fprintf('Fun��o de Transfer�ncia de malha - T_Loop(f):\n');
pretty(simplifyFraction(T_Loop_num, 'Expand', false))
fprintf('\n\n');

%% Resposta obtida no formato (NUM, DEN) utilizado pela fun��o tf

numLoop = [beta*K*eta*tau
           beta*K]';

denLoop = [eta*B*J*tau
           eta*J*(B+tau*K)
           eta*K*(J+tau*B)
           eta*K*B
           0]';
