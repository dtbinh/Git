% Tópicos Especiais em Engenharia Biomédia - avaliação 3
%   Script para resolver a QUESTÃO 5a da avaliação: análise de estabilidade
%   do sistema em malha fechada, para diferentes valores de beta e Td,
%   utilizando os diagramas de Bode e Nyquist

%  Autor: André Augusto Geraldes
%  E-mail: andregeraldes@lara.unb.br
%  Dezembro 2014

questao4

%% Definição dos parâmetros do sistema

% Valores de atraso Td a serem utilizados
dValues = [0 0.01 0.02 0.04];
nD = length(dValues);

% Inicialização do vetor de frequências para calcular o diagrama de bode
wValues = 0.1:0.1:100;

%% Cálculo dos valores de beta que tornam o sistema criticamente estável

% Inicialização do vetor para armazenar os valores de beta calculados
betaValues = zeros(1,nD);

% Cálculo do valor limite de beta, para cada valor do atraso Td
for iD = 1:nD
    
    % Construção da função de transferência usando o valor padrão de beta
    nLoop = double(subs(numLoop, {J, B, K, tau, eta, beta}, {0.1, 2, 50, 1/300, 5, 100}));
    dLoop = double(subs(denLoop, {J, B, K, tau, eta, beta}, {0.1, 2, 50, 1/300, 5, 100}));
    
    % Aplicação do atraso na função de transferência
    T_Loop = tf(nLoop, dLoop, 'InputDelay', dValues(iD));
    
    % Estimação da margem de ganho do sistema através do diagrama de bode
    [magnitude_Loop, phase_Loop] = bode(T_Loop, wValues);
    index = find(phase_Loop <= -180);
    gainMargin = 1/magnitude_Loop(index(1));
    
    % Atualização do parâmetro beta, com base na margem de ganho
    betaValues(iD) = 100 * gainMargin;
    
    % Contrução da nova função de transferência com o novo valor de beta
    nLoop = double(subs(numLoop, {J, B, K, tau, eta, beta}, {0.1, 2, 50, 1/300, 5, betaValues(iD)}));
    dLoop = double(subs(denLoop, {J, B, K, tau, eta, beta}, {0.1, 2, 50, 1/300, 5, betaValues(iD)}));
    T_Loop = tf(nLoop, dLoop, 'InputDelay', dValues(iD));
    
    % Exibição do diagrama de Nyquist do sistema, para verificar que o
    % sistema é criticamente estável (apresenta oscilações sustentadas)
    figure;
    nyqlog(T_Loop, 'nodisplay');
end
