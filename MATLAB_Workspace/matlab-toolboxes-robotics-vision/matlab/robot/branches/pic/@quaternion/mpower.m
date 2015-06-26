%MPOWER	raise quaternion object to integer power

%	Copright (C) Peter Corke 1999
function qp = mpower(q, p)

	% check that exponent is an integer
	if (p - floor(p)) ~= 0,
		error('quaternion exponent must be integer');
	end

	qp = q;

	% multiply by itself so many times
	for i = 2:abs(p),
		qp = qp * q;
	end

	% if exponent was negative, invert it
	if p<0,
		qp = inv(qp);
	end
