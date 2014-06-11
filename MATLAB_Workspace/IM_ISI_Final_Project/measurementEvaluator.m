function varargout = measurementEvaluator(varargin)
% MEASUREMENTEVALUATOR MATLAB code for measurementEvaluator.fig
%      MEASUREMENTEVALUATOR, by itself, creates a new MEASUREMENTEVALUATOR or raises the existing
%      singleton*.
%
%      H = MEASUREMENTEVALUATOR returns the handle to a new MEASUREMENTEVALUATOR or the handle to
%      the existing singleton*.
%
%      MEASUREMENTEVALUATOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MEASUREMENTEVALUATOR.M with the given input arguments.
%
%      MEASUREMENTEVALUATOR('Property','Value',...) creates a new MEASUREMENTEVALUATOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before measurementEvaluator_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to measurementEvaluator_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help measurementEvaluator

% Last Modified by GUIDE v2.5 27-Feb-2014 23:08:12

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @measurementEvaluator_OpeningFcn, ...
                   'gui_OutputFcn',  @measurementEvaluator_OutputFcn, ...
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


% --- Executes just before measurementEvaluator is made visible.
function measurementEvaluator_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to measurementEvaluator (see VARARGIN)

% Choose default command line output for measurementEvaluator
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

%
%
%
% Declare global variables
global guiObject guiHandles ultrasoundImage needleImage 
global error posR posC centerR centerC GTPos

% Decode varargin
if(nargin < 5)
    fprintf('ERROR: needleTipFinder_manual requires at least 2 inputs');
    delete(hObject);
else
    ultrasoundImage = varargin{1};
    needleImage = varargin{2};
    GTPos = varargin{3};
    needlePos = varargin{4};
end


% Assign GUI handlers to global variables
guiObject = hObject;
guiHandles = handles;

[nRow nColumn] = size(needleImage);
centerR = (nRow+1)/2;
centerC = (nColumn+1)/2;
posR = needlePos(1);
posC = needlePos(2);

error = 0.1;
displayImage();

uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = measurementEvaluator_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global error
% Get default command line output from handles structure
varargout{1} = error;
% delete(handles.figure1);


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

% --- Executes on button press in pushbutton9.
function pushbutton0_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global error guiObject
error = 0.0;
delete(guiObject);

% --- Executes on button press in pushbutton9.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global error guiObject
error = 0.1;
delete(guiObject);

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global error guiObject
error = 0.2;
delete(guiObject);

% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global error guiObject
error = 0.3;
delete(guiObject);

% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global error guiObject
error = 0.4;
delete(guiObject);

% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global error guiObject
error = 0.5;
delete(guiObject);

% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global error guiObject
error = 0.6;
delete(guiObject);

% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global error guiObject
error = 0.7;
delete(guiObject);

% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global error guiObject
error = 0.8;
delete(guiObject);

% --- Executes on button press in pushbutton1.
function pushbutton9_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global error guiObject
error = 0.9;
delete(guiObject);

% --- Executes on button press in pushbutton10.
function pushbutton10_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global error guiObject
error = 1.0;
delete(guiObject);


function displayImage()

% Global Variables
global guiObject guiHandles ultrasoundImage needleImage 
global posR posC error centerR centerC GTPos GTpresent

axes(guiHandles.ultrasoundAxes); hold off;
imshow(ultrasoundImage);
hold on;
plot(GTPos(2), GTPos(1), 'b*');
plot(posC, posR, 'r*');

% Display the image in the imageAxes
axes(guiHandles.needleAxes); hold off;
imshow(needleImage);
hold on;
plot(GTPos(2), GTPos(1), 'b*');
plot(posC, posR, 'r*');
