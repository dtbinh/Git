function test4()

close all; clear all;

% IL  = iread('whouse_left.png', 'grey', 'double');
% IR = iread('whouse_right.png', 'grey', 'double');
% P = load('whouse_points.txt');
% 
% PL = P(:,1:2);
% PR = P(:,3:4);
% 
% rectifyImages(IL, IR, PL, PR);
% 
% IL  = iread('telephone_left.png', 'grey', 'double');
% IR = iread('telephone_right.png', 'grey', 'double');
% P = load('telephone_points.txt');
% 
% PL = P(:,1:2);
% PR = P(:,3:4);
% 
% rectifyImages(IL, IR, PL, PR);
% 
% 
IL  = iread('toy_left.png', 'grey', 'double');
IR = iread('toy_right.png', 'grey', 'double');
P = load('toy_points.txt');

PL = P(:,1:2);
PR = P(:,3:4);

rectifyImages(IL, IR, PL, PR);





imageLeft  = iread('toy_left.png', 'grey', 'double');
imageRight = iread('toy_right.png', 'grey', 'double');

points = load('toy_points.txt');

F = eightPoint(points(:, 1:2), points(:, 3:4));
[U ~, V] = svd(F);

el0 = U(:,3);
er0 = V(:,3);

fl = 1;
fr = 1;

[hl wl] = size(imageLeft);
kl = [fl 0 wl/2; 0 fl hl/2; 0 0 1];

[hr wr] = size(imageRight);
kr = [fr 0 wr/2; 0 fr hr/2; 0 0 1];

[el1 Hl1] = rotateVector(el0, [el0(1) el0(2) 0]', kl)
% el1 = el1 / norm(el1);
[el2 Hl2] = rotateVector(el1, [1 0 0]', kl)

[er1 Hr1] = rotateVector(er0, [er0(1) er0(2) 0]', kr)
% er1 = er1 / norm(er1);
[er2 Hr2] = rotateVector(er1, [1 0 0]', kr)

HL = Hl2*Hl1
HR = Hr2*Hr1
% 
% imageLeftRect = homwarp(HL, imageLeft, 'full');
% imageRightRect = homwarp(HR, imageRight, 'full');
% 
% figure;
% idisp(imageLeftRect);
% figure;
% idisp(imageRightRect);
% 
% 
% 
% % a = inv(kl)*el;
% % b = inv(kl)*[el(1) el(2) 0]';
% % 
% % theta = acos(dot(a,b)/(norm(a)*norm(b)))
% % t = cross(a,b)/(norm(a)*norm(b))
% % t = t / norm(t)
% % 
% % 
% % tx = [0 -t(3) t(2); t(3) 0 -t(1); -t(2) t(1) 0];
% % 
% % R = I + sin(theta)*tx + (1 - cos(theta))*(tx*tx' - I);
% 
% 
% 
function [newVector R] = rotateVector(vector, desiredVector, K)

a = K\vector;
b = K\desiredVector;
theta = acos(dot(a,b)/(norm(a)*norm(b)));
t = cross(a,b)/(norm(a)*norm(b));
t = t / norm(t);
tx = [0 -t(3) t(2); t(3) 0 -t(1); -t(2) t(1) 0];

R = eye(3) + sin(theta)*tx + (1 - cos(theta))*(tx*tx' - eye(3));
newVector = R*vector;
% 
% % http://imagine.enpc.fr/publications/papers/BMVC10.pdf
% % http://en.wikipedia.org/wiki/Rodrigues'_rotation_formula