function edgeDetection(image, thresholds)

% EDGEDETECTION Detect edges using different methods
%    edgeDetection(image, thresholds) applies four different edge
%    detection algorithms (Roberts, Prewitt, Sobel, Canny) to the same
%    image and display them for comparison. 
%
%  Other m-files required: edgeRoberts.m, edgePrewitt.m, edgeSobel.m, idisp.m
%  Subfunctions: none
%  MAT-files required: none
%
% See also: EDGEROBERTS, EDGEPREWITT, EDGESOBEL

% Author: André Augusto Geraldes
% Email: andregeraldes@lara.unb.br
% September 2013; Last revision: 28-September-2013


eCanny = edge(image, 'canny', [thresholds(1) thresholds(2)]);
eRoberts = edgeRoberts(image, thresholds(3));
ePrewitt = edgePrewitt(image, thresholds(4));
eSobel = edgeSobel(image, thresholds(5));

figure;
subplot(221); idisp(eCanny,   'plain', 'axis',gca);
subplot(222); idisp(eRoberts, 'plain', 'axis',gca);
subplot(223); idisp(ePrewitt, 'plain', 'axis',gca);
subplot(224); idisp(eSobel,   'plain', 'axis',gca);