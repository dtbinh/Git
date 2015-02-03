clear all;
close all;
clc;

%% Section A - Transfer Function

% Define symbolic variables x0 and t
syms t x0;

% Build the given step response of the system
Vstep = x0 * (1 - exp(-5*t)) * heaviside(t);

% Apply the Laplace transform
VstepS = laplace(Vstep);

% Calculate the transfer function
stepS = laplace(heaviside(t));
Hs = VstepS / stepS;
fprintf('Função de transferência: \n H(s) = ');
disp(simplify(Hs));

%% Section B - Impulse Response

% Define the impulse function in the s-domain
impulse = dirac(t);
impulseS = laplace(impulse);

% Calculate the frequency response
VimpulseS = impulseS * Hs;

% Calculate the impulse response
Vimpulse = ilaplace(VimpulseS);
fprintf('Resposta ao impulso: \n V(t) = ');
disp(simplify(Vimpulse));

%% Section C - Ramp Response

% Define the ramp function in the s-domain
ramp = t*heaviside(t);
rampS = laplace(ramp);

% Calculate the frequency response
VrampS = rampS * Hs;

% Calculate the impulse response
Vramp = ilaplace(VrampS);
fprintf('Resposta à rampa: \n V(t) = ');
disp(simplify(Vramp));