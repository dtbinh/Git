function varargout = needleMarker(varargin)
% NEEDLEMARKER MATLAB code for needleMarker.fig
%      NEEDLEMARKER, by itself, creates a new NEEDLEMARKER or raises the existing
%      singleton*.
%
%      H = NEEDLEMARKER returns the handle to a new NEEDLEMARKER or the handle to
%      the existing singleton*.
%
%      NEEDLEMARKER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NEEDLEMARKER.M with the given input arguments.
%
%      NEEDLEMARKER('Property','Value',...) creates a new NEEDLEMARKER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before needleMarker_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to needleMarker_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help needleMarker

% Last Modified by GUIDE v2.5 26-Feb-2014 22:43:04

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @needleMarker_OpeningFcn, ...
                   'gui_OutputFcn',  @needleMarker_OutputFcn, ...
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


% --- Executes just before needleMarker is made visible.
function needleMarker_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to needleMarker (see VARARGIN)

% Choose default command line output for needleMarker
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

%
%
%
% Declare global variables
global guiObject guiHandles W nRow nColumn nFrame currentFrame firstClick firstClickCoordinates
global frameSequence maskSequence selectedFrame markedFrame croppPositionRow croppPositionColumn BLABLA
global brushSize brushSigma

% Decode varargin
if(nargin < 8)
    fprintf('ERROR: needleTipFinder_manual requires at least 5 inputs');
    delete(hObject);
else
    videoFile = varargin{1};
    selectedFrame = varargin{2};
    croppPositionRow = varargin{3};
    croppPositionColumn = varargin{4};
    W = varargin{5};
end

brushSize = 51;
brushSigma = brushSize/5.0;

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

% Initialize the maskSequence
maskSequence = zeros(2*W+1, 2*W+1, nFrame);
BLABLA = zeros(4, nFrame);
firstClick = 0;

% Initialize the array for keeping track of the marked frames
markedFrame = zeros(1, nFrame);

% Display the first image in the GUI
currentFrame = nFrame;
pushbuttonNext_Callback();

% UIWAIT makes videoCropper wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = needleMarker_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Global variables
global guiObject guiHandles W nRow nColumn nFrame currentFrame firstClick firstClickCoordinates
global frameSequence maskSequence selectedFrame markedFrame croppPositionRow croppPositionColumn BLABLA
global brushSize brushSigma

% Save the cropped images and close the GUI
varargout{1} = maskSequence;
varargout{2} = selectedFrame;
varargout{3} = brushSize;
varargout{4} = brushSigma;

% --- Executes on button press in pushbuttonSave.
function pushbuttonClear_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Global variables
global guiObject guiHandles W nRow nColumn nFrame currentFrame firstClick firstClickCoordinates
global frameSequence maskSequence selectedFrame markedFrame croppPositionRow croppPositionColumn BLABLA

markedFrame(currentFrame) = 0;
maskSequence(:,:,currentFrame) = zeros(2*W+1, 2*W+1);
displayImages


% --- Executes on button press in pushbuttonDiscard.
function pushbuttonDiscard_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonDiscard (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Global variables
global guiObject guiHandles W nRow nColumn nFrame currentFrame firstClick firstClickCoordinates
global frameSequence maskSequence selectedFrame markedFrame croppPositionRow croppPositionColumn BLABLA

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
global guiObject guiHandles W nRow nColumn nFrame currentFrame firstClick firstClickCoordinates
global frameSequence maskSequence selectedFrame markedFrame croppPositionRow croppPositionColumn BLABLA

% Find the next selected frame
if(currentFrame == nFrame) nextFrame = 1;
else                       nextFrame = currentFrame + 1; 
end
while(~(selectedFrame(nextFrame)))
    if(nextFrame == nFrame) nextFrame = 1;
    else                    nextFrame = nextFrame + 1; 
    end
end

% Update the GUI
currentFrame = nextFrame;
displayImages();


% --- Executes on button press in pushbuttonPrevious.
function pushbuttonPrevious_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonPrevious (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Global variables
global guiObject guiHandles W nRow nColumn nFrame currentFrame firstClick firstClickCoordinates
global frameSequence maskSequence selectedFrame markedFrame croppPositionRow croppPositionColumn BLABLA

% Find the next selected frame
if(currentFrame == 1) nextFrame = nFrame;
else                  nextFrame = currentFrame - 1; 
end
while(~(selectedFrame(nextFrame)))
    if(nextFrame == 1) nextFrame = nFrame;
    else               nextFrame = nextFrame - 1; 
    end
end

% Update the GUI
currentFrame = nextFrame;
displayImages();

% --- Executes on button press in pushbuttonFinish.
function pushbuttonFinish_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonFinish (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Global variables
global guiObject guiHandles W nRow nColumn nFrame currentFrame firstClick firstClickCoordinates
global frameSequence maskSequence selectedFrame markedFrame croppPositionRow croppPositionColumn BLABLA

% Check if all images have been saved and decide if the program should
% really close
finishProgram = 0;
unsavedImages = selectedFrame .* 1-markedFrame;

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
end

function displayImages()

% Global Variables
global guiObject guiHandles W nRow nColumn nFrame currentFrame firstClick firstClickCoordinates
global frameSequence maskSequence selectedFrame markedFrame croppPositionRow croppPositionColumn BLABLA

% Update the frame label
set(guiHandles.frameLabel, 'String', sprintf('Frame %d/%d', currentFrame, nFrame));

% Display the image in the imageAxes
axes(guiHandles.frameAxes); hold off;
imshow(frameSequence(:,:,currentFrame));

% Plot the green square over the image
hold on;
cy = croppPositionRow(currentFrame);
cx = croppPositionColumn(currentFrame);
rectangle('Position', [cx-W, cy-W, 2*W+1, 2*W+1], 'EdgeColor', 'g');

% Display the selected window in the windowAxes
axes(guiHandles.zoomAxes);
zoomHandle = imshow(frameSequence(cy-W:cy+W, cx-W:cx+W, currentFrame));
set(zoomHandle,'ButtonDownFcn',@ZoomClickCallback);


if(markedFrame(currentFrame))
    % Plot needle center line
    hold on;
    plot( BLABLA(1:2, currentFrame), BLABLA(3:4, currentFrame), 'r*-');
else
    % Plot a blue mark in the middle of the image
    hold on;
    plot(W+1, W+1, 'b*');
end

% Clear any clicks made in other images
firstClick = 1;
firstClickCoordinates = [W+1 W+1];


% Display the needle mask in the maskAxes
axes(guiHandles.maskAxes);
imshow(maskSequence(:, :, currentFrame));

function ZoomClickCallback ( objectHandle , eventData )

% Global Variables
global guiObject guiHandles W nRow nColumn nFrame currentFrame firstClick firstClickCoordinates
global frameSequence maskSequence selectedFrame markedFrame croppPositionRow croppPositionColumn BLABLA

axesHandle  = get(objectHandle,'Parent');
coordinates = get(axesHandle,'CurrentPoint');
coordinates = round(coordinates(1,1:2));

if(~(markedFrame(currentFrame)))
    if(~firstClick)
        firstClick = 1;
        firstClickCoordinates = coordinates;
        axes(guiHandles.zoomAxes);
        hold on;
        plot(coordinates(1), coordinates(2), 'r*');
    else
        markedFrame(currentFrame) = 1;
        BLABLA(1:2, currentFrame) = [firstClickCoordinates(1) ; coordinates(1)];
        BLABLA(3:4, currentFrame) = [firstClickCoordinates(2) ; coordinates(2)];
        generateImageMask();
        displayImages();
    end
end


function generateImageMask()

% Global Variables
global guiObject guiHandles W nRow nColumn nFrame currentFrame firstClick firstClickCoordinates
global frameSequence maskSequence selectedFrame markedFrame croppPositionRow croppPositionColumn BLABLA

x1 = BLABLA(1, currentFrame);
x2 = BLABLA(2, currentFrame);
y1 = BLABLA(3, currentFrame);
y2 = BLABLA(4, currentFrame);

deltaX = abs(x2-x1);
deltaY = abs(y2-y1);

if(deltaX > deltaY)
    if(x2 > x1)
        for x = x1:x2
            y = y1 + (x-x1)*(y2-y1)/(x2-x1);
            paintMask(round(y),round(x));
        end
    else
        for x = x2:x1
            y = y1 + (x-x1)*(y2-y1)/(x2-x1);
            paintMask(round(y),round(x));
        end
    end
else
    if(y2 > y1)
        for y = y1:y2
            x = x1 + (y-y1)*(x2-x1)/(y2-y1);
            paintMask(round(y),round(x));
        end
    else
        for y = y2:y1
            x = x1 + (y-y1)*(x2-x1)/(y2-y1);
            paintMask(round(y),round(x));
        end
    end
end

function paintMask(x,y)

% Global Variables
global guiObject guiHandles W nRow nColumn nFrame currentFrame firstClick firstClickCoordinates
global frameSequence maskSequence selectedFrame markedFrame croppPositionRow croppPositionColumn BLABLA
global brushSize brushSigma

center = (brushSize+1)/2;
brush = fspecial('gaussian', brushSize, brushSigma);
brush = brush / brush(center, center);
     
dirac = zeros(2*W+1);
dirac(x, y) = 1;
paint = conv2(dirac, brush, 'same');
maskSequence(:,:,currentFrame) = max(maskSequence(:,:,currentFrame), paint);
