%DISPLAY Display the value of a quaternion object

% $Log: not supported by cvs2svn $
% $Revision: 1.2 $
%
% Copyright (C) 1999-2002, by Peter I. Corke

function display(q)

	disp(' ');
	disp([inputname(1), ' = '])
	disp(' ');
	disp(['  ' char(q)])
	disp(' ');
