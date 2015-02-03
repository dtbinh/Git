% Tópicos Especiais em Engenharia Biomédia - avaliação 3
%   Script auxiliar para resolver a QUESTÃO 5b da avaliação: ver 
%   questao5b.m, para uma descrição mais detalhada

%  Autor: André Augusto Geraldes
%  E-mail: andregeraldes@lara.unb.br
%  Dezembro 2014

% Execução da simulação com os parâmetros já definidos no workspace
sim('nmreflex_step');

% Importação dos resultados da simulação para o workspace
load('nmrflx_step.mat');

% Extração do segundo e do terceiro terço do sinal de theta
theta = result(3,:);
nTheta3 = floor(length(theta)/3);
mediumTheta = theta( (end-2*nTheta3+1):(end-nTheta3) );
finalTheta  = theta( (end-1*nTheta3+1):(end        ) );

% Cálculo da amplitude da porção final e intermediária de theta
mediumRange = range(mediumTheta);
finalRange  = range(finalTheta);

% Cálculo da razão entre as amplitudes medidas
tolerance = 10^-3;
if(mediumRange < tolerance)
    
    % Considerar sinais de amplitude muito baixo como constantes
    rangeRatio = 0;

else
    rangeRatio = finalRange/mediumRange;
end