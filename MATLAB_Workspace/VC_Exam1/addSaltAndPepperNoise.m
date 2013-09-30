function noisyImage = addSaltAndPepperNoise(image, p)

% ADDSALTANDPEPPERNOISE Adds salt and pepper noise to image
%    noisyImage = addSaltAndPepperNoise(image, p) is the result of adding
%    salt and pepper noise to the original image. The larger the value of
%    the parameter p, the less pixels will get corrupted by noise.
%
%
%  Other m-files required: none
%  Subfunctions: none
%  MAT-files required: none
%
% See also: ADDGAUSSIANNOISE

% Author: André Augusto Geraldes
% Email: andregeraldes@lara.unb.br
% September 2013; Last revision: 28-September-2013

%[hard-coded parameter] noise maximum range
iMin = 0;
iMax = 255;

[nRow nColumn] = size(image);
noisyImage = zeros(nRow, nColumn);

for iRow = 1:nRow
    for iColumn = 1:nColumn
        
        if(rand < p)
            noisyImage(iRow, iColumn) = image(iRow, iColumn);
        else
            noisyImage(iRow, iColumn) = iMin + rand*(iMax-iMin);
        end
        
    end
end

noisyImage = uint8(noisyImage);