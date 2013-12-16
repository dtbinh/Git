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

% Last Modified by GUIDE v2.5 04-Dec-2013 03:04:20

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
global guiObject guiHandles imageList currentImage nImage firstClick firstClickCoordinates

% Decode varargin
if(nargin < 5)
    fprintf('ERROR: needleMarker requires at least 2 inputs');
    delete(hObject);
else
    sourceDirectory = varargin{1};
    targetDirectory = varargin{2};
end
    
% Create the targetDirectory (in case it doesn't exist)
mkdir(targetDirectory);

% Assign GUI handlers to global variables
guiObject = hObject;
guiHandles = handles;

% Initialize the imageList
initImageList(sourceDirectory, targetDirectory);

% Display the first image in the GUI
currentImage = 1;
displayMainImage();


% --- Outputs from this function are returned to the command line.
function varargout = needleMarker_OutputFcn(hObject, eventdata, handles) 
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
global guiObject guiHandles imageList currentImage nImage firstClick firstClickCoordinates

% Switch to the next image in imageList
if(currentImage == nImage)
    nextImage = 1;
else
    nextImage = currentImage + 1; 
end

% Update the GUI
currentImage = nextImage;
displayMainImage();
if(imageList(currentImage).marked)
    displayImageMask();
end


% --- Executes on button press in pushbuttonPrev.
function pushbuttonPrev_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonPrev (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Global Variables
global guiObject guiHandles imageList currentImage nImage firstClick firstClickCoordinates

% Switch to the previous image in imageList
if(currentImage == 1)
    nextImage = nImage;
else
    nextImage = currentImage - 1;
end

% Update the GUI
currentImage = nextImage;
displayMainImage();
if(imageList(currentImage).marked)
    displayImageMask();
end

% --- Executes on button press in pushbuttonClear.
function pushbuttonClear_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonClear (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Global Variables
global guiObject guiHandles imageList currentImage nImage firstClick firstClickCoordinates

imageList(currentImage).marked = 0;
imageList(currentImage).M = zeros(25);
displayMainImage();

% --- Executes on button press in pushbuttonFinish.
function pushbuttonFinish_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonFinish (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Global Variables
global guiObject guiHandles imageList currentImage nImage firstClick firstClickCoordinates

% Check if all images have been saved and decide if the program should
% really close
finishProgram = 0;
unmarkedImages = verifySavedImages();
if(unmarkedImages > 0)
    message = sprintf('There are %d unsaved images. Do you really want to finish the program?', unmarkedImages);
    choice = questdlg(message, 'Warning: unsaved images found', 'Yes','No','No');
    if(strcmp(choice, 'Yes'))
        finishProgram = 1;
    end
else
    finishProgram = 1;
end

if(finishProgram)
    for iImage = 1:nImage
        if(imageList(iImage).marked)
            imwrite(imageList(iImage).M, imageList(iImage).name);
        end
    end
    delete(guiObject);
end


function ImageClickCallback ( objectHandle , eventData )

% Global Variables
global guiObject guiHandles imageList currentImage nImage firstClick firstClickCoordinates

axesHandle  = get(objectHandle,'Parent');
coordinates = get(axesHandle,'CurrentPoint');
coordinates = round(coordinates(1,1:2));

if(~(imageList(currentImage).marked))
    
    if(~firstClick)
        firstClick = 1;
        firstClickCoordinates = coordinates;
        axes(guiHandles.imageAxes);
        hold on;
        plot(coordinates(1), coordinates(2), 'r*');
    else
        imageList(currentImage).marked = 1;
        imageList(currentImage).x = [firstClickCoordinates(1) coordinates(1)];
        imageList(currentImage).y = [firstClickCoordinates(2) coordinates(2)];
        generateImageMask();
        displayImageMask();
    end
end


function initImageList(sourceDirectory, targetDirectory)

% Global Variables
global guiObject guiHandles imageList currentImage nImage firstClick firstClickCoordinates

% Find all files in the source directory
allFiles = dir(sourceDirectory);
nFile = size(allFiles, 1);

% Find all jpg images in the source directory
iImage = 1;
for iFile = 1:nFile
    fileName = allFiles(iFile).name;
    length = size(fileName,2);
    if(length > 4)
        
        % For each jpg image found save its name and complete name
        if(strcmp(fileName(length-3:length), '.jpg'))
            imageFileName{iImage} = fileName;
            completeImageFileName{iImage} = sprintf('%s/%s',sourceDirectory, fileName);
            iImage = iImage + 1;
        end
        
    end
end

% Save the total amount of found images
nImage = iImage - 1;

% Initialize the imageList struct array
imageList = repmat(struct('I', zeros(25), 'M', zeros(25), 'name', '00-00-00 000.jpg', 'x', [0 0], 'y', [0 0], 'marked', 0), nImage, 1);
for iImage = 1:nImage
    image = imread(completeImageFileName{iImage});
    if(size(image,3) > 1)
        imageList(iImage).I = im2double(rgb2gray(image));
    else
        imageList(iImage).I = im2double(image);        
    end
    imageList(iImage).name = sprintf('%s/output_%s', targetDirectory, imageFileName{iImage});
end

function displayMainImage()

% Global Variables
global guiObject guiHandles imageList currentImage nImage firstClick firstClickCoordinates

% Display the image in the imageAxes
axes(guiHandles.imageAxes);
hold off;
imageHandle = imshow(imageList(currentImage).I);
set(imageHandle,'ButtonDownFcn',@ImageClickCallback);

% Display the selected window in the maskAxes
axes(guiHandles.maskAxes);
imshow(zeros(25));

% Clear any clicks made in other images
firstClick = 0;
firstClickCoordinates = [0 0];

function displayImageMask()

% Global Variables
global guiObject guiHandles imageList currentImage nImage firstClick firstClickCoordinates
 
% % Display the image in the imageAxes
axes(guiHandles.imageAxes);
hold on;
plot(imageList(currentImage).x, imageList(currentImage).y, 'r*-');

% Display the selected window in the maskAxes
axes(guiHandles.maskAxes);
imshow(imageList(currentImage).M);

function generateImageMask()

% Global Variables
global guiObject guiHandles imageList currentImage nImage firstClick firstClickCoordinates

x = imageList(currentImage).x;
y = imageList(currentImage).y;

% if(x(1) > x(2))
%     x1 = x(2);
%     x2 = x(1);
%     y1 = y(2);
%     y2 = y(1);
% else
x1 = x(1);
x2 = x(2);
y1 = y(1);
y2 = y(2);
% end

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
global guiObject guiHandles imageList currentImage nImage firstClick firstClickCoordinates

brush = [0.25 0.50 0.75 0.50 0.25; 
         0.50 0.75 1.00 0.75 0.50;
         0.75 1.00 1.00 1.00 0.75;
         0.50 0.75 1.00 0.75 0.50;
         0.25 0.50 0.75 0.50 0.25];
     
dirac = zeros(25);
dirac(x, y) = 1;
paint = conv2(dirac, brush, 'same');

% size(imageList(currentImage).M)
% size(paint)
imageList(currentImage).M = max(imageList(currentImage).M, paint);

function unmarkedImages = verifySavedImages()

% Global Variables
global guiObject guiHandles imageList currentImage nImage

unmarkedImages = 0;
for iImage = 1:nImage
    if(imageList(iImage).marked == 0)
        unmarkedImages = unmarkedImages + 1;
    end
end
