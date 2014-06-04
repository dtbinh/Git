function index = randArgMax(vector)

% RANDARGMAX Randomly drawn argument of the maximum
%    I = RANDARGMAX(V) finds the position I where the value of the vector V 
%    is maximum (V(I) == max(V)). If the maximum value of V appears at more
%    than one position, I is selected randomly from the available options.
%
%    Example:
%        V = [1 2 3 1 2 3 1 2 3];
%        I = randArgMax(V);
%
%    I is randomly drawn from the subset {3,6,9}
%
%
%    Other m-files required: none
%    Subfunctions: none
%    MAT-files required: none
%
%    See also: RANDOMVALIDACTION, INITPOLICY

% Author: André Augusto Geraldes
% Email: andregeraldes@lara.unb.br
% December 2013; Last revision: 20-December-2013


% Find all locations where the value of vector is maximum
[r c] = find(vector == max(vector));

% Draw one of the selected locations randomly
if(range(r) > 0)
    index = r(ceil(length(r)*rand));    
else
    index = c(ceil(length(c)*rand));    
end
