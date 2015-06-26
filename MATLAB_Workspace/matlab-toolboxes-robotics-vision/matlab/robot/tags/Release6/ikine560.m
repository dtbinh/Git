%IKINE560	Inverse kinematics for Puma 560 
%
%
%  Q = IKINE560(DH, T, CONFIG)
%
% This routine allows the caller to choose from a variety of outputs
% If the user only passes robot and Homogeneous_Transformation, the inverse 
% kinematics will default to a configuration of n1 = 1, n2 = -1, n4= -1.
% The user may opt to pass a third argument which specifies the configuration 
% of the arm.
% He may either specify the values of n1, n2, n4 using a (1x3) 
% vector, [n1, n2, n4],
% or the user may opt to use the right-left, up-down, flip-no flip conventions.
% In that case, a (1x3) vector with the characters will be passed ['r','u','f']
% Any combination of uppercase and lowercase is allowed.
% However, the user must pass the parameters as separate elements in the
% proper order: right or left first, followed by up or down and finally flip 
% or no-flip.
% There is an additional option to return all eight solutions- done by 
% sending the scalar 8.
% If the users passes anyvalue other than a (3x1) vector or the scalar 8,
% the default will be used.
%
% The Denavit-Hartenberg parameters from the robot matrix are passed in.
% Therefore, puma560.m must be run first.
% The DH parameters are then taken out of the robot matrix
%
% REFERENCE:
%
% Inverse kinematics for a PUMA 560 based on the equations by Paul and Zhang
% From The International Journal of Robotics Research
% Vol. 5, No. 2, Summer 1986, p. 32-44
%
%
% AUTHOR:
%	Robert Biro		gt2231a@prism.gatech.edu
%	with Gary Von McMurray
%
%	GTRI/ATRP/IIMB
%	Georgia Institute of Technology
%	2/13/95

% MOD HISTORY
%  4/99	use new robot object

function invkine= ikine560(robot, Homogeneous_Transformation,configuration)

if robot.n ~= 6,
	error('Solution only applicable for 6DOF manipulator');
end
L = robot.links;
a1 = L{1}.A
a2 = L{2}.A;
a3 = L{3}.A;

if ~isempty( find( [L{4}.A L{5}.A L{6}.A] ~= 0 ))
	error('wrist is not spherical')
end

d1 = L{1}.D;
d2 = L{2}.D;
d3 = L{3}.D;
d4 = L{4}.D;

% The Homogeneous Transformation may be passed as either a row vector
% or a 4x4 matrix

	size_Homogeneous_Transformation=size(Homogeneous_Transformation);
		if (size_Homogeneous_Transformation(1) == 1),
			Homogeneous_Transformation=	[Homogeneous_Transformation(1:4); ...
							Homogeneous_Transformation(5:8); ...
							Homogeneous_Transformation(9:12); ...
							Homogeneous_Transformation(13:16)]';
		end

% undo base transformation
Homogeneous_Transformation = inv(robot.base) * Homogeneous_Transformation;

% The following parameters are extracted from the Homogeneous Transformation
% as defined in equation 1, p. 34

Ox = Homogeneous_Transformation(1,2);
Oy = Homogeneous_Transformation(2,2);
Oz = Homogeneous_Transformation(3,2);

Ax = Homogeneous_Transformation(1,3);
Ay = Homogeneous_Transformation(2,3);
Az = Homogeneous_Transformation(3,3);

Px = Homogeneous_Transformation(1,4);
Py = Homogeneous_Transformation(2,4);
Pz = Homogeneous_Transformation(3,4);

% The configuration parameter determines what n1,n2,n4 values are used
% and how many solutions are determined.
% If a 1x3 vector is passed, it is assumed that a specific configuration is desired
% If the scalar 8 is passed, all eight configurations are returned in a (8x6) matrix
% Any other passed value defaults to the 1, -1, -1 configuration
%
if (nargin < 3),
	configuration = 1;
end
  
if (size(configuration,2) ~= 1),
	if ((configuration(1) == 'R') | (configuration(1) == 'r')),
		n1_lower = 1;
		n1_upper = 1;
	elseif ((configuration(1) == 'L') | (configuration(1) == 'l')),
		n1_lower = -1;
		n1_upper = -1;
	else
		n1_lower = sign(configuration(1));
		n1_upper = sign(configuration(1));
	end
	if ((configuration(2) == 'U') | (configuration(1) == 'u')),
		if (n1_lower == 1),
			n2_lower = 1;
			n2_upper = 1;
		else
			n2_lower = -1;
			n2_upper = -1;
		end
	elseif ((configuration(2) == 'D') | (configuration(2) == 'd')), 
		if (n1_lower == -1),
			n2_lower = 1;
			n2_upper = 1;
		else
			n2_lower = -1;
			n2_upper = -1;
		end
	else
		n2_lower = sign(configuration(2));
		n2_upper = sign(configuration(2));
	end
	if ((configuration(3) == 'F') | (configuration(3) == 'f')),
		n4_lower = -1;
		n4_upper = -1;
	elseif ((configuration(3) == 'N') | (configuration(3) == 'n')),
		n4_lower = 1;
		n4_upper = 1;
	else
		n4_lower = sign(configuration(3));
		n4_upper = sign(configuration(3));
	end
else
	if (configuration == 8),
		n1_lower = -1;
		n1_upper = 1;
		n2_lower = -1;
		n2_upper = 1;
		n4_lower = -1;
		n4_upper = 1;
	else
		n1_lower = 1;
		n1_upper = 1;
		n2_lower = -1;
		n2_upper = -1;
		n4_lower = -1;
		n4_upper = -1;
	end
end
%
% Initialize some variables
%
b = 0;

for n1=n1_lower:2:n1_upper,
	for n2=n2_lower:2:n2_upper,
		for n4=n4_lower:2:n4_upper,

%
% Solve for theta(1)
% 
% r is defined in equation 38, p. 39.
% theta(1) uses equations 40 and 41, p.39, 
% based on the configuration parameter n1
%

r=sqrt(Px^2 + Py^2);
if (n1 == 1),
	theta(1)= atan2(Py,Px) + asin(d3/r);
else
	theta(1)= atan2(Py,Px) + pi - asin(d3/r);
end

%
% Solve for theta(2)
%
% V114 is defined in equation 43, p.39.
% r is defined in equation 47, p.39.
% Psi is defined in equation 49, p.40.
% theta(2) uses equations 50 and 51, p.40, based on the configuration parameter n2
%

V114= Px*cos(theta(1)) + Py*sin(theta(1));
r=sqrt(V114^2 + Pz^2);
Psi = acos((a2^2-d4^2-a3^2+V114^2+Pz^2)/(2.0*a2*r));
theta(2) = atan2(Pz,V114) + n2*Psi;

%
% Solve for theta(3)
%
% theta(3) uses equation 57, p. 40.
%

num = cos(theta(2))*V114+sin(theta(2))*Pz-a2;
den = cos(theta(2))*Pz - sin(theta(2))*V114;
theta(3) = atan2(a3,d4) - atan2(num, den);

%
% Solve for theta(4)
%
% V113 is defined in equation 62, p. 41.
% V323 is defined in equation 62, p. 41.
% V313 is defined in equation 62, p. 41.
% theta(4) uses equation 61, p.40, based on the configuration parameter n4
%

V113 = cos(theta(1))*Ax + sin(theta(1))*Ay;
V323 = cos(theta(1))*Ay - sin(theta(1))*Ax;
V313 = cos(theta(2)+theta(3))*V113 + sin(theta(2)+theta(3))*Az;
theta(4) = atan2((n4*V323),(n4*V313));

%
% Solve for theta(5)
%
% num is defined in equation 65, p. 41.
% den is defined in equation 65, p. 41.
% theta(5) uses equation 66, p. 41.
%
 
num = -cos(theta(4))*V313 - V323*sin(theta(4));
den = -V113*sin(theta(2)+theta(3)) + Az*cos(theta(2)+theta(3));
theta(5) = atan2(num,den);

%
% Solve for theta(6)
%
% V112 is defined in equation 69, p. 41.
% V122 is defined in equation 69, p. 41.
% V312 is defined in equation 69, p. 41.
% V332 is defined in equation 69, p. 41.
% V412 is defined in equation 69, p. 41.
% V432 is defined in equation 69, p. 41.
% num is defined in equation 68, p. 41.
% den is defined in equation 68, p. 41.
% theta(6) uses equation 70, p. 41.
%

V112 = cos(theta(1))*Ox + sin(theta(1))*Oy;
V132 = sin(theta(1))*Ox - cos(theta(1))*Oy;
V312 = V112*cos(theta(2)+theta(3)) + Oz*sin(theta(2)+theta(3));
V332 = -V112*sin(theta(2)+theta(3)) + Oz*cos(theta(2)+theta(3));
V412 = V312*cos(theta(4)) - V132*sin(theta(4));
V432 = V312*sin(theta(4)) + V132*cos(theta(4));
num = -V412*cos(theta(5)) - V332*sin(theta(5));
den = - V432;
theta(6) = atan2(num,den);

b = b + 1;
invkine(b,:)=theta(:)';
		end
	end
end
return
