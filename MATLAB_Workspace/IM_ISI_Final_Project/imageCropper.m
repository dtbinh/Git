function varargout = imageCropper(varargin)
% IMAGECROPPER MATLAB code for imageCropper.fig
%      IMAGECROPPER, by itself, creates a new IMAGECROPPER or raises the existing
%      singleton*.
%
%      H = IMAGECROPPER returns the handle to a new IMAGECROPPER or the handle to
%      the existing singleton*.
%
%      IMAGECROPPER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IMAGECROPPER.M with the given input arguments.
%
%      IMAGECROPPER('Property','Value',...) creates a new IMAGECROPPER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before imageCropper_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to imageCropper_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help imageCropper

% Last Modified by GUIDE v2.5 03-Dec-2013 19:35:45

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @imageCropper_OpeningFcn, ...
                   'gui_OutputFcn',  @imageCropper_OutputFcn, ...
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

% --- Executes just before imageCropper is made visible.
function imageCropper_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to imageCropper (see VARARGIN)

% Choose default command line output for imageCropper
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

%
%
%
% Declare global variables
global guiObject guiHandles imageList currentImage nImage W

% HARD CODED PARAMETERS
W = 50;

% Decode varargin
if(nargin < 5)
    fprintf('ERROR: imageCropper requires at least 2 inputs');
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
displayImageAndWindow();


% --- Outputs from this function are returned to the command line.
function varargout = imageCropper_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in pushbuttonSave.
function pushbuttonSave_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Global Variables
global guiObject guiHandles imageList currentImage nImage W

% Remove the current image from imageList
imageList(currentImage).saved = 1;

% Change to the next image
pushbuttonNext_Callback();


% --- Executes on button press in pushbuttonDiscard.
function pushbuttonDiscard_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonDiscard (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Global Variables
global guiObject guiHandles imageList currentImage nImage W

% Remove the current image from imageList
imageList(currentImage).valid = 0;

% Change to the next image
pushbuttonNext_Callback();


% --- Executes on button press in pushbuttonNext.
function pushbuttonNext_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonNext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Global Variables
global guiObject guiHandles imageList currentImage nImage W

% Find the next valid image in imageList
if(currentImage == nImage)
    nextImage = 1;
else
    nextImage = currentImage + 1; 
end
while(~(imageList(nextImage).valid))
    if(nextImage == nImage) nextImage = 1;
    else nextImage = nextImage + 1; end
end

% If the next image is not saved yet, set its window position to the same
% as the previous image
if(~(imageList(nextImage).saved))
    imageList(nextImage).x = imageList(currentImage).x;
    imageList(nextImage).y = imageList(currentImage).y;
end

% Update the GUI
currentImage = nextImage;
displayImageAndWindow();


% --- Executes on button press in pushbuttonPrev.
function pushbuttonPrev_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonPrev (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Global Variables
global guiObject guiHandles imageList currentImage nImage W

% Find the previous valid image in imageList
if(currentImage == 1)
    nextImage = nImage;
else
    nextImage = currentImage - 1;
end
while(~(imageList(nextImage).valid))
    if(nextImage == 1) nextImage = nImage;
    else nextImage = nextImage - 1; end
end

% If the previous image is not saved yet, set its window position to the
% same as the next image
if(~(imageList(nextImage).saved))
    imageList(nextImage).x = imageList(currentImage).x;
    imageList(nextImage).y = imageList(currentImage).y;
end

% Update the GUI
currentImage = nextImage;
displayImageAndWindow();

% --- Executes on button press in pushbuttonFinish.
function pushbuttonFinish_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonFinish (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Global Variables
global guiObject guiHandles imageList currentImage nImage W

% Check if all images have been saved and decide if the program should
% really close
finishProgram = 0;
unsavedImages = verifySavedImages();
if(unsavedImages > 0)
    message = sprintf('There are %d unsaved images. Do you really want to finish the program?', unsavedImages);
    choice = questdlg(message, 'Warning: unsaved images found', 'Yes','No','No');
    if(strcmp(choice, 'Yes'))
        finishProgram = 1;
    end
else
    finishProgram = 1;
end

% Save the cropped images and close the GUI
if(finishProgram)
    for iImage = 1:nImage
        if(imageList(iImage).valid && imageList(iImage).saved)
            cx = imageList(iImage).x;
            cy = imageList(iImage).y;
            imwrite(imageList(iImage).I(cy-W:cy+W,cx-W:cx+W), imageList(iImage).name);
        end
    end
    delete(guiObject);
end

function ImageClickCallback ( objectHandle , eventData )

% Global Variables
global guiObject guiHandles imageList currentImage nImage W

axesHandle  = get(objectHandle,'Parent');
coordinates = get(axesHandle,'CurrentPoint');
coordinates = coordinates(1,1:2);
xLimits = xlim(axesHandle);
yLimits = ylim(axesHandle);

if(coordinates(1) <= W)
    imageList(currentImage).x = W+1;    
elseif(coordinates(1) >  floor(xLimits(2))-W)
    imageList(currentImage).x = floor(xLimits(2))-W;    
else
    imageList(currentImage).x = coordinates(1);
end

if(coordinates(2) <= W)
    imageList(currentImage).y = W+1;    
elseif(coordinates(2) >  floor(yLimits(2))-W)
    imageList(currentImage).y = floor(yLimits(2))-W;    
else
    imageList(currentImage).y = coordinates(2);
end

displayImageAndWindow();
   

function initImageList(sourceDirectory, targetDirectory)

% Global Variables
global guiObject guiHandles imageList currentImage nImage W

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
imageList = repmat(struct('I', zeros(600,800), 'name', '00-00-00 000.jpg', 'x', 300, 'y', 300, 'saved', 0, 'valid', 1), nImage, 1);
for iImage = 1:nImage
%     imageList(iImage).I = iread(completeImageFileName{iImage}, 'grey', 'double');
    image = imread(completeImageFileName{iImage});
    if(size(image,3) > 1)
        imageList(iImage).I = im2double(rgb2gray(image));
    else
        imageList(iImage).I = im2double(image);        
    end
    imageList(iImage).name = sprintf('%s/CROP_%s', targetDirectory, imageFileName{iImage});
end

function displayImageAndWindow()

% Global Variables
global guiObject guiHandles imageList currentImage nImage W

% Display the image in the imageAxes
axes(guiHandles.imageAxes);
hold off;
imageHandle = imshow(imageList(currentImage).I);
set(imageHandle,'ButtonDownFcn',@ImageClickCallback);

% Plot the red square over the image
hold on;
cx = imageList(currentImage).x;
cy = imageList(currentImage).y;
if(imageList(currentImage).saved)
    rectangle('Position', [cx-W, cy-W, 2*W+1, 2*W+1], 'EdgeColor', 'g');
else
    rectangle('Position', [cx-W, cy-W, 2*W+1, 2*W+1], 'EdgeColor', 'r');
end

% Display the selected window in the windowAxes
axes(guiHandles.windowAxes);
imshow(imageList(currentImage).I(cy-W:cy+W,cx-W:cx+W));

function unsavedImages = verifySavedImages()

% Global Variables
global guiObject guiHandles imageList currentImage nImage W

unsavedImages = 0;
for iImage = 1:nImage
    if(imageList(iImage).saved == 0 && imageList(iImage).valid == 1)
        unsavedImages = unsavedImages + 1;
    end
end
