%SUBSREF	subscript reference methods on a ROBOT object
%
%	ROBOT.n			return number of links
%	ROBOT.link		return cell array of link objects
%	ROBOT.gravity 		return gravity vector
%	ROBOT.base 		return homog xform of robot base
%	ROBOT.tool 		return homog xform of robot tool
%	ROBOT.qlim 		return joint limit matrix
%	ROBOT.offset 		return joint offset vector
%	ROBOT.islimit 		return joint limit boolean vector
%
%	ROBOT.name 		return name
%	ROBOT.manuf		return who built it
%	ROBOT.comment		return general comment
%
%	ROBOT.dh		return legacy DH matrix
%	ROBOT.dyn		return legacy DYN matrix

%	Copyright (C) Peter Corke 1999

function v = subsref(r, s)

	if s(1).type  ~= '.'
		%error('only .field supported')
	end

	% NOTE WELL:  the following code can't use getfield() since
	% getfield()  uses this, and Matlab will crash!!

	el = char(s(1).subs);
	switch el,
	case 'link',
		if length(s) == 1,
			v = r.link;
		elseif s(2).type == '{}'
			j = s(2).subs;
			j = j{1};
			if (j < 1) | (j > r.n)
				error('link index out of bounds')
			end
			v = r.link{j};
		end
	case 'offset',
		L = r.link;
		v = [];
		for i=1:r.n,
			v = [v; L{i}.offset];
		end
	case 'qlim',
		L = r.link;
		v = [];
		for i=1:r.n,
			v = [v; L{i}.qlim];
		end
	case 'islimit',
		L = r.link;
		if s(2).type  ~= '()'
			error('expecting argument for islimit method');
		end
		q = s(2).subs{1};
		if length(q) ~= r.n,
			error('argument for islimit method is wrong length');
		end
		v = [];
		for i=1:r.n,
			v = [v; L{i}.islimit(q(i))];
		end
	case 'n',
		v = r.n;
	case 'name',
		v = r.name;
	case 'dh',
		v = rdh(r);
	case 'dyn'
		v = rdyn(r);
	case 'gravity'
		v = r.gravity;
	case 'tool'
		v = r.tool;
	case 'base'
		v = r.base;
	case 'mdh',
		v = r.mdh;
	case 'q',
		v = r.q;
	case 'plotopt',
		v = r.plotopt;
	case 'lineopt'
		v = r.lineopt;
	case 'shadowopt'
		v = r.shadowopt;
	case {'show', 'handle'}
		v = r.handle';
	otherwise, error('Unknown method')
	end
