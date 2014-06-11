function varargout = needleTipFinder_manual2(varargin)
% NEEDLETIPFINDER_MANUAL2 MATLAB code for needleTipFinder_manual2.fig
%      NEEDLETIPFINDER_MANUAL2, by itself, creates a new NEEDLETIPFINDER_MANUAL2 or raises the existing
%      singleton*.
%
%      H = NEEDLETIPFINDER_MANUAL2 returns the handle to a new NEEDLETIPFINDER_MANUAL2 or the handle to
%      the existing singleton*.
%
%      NEEDLETIPFINDER_MANUAL2('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NEEDLETIPFINDER_MANUAL2.M with the given input arguments.
%
%      NEEDLETIPFINDER_MANUAL2('Property','Value',...) creates a new NEEDLETIPFINDER_MANUAL2 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before needleTipFinder_manual2_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to needleTipFinder_manual2_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help needleTipFinder_manual2

% Last Modified by GUIDE v2.5 24-Feb-2014 11:43:10

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @needleTipFinder_manual2_OpeningFcn, ...
                   'gui_OutputFcn',  @needleTipFinder_manual2_OutputFcn, ...
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


% --- Executes just before needleTipFinder_manual2 is made visible.
function needleTipFinder_manual2_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to needleTipFinder_manual2 (see VARARGIN)

% Choose default command line output for needleTipFinder_manual2
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);


%
%
%
% Declare global variables
global guiObject guiHandles ultrasoundImage needleImage 
global posR posC error centerR centerC GTPos GTpresent

% Decode varargin
if(nargin < 5)
    fprintf('ERROR: needleTipFinder_manual requires at least 2 inputs');
    delete(hObject);
else
    ultrasoundImage = varargin{1};
    needleImage = varargin{2};
end

GTpresent = 0;
if(nargin > 5)
    GTPos = varargin{3};
    GTpresent = 1;
end


% Assign GUI handlers to global variables
guiObject = hObject;
guiHandles = handles;

[nRow nColumn] = size(needleImage);
centerR = (nRow+1)/2;
centerC = (nColumn+1)/2;
posR = centerR;
posC = centerC;
error = 0.1;
displayImage();

uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = needleTipFinder_manual2_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Global Variables
global guiObject guiHandles ultrasoundImage needleImage 
global posR posC error centerR centerC GTPos GTpresent

% Get default command line output from handles structure
varargout{1} = posR - centerR;
varargout{2} = posC - centerC;
varargout{3} = error;
delete(handles.figure1);


function FrameClickCallback ( objectHandle , eventData )

% Global Variables
global guiObject guiHandles ultrasoundImage needleImage 
global posR posC error centerR centerC GTPos GTpresent

axesHandle  = get(objectHandle,'Parent');
coordinates = get(axesHandle,'CurrentPoint');
coordinates = round(coordinates(1,1:2));

posR = coordinates(2);
posC = coordinates(1);
displayImage();


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isequal(get(hObject, 'waitstatus'), 'waiting')
    uiresume(hObject);
else 
    delete(hObject);
end

% --- Executes on button press in pushbuttonMQ1.
function pushbuttonMQ1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonMQ1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global guiObject guiHandles ultrasoundImage needleImage 
global posR posC error centerR centerC GTPos GTpresent
error = 0.1;

% --- Executes on button press in pushbuttonMQ2.
function pushbuttonMQ2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonMQ2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global guiObject guiHandles ultrasoundImage needleImage 
global posR posC error centerR centerC GTPos GTpresent
error = 0.1778;

% --- Executes on button press in pushbuttonMQ3.
function pushbuttonMQ3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonMQ3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global guiObject guiHandles ultrasoundImage needleImage 
global posR posC error centerR centerC GTPos GTpresent
error = 0.3162;

% --- Executes on button press in pushbuttonMQ4.
function pushbuttonMQ4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonMQ4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global guiObject guiHandles ultrasoundImage needleImage 
global posR posC error centerR centerC GTPos GTpresent
error = 0.5623;

% --- Executes on button press in pushbuttonMQ5.
function pushbuttonMQ5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonMQ5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global guiObject guiHandles ultrasoundImage needleImage 
global posR posC error centerR centerC GTPos GTpresent
error = 1;



function displayImage()

% Global Variables
global guiObject guiHandles ultrasoundImage needleImage 
global posR posC error centerR centerC GTPos GTpresent

axes(guiHandles.ultrasoundAxes); hold off;
imshow(ultrasoundImage);
hold on;
if(GTpresent)
    plot(GTPos(2), GTPos(1), 'b*');
end
plot(posC, posR, 'r*');


% Display the image in the imageAxes
axes(guiHandles.needleAxes); hold off;
frameHandle = imshow(needleImage);
set(frameHandle,'ButtonDownFcn',@FrameClickCallback);

% Plot a red mark in the needle tip
hold on;
if(GTpresent)
    plot(GTPos(2), GTPos(1), 'b*');
end
plot(posC, posR, 'r*');