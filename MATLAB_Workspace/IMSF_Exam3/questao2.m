% T�picos Especiais em Engenharia Biom�dia - avalia��o 3
%   Script para resolver a QUEST�O 2 da avalia��o: resposta em frequ�ncia
%   do sistema a partir das fun��es de transfer�ncia anal�ticas

%  Autor: Andr� Augusto Geraldes
%  E-mail: andregeraldes@lara.unb.br
%  Dezembro 2014

questao1

%% Substitui��o de s por j*(2*pi*f)

syms f;
T_MA_f = subs(T_MA, s, 1i*(2*pi*f));
T_MF_f = subs(T_MF, s, 1i*(2*pi*f));

%% Substitui��o dos par�metros pelos seus valores num�ricos

T_MA_num = subs(T_MA_f, {J, B, K, tau, eta, beta}, {0.1, 2, 50, 1/300, 5, 100});
T_MF_num = subs(T_MF_f, {J, B, K, tau, eta, beta}, {0.1, 2, 50, 1/300, 5, 100});

fprintf('Fun��o de Transfer�ncia em Malha Aberta - T_MA(f):\n');
pretty(simplifyFraction(T_MA_num, 'Expand', false))
fprintf('\n\n');

fprintf('Fun��o de Transfer�ncia em Malha Fechada - T_MF(f):\n');
pretty(simplifyFraction(T_MF_num, 'Expand', false))
fprintf('\n\n');

%% C�lculo da Resposta em Frequ�ncia

% Gera��o do vetor de frequ�ncias a serem avaliadas
fValue = 0.2:0.1:15;
nF = length(fValue);

% Inicializa��o dos vetores para armazenar os valores de magnitude e fase
magnitude_MA = zeros(1, nF);
magnitude_MF = zeros(1, nF);
phase_MA = zeros(1, nF);
phase_MF = zeros(1, nF);

% C�lculo da resposta em frequ�ncia para cada valor de f
for iF = 1:nF
    frequencyResponse_MA = double(subs(T_MA_num, f, fValue(iF)));
    magnitude_MA(iF) = abs(frequencyResponse_MA);
    phase_MA(iF) = angle(frequencyResponse_MA);
    
    frequencyResponse_MF = double(subs(T_MF_num, f, fValue(iF)));
    magnitude_MF(iF) = abs(abs(frequencyResponse_MF));
    phase_MF(iF) = angle(frequencyResponse_MF);
end

% Corre��o da fase e conver��o de radiano para graus
phase_MA = rad2deg(unwrap(phase_MA));
phase_MF = rad2deg(unwrap(phase_MF));

%% Exibi��o dos resultados em escalas lineares

% Exibi��o do diagrama de malha aberta
figure(1);
subplot(211); 
plot(fValue, magnitude_MA);
title('Resposta em frequ�ncia de malha aberta T_{MA}(f)');
ylabel('M_{MA}(f)');
subplot(212); 
plot(fValue, phase_MA);
ylabel('\Phi_{MA}(f)');
xlabel('f (Hz)');

% Exibi��o do diagrama de malha fechada
figure(2);
subplot(211); 
plot(fValue, magnitude_MF);
title('Resposta em frequ�ncia de malha fechada T_{MF}(f)');
ylabel('M_{MF}(f)');
subplot(212); 
plot(fValue, phase_MF);
ylabel('\Phi_{MF}(f)');
xlabel('f (Hz)');


%% Extra��o de pontos chave de cada um dos diagramas para uso na quest�o 3

% Sele��o das frequ�ncias de interesse
MA_targetF = [0.2 0.4 0.7 1 4 10];
MF_targetF = [0.2 1.5 2.5 4 6 10];

% Inicializa��o dos vetores para armazenar os valores selecionados
nF_MA = length(MA_targetF);
MA_KeyFrequency = zeros(1, nF_MA);
MA_KeyMagnitude = zeros(1, nF_MA);
MA_KeyPhase = zeros(1, nF_MA);

nF_MF = length(MF_targetF);
MF_KeyFrequency = zeros(1, nF_MF);
MF_KeyMagnitude = zeros(1, nF_MF);
MF_KeyPhase = zeros(1, nF_MF);

% Extra��o dos pontos chave no diagrama de malha aberta
for iF = 1:nF_MA
    
    % Localiza��o do ponto do diagrama mais pr�ximo � frequ�ncia de interesse
    index = find(fValue >= MA_targetF(iF));
    
    % Salvar a magnitude e a fase como ponto chave
    MA_KeyFrequency(iF) = fValue(index(1));
    MA_KeyMagnitude(iF) = magnitude_MA(index(1));
    MA_KeyPhase(iF) = phase_MA(index(1));
end

% Extra��o dos pontos chave no diagrama de malha aberta
for iF = 1:nF_MF
    
    % Localiza��o do ponto do diagrama mais pr�ximo � frequ�ncia de interesse
    index = find(fValue >= MF_targetF(iF));
    
    % Salvar a magnitude e a fase como ponto chave
    MF_KeyFrequency(iF) = fValue(index(1));
    MF_KeyMagnitude(iF) = magnitude_MF(index(1));
    MF_KeyPhase(iF) = phase_MF(index(1));
end

% Salvar os pontos selecionados em arquivo externo
save('pontos_chave.mat', 'MA_KeyFrequency', 'MA_KeyMagnitude', 'MA_KeyPhase', 'MF_KeyFrequency', 'MF_KeyMagnitude', 'MF_KeyPhase');

%% Exibi��o dos pontos chave selecionados

figure(1);
subplot(211); hold on; plot(MA_KeyFrequency, MA_KeyMagnitude, 'b*');
subplot(212); hold on; plot(MA_KeyFrequency, MA_KeyPhase, 'b*');

figure(2);
subplot(211); hold on; plot(MF_KeyFrequency, MF_KeyMagnitude, 'b*');
subplot(212); hold on; plot(MF_KeyFrequency, MF_KeyPhase, 'b*');

%% Compara��o das respostas obtidas com um diagrama de Bode do Matlab

% % Gera��o dos diagramas de bode do Matlab
% nMA = double(subs(numMA, {J, B, K, tau, eta, beta}, {0.1, 2, 50, 1/300, 5, 100}));
% dMA = double(subs(denMA, {J, B, K, tau, eta, beta}, {0.1, 2, 50, 1/300, 5, 100}));
% nMF = double(subs(numMF, {J, B, K, tau, eta, beta}, {0.1, 2, 50, 1/300, 5, 100}));
% dMF = double(subs(denMF, {J, B, K, tau, eta, beta}, {0.1, 2, 50, 1/300, 5, 100}));
% [bodeMag_MA, bodePhase_MA] = bode(tf(nMA, dMA), 2*pi*fValue);
% [bodeMag_MF, bodePhase_MF] = bode(tf(nMF, dMF), 2*pi*fValue);
% 
% % Diagramas de malha aberta
% figure;
% subplot(211); loglog(fValue, magnitude_MA, 'r');
% hold on; plot(fValue, reshape(bodeMag_MA, 1, nF), 'b');
% subplot(212); semilogx(fValue, phase_MA, 'r');
% hold on; plot(fValue, reshape(bodePhase_MA, 1, nF), 'b');
% 
% % Diagramas de malha fechada
% figure;
% subplot(211); loglog(fValue, magnitude_MF, 'r');
% hold on; plot(fValue, reshape(bodeMag_MF, 1, nF), 'b');
% subplot(212); semilogx(fValue, phase_MF, 'r');
% hold on; plot(fValue, reshape(bodePhase_MF, 1, nF), 'b');
% 
% % OBS: Em ambas as figuras, apenas a curva azul aparece, pois os gr�ficos
% % obtidos pela minha fun��o e pela fun��o padr�o do Matlab s�o id�nticos
