function nextState = needleRPYModel

px = sym('px');
py = sym('py');
pz = sym('pz');
R = sym('R');
P = sym('P');
Y = sym('Y');

needleCurvature = sym('k');
insertionSeed = sym('v');
rotationSpeed = sym('w');

state = [px; py; pz; R; P; Y];

parameters = [needleCurvature];
controlInputs = [insertionSeed rotationSpeed];

nextState = processFunction(state, [parameters controlInputs]);


function nextState = processFunction(state, parameter)

% Decode the state componentes
px = state(1);
py = state(2);
pz = state(3);
roll = state(4);
pitch = state(5);
yaw = state(6);
k = parameter(1);
u1 = parameter(2);
u2 = parameter(3);

if(abs(u1) + abs(u2) ~= 0)
    
    % Convert current state to dual quaternion
    currentTranslation = [zeros(1,1); px; py; pz];
    currentRotation = angle2quat_sym(roll, pitch, yaw);
    currentPrimary = currentRotation;
    currentDual = 0.5*quatmultiply_sym(currentTranslation', currentRotation);
    
    % Calculate the dual quaternion corresponding to the input signals
    phi = (u2.^2 + (k.^2) .* (u1.^2)).^(0.5);
    B = sin(phi/2) ./ phi;
    incTranslation = [zeros(1,1); u1; zeros(2,1)];
    incRotation = [cos(phi/2); B.*u2; zeros(1,1); B.*u1.*k];
    incPrimary = incRotation';
    incDual = 0.5*quatmultiply_sym(incTranslation', incRotation');
    
    % Calculate the resulting dual quaternion
    nextPrimary = quatmultiply_sym(currentPrimary, incPrimary);
    nextDual = quatmultiply_sym(currentPrimary, incDual) + quatmultiply_sym(currentDual, incPrimary);
    
    % Decompose the resulting dual quaternion into the sigma point components
    rotationQuaternion = nextPrimary;
    conjugateMatrix = repmat([1 -1 -1 -1], 1, 1);
    translationQuaternion = 2*quatmultiply_sym(nextDual, nextPrimary .* conjugateMatrix);
    
    [R P Y] = quat2angle_sym(rotationQuaternion);
    positions = translationQuaternion;
    
    nextState(1,1) = positions(2);
    nextState(2,1) = positions(3);
    nextState(3,1) = positions(4);
    nextState(4,1) = R;
    nextState(5,1) = P;
    nextState(6,1) = Y;
    
else
    
    nextState(1,1) = state(1);
    nextState(2,1) = state(2);
    nextState(3,1) = state(3);
    nextState(4,1) = state(4);
    nextState(5,1) = state(5);
    nextState(6,1) = state(6);
    
end

function qout = angle2quat_sym(R, P, Y)

q0 = cos(R/2) * cos(P/2) * cos(Y/2) + sin(R/2) * sin(P/2) * sin(Y/2);
q1 = sin(R/2) * cos(P/2) * cos(Y/2) - cos(R/2) * sin(P/2) * sin(Y/2);
q2 = cos(R/2) * sin(P/2) * cos(Y/2) + sin(R/2) * cos(P/2) * sin(Y/2);
q3 = cos(R/2) * cos(P/2) * sin(Y/2) - sin(R/2) * sin(P/2) * cos(Y/2);

qout = [q0 q1 q2 q3];

function qout = quatmultiply_sym(q,r)

p0 = q(1)*r(1) - q(2)*r(2) - q(3)*r(3) - q(4)*r(4);
p1 = q(1)*r(2) + r(1)*q(2) + q(3)*r(4) - q(4)*r(3);
p2 = q(1)*r(3) + r(1)*q(3) + q(4)*r(2) - q(2)*r(4);
p3 = q(1)*r(4) + r(1)*q(4) + q(2)*r(3) - q(3)*r(2);

qout = [p0 p1 p2 p3];

function [R P Y] = quat2angle_sym(q)

qin= q./(sqrt(sum(q.^2,2))* ones(1,4));

r11 = 2.*(qin(:,2).*qin(:,3) + qin(:,1).*qin(:,4));
r12 = qin(:,1).^2 + qin(:,2).^2 - qin(:,3).^2 - qin(:,4).^2;
r21 = -2.*(qin(:,2).*qin(:,4) - qin(:,1).*qin(:,3));
r31 = 2.*(qin(:,3).*qin(:,4) + qin(:,1).*qin(:,2));
r32 = qin(:,1).^2 - qin(:,2).^2 - qin(:,3).^2 + qin(:,4).^2;

R = atan( r31 / r32 );
P = asin( r21 );
Y = atan( r11 / r12 );


