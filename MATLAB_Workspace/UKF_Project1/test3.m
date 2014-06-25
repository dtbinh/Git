function test3


k = 2;
Q = eye(2);
R = eye(2);
dimX = 3;
dimZ = 2;
c = 3;
ukf = HomMinSymAUKF(@processFunction, [k], @measurementFunction, 0, Q, R, dimX, dimZ, c)





function newS = processFunction(s, u, k)

newS(1,:) = s(1,:) + (2 * (1 - cos((k+s(5,:)) .* (u+s(4,:)))) ./ (((k+s(5,:))).^2)).^(0.5) .* cos(s(3,:) + 0.5 .* (u+s(4,:)) .* (k+s(5,:)));
newS(2,:) = s(2,:) + (2 * (1 - cos((k+s(5,:)) .* (u+s(4,:)))) ./ (((k+s(5,:))).^2)).^(0.5) .* sin(s(3,:) + 0.5 .* (u+s(4,:)) .* (k+s(5,:)));
newS(3,:) = s(3,:) + (k+s(5,:)) .* (u+s(4,:));
newS(4:5,:) = s(6:7,:);

function newS = measurementFunction(s, ~)

newS(1,:) = s(1,:) + s(4,:);
newS(2,:) = s(2,:) + s(5,:);

