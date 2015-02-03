% T�picos Especiais em Engenharia Biom�dia - avalia��o 3
%   Script auxiliar para resolver a QUEST�O 5b da avalia��o: ver 
%   questao5b.m, para uma descri��o mais detalhada

%  Autor: Andr� Augusto Geraldes
%  E-mail: andregeraldes@lara.unb.br
%  Dezembro 2014

% Execu��o da simula��o com os par�metros j� definidos no workspace
sim('nmreflex_step');

% Importa��o dos resultados da simula��o para o workspace
load('nmrflx_step.mat');

% Extra��o do segundo e do terceiro ter�o do sinal de theta
theta = result(3,:);
nTheta3 = floor(length(theta)/3);
mediumTheta = theta( (end-2*nTheta3+1):(end-nTheta3) );
finalTheta  = theta( (end-1*nTheta3+1):(end        ) );

% C�lculo da amplitude da por��o final e intermedi�ria de theta
mediumRange = range(mediumTheta);
finalRange  = range(finalTheta);

% C�lculo da raz�o entre as amplitudes medidas
tolerance = 10^-3;
if(mediumRange < tolerance)
    
    % Considerar sinais de amplitude muito baixo como constantes
    rangeRatio = 0;

else
    rangeRatio = finalRange/mediumRange;
end