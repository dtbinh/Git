clear all;
close all;
clc;
warning off;

%% Introduction

% Build the described block diagram in Simulink
% Diagram: (list2_question3_simulink)

%% Section A - alpha = 0

% Set the value of alpha
alpha = 0;

% Extract the transfer function from the simulink model
SYS = linmod('list2_question3_simulink');
Tss = ss(SYS.a, SYS.b, SYS.c, SYS.d);
[n d] = tfdata(Tss, 'v');
fprintf('Função de transferência de malha fechada: \n H(s) = ');
T = tf(n, d, 'outputn', 'H(s)')

% Plot the frequency response diagrams 
figure; bode(T);
[~, Z] = damp(T);
fprintf('Caso A (alpha = 0): coeficiente de amortecimento  = %f \n', max(Z));


%% Section B - alpha = 0.5

% Set the value of alpha
alpha = 0.5;

% Extract the transfer function from the simulink model
SYS = linmod('list2_question3_simulink');
Tss = ss(SYS.a, SYS.b, SYS.c, SYS.d);
[n d] = tfdata(Tss, 'v');
fprintf('Função de transferência de malha fechada: \n H(s) = ');
T = tf(n, d, 'outputn', 'H(s)')

% Plot the frequency response diagrams 
figure; bode(T);
[~, Z] = damp(T);
fprintf('Caso B (alpha = 0.5): coeficiente de amortecimento  = %f \n', max(Z));

%% Section C - alpha = 2

% Set the value of alpha
alpha = 2;

% Extract the transfer function from the simulink model
SYS = linmod('list2_question3_simulink');
Tss = ss(SYS.a, SYS.b, SYS.c, SYS.d);
[n d] = tfdata(Tss, 'v');
fprintf('Função de transferência de malha fechada: \n H(s) = ');
T = tf(n, d, 'outputn', 'H(s)')

% Plot the frequency response diagrams 
figure; bode(T);
[~, Z] = damp(T);
fprintf('Caso C (alpha = 2): coeficiente de amortecimento  = %f \n', max(Z));

%% Conclusion

% Analisando os diagramas de Bode, vemos claramente que o caso alpha = 2 é
% o mais amortecido. Isso pode ser confirmado observando-se os valores
% medidos para o coeficiente de amortecimento em cada caso. No caso alpha =
% 2 o coeficiente de amortecimento é máximo.
