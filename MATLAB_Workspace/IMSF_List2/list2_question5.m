clear all;
close all;
clc;

%% Introduction - Transfer Function

% Define symbolic variables s and K
syms s K;

% Build the closed loop transfer function
G = 0.005/((s+2)*(s+5));
H = K/(s+3);
T = simplify(G / (1 + G*H))

%% Section A - Routh-Hurwitz

% Extract the coefficients of the denominator of the transfer function
[~, D] = numden(T);
coefficients = fliplr(coeffs(D, s));

% Apply the Routh-Hurwitz stability criterion
R = myRouth(coefficients);

% Find the K range where all the values in the Routh-Hurwitz table become
% positive
positiveInterval = solve(R(:,1) >= 0, K);

% Find the K range where all the values in the Routh-Hurwitz table become
% negative
negativeInterval = solve(R(:,1) <= 0, K);

% Print out the final answer
if(length(positiveInterval) == 0 && length(negativeInterval) == 0)
    fprintf('Não existe nenhum valor de K que satisfaça o critério de Routh-Hurwitz \n');
elseif(length(positiveInterval) == 0 && length(negativeInterval) > 0)
    fprintf('Segundo o critério de Routh-Hurwitz, os valores de K que estabilizam o sistema de malha fechada estão no seguinte intervalo: \n');
    disp(negativeInterval);
elseif(length(positiveInterval) > 0 && length(negativeInterval) == 0)
    fprintf('Segundo o critério de Routh-Hurwitz, os valores de K que estabilizam o sistema de malha fechada estão no seguinte intervalo: \n');
    disp(positiveInterval);    
else
    fprintf('Segundo o critério de Routh-Hurwitz, os valores de K que estabilizam o sistema de malha fechada estão nos seguintes intervalo: \n');
    disp(positiveInterval);    
    disp(negativeInterval);    
end

%% Section B - Nyquist

K = 1;

n = K * 1/200;
d = [1 10 31 30];
openT = tf(n, d, 'outputn', 'H(s)_MA')
figure; nyqlog(openT);