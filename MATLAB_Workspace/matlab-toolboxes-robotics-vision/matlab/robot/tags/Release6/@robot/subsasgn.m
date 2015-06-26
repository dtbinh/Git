%SUBSASGN	assignment methods on a ROBOT object
%
%	ROBOT.gravity = [gx gy gz]
%	ROBOT.base = 4x4 homog xform
%	ROBOT.tool = 4x4 homog xform
%	ROBOT.name = 'name'
%	ROBOT.manuf = 'who built it'
%	ROBOT.comment = 'general comment'
%	ROBOT.lineopt = line options for display of robot
%	ROBOT.shadowopt = line options for display of shadow
%	ROBOT.qlim	set joint limits
%	ROBOT.offset 		return joint offset vector
%
%	Copyright (C) Peter Corke 1999

function r = subsasgn(r, s, v)

	if s(1).type  ~= '.'
		error('only .field supported')
	end
	switch s(1).subs,
	case 'lineopt',
		r.lineopt = v;
	case 'shadowopt',
		r.shadowopt = v;
	case 'offset',
		L = r.link;
		for i=1:r.n,
			L{i}.offset = v(i);
		end
	case 'qlim',
		if numrows(v) ~= r.n,
			error('insufficient rows in joint limit matrix');
		end
		L = r.link;
		for i=1:r.n,
			L{i}.qlim = v(i,:);
		end
	case 'q',
		r.q = v;
	case 'handle',
		r.handle = v;
	case 'plotopt',
		r.plotopt = v;
	case 'gravity',
		r.gravity = v;
	case 'tool',
		if ~ishomog(v)
			error('base must be a homogeneous transform');
		end
		r.tool = v;
	case 'base',
		if ~ishomog(v)
			error('base must be a homogeneous transform');
		end
		r.base = v;
	case 'name',
		r.name = v;
	case 'manuf',
		r.manuf = v;
	case 'comment',
		r.comment = v;
	otherwise, error('Unknown method')
	end
