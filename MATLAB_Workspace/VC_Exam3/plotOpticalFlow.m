function plotOpticalFlow(image, opticalFlow, varargin)

% PLOTOPTICALFLOW Display the optical flow over an image
%    PLOTOPTICALFLOW(I, F) display the calculated optical flows F over the
%    images I, using the function quiver. In order to imporve visibility of
%    the displayed image, a few processing stages are applied to F before
%    calling the function quiver.
%
%    Supression of non maximum values:
%    In order to avoid plotting too many arrows, each local maximum of F
%    supress other values in a neighborhood of width 'minPixelDist'.
%
%    Saturation:
%    In order to optimize the scale of the plotted arrows, all velocity
%    values are saturated to the range [-vSat, vSat].
%
%    Small values supression:
%    In order to avoid multiple blue dots in the displayed image, valus
%    within the range [-vZero, vZero] are also supressed.
%
%    PLOTOPTICALFLOW(I, param1, value1, param2, value2, ...) allows
%    changing the default plotting parameters. The available parameters are:
%
%        satVelocity - set the value of vSat
%        zeroThresh  - set the value of vZero
%        pixelDist   - the width of the non maximum supression neighborhood
%        arrowSize   - the arrow scale factor
%
%    Other m-files required: none
%    Subfunctions: supressNonMaximumValues, saturateMatrix,
%    findBestSaturationValue, eraseZeroAndNanSlots
%    MAT-files required: none
%
%    See also: CONSTANTFLOW, QUIVER

% Author: André Augusto Geraldes
% Email: andregeraldes@lara.unb.br
% December 2013; Last revision: 09-December-2013

% Default parameters
minPixelDistance = 4;
arrowSize = 15;
vZero = 0.1;
vSatMax = 10;

% Check varargin for updating the plot parameters
if(nargin > 2 && mod(nargin,2) == 0)
    for iArgin = 1:(nargin-2)/2
        if(strcmp(varargin{2*iArgin-1}, 'pixelDist'))
            minPixelDistance = varargin{2*iArgin};
        elseif(strcmp(varargin{2*iArgin-1}, 'arrowSize'))
            arrowSize = varargin{2*iArgin};      
        elseif(strcmp(varargin{2*iArgin-1}, 'vZero'))
            vZero = varargin{2*iArgin};       
        elseif(strcmp(varargin{2*iArgin-1}, 'vSat'))
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
    set(gca,'position',[0 0 1 1],'units','normalized')
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

