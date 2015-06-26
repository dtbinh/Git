%DIFF2TR	Convert a differential to a homogeneous transform
%
%	DIFF2TR(D) returns a homogeneous transform representing differential
%	translation and rotation.
%
%	See also TR2DIFF, DIFF

%	Copyright (C) Peter Corke 1993
function delta = diff2tr(d)
	delta =[	0	-d(6)	d(5)	d(1)
		d(6)	0	-d(4)	d(2)
		-d(5)	d(4)	0	d(3)
		0	0	0	0	];
