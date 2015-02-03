% T�picos Especiais em Engenharia Biom�dia - avalia��o 3
%   Script para resolver a QUEST�O 5a da avalia��o: an�lise de estabilidade
%   do sistema em malha fechada, para diferentes valores de beta e Td,
%   utilizando os diagramas de Bode e Nyquist

%  Autor: Andr� Augusto Geraldes
%  E-mail: andregeraldes@lara.unb.br
%  Dezembro 2014

questao4

%% Defini��o dos par�metros do sistema

% Valores de atraso Td a serem utilizados
dValues = [0 0.01 0.02 0.04];
nD = length(dValues);

% Inicializa��o do vetor de frequ�ncias para calcular o diagrama de bode
wValues = 0.1:0.1:100;

%% C�lculo dos valores de beta que tornam o sistema criticamente est�vel

% Inicializa��o do vetor para armazenar os valores de beta calculados
betaValues = zeros(1,nD);

% C�lculo do valor limite de beta, para cada valor do atraso Td
for iD = 1:nD
    
    % Constru��o da fun��o de transfer�ncia usando o valor padr�o de beta
    nLoop = double(subs(numLoop, {J, B, K, tau, eta, beta}, {0.1, 2, 50, 1/300, 5, 100}));
    dLoop = double(subs(denLoop, {J, B, K, tau, eta, beta}, {0.1, 2, 50, 1/300, 5, 100}));
    
    % Aplica��o do atraso na fun��o de transfer�ncia
    T_Loop = tf(nLoop, dLoop, 'InputDelay', dValues(iD));
    
    % Estima��o da margem de ganho do sistema atrav�s do diagrama de bode
    [magnitude_Loop, phase_Loop] = bode(T_Loop, wValues);
    index = find(phase_Loop <= -180);
    gainMargin = 1/magnitude_Loop(index(1));
    
    % Atualiza��o do par�metro beta, com base na margem de ganho
    betaValues(iD) = 100 * gainMargin;
    
    % Contru��o da nova fun��o de transfer�ncia com o novo valor de beta
    nLoop = double(subs(numLoop, {J, B, K, tau, eta, beta}, {0.1, 2, 50, 1/300, 5, betaValues(iD)}));
    dLoop = double(subs(denLoop, {J, B, K, tau, eta, beta}, {0.1, 2, 50, 1/300, 5, betaValues(iD)}));
    T_Loop = tf(nLoop, dLoop, 'InputDelay', dValues(iD));
    
    % Exibi��o do diagrama de Nyquist do sistema, para verificar que o
    % sistema � criticamente est�vel (apresenta oscila��es sustentadas)
    figure;
    nyqlog(T_Loop, 'nodisplay');
end
