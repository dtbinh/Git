function varargout = videoCropper(varargin)
% VIDEOCROPPER MATLAB code for videoCropper.fig
%      VIDEOCROPPER, by itself, creates a new VIDEOCROPPER or raises the existing
%      singleton*.
%
%      H = VIDEOCROPPER returns the handle to a new VIDEOCROPPER or the handle to
%      the existing singleton*.
%
%      VIDEOCROPPER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VIDEOCROPPER.M with the given input arguments.
%
%      VIDEOCROPPER('Property','Value',...) creates a new VIDEOCROPPER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before videoCropper_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to videoCropper_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help videoCropper

% Last Modified by GUIDE v2.5 26-Feb-2014 18:14:08

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @videoCropper_OpeningFcn, ...
                   'gui_OutputFcn',  @videoCropper_OutputFcn, ...
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


% --- Executes just before videoCropper is made visible.
function videoCropper_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to videoCropper (see VARARGIN)

% Choose default command line output for videoCropper
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

%
%
%
% Declare global variables
global guiObject guiHandles W nRow nColumn nFrame currentFrame
global frameSequence selectedFrame savedFrame croppPositionRow croppPositionColumn

% Decode varargin
if(nargin < 6)
    fprintf('ERROR: needleTipFinder_manual requires at least 3 inputs');
    delete(hObject);
else
    videoFile = varargin{1};
    W = varargin{2};
    frameRateDivider = varargin{3};
end

% Assign GUI handlers to global variables
guiObject = hObject;
guiHandles = handles;

% Read the provided video and measure size of frames
video = read(mmreader(videoFile));
nRow = size(video, 1);
nColumn = size(video, 2);
nFrame = size(video, 4);

% Initialize the frameSequence
frameSequence = zeros(nRow, nColumn, nFrame);
for iFrame = 1:nFrame
    frameSequence(:,:,iFrame) = im2double(rgb2gray(video(:,:,:,iFrame)));
end

% Initialize the selectedFrame array
selectedFrame = zeros(1, nFrame);
iCounter = 0;
for iFrame = 1:nFrame
    iCounter = iCounter+1;
    if(iCounter >= frameRateDivider)
        selectedFrame(iFrame) = 1;
        iCounter = 0;
    end
end

% Initialize the arrays for marking the cropping positions
croppPositionRow = (nRow+1)/2 * ones(1, nFrame);
croppPositionColumn = (nColumn+1)/2 * ones(1, nFrame);
savedFrame = zeros(1, nFrame);

% Display the first image in the GUI
currentFrame = nFrame;
pushbuttonNext_Callback();

% UIWAIT makes videoCropper wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = videoCropper_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Global variables
global guiObject guiHandles W nRow nColumn nFrame currentFrame
global frameSequence selectedFrame savedFrame croppPositionRow croppPositionColumn

% Save the cropped images and close the GUI
varargout{1} = selectedFrame;
varargout{2} = croppPositionRow;
varargout{3} = croppPositionColumn;



% --- Executes on button press in pushbuttonSave.
function pushbuttonSave_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Global variables
global guiObject guiHandles W nRow nColumn nFrame currentFrame
global frameSequence selectedFrame savedFrame croppPositionRow croppPositionColumn

savedFrame(currentFrame) = 1;
pushbuttonNext_Callback();

% --- Executes on button press in pushbuttonDiscard.
function pushbuttonDiscard_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonDiscard (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Global variables
global guiObject guiHandles W nRow nColumn nFrame currentFrame
global frameSequence selectedFrame savedFrame croppPositionRow croppPositionColumn

if(sum(selectedFrame) > 1)
    selectedFrame(currentFrame) = 0;
    pushbuttonNext_Callback();
end


% --- Executes on button press in pushbuttonNext.
function pushbuttonNext_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonNext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Global variables
global guiObject guiHandles W nRow nColumn nFrame currentFrame
global frameSequence selectedFrame savedFrame croppPositionRow croppPositionColumn

% Find the next selected frame
if(currentFrame == nFrame) nextFrame = 1;
else                       nextFrame = currentFrame + 1; 
end
while(~(selectedFrame(nextFrame)))
    if(nextFrame == nFrame) nextFrame = 1;
    else                    nextFrame = nextFrame + 1; 
    end
end

% If the next frame is not saved yet, set its window position to the same
% as the previous frame
if(~(savedFrame(nextFrame)))
    croppPositionRow(nextFrame)    = croppPositionRow(currentFrame);
    croppPositionColumn(nextFrame) = croppPositionColumn(currentFrame);
end

% Update the GUI
currentFrame = nextFrame;
displayImageAndCroppWindow();


% --- Executes on button press in pushbuttonPrevious.
function pushbuttonPrevious_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonPrevious (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Global variables
global guiObject guiHandles W nRow nColumn nFrame currentFrame
global frameSequence selectedFrame savedFrame croppPositionRow croppPositionColumn

% Find the next selected frame
if(currentFrame == 1) nextFrame = nFrame;
else                  nextFrame = currentFrame - 1; 
end
while(~(selectedFrame(nextFrame)))
    if(nextFrame == 1) nextFrame = nFrame;
    else               nextFrame = nextFrame - 1; 
    end
end

% If the next frame is not saved yet, set its window position to the same
% as the previous frame
if(~(savedFrame(nextFrame)))
    croppPositionRow(nextFrame)    = croppPositionRow(currentFrame);
    croppPositionColumn(nextFrame) = croppPositionColumn(currentFrame);
end

% Update the GUI
currentFrame = nextFrame;
displayImageAndCroppWindow();

% --- Executes on button press in pushbuttonFinish.
function pushbuttonFinish_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonFinish (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Global variables
global guiObject guiHandles W nRow nColumn nFrame currentFrame
global frameSequence selectedFrame savedFrame croppPositionRow croppPositionColumn

% Check if all images have been saved and decide if the program should
% really close
finishProgram = 0;
unsavedImages = selectedFrame .* 1-savedFrame;

if(sum(unsavedImages) > 0)
    message = sprintf('There are %d unsaved images. Do you really want to finish the program?', sum(unsavedImages));
    choice = questdlg(message, 'Warning: unsaved images found', 'Yes','No','No');
    if(strcmp(choice, 'Yes'))
        finishProgram = 1;
        selectedFrame(find(unsavedImages == 1)) = 0;
    end
else
    finishProgram = 1;
end

% Save the cropped images and close the GUI
if(finishProgram)
    delete(guiObject);
%     videoCropper_OutputFcn(guiObject, 0, guiHandles);
end

function displayImageAndCroppWindow()

% Global Variables
global guiObject guiHandles W nRow nColumn nFrame currentFrame
global frameSequence selectedFrame savedFrame croppPositionRow croppPositionColumn

% Update the frame label
set(guiHandles.frameLabel, 'String', sprintf('Frame %d/%d', currentFrame, nFrame));

% Display the image in the imageAxes
axes(guiHandles.frameAxes); hold off;
frameHandle = imshow(frameSequence(:,:,currentFrame));
set(frameHandle,'ButtonDownFcn',@FrameClickCallback);

% Plot the green square over the image
hold on;
cy = croppPositionRow(currentFrame);
cx = croppPositionColumn(currentFrame);
if(savedFrame(currentFrame))
    rectangle('Position', [cx-W, cy-W, 2*W+1, 2*W+1], 'EdgeColor', 'g');
else
    rectangle('Position', [cx-W, cy-W, 2*W+1, 2*W+1], 'EdgeColor', 'r');
end

% Display the selected window in the windowAxes
axes(guiHandles.zoomAxes);
zoomHandle = imshow(frameSequence(cy-W:cy+W, cx-W:cx+W, currentFrame));
set(zoomHandle,'ButtonDownFcn',@ZoomClickCallback);

% Plot a blue mark in the middle of the image
hold on;
plot(W+1, W+1, 'b*');

function FrameClickCallback ( objectHandle , eventData )

% Global Variables
global guiObject guiHandles W nRow nColumn nFrame currentFrame
global frameSequence selectedFrame savedFrame croppPositionRow croppPositionColumn

axesHandle  = get(objectHandle,'Parent');
coordinates = get(axesHandle,'CurrentPoint');
coordinates = round(coordinates(1,1:2));

croppPositionRow(currentFrame) = coordinates(2);
croppPositionColumn(currentFrame) = coordinates(1);
savedFrame(currentFrame) = 1;

if    (croppPositionRow(currentFrame) <= W)        croppPositionRow(currentFrame) = W+1;
elseif(croppPositionRow(currentFrame) > nRow-W)    croppPositionRow(currentFrame) = nRow-W; 
end
if    (croppPositionColumn(currentFrame) <= W)        croppPositionColumn(currentFrame) = W+1;
elseif(croppPositionColumn(currentFrame) > nColumn-W) croppPositionColumn(currentFrame) = nColumn-W; 
end

displayImageAndCroppWindow();

function ZoomClickCallback ( objectHandle , eventData )

% Global Variables
global guiObject guiHandles W nRow nColumn nFrame currentFrame
global frameSequence selectedFrame savedFrame croppPositionRow croppPositionColumn

axesHandle  = get(objectHandle,'Parent');
coordinates = get(axesHandle,'CurrentPoint');
coordinates = round(coordinates(1,1:2));

croppPositionRow(currentFrame) = croppPositionRow(currentFrame) + coordinates(2)-(W+1);
croppPositionColumn(currentFrame) = croppPositionColumn(currentFrame) + coordinates(1)-(W+1);
savedFrame(currentFrame) = 1;

if    (croppPositionRow(currentFrame) <= W)        croppPositionRow(currentFrame) = W+1;
elseif(croppPositionRow(currentFrame) > nRow-W)    croppPositionRow(currentFrame) = nRow-W; 
end
if    (croppPositionColumn(currentFrame) <= W)        croppPositionColumn(currentFrame) = W+1;
elseif(croppPositionColumn(currentFrame) > nColumn-W) croppPositionColumn(currentFrame) = nColumn-W; 
end

displayImageAndCroppWindow();
