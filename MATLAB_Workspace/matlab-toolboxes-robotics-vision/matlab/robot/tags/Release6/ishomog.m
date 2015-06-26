%ISHOMOG	test if argument is a homogeneous transformation


function h = ishomog(tr)
	if ndims(tr) == 2,
		h =  all(size(tr) == [4 4]);
	else
		h = 0;
	end
