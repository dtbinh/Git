%DIFF2TR Convert a differential to a homogeneous transform
%
% 	TR = DIFF2TR(D)
%
% Returns a homogeneous transform representing differential translation 
% and rotation.  The matrix contains a skew symmetric rotation submatrix.
%
% See also: TR2DIFF.

% $Log: not supported by cvs2svn $
% $Revision: 1.2 $
% Copyright (C) 1993-2002, by Peter I. Corke

function delta = diff2tr(d)
	delta =[	0	-d(6)	d(5)	d(1)
			d(6)	0	-d(4)	d(2)
			-d(5)	d(4)	0	d(3)
			0	0	0	0	];
