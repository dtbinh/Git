function [deltaRow deltaColumn uncertainty] = needleTipFinder(needleMask, previousTheta, varargin)

%
%   FUNCTION DESCRIPTION
%
%    Other m-files required: none
%    Subfunctions: none
%    MAT-files required: none
%
%    See also: 

% http://en.wikipedia.org/wiki/Image_moment
% http://homepages.inf.ed.ac.uk/rbf/CVonline/LOCAL_COPIES/OWENS/LECT2/node3.html
% http://www.mathworks.com/help/images/ref/regionprops.html#bqkf8h_

% Author: André Augusto Geraldes
% Email: andregeraldes@lara.unb.br
% February 2014; Last revision: 18-February-2014

%% Default parameters

tipOffsetPercentage = 0.1;
tipOffset = round(tipOffsetPercentage * size(needleMask,1));

if(nargin > 2)
    debugMode = 1;
else
    debugMode = 0;
end

%% Find the needle centroid
Ibw = imfill(needleMask,'holes');
% Ilabel = logical(Ibw);
maskProperties = regionprops(Ibw, 'MajorAxisLength', 'MinorAxisLength', 'Area', 'Centroid', 'Orientation', 'ConvexArea', 'ConvexHull');

needleArea = -1;
totalArea = 0;
for i = 1: numel(maskProperties)
    if(maskProperties(i).Area > needleArea)
        needleRegion = i;
        needleArea = maskProperties(i).Area;
    end
    totalArea = totalArea + maskProperties(i).Area;
end
if(numel(maskProperties) < 1)
    figure(8);
    idisp(needleMask);
end
needleProperties = maskProperties(needleRegion);

theta = deg2rad(needleProperties.Orientation);
ci = round(needleProperties.Centroid(2));           % Centroid Row
cj = round(needleProperties.Centroid(1));           % Centroid Column


%% DEBUG
% 
% major = needleProperties.MajorAxisLength / 2;
% minor = needleProperties.MinorAxisLength / 2;
% 
% p1Col = [cj - major * cos(-theta) ; cj + major * cos(-theta)];
% p1Row = [ci - major * sin(-theta) ; ci + major * sin(-theta)];
% 
% theta2 = theta + pi/2;
% p2Col = [cj - minor * cos(-theta2) ; cj + minor * cos(-theta2)];
% p2Row = [ci - minor * sin(-theta2) ; ci + minor * sin(-theta2)];
% 
% figure(9);
% idisp(needleMask, 'plain');
% set(gca,'position',[0 0 1 1],'units','normalized')
% hold on;
% plot(needleProperties.ConvexHull(:,1), needleProperties.ConvexHull(:,2), 'r-');
% plot(cj, ci, 'bo');
% plot(p1Col, p1Row, 'b-');
% plot(p2Col, p2Row, 'b-');
% pause();


%% Find the needle tip over the center line

% Measure the image size
[nRow, nColumn] = size(needleMask);

% Initialize the return variables with meaningless data
deltaRow = nRow;
deltaColumn = nColumn;

% Search for the needle tip over the center line
% CASE 1: The center line is horizontal
if(theta == 0)
    
    deltaRow = ci - (nRow+1)/2;
    maxDColumn = max(nColumn - cj, cj - 1);
    
    % Move along the center line in both directions
    for dColumn = 1:maxDColumn
        
%         % Move right
%         if(cj+dColumn <= nColumn)
%             if(needleMask(ci, cj+dColumn) == 0)
%                 deltaColumn = max(dColumn - tipOffset, 0);
%                 break;
%             end
%         end

        % Move left
        if(cj-dColumn >= 1)
            if(needleMask(ci, cj-dColumn) == 0)
                deltaColumn = (-1) * max(dColumn - tipOffset, 0);
                break;
            end
        end
    end

% CASE 2: The center line is not horizontal
else    
    
    % CASE 2.1: line angle is between -45º and 45º
    if(theta > -pi/4 && theta < pi/4)
        
        % Scale factor for calculating the row displacement
        kRow = tan(-theta);
        maxDColumn = max(nColumn - cj, cj - 1);
        
        % Move along the center line in both directions
        for dColumn = 1:maxDColumn
            dRow = round(kRow * dColumn);
            
%             % Move right
%             if(cj+dColumn <= nColumn && ci+dRow >= 1 && ci+dRow <= nRow)
%                 if(needleMask(ci+dRow, cj+dColumn) == 0)                    
%                     deltaColumn = max(dColumn - tipOffset, 0);
%                     deltaRow = round(kRow * deltaColumn);
%                     break;
%                 end
%             end
            
            % Move left
            if(cj-dColumn >= 1 && ci-dRow >= 1 && ci-dRow <= nRow)
                if(needleMask(ci-dRow, cj-dColumn) == 0)
                    deltaColumn = (-1) * max(dColumn - tipOffset, 0);
                    deltaRow = round(kRow * deltaColumn);
                    break;
                end
            end
        end

    % CASE 2.1: line angle is lower than -45º or greater than 45º
    else
        
        % Scale factor for calculating the column displacement
        kColumn = 1.0 / tan(-theta);
        maxDRow = max(nRow - ci, ci - 1);
        
        % Move along the center line in both directions
        for dRow = 1:maxDRow
            dColumn = round(kColumn * dRow);
            
            % Move down
            if(ci+dRow <= nRow && cj+dColumn >= 1 && cj+dColumn <= nColumn)
                if(needleMask(ci+dRow, cj+dColumn) == 0)
                    deltaRow = max(dRow - tipOffset, 0);
                    deltaColumn = round(kColumn * deltaRow);
                    break;
                end
            end
            
%             % Move up
%             if(ci-dRow >= 1 && cj-dColumn >= 1 && cj-dColumn <= nColumn)
%                 if(needleMask(ci-dRow, cj-dColumn) == 0)
%                     deltaRow = (-1) * max(dRow - tipOffset, 0);
%                     deltaColumn = round(kColumn * deltaRow);
%                     break;
%                 end    
%             end
        end

    end
end

%% DEBUG

% figure(6);
% idisp(needleMask);
% hold on;
% plotHoughLines(needleMask, rho, theta);
% plot(cj, ci, 'ro');
% plot(cj+deltaColumn, ci+deltaRow, 'b*');
% fprintf('dRow = %f, dCol = %f \n', deltaRow, deltaColumn)
% pause();

%% Estimate the uncertainty associated to the center line direction

% If the needle tip could not be found, set the uncertainty to maximum
if(deltaColumn == nColumn)
    uncertainty = 1.0;
else
    
    % Translate the calculates deltaRow and deltaColumn from the centroid
    % to the center of the image
    deltaRow = deltaRow + ci - (nRow+1)/2;
    deltaColumn = deltaColumn + cj - (nColumn+1)/2;
    
    % Performance Measurement 1: Needle Area
    areaCoef = 2*needleArea / totalArea - 1;
    
    areaCoef2 = needleArea / needleProperties.ConvexArea;
    
    % Performance Measurement 2: Second Moment
    momentCoef = 1 - needleProperties.MinorAxisLength / needleProperties.MajorAxisLength;
    momentCoef = min(momentCoef / 0.7, 1.0);
    
    % Performance Measurement 3: Angle Difference
    
    if(isnan(previousTheta))
        previousTheta = -theta;
    end
    thetaDifference = abs(-theta - previousTheta);
    if(thetaDifference > pi)
        thetaDifference = 2*pi - thetaDifference;
    end
    thetaCoef = 1 - thetaDifference / pi;
    
    
    
%     % Calculate the Hu performance coeficient
%     F = invmoments(needleMask);
%     %     huCoef = (F(2)^2)*(10^3);
%     huCoef = 0.7 * (F(2)^2)*(10^3) / (4*F(1))^4;
%     huCoef = min(huCoef, 1);
%     
%     % Calculate the angle difference between the current and the previous measured angles
%     thetaNew = atan(deltaRow / deltaColumn);
%     if(isnan(thetaNew))
%         thetaNew = theta;
%     end
%     
%     thetaDifferenceNew = abs(-thetaNew - previousTheta);
%     if(thetaDifferenceNew > pi)
%         thetaDifferenceNew = 2*pi - thetaDifferenceNew;
%     end
%     thetaCoef2 = (pi - thetaDifferenceNew) / pi;
%     
% %     uncertainty = 1 - huCoef * thetaCoef1 * thetaCoef2^(0.25);
%     regionCoef = 1 / (numel(statCentroid));
    
    
    % Combine both coeficients in the uncertainty measurement
                       k1 = 2;         k2 = 1;        k3 = 0.5;       k4 = 1;
                               
    uncertainty = 1 - areaCoef^k1 * momentCoef^k2 * thetaCoef^k3 * areaCoef2^k4;
    
    if(debugMode)
        fprintf('ERROR = %f, \t AREA = %f, \t MOM = %f \t T = %f\n', uncertainty, areaCoef, momentCoef, thetaCoef);
    end
    
end



