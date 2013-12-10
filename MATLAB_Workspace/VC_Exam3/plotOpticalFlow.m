function [currentFlowX currentFlowY] = plotOpticalFlow(image, opticalFlow, varargin)

%
% FUNCTION DESCRIPTION
%

% Author: André Augusto Geraldes
% Email: andregeraldes@lara.unb.br
% December 2013; Last revision: 08-December-2013


% Default parameters
minPixelDistance = 5;
arrowSize = 20;
vZero = 0.1;
vSatMax = 5;

% Check varargin for updating the plot parameters
if(nargin > 2 && mod(nargin,2) == 0)
    for iArgin = 1:(nargin-2)/2
        if(strcmp(varargin{2*iArgin-1}, 'pixelDist'))
            minPixelDistance = varargin{2*iArgin};
        elseif(strcmp(varargin{2*iArgin-1}, 'arrowSize'))
            arrowSize = varargin{2*iArgin};      
        elseif(strcmp(varargin{2*iArgin-1}, 'zeroThresh'))
            vZero = varargin{2*iArgin};       
        elseif(strcmp(varargin{2*iArgin-1}, 'satVelocity'))
            vSatMax = varargin{2*iArgin};       
        end
    end
end

% For each provided optical flow:
[nRow nColumn nFlow] = size(opticalFlow);
for iFlow = 1:nFlow   
    
    % Copy the current optical flow to the matrices currentFlowX and currentFlowY
    currentFlowX = zeros(nRow, nColumn);
    currentFlowY = zeros(nRow, nColumn);
    for iRow = 1:nRow
        for iColumn = 1:nColumn
            currentFlowX(iRow, iColumn) = opticalFlow(iRow, iColumn, iFlow).x;
            currentFlowY(iRow, iColumn) = opticalFlow(iRow, iColumn, iFlow).y;
        end
    end
    
    % For each NxN window keep only the highest value of the optical flow
    [currentFlowX currentFlowY] = supressNonMaximumValues(currentFlowX, currentFlowY, minPixelDistance);
    
    % Saturate the current optical flow
    currentFlowX = saturateMatrix(currentFlowX, vSatMax);
    currentFlowY = saturateMatrix(currentFlowY, vSatMax);
    
    % Generate the X and Y coordinate matrices for plotting the optical flow
    [xCoord yCoord] = meshgrid(1:nColumn, 1:nRow);
    [xCoord yCoord] = eraseZeroAndNanSlots(xCoord, yCoord, currentFlowX, currentFlowY, vZero);
    
    %% Plot the current optical flow
    
    figure;
    idisp(image(:,:,iFlow), 'plain');
    hold on;
    quiver(xCoord, yCoord, currentFlowX, currentFlowY, 'AutoScaleFactor', arrowSize);
    
end

function [xMatrixSupressed yMatrixSupressed] = supressNonMaximumValues(xMatrix, yMatrix, N)

[nRow nColumn] = size(xMatrix);
xMatrixSupressed = zeros(nRow, nColumn);
yMatrixSupressed = zeros(nRow, nColumn);

magnitudeMatrix = xMatrixSupressed.^2 + yMatrixSupressed.^2;
minValue = min(min(magnitudeMatrix));
maxValue = max(max(magnitudeMatrix));

while maxValue > minValue-1
    [r c] = find(magnitudeMatrix == maxValue);
    xMatrixSupressed(r(1), c(1)) = xMatrix(r(1), c(1));
    yMatrixSupressed(r(1), c(1)) = yMatrix(r(1), c(1));
    
    rmin = max(1   , r(1)-N);
    rmax = min(nRow, r(1)+N);
    cmin = max(1      , c(1)-N);
    cmax = min(nColumn, c(1)+N);
    
    for i = rmin:rmax
        for j = cmin:cmax
            magnitudeMatrix(i,j) = minValue-1;
        end
    end
    
    maxValue = max(max(magnitudeMatrix));
end

function matrix = saturateMatrix(matrix, maxSatValue)

satValue = min(findBestSaturationValue(matrix), maxSatValue);
matrix(matrix > satValue) = satValue;
matrix(matrix < -satValue) = -satValue;

function bestVSat = findBestSaturationValue(matrix)

matrix = abs(matrix);
minValue = min(min(matrix));
maxValue = max(max(matrix));
matrix = matrix - minValue;
matrix = matrix / maxValue;

hist = imhist(matrix)';
histsum = zeros(length(hist));
for i = 2:length(histsum)
    histsum(i) = histsum(i-1) + hist(i);
end

histsum = histsum / max(histsum);
[r ~] = find(histsum > 0.99);
bestVSat = minValue + (r(1)/length(histsum)) * (maxValue-minValue);


function [xCoord yCoord] = eraseZeroAndNanSlots(xCoord, yCoord, currentFlowX, currentFlowY, vZero)

nanX = isnan(currentFlowX);
nanY = isnan(currentFlowY);
zeroX = (currentFlowX < vZero & currentFlowX > -vZero);
zeroY = (currentFlowY < vZero & currentFlowY > -vZero);

xCoord(nanX | zeroX) = nan;
yCoord(nanY | zeroY) = nan;

