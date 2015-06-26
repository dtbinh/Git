%EUL2TR
%
%	EUL2TR([R P Y])
%	EUL2TR(R,P,Y) returns a homogeneous tranformation for the specified
%	Euler angles.  These correspond to rotations about the
%	Z, X, Z axes respectively.
%
%	See also TR2EUL, RPY2TR

%	Copright (C) Peter Corke 1993
function r = eul2tr(phi, theta, psi)
        if length(phi) == 3,
                r = rotz(phi(1)) * roty(phi(2)) * rotz(phi(3));
        else
                r = rotz(phi) * roty(theta) * rotz(psi);
        end
