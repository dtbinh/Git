%decomp_mult(a,b) returns the result of the
%decompositional multiplication of dual quaternions a and b
function dq = decomp_mult(a,b)
dq = tplus(b)*tplus(a)*b.P*a.P;