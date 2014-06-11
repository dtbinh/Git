function varargout = needleTipFinder_manual(varargin)
% NEEDLETIPFINDER_MANUAL MATLAB code for needleTipFinder_manual.fig
%      NEEDLETIPFINDER_MANUAL, by itself, creates a new NEEDLETIPFINDER_MANUAL or raises the existing
%      singleton*.
%
%      H = NEEDLETIPFINDER_MANUAL returns the handle to a new NEEDLETIPFINDER_MANUAL or the handle to
%      the existing singleton*.
%
%      NEEDLETIPFINDER_MANUAL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NEEDLETIPFINDER_MANUAL.M with the given input arguments.
%
%      NEEDLETIPFINDER_MANUAL('Property','Value',...) creates a new NEEDLETIPFINDER_MANUAL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before needleTipFinder_manual_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to needleTipFinder_manual_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% OBS: This program replaces the Needle Detection + Needle Tip Finder,
% alowing to save the results to an external file, generating in that way
% fake measurements

% Edit the above text to modify the response to help needleTipFinder_manual

% Last Modified by GUIDE v2.5 21-Feb-2014 16:12:45

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @needleTipFinder_manual_OpeningFcn, ...
                   'gui_OutputFcn',  @needleTipFinder_manual_OutputFcn, ...
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


% --- Executes just before needleTipFinder_manual is made visible.
function needleTipFinder_manual_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to needleTipFinder_manual (see VARARGIN)

% Choose default command line output for needleTipFinder_manual
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

%
%
%
% Declare global variables
global guiObject guiHandles
global frameSequence outputFileName
global posR posC error savedFrame
global currentFrame W nFrame nRow nColumn

% Parameters
W = 64;

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
error = 0.1         * ones(1, nFrame);
savedFrame = zeros(1, nFrame);

% Display the first image in the GUI
currentFrame = 1;
displayImageAndWindow();




% UIWAIT makes needleTipFinder_manual wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = needleTipFinder_manual_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbuttonNext.
function pushbuttonNext_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonNext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Global Variables
global guiObject guiHandles
global frameSequence outputFileName
global posR posC error savedFrame
global currentFrame W nFrame nRow nColumn

% Find the next valid image in imageList
if(currentFrame == nFrame) 
    nextFrame = 1;
else
    nextFrame = currentFrame + 1;
end

% If the next image is not saved yet, set its window position to the same
% as the previous image
if(~savedFrame(nextFrame))
    posR(nextFrame) = posR(currentFrame);
    posC(nextFrame) = posC(currentFrame);
end

% Update the GUI
currentFrame = nextFrame;
displayImageAndWindow();


% --- Executes on button press in pushbuttonPrev.
function pushbuttonPrev_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonPrev (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Global Variables
global guiObject guiHandles
global frameSequence outputFileName
global posR posC error savedFrame
global currentFrame W nFrame nRow nColumn

% Find the next valid image in imageList
if(currentFrame == 1) 
    nextFrame = nFrame;
else
    nextFrame = currentFrame - 1;
end

% If the next image is not saved yet, set its window position to the same
% as the previous image
if(~savedFrame(nextFrame))
    posR(nextFrame) = posR(currentFrame);
    posC(nextFrame) = posC(currentFrame);
end

% Update the GUI
currentFrame = nextFrame;
displayImageAndWindow();


% --- Executes on button press in pushbuttonFinish.
function pushbuttonFinish_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonFinish (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Global Variables
global guiObject guiHandles
global frameSequence outputFileName
global posR posC error savedFrame
global currentFrame W nFrame nRow nColumn

% Check if all images have been saved and decide if the program should
% really close
finishProgram = 0;
if(sum(savedFrame) < nFrame)
    message = sprintf('There are %d unsaved images. Do you really want to finish the program?', nFrame - sum(savedFrame));
    choice = questdlg(message, 'Warning: unsaved images found', 'Yes','No','No');
    if(strcmp(choice, 'Yes'))
        finishProgram = 1;
    end
else
    finishProgram = 1;
end

% Save the cropped images and close the GUI
if(finishProgram)
    save(outputFileName, 'posR', 'posC', 'error');
    delete(guiObject);
end


function displayImageAndWindow()

% Global Variables
global guiObject guiHandles
global frameSequence outputFileName
global posR posC error savedFrame
global currentFrame W nFrame nRow nColumn

% Update the frame label
set(guiHandles.frameLabel, 'String', sprintf('Frame %d/%d', currentFrame, nFrame));

% Display the image in the imageAxes
axes(guiHandles.frameAxes); hold off;
frame = im2double(rgb2gray(frameSequence(:,:,:,currentFrame)));
frameHandle = imshow(frame);
set(frameHandle,'ButtonDownFcn',@FrameClickCallback);

% Plot the green square over the image
hold on;
cy = posR(currentFrame);
cx = posC(currentFrame);
if(savedFrame(currentFrame))
    rectangle('Position', [cx-W, cy-W, 2*W+1, 2*W+1], 'EdgeColor', 'g');
else
    rectangle('Position', [cx-W, cy-W, 2*W+1, 2*W+1], 'EdgeColor', 'r');
end

% Display the selected window in the windowAxes
axes(guiHandles.zoomAxes);
zoomHandle = imshow(frame(cy-W:cy+W,cx-W:cx+W));
set(zoomHandle,'ButtonDownFcn',@ZoomClickCallback);

% Plot a blue mark in the middle of the image
hold on;
plot(W+1, W+1, 'b*');

function FrameClickCallback ( objectHandle , eventData )

% Global Variables
global guiObject guiHandles
global frameSequence outputFileName
global posR posC error savedFrame
global currentFrame W nFrame nRow nColumn

axesHandle  = get(objectHandle,'Parent');
coordinates = get(axesHandle,'CurrentPoint');
coordinates = round(coordinates(1,1:2));

posR(currentFrame) = coordinates(2);
posC(currentFrame) = coordinates(1);
savedFrame(currentFrame) = 1;

if    (posR(currentFrame) <= W)        posR(currentFrame) = W+1;
elseif(posR(currentFrame) > nRow-W)    posR(currentFrame) = nRow-W; 
end
if    (posC(currentFrame) <= W)        posC(currentFrame) = W+1;
elseif(posC(currentFrame) > nColumn-W) posC(currentFrame) = nColumn-W; 
end

displayImageAndWindow();

function ZoomClickCallback ( objectHandle , eventData )

% Global Variables
global guiObject guiHandles
global frameSequence outputFileName
global posR posC error savedFrame
global currentFrame W nFrame nRow nColumn

axesHandle  = get(objectHandle,'Parent');
coordinates = get(axesHandle,'CurrentPoint');
coordinates = round(coordinates(1,1:2));

posR(currentFrame) = posR(currentFrame) + coordinates(2)-(W+1);
posC(currentFrame) = posC(currentFrame) + coordinates(1)-(W+1);
savedFrame(currentFrame) = 1;

if    (posR(currentFrame) <= W)        posR(currentFrame) = W+1;
elseif(posR(currentFrame) > nRow-W)    posR(currentFrame) = nRow-W; 
end
if    (posC(currentFrame) <= W)        posC(currentFrame) = W+1;
elseif(posC(currentFrame) > nColumn-W) posC(currentFrame) = nColumn-W; 
end

displayImageAndWindow();


% --- Executes on button press in pushbuttonSave.
function pushbuttonSave_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Global Variables
global guiObject guiHandles
global frameSequence outputFileName
global posR posC error savedFrame
global currentFrame W nFrame nRow nColumn

% Remove the current image from imageList
savedFrame(currentFrame) = 1;

% Change to the next image
pushbuttonNext_Callback();
