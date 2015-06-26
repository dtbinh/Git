%NOFRICTION	return robot object with zero link friction 
%
%	ROBORT = NOFRICTION(ROBOT)
%
%

% MOD HISTORY

%	Copyright (C) 1999 Peter. I. Corke

function  r2 = nofriction(r)

	r2 = robot(r);

	for i=1:r2.n,
		l2{i} = nofriction(r.link{i});
	end

	r2.link = l2;
