function varargout = needleTipFinder_manual3(varargin)
% NEEDLETIPFINDER_MANUAL3 MATLAB code for needleTipFinder_manual3.fig
%      NEEDLETIPFINDER_MANUAL3, by itself, creates a new NEEDLETIPFINDER_MANUAL3 or raises the existing
%      singleton*.
%
%      H = NEEDLETIPFINDER_MANUAL3 returns the handle to a new NEEDLETIPFINDER_MANUAL3 or the handle to
%      the existing singleton*.
%
%      NEEDLETIPFINDER_MANUAL3('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NEEDLETIPFINDER_MANUAL3.M with the given input arguments.
%
%      NEEDLETIPFINDER_MANUAL3('Property','Value',...) creates a new NEEDLETIPFINDER_MANUAL3 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before needleTipFinder_manual3_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to needleTipFinder_manual3_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help needleTipFinder_manual3

% Last Modified by GUIDE v2.5 09-Mar-2014 22:58:12

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @needleTipFinder_manual3_OpeningFcn, ...
                   'gui_OutputFcn',  @needleTipFinder_manual3_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before needleTipFinder_manual3 is made visible.
function needleTipFinder_manual3_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to needleTipFinder_manual3 (see VARARGIN)

% Choose default command line output for needleTipFinder_manual3
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

%
%
%
% Declare global variables

% Parameters
global guiObject guiHandles
global frameSequence outputFileName  posR posC
global currentFrame W nFrame nRow nColumn

W = 57;

% Decode varargin
if(nargin < 5)
    fprintf('ERROR: needleTipFinder_manual requires at least 2 inputs');
    delete(hObject);
else
    frameSequence = read(mmreader(varargin{1}));
    outputFileName = varargin{2};
end

% Assign GUI handlers to global variables
guiObject = hObject;
guiHandles = handles;

% Initialize output variables
nFrame = size(frameSequence,4);
[nRow nColumn] = size(frameSequence(:,:,1,1));

posR = round(nRow/2)    * ones(1, nFrame);
posC = round(nColumn/2) * ones(1, nFrame);

% Display the first image in the GUI
currentFrame = 1;
displayImageAndWindow();


% --- Outputs from this function are returned to the command line.
function varargout = needleTipFinder_manual3_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function displayImageAndWindow()

% Global Variables
global guiObject guiHandles
global frameSequence outputFileName  posR posC
global currentFrame W nFrame nRow nColumn


% Update the frame label
set(guiHandles.frameLabel, 'String', sprintf('%d/%d', currentFrame, nFrame));

% Display the image in the imageAxes
axes(guiHandles.frameAxes); hold off;
frame = im2double(rgb2gray(frameSequence(:,:,:,currentFrame)));
frameHandle = imshow(frame);
set(frameHandle,'ButtonDownFcn',@FrameClickCallback);

% Plot the green square over the image
hold on;
cy = posR(currentFrame);
cx = posC(currentFrame);
rectangle('Position', [cx-W, cy-W, 2*W+1, 2*W+1], 'EdgeColor', 'g');


function FrameClickCallback ( objectHandle , eventData )

% Global Variables
global guiObject guiHandles
global frameSequence outputFileName  posR posC
global currentFrame W nFrame nRow nColumn


axesHandle  = get(objectHandle,'Parent');
coordinates = get(axesHandle,'CurrentPoint');
coordinates = round(coordinates(1,1:2));

posR(currentFrame) = coordinates(2);
posC(currentFrame) = coordinates(1);

if    (posR(currentFrame) <= W)        posR(currentFrame) = W+1;
elseif(posR(currentFrame) > nRow-W)    posR(currentFrame) = nRow-W; 
end
if    (posC(currentFrame) <= W)        posC(currentFrame) = W+1;
elseif(posC(currentFrame) > nColumn-W) posC(currentFrame) = nColumn-W; 
end

goToNextFrame();

function goToNextFrame()

% Global Variables
global guiObject guiHandles
global frameSequence outputFileName  posR posC
global currentFrame W nFrame nRow nColumn


% Find the next valid image in imageList
if(currentFrame == nFrame) 
    save(outputFileName, 'posR', 'posC');
    delete(guiObject);
else
    posR(currentFrame+1) = posR(currentFrame);
    posC(currentFrame+1) = posC(currentFrame);
    currentFrame = currentFrame+1;
    displayImageAndWindow();
end
