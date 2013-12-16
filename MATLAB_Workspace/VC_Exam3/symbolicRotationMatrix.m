% Build the generic rotation matriz R1 with angle t1 and vector U
t1 = sym('t1');
Ux = sym('Ux');
Uy = sym('Uy');
Uz = sym('Uz');
R1 = rotationMatrix(t1, [Ux Uy Uz]);

% Build the generic rotation matriz R2 with angle t2 and vector V
t2 = sym('t2');
Vx = sym('Vx');
Vy = sym('Vy');
Vz = sym('Vz');
R2 = rotationMatrix(t2, [Vx Vy Vz]);

% Specify the rotation axes
ty = sym('ty');
tz = sym('tz');
Rz = subs(R1, {t1, Ux,Uy,Uz}, {sym('tz'),0,0,1})
Ry = subs(R2, {t2, Vx,Vy,Vz}, {sym('ty'),0,1,0})

% Measure the difference between applying the rotations in the direct or inverse order
Rzy = Ry*Rz
Ryz = Rz*Ry
Rdiff = simplify(Rzy-Ryz)

% Assign different values to ty and tz
RdiffBig = subs(Rdiff, {ty,tz}, {deg2rad(45), deg2rad(60)})
RdiffSmall = subs(Rdiff, {ty,tz}, {deg2rad(1), deg2rad(2)})
