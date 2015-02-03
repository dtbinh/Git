% Introdução aos Processos Estocásticos
%   Lista de Exercícios 3 - questão 3
%

%  Autor: André Augusto Geraldes
%  E-mail: andregeraldes@lara.unb.br
%  Outubro 2014

clear all;
close all;

%% Geração do vetor de amostras x

N = 5000;
mu = [2 ; 0];
sigma = [1 0.2 ; 0.2 3];

X = (mvnrnd(mu, sigma, N))';

figure; plot(X(1,:), X(2,:), '.'); axis equal;

%% Geração da transformação Ya = Px^(-1/2) * (X - E{X})

Ya = sigma^(-1/2) * (X - repmat(mu,1,N));

figure; plot(Ya(1,:), Ya(2,:), '.'); axis equal;

%% Geração da transformação Yb = (X - E{X})'(X - E{X})

Yb = (X(1,:)-repmat(mu(1,:),1,N)).^2 + (X(2,:)-repmat(mu(2,:),1,N)).^2;

figure; plot(Yb(1,:), ones(1,N), '.'); axis equal;

%% Comparação entre o histograma de Ya e Za ~ N(0,I2)

% Geração da FDP analítica para Za ~ N(0, I2)
X1 = -4:0.1:4;
X2 = -4:0.1:4;
Za = zeros(length(X1), length(X2));
for i1 = 1:length(X1)
    for i2 = 1:length(X2)
        v = [X1(i1) ; X2(i2)];
        Za(i1, i2) = 1/(2*pi) * exp((-1/2) * (v'*v));
    end
end

% Normalização do histograma de Ya
[Ha, Ba] = hist3(Ya', [20 20]);
Ha = Ha / trapz(Ba{2},trapz(Ba{1},Ha,2));
wa = 2.57*(Ba{1}(2)-Ba{1}(1));

% Exibição da diferença entre Ya e Za
figure; 
subplot(2,2,1); surf(Ba{1}, Ba{2}, Ha);

subplot(2,2,2); mesh(X1, X2, Za); 

subplot(2,2,3); mesh(X1, X2, Za); 
hold on; surf(Ba{1}, Ba{2}, Ha);

subplot(2,2,4); bar(Ba{1}, Ha(:, end/2+1), wa);
hold on; plot(X1, Za(:, (end+1)/2), 'r-');

%% Comparação entre o histograma de Yb e Zb ~ EXP(1/4)

% Geração da FDP analítica para Zb ~ EXP(1/4)
X3 = 0:0.1:40;
Zb = zeros(1, length(X3));
for i = 1:length(X3)
    Zb(i) = 1/4 * exp(-X3(i) * 1/4);
end

% Normalização do histograma de Yb
[Hb, Bb] = hist(Yb, 50);
Hb = Hb / trapz(Bb,Hb,2);
wb = 1.16*(Bb(2)-Bb(1));

% Exibição da diferença entre Yb e Zb
figure;
bar(Bb, Hb, wb);
xaxis([Bb(1)-wb/2 Bb(end)+wb/2]);
hold on;
plot(X3, Zb, 'r-');


