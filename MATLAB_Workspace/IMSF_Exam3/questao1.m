% T�picos Especiais em Engenharia Biom�dia - avalia��o 3
%   Script para resolver a QUEST�O 1 da avalia��o: c�lculo simb�lico das
%   fun��es de transfer�ncia de malha aberta e malha fechada do sistema

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

% Simplifica��o (Td = 0)
H = subs(H, Td, 0);

%% Fun��o de transfer�ncia em malha aberta

T_MA = G;
fprintf('Fun��o de Transfer�ncia em Malha Aberta - T_MA(s):\n');
pretty(simplifyFraction(T_MA, 'Expand', true))
fprintf('\n\n');

%% Fun��o de transfer�ncia em malha fechada

T_MF = G / (1 + G*H);
fprintf('Fun��o de Transfer�ncia em Malha Fechada - T_MF(s):\n');
pretty(simplifyFraction(T_MF, 'Expand', false))
fprintf('\n\n');


%% Resposta obtida no formato (NUM, DEN) utilizado pela fun��o tf

numMA = [K];
denMA = [B*J J*K B*K 0];

numMF = [K*eta*tau K*eta];
denMF = [eta*B*J*tau 
         eta*J*(B+K*tau) 
         eta*K*(J+B*tau) 
         eta*K*(B+beta*tau) 
         beta*K]';
     