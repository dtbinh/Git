function gaus = gaussianKernel(sigma, size);

% Generates a discrete gaussian mask of dimensions 'size' x 'size', with zero
% mean and standard deviation equals to 'sigma'

gaus = double(ones(size));
c = (size+1)/2;

for i = 1:size
    for j = 1:size
        if(i ~= c || j ~= c)
            x2 = (i-c)^2 + (j-c)^2;
            gaus(i,j) = exp( - x2 / (2*sigma^2));
        end
    end
end

s = sum(sum(gaus));

for i = 1:size
    for j = 1:size
        gaus(i,j) = gaus(i,j) / s;
    end
end