function plotImagePointsAndEpipolarLines(IL, IR, PL, PR, eL, eR)

% PLOTIMAGEPOINTSANDEPIPOLARLINES
%    PLOTIMAGEPOINTSANDEPIPOLARLINES(IL, IR, PL, PR, EL, ER) plots an
%    image, a set of points and a set of epipolar lines associated to the
%    plotted points. The epipolar lines should be found by using
%    corresponding points in another image and not simply the epipole
%    location.
%
%
%    Other m-files required: none
%    Subfunctions: none
%    MAT-files required: none
%
%    See also: FINDANDPLOTEPIPOLARLINES, GENERATEEPIPOLARLINES  

% Author: André Augusto Geraldes
% Email: andregeraldes@lara.unb.br
% October 2013; Last revision: 02-November-2013

nPoint = size(PL,1);

figure;
idisp(IL, 'plain');
set(gca,'position',[0 0 1 1],'units','normalized')
hold on;
for iPoint = 1:nPoint
    plot(PL(iPoint,1), PL(iPoint,2), 'b*');
    plot(eL(iPoint,1:2), eL(iPoint,3:4), 'r-');
end

figure;
idisp(IR, 'plain');
set(gca,'position',[0 0 1 1],'units','normalized')
hold on;
for iPoint = 1:nPoint
    plot(PR(iPoint,1), PR(iPoint,2), 'b*');
    plot(eR(iPoint,1:2), eR(iPoint,3:4), 'r-');
end