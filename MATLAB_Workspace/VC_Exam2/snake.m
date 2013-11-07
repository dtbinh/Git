function contour = snake(varargin)

% SNAKE Fit a deformable contour to image object (E. Trucco, page 112)
%    C = SNAKE(I) creates a circular contour in the gray level image I and 
%    fits it to the image content, using the magnitude of the gradient.
%    When the algorithm converges, C is a cell array containing the X and Y
%    coordinates of each point in the contour.
%
%    C = SNAKE(image, param1, value1, param2, value2, ...) allows
%    specifying the algorithm parameters. Parameters non specified assume
%    their default values. The available parameters are:
%
%        weights        - an array [a b c] containing the weights alpha,
%                         beta and gama used by the optimization algorithm
%        nPoint         - the number of points in the contour
%        NHoodW         - the width of the neighborhood used to move each
%                         point of the contour
%        curvThresh     - the threshold value for stop considering the 
%                         curvature energy of a point in the contour
%        maxIteractions - the maximum number of iteractions (in case the
%                         optimization algorithm does not converge)
%        tolerance      - percentage of points in the contour allowed to
%                         move, when convergence is considered achieved
%        contour        - an array [x y r] containing the center and radius
%                         of the initial contour (values are given as 
%                         percentages of the image size)
% 
%
%    Other m-files required: imagegradient.m, range2.m
%    Subfunctions: perimeter, findLargeCurvatures, plotContourPoints
%    MAT-files required: none
%
%    See also: IMGRADIENT, 

% Author: André Augusto Geraldes
% Email: andregeraldes@lara.unb.br
% October 2013; Last revision: 30-October-2013

%% Default Parameters

alphaValue = 1;
betaValue  = 1;
gamaValue  = 1.5;

nPoint = 30;
NHoodWidth = 1;
curvatureThreshold = 100;

maxIteractions = 1000;
minPointMovedRatio = 0.2;
initialCountour = [0.0 0.0 0.4];

% [hard-coded parameter] The plot period in loop cycles
displayRatio = 5;

%% Parse parameters from varargin

I = varargin{1};
for iArgin = 1:(nargin-1)/2
    if(strcmp(varargin{2*iArgin},'weights'))
        alphaBetaGama = varargin{2*iArgin+1};
        alphaValue = alphaBetaGama(1);
        betaValue = alphaBetaGama(2);
        gamaValue = alphaBetaGama(3);
    elseif(strcmp(varargin{2*iArgin},'nPoint'))
        nPoint = varargin{2*iArgin+1};        
    elseif(strcmp(varargin{2*iArgin},'NHoodW'))
        NHoodWidth = varargin{2*iArgin+1};
    elseif(strcmp(varargin{2*iArgin},'curvThresh'))
        curvatureThreshold = varargin{2*iArgin+1};
    elseif(strcmp(varargin{2*iArgin},'maxIteractions'))
        maxIteractions = varargin{2*iArgin+1};
    elseif(strcmp(varargin{2*iArgin},'tolerance'))
        minPointMovedRatio = varargin{2*iArgin+1};
    elseif(strcmp(varargin{2*iArgin},'contour'))
        initialCountour = varargin{2*iArgin+1};        
    end
end


%% Initialize the data structures

% X and y coordinates of each point in the contour
xPoint = zeros(1, nPoint);
yPoint = zeros(1, nPoint);

% Weights alpha, beta and gama of each point in the contour
alpha = alphaValue*ones(1,nPoint);
beta  = betaValue*ones(1,nPoint);
gama  = gamaValue*ones(1,nPoint);

% Matrices for storing the energy values in respect to different points
% within the same neighborhood
NHoodSize = 2*NHoodWidth+1;
ECont  = zeros(NHoodSize);
ECurv  = zeros(NHoodSize);
EImage = zeros(NHoodSize);

% Tolerance value for considering convergence
minPointMoved = floor(minPointMovedRatio * nPoint);

%% Initialize the circular contour points

% Calculate the image size
[nRow nColumn] = size(I);
imageSize = min(nRow, nColumn);

% Scale the coordinates of the contour in respect to the image size
xOffset = initialCountour(1) * imageSize;
yOffset = initialCountour(2) * imageSize;
radius = initialCountour(3) * imageSize;

% Find the center of the contour
centerRow    = xOffset + ceil(nRow/2);
centerColumn = yOffset + ceil(nColumn/2);

% Calculate the X and Y coordinate of each point in the contour
for iPoint = 1:nPoint
    angle =  (iPoint-1) * 2*pi/nPoint;
    xPoint(iPoint) = round(centerRow + radius*cos(angle));
    yPoint(iPoint) = round(centerColumn + radius*sin(angle));
end

% Calculate the average distance between points
avgPointDistance = perimeter(xPoint, yPoint)/nPoint;

%% Calculate the image gradient

gradient = imageGradient(I);
gradientNorm = (gradient - min(min(gradient))) / range2(gradient);

%% Display the image and plot the initial contour

figure;
idisp(I, 'plain');
hold on;
plotContourPoints(xPoint, yPoint, beta);
set(gca,'position',[0 0 1 1],'units','normalized')

%% Optimization loop

for iteraction = 1:maxIteractions
    
    % Clear the moved points counter
    nPointMoved = 0;
    
    % For each point of the contour:
    for iPoint = 1:nPoint
        
        % Get the coordinates of the adjacent points
        if(iPoint == 1)
            xBuffer = [xPoint(nPoint) xPoint(iPoint) xPoint(iPoint+1)];
            yBuffer = [yPoint(nPoint) yPoint(iPoint) yPoint(iPoint+1)];
        elseif(iPoint == nPoint)
            xBuffer = [xPoint(iPoint-1) xPoint(iPoint) xPoint(1)];
            yBuffer = [yPoint(iPoint-1) yPoint(iPoint) yPoint(1)];
        else
            xBuffer = [xPoint(iPoint-1) xPoint(iPoint) xPoint(iPoint+1)];
            yBuffer = [yPoint(iPoint-1) yPoint(iPoint) yPoint(iPoint+1)];
        end
        
        % For each point inside the neighborhood of the current point
        for xNHood = 1:NHoodSize
            for yNHood = 1:NHoodSize                
                  
                % Get the coordinates of the neighborhood point
                xBuffer(2) = xPoint(iPoint) + (xNHood-1-NHoodWidth);
                yBuffer(2) = yPoint(iPoint) + (yNHood-1-NHoodWidth);
                
                % If the point is too close to the image border, do not
                % compute its energy as it should not be evaluated as a
                % possible point update
                if(xBuffer(2) <= NHoodWidth || yBuffer(2) <= NHoodWidth || xBuffer(2) > nRow-NHoodWidth || yBuffer(2) > nColumn-NHoodWidth)
                    ECont(xNHood, yNHood)  = NaN;
                    ECurv(xNHood, yNHood)  = NaN;
                    EImage(xNHood, yNHood) = NaN;
                
                % Otherwise, calculate ECont, ECurv e EImage
                else
                    ECont(xNHood, yNHood)  = (avgPointDistance - sqrt((xBuffer(2)-xBuffer(1))^2+(yBuffer(2)-yBuffer(1))^2))^2;
                    ECurv(xNHood, yNHood)  = (xBuffer(1)-2*xBuffer(2)+xBuffer(3))^2+(yBuffer(1)-2*yBuffer(2)+yBuffer(3))^2;
                    EImage(xNHood,yNHood) = -gradientNorm(xBuffer(2), yBuffer(2));
                end
            end
        end
        
        % Calculate the normalized total energy
        ECont  = ECont  / max(max(ECont));
        ECurv  = ECurv  / max(max(ECurv));
        totalE = alpha(iPoint)*ECont + beta(iPoint)*ECurv + gama(iPoint)*EImage;
        
        % Find the point inside the neighborhood that minimizes the total
        % energy
        [xMin yMin] = find(totalE == min(min(totalE)));
        
        % If the minimun energy point is not the center of the
        % neighborhood, move the contour point
        if((xMin(1) ~= (NHoodWidth+1)) || (yMin(1) ~= (NHoodWidth+1)))
            xPoint(iPoint) = xPoint(iPoint) - NHoodWidth + (xMin(1)-1);
            yPoint(iPoint) = yPoint(iPoint) - NHoodWidth + (yMin(1)-1);
            nPointMoved = nPointMoved + 1;
        end
    end
    
    % Plot the updated contour points
    if(mod(iteraction, displayRatio) == 0)
        plotContourPoints(xPoint, yPoint, beta);
        pause(0.1);
    end
    
    % If enough points have been updated
    if(nPointMoved > minPointMoved)
        
        % Update the average distance between points
        avgPointDistance = perimeter(xPoint, yPoint)/nPoint;
        
        beta = beta .* findLargeCurvatures(xPoint, yPoint, curvatureThreshold);
       
    % If not enough points have been updated, stop the algorithm
    else
        break;
    end
end

% Plot another image showing only the final position of the contour
% figure;
% idisp(I, 'plain');
% hold on;
% plotContourPoints(xPoint, yPoint, beta);

% Return the final contour
contour = cell(1,2);
contour{1} = xPoint;
contour{2} = yPoint;


%% Calculate the perimeter of the contour
function p = perimeter(xPoint, yPoint)
p = 0;
nPoint = size(xPoint,2);
for i = 1:nPoint-1
    p = p + sqrt((xPoint(i)-xPoint(i+1))^2+(yPoint(i)-yPoint(i+1))^2);
end
p = p + sqrt((xPoint(nPoint)-xPoint(1))^2+(yPoint(nPoint)-yPoint(1))^2);



%% Calculate the curvature of each point in the contour and sign local maximum curvatures greater than the threshold
function indices = findLargeCurvatures(xPoint, yPoint, threshold)

nPoint = size(xPoint,2);
indices = ones(1, nPoint);
curvArray = zeros(1, nPoint);

% Calculate the curvature at each point of the contour
curvArray(1) = sqrt((xPoint(nPoint)-2*xPoint(1)+xPoint(2))^2+(yPoint(nPoint)-2*yPoint(1)+yPoint(2))^2);
for i = 2:nPoint-1;
    curvArray(i) = sqrt((xPoint(i-1)-2*xPoint(i)+xPoint(i+1))^2+(yPoint(i-1)-2*yPoint(i)+yPoint(i+1))^2);
end
curvArray(nPoint) = sqrt((xPoint(nPoint-1)-2*xPoint(nPoint)+xPoint(1))^2+(yPoint(nPoint-1)-2*yPoint(nPoint)+yPoint(1))^2);

% Search the local maxima of the calaculated values and sign those greater than threshold 
if(curvArray(1) > threshold && curvArray(1) > max(curvArray(nPoint),curvArray(2)))
    indices(1) = 0;
end
for i = 2:nPoint-1
    if(curvArray(i) > threshold && curvArray(i) > max(curvArray(i-1),curvArray(i+1)))
        indices(i) = 0;
    end
end
if(curvArray(nPoint) > threshold && curvArray(nPoint) > max(curvArray(nPoint-1),curvArray(1)))
    indices(nPoint) = 0;
end


%% Plot the contour, marking those which the curvature energy has been disabled
function plotContourPoints(xPoint, yPoint, beta)

nPoint = size(xPoint,2);
for iPoint = 1:nPoint
    if(beta(iPoint) == 0)
        plot(yPoint(iPoint), xPoint(iPoint), 'b*');
    else
        plot(yPoint(iPoint), xPoint(iPoint), 'r*');
    end
end
