%JACOBN	Compute manipulator Jacobian in end-effector frame
%
%	JACOBN(ROBOT, Q) returns a Jacobian matrix for the current pose Q.
%
% 	The manipulator Jacobian matrix maps differential changes in joint space
%	to differential Cartesian motion of the end-effector.
%			dX = J dQ
%
%	This function uses the technique of
%		Paul, Shimano, Mayer
%		Differential Kinematic Control Equations for Simple Manipulators
%		IEEE SMC 11(6) 1981
%		pp. 456-460
%
%	For an n-axis manipulator the Jacobian is a 6 x n matrix.
%
%	See also DIFF2TR, TR2DIFF, DIFF

% MOD.HISTORY
%	3/99	uses objects
%
%	Copyright (C) Peter Corke 1999
function J = jacobn(robot, q)
	J = [];
	n = robot.n;

	if robot.mdh ~= 0,
		error('Jacobian only valid for standard D&H parameters')
	end
	
	T = robot.tool;
	%T = eye(4,4);
	L = robot.link;
	for j=n:-1:1,
		T = L{j}( q(j) ) * T;
		if L{j}.RP == 'R',
			% revolute axis
			d = [	-T(1,1)*T(2,4)+T(2,1)*T(1,4)
				-T(1,2)*T(2,4)+T(2,2)*T(1,4)
				-T(1,3)*T(2,4)+T(2,3)*T(1,4)];
			delta = T(3,1:3)';	% nz oz az
		else
			% prismatic axis
			d = T(3,1:3)';		% nz oz az
			delta = zeros(3,1);	%  0  0  0
		end
		J = [[d; delta] J];
	end
