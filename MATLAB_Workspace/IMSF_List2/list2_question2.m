clear all;
close all;
clc;
warning off;

%% Introduction - Closed Loop Transfer Function

% Build the described block diagram in Simulink
% Diagram: (list2_question2_simulink)

% Declare the numeric values of the system parameters
G_J = 14400;    % G/J = 14400 rad²/s²
B_J = 4;        % B/J = 4 rad/s
Kv = 0.01;      % Kv = 0.01

% Extract the transfer function from the simulink model
SYS = linmod('list2_question2_simulink');
Tss = ss(SYS.a, SYS.b, SYS.c, SYS.d);
[n d] = tfdata(Tss, 'v');
fprintf('Função de transferência de malha fechada: \n H(s) = ');
T = tf(n, d, 'outputn', 'H(s)')

%% Section A - Frequency Response (linear scale diagrams)

% Generate the frequency array
Wmax = 10^3;
W = 0:Wmax;

% Calculate the frequency response of the system
response = freqresp(T, W);

% Extract the magnitude and phase components of the frequecy response
magnitude = reshape(abs(response), 1, length(W));
phase = reshape(angle(response), 1, length(W));
phasedeg = rad2deg(phase);

% Plot the frequency response diagrams in linear scale
figure; 
suptitle('Resposta em frequência em escala linear');

subplot(2,1,1); 
plot(W, magnitude);
set(gca,'FontSize',10);
set(gca,'YTick',[0:0.25:1.5])
ylabel('Magnitude (linear)', 'Fontsize', 12);

subplot(2,1,2); 
plot(W, phasedeg);
set(gca,'FontSize',10);
set(gca,'YTick',[-180:45:0])
xlabel('Frequência (rad/s)', 'Fontsize', 12);
ylabel('Fase (graus)', 'Fontsize', 12);

%% Section B - Bode Plot

% Generate Bode Plots
figure; bode(T);

%% Section C - Nyquist Plot

% Convert the closed loop transfer function of the previous system into an
% open loop transfer function of a unit negative feedback form system
[n d] = tfdata(T, 'v');
fprintf('Função de transferência de malha aberta: \n H(s) = ');
openT = tf(n, d-n, 'outputn', 'H(s)_MA')

% For verification, build the equivalent block diagram in Simulink, in the
% unit negative feedback form
% Diagram: (list2_question2_simulink2)

% Verify that the generated block diagram is equivalent to the previous one
SYS = linmod('list2_question2_simulink2');
Tss = ss(SYS.a, SYS.b, SYS.c, SYS.d);
[n d] = tfdata(Tss, 'v');
fprintf('Função de transferência de malha fechada do diagrama equivalente: \n H(s) = ');
closedT = tf(n, d, 'outputn', 'H(s)')

% Plot the nyquist diagram for the open loop transfer function
figure; nyqlog(openT, 'nodisplay');

%% QUESTION 4 - Section A - Gain Margin and Phase Margin

[Gm,Pm,Wgm,Wpm] = margin(openT);
fprintf('Margem de ganho do sistema para Kv = 0.01: %f\n', Gm);
fprintf('Margem de fase do sistema para Kv = 0.01: %f\n', Pm);

%% QUESTION 4 - Section B1 - Stable system in Nyquist Plot

Kv = -1/3600 * 0.95;

SYS = linmod('list2_question2_simulink');
Tss = ss(SYS.a, SYS.b, SYS.c, SYS.d);
[n d] = tfdata(Tss, 'v');
openT = tf(n, d-n, 'outputn', 'H(s)_MA');
figure; nyqlog(openT); fprintf('\n\n');
title(sprintf('Sistema estável (Kv = %f)', Kv));

%% QUESTION 4 - Section B1 - Oscilating system in Nyquist Plot

Kv = -1/3600 * 1;

SYS = linmod('list2_question2_simulink');
Tss = ss(SYS.a, SYS.b, SYS.c, SYS.d);
[n d] = tfdata(Tss, 'v');
openT = tf(n, d-n, 'outputn', 'H(s)_MA');
figure; nyqlog(openT); fprintf('\n\n');
title(sprintf('Sistema com oscilações sustentadas (Kv = %f)', Kv));

%% QUESTION 4 - Section B1 - Unstable system in Nyquist Plot

Kv = -1/3600 * 1.05;

SYS = linmod('list2_question2_simulink');
Tss = ss(SYS.a, SYS.b, SYS.c, SYS.d);
[n d] = tfdata(Tss, 'v');
openT = tf(n, d-n, 'outputn', 'H(s)_MA');
figure; nyqlog(openT); fprintf('\n\n');
title(sprintf('Sistema instável (Kv = %f)', Kv));

