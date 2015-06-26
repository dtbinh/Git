disp('- Machine Vision Toolbox for Matlab (release 3)')
tbpath = fileparts(which('blackbody'));
addpath( fullfile(tbpath, 'examples') );
addpath( fullfile(tbpath, 'images') );
addpath( fullfile(tbpath, 'mex') );
% add the contrib code to the path
p = fullfile(rvcpath, 'contrib/vgg');
if exist(p)
    addpath( p );
    disp([' - VGG contributed code (' p ')']);
end
p = fullfile(rvcpath, 'contrib/EPnP/EPnP');
if exist(p)
    addpath( p );
    disp([' - EPnP contributed code (' p ')']);
end
p = fullfile(tbpath, ['../contrib/vlfeat-0.9.9/toolbox/mex/' mexext]);
if exist(p)
    addpath( p );
    disp([' - VLFeat contributed code (' p ')']);
end
p = fullfile(tbpath, '../contrib/graphseg');
if exist(p)
    addpath( p );
    disp([' - graphseg contributed code (' p ')']);
end
p = fullfile(tbpath, '../contrib/camera_calib');
if exist(p)
    addpath( p );
    disp([' - camera calibration toolbox contributed code (' p ')']);
end
