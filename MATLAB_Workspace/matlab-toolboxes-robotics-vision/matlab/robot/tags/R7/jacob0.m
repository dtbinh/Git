%JACOB0 Compute manipulator Jacobian in world coordinates
%
%	J0 = JACOB0(ROBOT, Q)
%
% Returns a Jacobian matrix for the robot ROBOT in pose Q.
%
% The manipulator Jacobian matrix maps differential changes in joint space
% to differential Cartesian motion (world coord frame) of the end-effector.
% 		dX = J dQ
%
% For an n-axis manipulator the Jacobian is a 6 x n matrix.
%
% See also: JACOBN, DIFF2TR, TR2DIFF.


% Copyright (C) 1999-2002, by Peter I. Corke
% MOD.HISTORY
% 3/99	uses objects
% $Log: not supported by cvs2svn $
% $Revision: 1.2 $

function J0 = jacob0(robot, q)
	%
	%   dX_tn = Jn dq
	%
	Jn = jacobn(robot, q);	% Jacobian from joint to wrist space

	%
	%  convert to Jacobian in base coordinates
	%
	Tn = fkine(robot, q);	% end-effector transformation
	R = tr2rot(Tn);
	J0 = [R zeros(3,3); zeros(3,3) R] * Jn;
