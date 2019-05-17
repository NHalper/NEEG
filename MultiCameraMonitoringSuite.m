function varargout = MultiCameraMonitoringSuite(varargin)
% MULTICAMERAMONITORINGSUITE MATLAB code for MultiCameraMonitoringSuite.fig
%      MULTICAMERAMONITORINGSUITE, by itself, creates a new MULTICAMERAMONITORINGSUITE or raises the existing
%      singleton*.
%
%      H = MULTICAMERAMONITORINGSUITE returns the handle to a new MULTICAMERAMONITORINGSUITE or the handle to
%      the existing singleton*.
%
%      MULTICAMERAMONITORINGSUITE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MULTICAMERAMONITORINGSUITE.M with the given input arguments.
%
%      MULTICAMERAMONITORINGSUITE('Property','Value',...) creates a new MULTICAMERAMONITORINGSUITE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MultiCameraMonitoringSuite_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MultiCameraMonitoringSuite_OpeningFcn via varargin.
%F
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MultiCameraMonitoringSuite

% Last Modified by GUIDE v2.5 25-Jun-2015 14:32:13

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MultiCameraMonitoringSuite_OpeningFcn, ...
                   'gui_OutputFcn',  @MultiCameraMonitoringSuite_OutputFcn, ...
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


% --- Executes just before MultiCameraMonitoringSuite is made visible.
function MultiCameraMonitoringSuite_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MultiCameraMonitoringSuite (see VARARGIN)

global AppType
AppType = 'V2'; % Could be V1 or V2 (h.264 capable)

warning('off','MATLAB:timer:deleterunning')

% Choose default command line output for MultiCameraMonitoringSuite
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

%Define closing function in case big red x is pressed.
set(hObject, 'DeleteFcn', @HardClose)

%Define resize function to adjust tables
set(gcf,'ResizeFcn',@Resize);

%Center the GUI and define size
set(gcf, 'units','normalized','OuterPosition',[0.5 0.2 0.7 0.9]);
movegui(hObject,'center')
set(gcf,'units','pixels')
PositionArray = get(gcf,'Position');
FigureWidth = PositionArray(3)/2;


%Turn main panel (whole app) into tab set
handles.Parent = uiextras.TabPanel('Parent',handles.MainPanel,'Padding',25);

%These list the tabs created. This is using the GUILayout toolbox included
%as part of the installer. The organization is that tabs are listed, and
%they are filled with 'Boxes' which have contents within them. The
%flexibility of the layout view allows new components to be added easily
%and flexibly without the use of GUIDE. 
MenuTab = uiextras.VBoxFlex('Parent',handles.Parent,'Spacing',1,'BackgroundColor','black');
    Title = uiextras.HBox('Parent',MenuTab','Spacing',0,'Padding',15);
        uicontrol('Parent',Title,'Style','Text','String','Blackrock Multi-Camera EEG Monitoring Suite','FontSize',16);
    MenuTabColumns = uiextras.HBox('Parent',MenuTab,'Spacing',1,'BackgroundColor','black');
        Column1 = uiextras.VBoxFlex('Parent',MenuTabColumns,'Spacing',1,'BackgroundColor','black');
            TopBox = uiextras.HBox('Parent',Column1,'Spacing',5);
                FileLoadMenu = uiextras.HBox('Parent',TopBox,'Spacing',10,'Padding',10);
                    uicontrol('Parent',FileLoadMenu,'Style','pushbutton','String','Browse','Callback',@Browse);
                    handles.FileField = uicontrol('Parent',FileLoadMenu,'Style','Text','String','Filename','FontSize',10,'HorizontalAlignment','left','BackgroundColor','white');


                ConnectionMenu = uiextras.HBox('Parent',TopBox,'Spacing',5,'Padding',10);
                    %handles.ConnectCentralButton = uicontrol('Parent',ConnectionMenu,'Style','pushbutton','String','Connect to Central','Callback',@Connect);
                    %handles.DisconnectCentralButton = uicontrol('Parent',ConnectionMenu,'Style','pushbutton','String','Disconnect from Central','Callback',@Disconnect);
                    handles.FindCamerasButton = uicontrol('Parent',ConnectionMenu,'Style','pushbutton','String','Connect to Devices','Callback',@FindCameras);
            SetupArea = uiextras.HBox('Parent',Column1,'Padding',10);
                LowerMainPanel = uiextras.HBoxFlex('Parent',SetupArea,'Spacing',2,'Padding',5);
                    CameraListingMenu = uiextras.VBox('Parent',LowerMainPanel,'Spacing',12,'Padding',5);
                        uicontrol('Parent',CameraListingMenu,'Style','Text','String','Camera/Animal Pairing Table','FontSize',10);
                        handles.CameraListingTable = uitable('Parent',CameraListingMenu,...
                            'ColumnName',{'Active','CameraID','Device Name','Animal','Channels'},...
                            'ColumnFormat',{'logical' 'char' 'char' {'Green' 'Blue' 'Red' 'Black' 'Cyan' 'Magenta'} 'numeric'},...
                            'ColumnEditable',[true false false true true ],...
                            'ColumnWidth',{(10/350)*FigureWidth,(10/350)*FigureWidth ,(10/350)*FigureWidth,(20/350)*FigureWidth,(20/350)*FigureWidth},...
                            'TooltipString','Pair Cameras with Animals',...
                            'Enable','off');
%                                                     'Data',{'False' 'Detect Cameras' 'Detect Cameras' 'Detect Cameras' 'Detect Cameras' },...
                        TableDataMenu = uiextras.HBox('Parent',CameraListingMenu,'Spacing',10,'Padding',3);
                            handles.ExportButton = uicontrol('Parent',TableDataMenu,'Style','pushbutton','String','Export Animal/Channel Pairings','Callback',@ExportChannelPairings,'Enable','off');
                            handles.ImportButton = uicontrol('Parent',TableDataMenu,'Style','pushbutton','String','Import Animal/Channel Pairings','Callback',@ImportChannelPairings,'Enable','off');

                    %LogPanel = uiextras.VBox('Parent',LowerMainPanel,'Padding',5);
                        %uicontrol('Parent',LogPanel,'Style','Text','String','Log')
                        %handles.Log = uicontrol('Parent',LogPanel,'Style','Text','String',{' ',' '},'BackgroundColor','white');

                SchedulingPanel = uiextras.HBox('Parent',SetupArea,'Spacing',2,'Padding',5);
                    SchedulingMenu = uiextras.VBox('Parent',SchedulingPanel,'Spacing',12,'Padding',5);
                        uicontrol('Parent',SchedulingMenu,'Style','Text','String','Scheduling Table','FontSize',10);
                        handles.SchedulingTable = uitable('Parent',SchedulingMenu,...
                            'ColumnName',{'Active','Start Time','Stop Time','Number of Segments' 'Days'},...
                            'ColumnFormat',{'logical' 'char' 'char' 'numeric' 'numeric'},...
                            'Data',{true '00:00' '01:00' 1 1},...
                            'ColumnEditable',[true true true true true],...
                            'ColumnWidth',{(10/100)*FigureWidth (10/100)*FigureWidth (10/100)*FigureWidth (20/100)*FigureWidth (20/100)*FigureWidth},...
                            'TooltipString','Schedule recording starts and stops in 24 hour windows.',...
                            'CellEditCallback',@PairAnimalChannel,...
                            'Enable','on');
                        SchedulingDataMenu = uiextras.HBox('Parent',SchedulingMenu,'Spacing',10,'Padding',3);
                            handles.ExportScheduleButton = uicontrol('Parent',SchedulingDataMenu,'Style','pushbutton','String','Export Schedule','Callback',@ExportSchedule,'Enable','off');
                            handles.ImportScheduleButton = uicontrol('Parent',SchedulingDataMenu,'Style','pushbutton','String','Import Schedule','Callback',@ImportSchedule,'Enable','off');



            CollectionPanel = uiextras.HBox('Parent',Column1,'Spacing',10,'Padding',20);
                handles.RecordButton = uicontrol('Parent',CollectionPanel,'Style','pushbutton','String','Begin Recording','Callback',@PreRecordCheck);
                handles.StopRecordButton = uicontrol('Parent',CollectionPanel,'Style','pushbutton','String','Stop Recording','Callback',@StopRecording);
                
    handles.LogLine = uicontrol('Parent',MenuTab,'Style','Text','String',{' ',' '},'HorizontalAlignment','left');
                
        %Column2 = uiextras.HBoxFlex('Parent',MenuTabColumns);
LogTab = uiextras.VBox('Parent',handles.Parent,'Padding',5);
    uicontrol('Parent',LogTab,'Style','Text','String','Log')
    handles.Log = uicontrol('Parent',LogTab,'Style','Text','String',{' ',' '},'BackgroundColor','white');
            
    
    
CameraTab = uiextras.VBox('Parent',handles.Parent,'Spacing',5);
    handles.SelectCamera = uicontrol('Parent',CameraTab,'Style','popupmenu','BackgroundColor','white','String',{'No Camera Connected'},'Callback',@SelectCamera);
    handles.CameraAxes = axes('Parent',CameraTab);
    set(handles.CameraAxes,'YTick',[])
    set(handles.CameraAxes,'XTick',[])

    
ReviewTab = uiextras.VBoxFlex('Parent',handles.Parent,'Spacing',1,'BackgroundColor','black');
    FileReviewMenu = uiextras.HBox('Parent',ReviewTab,'Spacing',5,'Padding',5);
        uicontrol('Parent',FileReviewMenu,'Style','pushbutton','String','Browse','Callback',@ReviewBrowse);
        handles.ReviewFileField = uicontrol('Parent',FileReviewMenu,'Style','Text','String','Filename','BackgroundColor','white','FontSize',10,'HorizontalAlignment','left');
        
    CameraViewingArea = uiextras.HBox('Parent',ReviewTab,'Spacing',0,'Padding',1);
        handles.MovieAxes = axes('Parent',CameraViewingArea);
        VideoStatColumn = uiextras.VBox('Parent',CameraViewingArea,'Spacing',0,'Padding',0);
            uicontrol('Parent',VideoStatColumn,'Style','Text','String','');
            handles.FrameNumberField = uicontrol('Parent',VideoStatColumn,'Style','Text','String','Frame 0');
            handles.TimeField = uicontrol('Parent',VideoStatColumn,'Style','Text','String',datestr(clock));

    DataViewingArea = uiextras.VBox('Parent',ReviewTab,'Spacing',1,'Padding',1);
        handles.DataReviewAxes = axes('Parent',DataViewingArea);
        handles.ReviewSlider = uicontrol('Parent',DataViewingArea,'Style','Slider','Callback',@SliderJumpToTime);
        
    NavigationButtonsBox = uiextras.HButtonBox('Parent',ReviewTab,'Spacing',5,'Padding',5);
        handles.Nav1 = uicontrol('Parent',NavigationButtonsBox,'Style','pushbutton','String','|<','TooltipString','Skip to oldest data.','Callback',@Nav1);
        handles.Nav2 = uicontrol('Parent',NavigationButtonsBox,'Style','pushbutton','String','<<','TooltipString','Skip multiple windows.','Callback',@Nav2);
        handles.Nav3 = uicontrol('Parent',NavigationButtonsBox,'Style','pushbutton','String','<','TooltipString','Move a single window.','Callback',@Nav3);
        handles.PlayButton = uicontrol('Parent',NavigationButtonsBox,'Style','pushbutton','String','Play','Callback',@Play);
        handles.Nav4 = uicontrol('Parent',NavigationButtonsBox,'Style','pushbutton','String','>','TooltipString','Move a single window.','Callback',@Nav4);
        handles.Nav5 = uicontrol('Parent',NavigationButtonsBox,'Style','pushbutton','String','>>','TooltipString','Skip multiple windows.','Callback',@Nav5);
        handles.Nav6 = uicontrol('Parent',NavigationButtonsBox,'Style','pushbutton','String','>|','TooltipString','Skip to newest data.','Callback',@Nav6);
        
    LowerVideoControlPanel = uiextras.VBox('Parent',ReviewTab,'Spacing',5,'Padding',5);
        JumpToTimeLine = uiextras.HBox('Parent',LowerVideoControlPanel,'Spacing',100,'Padding',5);
            uicontrol('Parent',JumpToTimeLine,'Style','Text','String','Jump to Time: ','FontSize',10,'HorizontalAlignment','right');
            handles.JumpTimeSelect = uicontrol('Parent',JumpToTimeLine,'Style','edit','BackgroundColor','white','String','00:00:00','Callback',@JumpToTime);
        VideoSettingsButtonsLine = uiextras.HBox('Parent',LowerVideoControlPanel,'Spacing',100,'Padding',5);
            uicontrol('Parent',VideoSettingsButtonsLine,'Style','Text','String','Playback Speed: ','FontSize',10,'HorizontalAlignment','right');
            handles.SelectSpeed = uicontrol('Parent',VideoSettingsButtonsLine,'Style','popupmenu','BackgroundColor','white','String',{'1x' '2x' '4x' '8x'},'Callback',@SelectSpeed);
        DataWindowLine = uiextras.HBox('Parent',LowerVideoControlPanel,'Spacing',100,'Padding',5);
            uicontrol('Parent',DataWindowLine,'Style','Text','String','Size of Data Window (s): ','FontSize',10,'HorizontalAlignment','right');
            handles.DataWindowControl = uicontrol('Parent',DataWindowLine,'Style','edit','BackgroundColor','white','String','1','Callback',@DataWindowSelect);
        

set(handles.Parent, 'TabNames', {'Connect','Log','Camera', 'Review'},'SelectedChild',1);

% Set Box Sizes
set(MenuTab,'Sizes',[60 -10 15]);
set(MenuTabColumns,'Sizes',[-4]);
set(Column1,'Sizes',[50 -5  90]);
%set(LowerMainPanel,'Sizes',[-2]);
set(SchedulingMenu,'Sizes',[18 -8 35]);
set(CameraListingMenu,'Sizes',[18 -8 35]);
set(JumpToTimeLine,'Sizes',[-5 -2])
set(VideoSettingsButtonsLine,'Sizes',[-5 -2])
set(DataWindowLine,'Sizes',[-5 -2])

%set(TableDataMenu,'Sizes',[50 50]);
set(FileLoadMenu,'Sizes',[-2 -7]);
set(TopBox,'Sizes',[-5 -5]);
set(FileReviewMenu,'Sizes',[-1 -7]);
set(ConnectionMenu,'Sizes',[-4]);
set(LogTab,'Sizes',[18 -1]);
set(CameraTab,'Sizes',[-1 -9]);
set(CameraViewingArea,'Sizes',[-19 -2]);
set(DataViewingArea,'Sizes',[-19 -2]);
set(ReviewTab,'Sizes',[30 -5 -3  30 90]);
%set(DataTab,'Sizes',[-1 -9]);
%set(DataAxesBox,'Sizes',[-1 -14 -1 -1]);

handles.NumberOfCameras = 0;
handles.CentralConnect = 0;

handles.FullFile = 'Filename';

handles.MainObject = hObject;

handles.DataWindowSize = 2000;

set(handles.MovieAxes,'XTick',[],'YTick',[],'XTickLabel',[],'YTickLabel',[],'Visible','off')
set(handles.CameraAxes,'XTick',[],'YTick',[],'XTickLabel',[],'YTickLabel',[],'Visible','off')
set(handles.DataReviewAxes,'XTick',[],'YTick',[],'XTickLabel',[],'YTickLabel',[],'Visible','off')

%Prepopulate scheduling table
    for idx = 1:24
        EnableStatus{idx} = false;
        StartTimes{idx} = '14:00';
        StopTimes{idx} = '16:00';
        SegmentNumbers{idx} = 2;
        RepeatDays{idx} = 0;
    end

    %set(handles.CameraListingTable,'ColumnFormat',{AvailableCameras AvailableCameraNames AvailableAnimals});

    for n = 1:24
        ScheduleTableData(n,1) = {EnableStatus{n}};
        ScheduleTableData(n,2) = {StartTimes{n}};
        ScheduleTableData(n,3) = {StopTimes{n}};
        ScheduleTableData(n,4) = {SegmentNumbers{n}};
        ScheduleTableData(n,5) = {RepeatDays{idx}};
    end

set(handles.SchedulingTable,'Data',ScheduleTableData)

global Recording
Recording = 0;

global Stopping
Stopping = 0;

global FileIncrement
FileIncrement = 0;

set(handles.RecordButton,'Enable','off')
set(handles.StopRecordButton,'Enable','off')
set(handles.SchedulingTable,'Enable','off')

guidata(hObject, handles);

% UIWAIT makes MultiCameraMonitoringSuite wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = MultiCameraMonitoringSuite_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

%This has a different function structure and handles call
function PreRecordCheck(hObject,~,handles)
handles = guidata(hObject);
global Recording

if Recording == 0
    if handles.NumberOfCameras < 1
        uiwait(msgbox('Please use the find cameras button to search for cameras','No Cameras Available','modal'));

    else
        if handles.CentralConnect == 0
            uiwait(msgbox('Please use the Connect to Central button to initiate a connection','No Connection to Central','modal'));
        else
            
            TableData = get(handles.CameraListingTable,'Data');
            handles.ActiveCameras = [];
            for i = 1:handles.NumberOfCameras
                if TableData{i,1} == 1 
                    handles.ActiveCameras = [handles.ActiveCameras i];
                end
            end

            global FileIncrement
            FileIncrement = 0;
            Recording = 0;

            CurrentTime = clock;
            SchedulingData = get(handles.SchedulingTable,'Data');
            Scheduling = false;
            for Day = 0:SchedulingData{1,5}
            for ScheduleItem = 1:size(SchedulingData,1)
               
                    if(SchedulingData{ScheduleItem,1} == 1)
                        Scheduling = true;
                        
                        StartTime = CurrentTime;
                        SplitStartTime = strsplit(SchedulingData{ScheduleItem,2},':');
                        StartTime(3) = StartTime(3) + Day;
                        StartTime(4) = str2num(SplitStartTime{1});
                        StartTime(5) = str2num(SplitStartTime{2});

                        if(etime(CurrentTime,StartTime)<0)
                            
                            StopTime = CurrentTime;
                            SplitStopTime = strsplit(SchedulingData{ScheduleItem,3},':');
                            StopTime(3) = StopTime(3) + Day;
                            StopTime(4) = str2num(SplitStopTime{1});
                            StopTime(5) = str2num(SplitStopTime{2});



                            TimeDifference = round((etime(StopTime,StartTime))/SchedulingData{ScheduleItem,4});


                            %StartTime = SchedulingData{ScheduleItem,2};
                            %StopTime = SchedulingData{ScheduleItem,3};



                            handles.SchedulingTimer(ScheduleItem) = timer('TimerFcn',{@ScheduledSplit,handles},'Tag','Scheduling','Name',datestr(StartTime),'ExecutionMode','fixedRate','TasksToExecute',SchedulingData{ScheduleItem,4}+1,'Period',TimeDifference);
                            %startat(handles.SchedulingTimer,CurrentTime(1),CurrentTime(2),CurrentTime(3)+Day,CurrentTime(4),CurrentTime(5),CurrentTime(6))
                            startat(handles.SchedulingTimer(ScheduleItem),StartTime)
                            LogAdd(hObject,handles,strcat('A recording will start at ',datestr(StartTime)));
                        end
                    end
            end
            end

            if Scheduling == false
                FileIncrement = 1;
                Record(1,1,handles)
            end

        end
    end
else
end



function Record(hObject,eventdata,handles)
global AppType

global Stopping
while Stopping == 1
   pause(2)
   disp('Waiting for Stop Record to Execute');
end

   LogAdd(hObject,handles,'Start Recording Function Initiated!');
    LogAdd(hObject,handles,strcat('Time: ',datestr(clock)));

if hObject == 1
    disp('hObject was 1')
    handles = guidata(handles.RecordButton);
else
    handles = guidata(hObject);
end
global Recording
Recording = 1;
set(handles.RecordButton,'Enable','off')
set(handles.StopRecordButton,'Enable','on')
if get(handles.Parent,'SelectedChild')==4
    LogAdd(hObject,handles,'Reviewing during recording may cause disk write speed issues.');
    set(handles.Parent,'SelectedChild',1)
end

global FileIncrement

TableData = get(handles.CameraListingTable,'Data');
[Path,Name,ext] = fileparts(handles.FullFile);
save(strcat(Path,'/',Name,'-','Segment',num2str(FileIncrement),'.mcm'),'TableData');
%save(handles.FullFile,'TableData');
FileComment = ['MultiCameraSuite:'];

handles.ActiveCameras = [];
for i = 1:handles.NumberOfCameras
    if TableData{i,1} == 1 
        handles.ActiveCameras = [handles.ActiveCameras i];
    end
end

pause(2)

if FileIncrement == 1
    delete(handles.v);
end
VidStruct = imaqhwinfo('winvideo');
ValidDeviceIDs = [];

% Checking App Type Allows one to Easily Compile for One Version or the
% Other
if AppType == 'V1'
    % for i = 2:3:length(VidStruct.DeviceIDs)
    for i = 1:length(VidStruct.DeviceIDs)
        if(not(isempty(VidStruct.DeviceInfo(i).DeviceName(1:7))))
           ValidDeviceIDs = [ValidDeviceIDs VidStruct.DeviceInfo(i).DeviceID];
           %disp(VidStruct.DeviceInfo(i).DefaultFormat)
        else
            LogAdd(hObject,handles,['Device ID ' i ' not valid']);
        end
    end
elseif AppType == 'V2'
    for i = 2:3:length(VidStruct.DeviceIDs)
%     for i = 1:length(VidStruct.DeviceIDs)
        if(not(isempty(VidStruct.DeviceInfo(i).DeviceName(1:7))))
           ValidDeviceIDs = [ValidDeviceIDs VidStruct.DeviceInfo(i).DeviceID];
           %disp(VidStruct.DeviceInfo(i).DefaultFormat)
        else
            LogAdd(hObject,handles,['Device ID ' i ' not valid']);
        end
    end 
end


for i = 1:length(ValidDeviceIDs)
    try
        handles.v(i) = videoinput('winvideo',ValidDeviceIDs(i),VidStruct.DeviceInfo(find(cell2mat(VidStruct.DeviceIDs)==ValidDeviceIDs(i))).SupportedFormats{21});
     catch
         handles.v(i) = videoinput('winvideo',ValidDeviceIDs(i),VidStruct.DeviceInfo(find(cell2mat(VidStruct.DeviceIDs)==ValidDeviceIDs(i))).SupportedFormats{1});
         LogAdd(hObject,handles,'Unrecognized camera type; camera still added.');
    end
    handles.framerate(i) = 10;
    set(handles.v(i),'LoggingMode','disk');
end



% disp('Stopping Cameras')
% stop(handles.v(handles.ActiveCameras)) 
%fclose all

%End Test Code 11/7/16

for i = handles.ActiveCameras
    %TableData = get(handles.CameraListingTable,'Data');
     %handles.Writer{i} = VideoWriter(strcat(handles.FullFile,'-',TableData{i,2},'-',TableData{i,4},'-','Segment',num2str(FileIncrement)),'MPEG-4');
    handles.Writer{i} = VideoWriter(strcat(handles.FullFile,'-',TableData{i,2},'-',TableData{i,4},'-','Segment',num2str(FileIncrement)));    
    set(handles.Writer{i},'FrameRate',handles.framerate(i));
    
%     disp(datestr(now))
%     disp(handles.Writer{i}.ColorChannels)
%     disp(handles.Writer{i}.VideoCompressionMethod)
    

    set(handles.v(i),'DiskLogger',handles.Writer{i});
    FileComment = [FileComment TableData{i,2} TableData{i,5}];
    pause(0.2)
end

for i = handles.ActiveCameras
    set(handles.v(i),'FramesPerTrigger',Inf);
    pause(0.1)
end
triggerconfig(handles.v(:),'manual');

for i = handles.ActiveCameras
    TempLogger = get(handles.v(i),'DiskLogger');
    while ~strcmpi([TempLogger.Path '\' TempLogger.Filename],strcat(handles.FullFile,'-',TableData{i,2},'-',TableData{i,4},'-','Segment',num2str(FileIncrement),'.avi'))
       pause(0.2);
       disp('Waiting for VideoWriter to Initialize');
    end
end

for i = handles.ActiveCameras
    TempLogger = get(handles.v(i),'DiskLogger');
    if(exist([TempLogger.Path '\' TempLogger.Filename]))
        delete([TempLogger.Path '\' TempLogger.Filename]);
        disp('File already exists, deleting!');
    end
end



start(handles.v(handles.ActiveCameras))
pause(1);
AllRunning = 0;
while AllRunning == 0
    AllRunning = 1;
    for i = handles.ActiveCameras
       Status = get(handles.v(i),'Running');
       if strcmpi(Status,'Off')
            AllRunning = 0;
       end
    end
    if AllRunning == 0
       disp('Some Cameras Failed to Start. Starting Again');
       stop(handles.v(handles.ActiveCameras)) ;
       pause(1)
       start(handles.v(handles.ActiveCameras));
       pause(2);
    end
end


cbmex('fileconfig',strcat(handles.FullFile,'-','Segment',num2str(FileIncrement)),'Video Recording Suite',0);
pause(3)
cbmex('fileconfig',strcat(handles.FullFile,'-','Segment',num2str(FileIncrement)),'Video Recording Suite',1);

% for i = handles.ActiveCameras
% TotalFramesAcquired{i} = handles.v(handles.ActiveCameras(i)).FramesAcquired;
% end
% disp('Total Frames Acquired')
% disp(TotalFramesAcquired)
% pause(1)

%Start files actually collecting frames
trigger(handles.v(handles.ActiveCameras))



handles.MainTimer = timer('TimerFcn',{@CommentFile,handles},'Tag','Main','Name','Comment Timer','ExecutionMode','FixedDelay');

start(handles.MainTimer);

% for i = handles.ActiveCameras
% TotalFramesAcquired{i} = handles.v(handles.ActiveCameras(i)).FramesAcquired;
% end
% disp('Total Frames Acquired Post Trigger')
% disp(TotalFramesAcquired)

LogAdd(hObject,handles,'Recording started!');
LogAdd(hObject,handles,strcat('Time: ',datestr(clock)));


guidata(handles.RecordButton, handles);

disp('Finished the Recording Start Function');
   LogAdd(hObject,handles,'Start Recording Function Completed!');
    LogAdd(hObject,handles,strcat('Time: ',datestr(clock)));

function StopRecording(hObject,eventdata,handles)
    
global Stopping
Stopping = 1;   
    
if hObject == 1
    disp('hObject was 1')
    handles = guidata(handles.RecordButton);
else
    handles = guidata(hObject);
    if exist('handles.SchedulingTimer')
        for i = size(handles.SchedulingTimer,1) 
            try
            delete(handles.SchedulingTimer(i))
            catch
               LogAdd(hObject,handles,'Timer Deleted'); 
            end
        end
    end
end

LogAdd(hObject,handles,'Stop Recording Function Initiated!');
LogAdd(hObject,handles,strcat('Time: ',datestr(clock)));

global Recording
Recording = 0;
set(handles.RecordButton,'Enable','on')
set(handles.StopRecordButton,'Enable','off')

delete(timerfind('Tag','Main'))

%Check memory
    %disp('Checking Memory Pre-Flush')
    %disp(datestr(now))
    %memory
    %imaqmem

 try

    elogarray = handles.v(handles.ActiveCameras).EventLog;
    pause(1)
    for i = 1:length(handles.ActiveCameras)
        if length(elogarray{i}) > 2
            disp('Errors in video file');
            %x = input('Elog Fail');
        end
    end
    
    FAq = handles.v(handles.ActiveCameras).FramesAcquired
    Dlog = handles.v(handles.ActiveCameras).DiskLoggerFrameCount
    disp('Stopping Cameras')
    stop(handles.v(handles.ActiveCameras))

    
    
    pause(1)
    disp('Pause 1 Sec')
%    FAq = handles.v(handles.ActiveCameras).FramesAcquired
%    Dlog = handles.v(handles.ActiveCameras).DiskLoggerFrameCount
    
    %Ensure all objects are stopped.
    Running = true;
    while Running == true
        Objects = imaqfind;
        RunningCount = 0;
        for i = 1:size(Objects,2)
            if isrunning(Objects(i))
                RunningCount = RunningCount + 1;
                stop(Objects(i))
            end
        end
        if RunningCount > 0
            Running = true;
        else
            Running = false;
        end
    end
    
    disp('Flushing Cache')
    flushdata(handles.v(handles.ActiveCameras))
    delete(handles.v(handles.ActiveCameras))
    
    pause(1)
    
    LogAdd(hObject,handles,'Clearing Video Objects!');
    LogAdd(hObject,handles,strcat('Time: ',datestr(clock)));
    whos

    disp('Truly clearing vid objects');
    a=whos;
    VideoObjectsToClear = [];
    for ix = 1:length({a(:).class})
        if(strcmpi(a(ix).class,'videoinput'))
            VideoObjectsToClear = [VideoObjectsToClear ix];
            VideoObjectNamesToClear{ix} = a(ix).name;
        end
    end
    for iy = VideoObjectsToClear
        disp('Clearing: ');
        disp(VideoObjectNamesToClear{iy});
        clear(VideoObjectNamesToClear{iy});
    end

    whos
    LogAdd(hObject,handles,'Finished Clearing Video Objects!');
    LogAdd(hObject,handles,strcat('Time: ',datestr(clock)));

    %ENSURE that data is written to disc before moving on.
%     for i = handles.ActiveCameras
%         disp(['Ensuring video data is finished writing to disk.' 'Camera ' num2str(i)]);
%         disp(datestr(now))
%         TempCount = 0;
%         while islogging(handles.v(i)) ==  1 && TempCount < 10
%             pause(0.1)
%             TempCount = TempCount+1;
%         end
% %        if (not(handles.v(i).FramesAcquired == handles.v(i).DiskLoggerFrameCount))
% %             disp('Frames Acquired Not Equal to Frames Written...')
% %             handles.v(i).FramesAcquired
% %             handles.v(i).DiskLoggerFrameCount
% %             pause(0.5)
% %        end
%     end
%     
%    FAq = handles.v(handles.ActiveCameras).FramesAcquired
%    Dlog = handles.v(handles.ActiveCameras).DiskLoggerFrameCount
    
    %flushdata(handles.v(handles.ActiveCameras))
    
%     LogAdd(hObject,handles,'Beginning to close video files...');
%     for i = handles.ActiveCameras
%         disp(['Closing Camera' ' ' num2str(i)]);
%         close(handles.Writer{i})
%         pause(0.5)
%     end
%     LogAdd(hObject,handles,'Video Files Closed');

 catch ME
        LogAdd(hObject,handles,'Error in closing file writing.');
        LogAdd(hObject,handles,ME.identifier);
        LogAdd(hObject,handles,ME.message);
        LogAdd(hObject,handles,ME.stack);
        
 end
 
 pause(2)
 disp('Closing Central Recording Session');
 LogAdd(hObject,handles,'Closing Central Recording Session');
FileName = fullfile('C:\Users\Blackrock\Desktop\',get(handles.FileField,'string'));

cbmex('fileconfig',FileName,'Video Recording Suite',0);


cbmex('fileconfig',FileName,'Video Recording Suite',0,'option','close');

        
        

%clear(imaqfind)
%delete(imaqfind)


disp('Recording Stopped')
LogAdd(hObject,handles,'Recording stopped!');
LogAdd(hObject,handles,strcat('Time: ',datestr(clock)));

%Check memory
    %disp('Checking Memory Post Flush');
    disp(datestr(now));
    %memory;
    %imaqmem;
    global FileIncrement
    TableData = get(handles.CameraListingTable,'Data');
   %strcat(handles.FullFile,'-',TableData{i,2},'-',TableData{i,4},'-','Segment',num2str(FileIncrement))
   for i = handles.ActiveCameras
        fileattrib(strcat(handles.FullFile,'-',TableData{i,2},'-',TableData{i,4},'-','Segment',num2str(FileIncrement),'.avi'),'-w');
   end
   
   disp('Deleting video input objects');
   
   
%    for i = handles.ActiveCameras
%         clear(handles.v(i).DiskLogger)
%    end
   delete(handles.v);
   disp('Clearing video input objects');
   clear handles.v
   
   
   pause(2)
   
   Stopping = 0;
   disp('Finished the Stop Recording Function');
   LogAdd(hObject,handles,'Stop Recording Completed!');
    LogAdd(hObject,handles,strcat('Time: ',datestr(clock)));



    

%guidata(handles.StopRecordButton, handles);

%This has a different function structure and handles call
function CommentFile(hObject,~,handles)
%handles = guidata(hObject);

Frame = handles.v(handles.ActiveCameras(1)).FramesAcquired;
cbmex('comment', 16711935, 0,strcat('Frame:',num2str(Frame)));

%disp(handles.v(handles.ActiveCameras).FramesAcquired)


function SplitStatusChange(hObject,handles)
handles = guidata(hObject);

if(get(handles.SplitCheck,'Value') == 1)
    set(handles.SplitInterval,'Enable','on')
%    set(handles.SplitStart,'Enable','on')
elseif(get(handles.SplitCheck,'Value') == 0)
    set(handles.SplitInterval,'Enable','off')
 %   set(handles.SplitStart,'Enable','off')
end

guidata(hObject, handles);

%This has a different function structure and handles call
function ScheduledSplit(hObject,~,handles)
    
    
disp(hObject.TasksToExecute)
disp(hObject.TasksExecuted)
%handles = guidata(hObject);
disp('Scheduled Split')
global Recording
if Recording == 1
    %This handles structure is outdated, it is updated correctly when a
    %normal stop recording is called/performed.
    disp('Entering the Stop Recording Function')
    StopRecording(1,1,handles)
end

pause(300)

if hObject.TasksToExecute > hObject.TasksExecuted
    disp('Beginning Another Segment')
    global FileIncrement
    FileIncrement = FileIncrement + 1;
    Record(1,1,handles)
else
    disp('TagsToExecute Equal to TasksExecuted');
end

disp('Finished the Recording Split Function');
%out = timerfindall





%guidata(hObject, handles);

function HardClose(hObject,handles)
    handles = guidata(hObject);
    try
        stop(handles.MainTimer)

        for i = handles.ActiveCameras
            stop(handles.v(i))
        end


        for i = handles.ActiveCameras
            close(handles.Writer{i})
        end
        delete(timerfindall);
        cbmex('fileconfig','Filename','none',0);

        cbmex('close')
    catch
        disp('Hard closed Multi Camera Monitoring Suite.');
        delete(timerfindall);
        delete(imaqfind)
    end
    
    fclose all

guidata(hObject, handles);

function PairAnimalChannel(hObject,eventData)
% handles = guidata(hObject);
% %Data = eventData;
%  %   if Data.Indices(2) == 4
%   %
%    % end      %NewData = Data.NewData
%     %    NewData = [str2num(Data.NewData)];
%     %else
% guidata(hObject, handles);


 function Resize(hObject,eventData)
 handles = guidata(hObject);
 PositionArray = get(gcf,'Position');
FigureWidth = PositionArray(3)-60;
set(handles.CameraListingTable,'ColumnWidth',{(10/100)*FigureWidth ,(7/100)*FigureWidth,(8/100)*FigureWidth,(9/100)*FigureWidth});
set(handles.SchedulingTable,'ColumnWidth',{(5/100)*FigureWidth (6/100)*FigureWidth (6/100)*FigureWidth (10/100)*FigureWidth (10/100)*FigureWidth});

guidata(hObject, handles);

function ExportChannelPairings(hObject,eventData)
handles = guidata(hObject);

TableData = get(handles.CameraListingTable,'Data');
[Filename,Pathname,~] = uiputfile;
[Path,Name,ext] = fileparts(fullfile(Pathname,Filename));
if(Filename ~= 0)
    try
    save(strcat(Path,'/',Name,'.mcm'),'TableData');
    LogAdd(hObject,handles,'Channel pairings exported succesfully!');
    LogAdd(hObject,handles,strcat('Location',fullfile(Path,Name)));
    catch
        LogAdd(hObject,handles,'Error exporting channel pairings!');
    end
else
    LogAdd(hObject,handles,'No Filename selected. Channel pairings not exported!');
end



guidata(hObject, handles);

function ExportSchedule(hObject,eventData)
handles = guidata(hObject);

TableData = get(handles.SchedulingTable,'Data');
[Filename,Pathname,~] = uiputfile;
[Path,Name,ext] = fileparts(fullfile(Pathname,Filename));
if(Filename ~= 0)
    try
    save(strcat(Path,'/',Name,'.mcs'),'TableData');
    LogAdd(hObject,handles,'Schedule exported succesfully!');
    LogAdd(hObject,handles,strcat('Location',fullfile(Path,Name)));
    catch
        LogAdd(hObject,handles,'Error exporting channel pairings!');
    end
else
    LogAdd(hObject,handles,'No Filename selected. Schedule not exported!');
end



guidata(hObject, handles);

function ImportChannelPairings(hObject,eventData)
handles = guidata(hObject);

try
[Filename,Pathname,~] = uigetfile('.mcm');
ImportFile = load(fullfile(Pathname,Filename),'-mat');
ImportData = ImportFile.TableData;
TableData = get(handles.CameraListingTable,'Data');

for i = 1:size(TableData,1)
    for idx = 1:size(TableData,1)
        if (strcmpi(TableData{i,2},ImportData{idx,2}))
            disp('Found it!')
            TableData{i,1} = ImportData{i,1};
            TableData{i,4} = ImportData{i,4};
            TableData{i,5} = ImportData{i,5};
        end
    end
end

set(handles.CameraListingTable,'Data',TableData);   
LogAdd(hObject,handles,'Channel pairings imported succesfully!');
catch
    LogAdd(hObject,handles,'Error importing channel pairings!');
end

guidata(hObject, handles);


function ImportSchedule(hObject,eventData)
handles = guidata(hObject);

try
[Filename,Pathname,~] = uigetfile('.mcs');
ImportFile = load(fullfile(Pathname,Filename),'-mat');
ImportData = ImportFile.TableData;
TableData = get(handles.SchedulingTable,'Data');

% for i = 1:size(TableData,1)
%     if strcmpi(TableData{i,3},ImportData{i,3})
%         %disp('Found it!')
%         TableData{i,4} = ImportData{i,4};
%     end
% end
set(handles.SchedulingTable,'Data',ImportData);   
LogAdd(hObject,handles,'Scheduling imported succesfully!');
catch
    LogAdd(hObject,handles,'Error importing schedules!');
end

guidata(hObject, handles);

function Browse(hObject,handles)
handles = guidata(hObject);


if exist('C:\Blackrock Microsystems\MCM\PreviousFile.mcmdata','file')
    
    ImportFile = load('C:\Blackrock Microsystems\MCM\PreviousFile.mcmdata','-mat');
    StoredFilePath = ImportFile.PreviousFilePath;
    [Filename, Pathname] = uiputfile(strcat(StoredFilePath,'*.avi'));
else
    PreviousFilePath = 'C:\';
    try
        save('C:\Blackrock Microsystems\MCM\PreviousFile.mcmdata','PreviousFilePath');
    catch
        LogAdd(hObject,handles,'Error accessing file history. This is superficial and does not affect program performance.');
    end
    [Filename, Pathname] = uiputfile('C:\*.avi');

end
    
PreviousFilePath = Pathname;

try
    save('C:\Blackrock Microsystems\MCM\PreviousFile.mcmdata','PreviousFilePath');
catch
    LogAdd(hObject,handles,'Error accessing file history. This is superficial and does not affect program performance.');
end


    handles.FileIncrement = 1;

    handles.FullFile = fullfile(Pathname,Filename);
    [handles.PathName,handles.FileName,~] = fileparts(handles.FullFile);
    handles.FullFile = fullfile(handles.PathName,handles.FileName);

    set(handles.FileField,'String',handles.FileName);
    
    if(Filename ~= 0)
        LogAdd(hObject,handles,strcat('FullFile:',handles.FullFile));
    else
        LogAdd(hObject,handles,'No Filename selected!');
    end


guidata(hObject, handles);


function ReviewBrowse(hObject,handles)
handles = guidata(hObject);


if exist('C:\Blackrock Microsystems\MCM\PreviousFile.mcmdata','file')
    
    ImportFile = load('C:\Blackrock Microsystems\MCM\PreviousFile.mcmdata','-mat');
    StoredFilePath = ImportFile.PreviousFilePath;
    [Filename, Pathname,~] = uigetfile(strcat(StoredFilePath,'*.avi'));
else
    PreviousFilePath = 'C:\';
    try
        save('C:\Blackrock Microsystems\MCM\PreviousFile.mcmdata','PreviousFilePath');
    catch
        LogAdd(hObject,handles,'Error accessing file history. This is superficial and does not affect program performance.');
    end
    [Filename, Pathname] = uigetfile('C:\*.avi');

end
    
PreviousFilePath = Pathname;

try
    save('C:\Blackrock Microsystems\MCM\PreviousFile.mcmdata','PreviousFilePath');
catch
    LogAdd(hObject,handles,'Error accessing file history. This is superficial and does not affect program performance.');
end

%     %Experimental block from NPMK
%     settingFileFullPath = getSettingFileFullPath('getFile');
%     settingsFID = fopen(settingFileFullPath, 'w');
%     fprintf(settingsFID, '%s', PreviousFilePath);
%     fclose(settingsFID);

    %[Filename, Pathname, ~] = uigetfile('.avi');

    handles.ReviewFullFile = fullfile(Pathname,Filename);
    
    %CameraNumber = Filename(findstr(Filename,'-Camera-')+8);
    AnimalNumber = Filename(findstr(Filename,'-Animal-')+8);
    AnimalNumberFormatted = strcat('Animal-',num2str(AnimalNumber));

    set(handles.ReviewFileField,'String',handles.ReviewFullFile);
    
    
%     %Make openNSx open from video location
%     settingFileFullPath = getSettingFileFullPath('getFile');
%     if ischar(Pathname)
%         settingsFID = fopen(settingFileFullPath, 'w');
%         fprintf(settingsFID, '%s', Pathname);
%         fclose(settingsFID);
%     end
    
    %Open data file
    try
    NSx = openNSx();
    catch ME
        LogAdd(hObject,handles,'Error in opening data file.');
        disp(ME.identifier)
        disp('Error in opening data file.')
        LogAdd(hObject,handles,ME.identifier);
        LogAdd(hObject,handles,ME.message);
    end
        
    %strcat(NSx.MetaTags.FilePath,'\',NSx.MetaTags.Filename,'.mcm')
    try
        load(strcat(NSx.MetaTags.FilePath,'\',NSx.MetaTags.Filename(1:end-3),'.mcm'),'-mat');
    catch
        LogAdd(hObject,handles','Error in loading MCM file');
    end
    
    ImportData = TableData;
    for TableEntry = 1:size(ImportData,1)
        if size(ImportData,2) == 5
            if strcmpi(ImportData{TableEntry,4},AnimalNumberFormatted)
                %disp('Animal Channels Found')
                Channels = str2num(ImportData{TableEntry,5});
                break
            end
        elseif size(ImportData,2) == 4
            if strcmpi(ImportData{TableEntry,3},AnimalNumberFormatted)
                %disp('Animal Channels Found')
                Channels = str2num(ImportData{TableEntry,4});
                break
            end
        end
    end
    if iscell(NSx.Data)
       
        BeginningTimestamps = NSx.MetaTags.Timestamp;
        ValidSegments = [];
        for segment = length(NSx.Data.Timestamp):2
            if BeginningTimestamps(segment-1)<BeginningTimestamps(segment)
                ValidSegments = [segment ValidSegments];
            else
                LogAdd(hObject,handles,'Synchronized NSP Recordings Not Currently Supported. Please contact support@blackrockmicro.com to learn more.');
            end
        end
        
        handles.Data = [];
        
        for segment = ValidSegments
            if isempty(handles.Data)
                handles.Data = [repmat(0,size(NSx.Data{segment},1),round(BeginningTimestamps(segment)/(30000/NSx.MetaTags.SamplingFreq))) NSx.Data{segment}];
            else
                MissingTimestamps = BeginningTimestamps(segment) - size(handles.Data,2);
                handles.Data = [handles.Data repmat(0,size(NSx.Data{segment},1),round(MissingTimestamps/(30000/NSx.MetaTags.SamplingFreq))) NSx.Data{segment}];
            end
        end
        
        handles.ChannelIndexes = [];
        for Electrode = 1:length(Channels)
            handles.ChannelIndexes = [handles.ChannelIndexes find([NSx.ElectrodesInfo(:).ElectrodeID]==Channels(Electrode))];
        end
        
        handles.Data = double(handles.Data(handles.ChannelIndexes,:));
            
                
        %%Before corrections    
        %PreData = NSx.Data{1};
        %handles.ChannelIndexes = [];
        %for Electrode = 1:length(Channels)
        %    handles.ChannelIndexes = [handles.ChannelIndexes find([NSx.ElectrodesInfo(:).ElectrodeID]==Channels(Electrode))];
        %end
        %handles.Data = double(PreData(handles.ChannelIndexes,:));
    else
        handles.ChannelIndexes = [];
        for Electrode = 1:length(Channels)
            handles.ChannelIndexes = [handles.ChannelIndexes find([NSx.ElectrodesInfo(:).ElectrodeID]==Channels(Electrode))];
        end
        handles.Data = double(NSx.Data(handles.ChannelIndexes,:));
    end
    
    if length(handles.ChannelIndexes)==0
        disp('Please choose a datafile with the proper channels.')
        return
    end
    
    YMax = double(max(max(handles.Data)));
    ScalingArray = [];
    for index = 1:length(handles.ChannelIndexes)
        ScalingArray(index) = (-2*YMax+2*YMax*(index));
    end
    
    ScalingArray = (flipud(transpose(ScalingArray)));
    
    ScalingArray = repmat(ScalingArray,1,length(handles.Data));
    
    handles.Data = handles.Data + ScalingArray;
    
    NEV = openNEV(strcat(NSx.MetaTags.FilePath,'\',NSx.MetaTags.Filename,'.nev'),'nosave','noread');
    
    handles.RecordingStartTime = NEV.MetaTags.DateTime;
    handles.SamplingFrequency = NSx.MetaTags.SamplingFreq;
    
    handles.DataReviewAxes
    %ylim([min(min(handles.Data,[],2)) max(max(handles.Data,[],2))*length(handles.ChannelIndexes)*2]);
    if min(min(handles.Data,[],2)) == 0 &&  max(max(handles.Data,[],2))*length(handles.ChannelIndexes) == 0
            ylim([-1 1]);
    else
        ylim([min(min(handles.Data,[],2)) max(max(handles.Data,[],2))*length(handles.ChannelIndexes)]);
    end
    set(handles.DataReviewAxes, 'LooseInset', [0,0,0,0]);

    handles.ReviewVideoReader = VideoReader(handles.ReviewFullFile);
    read(handles.ReviewVideoReader,Inf);
    FinalFrameCount = handles.ReviewVideoReader.NumberOfFrames;

    %%Experimental Section - Begin
    FrameCommentIndices = find(NEV.Data.Comments.Color == 16711935);
    
    %%Experimental Section - End
    
    %Added frame comment indices
    [~, NumberOfFrameComments] = size(NEV.Data.Comments.Text(FrameCommentIndices));
    FrameNumbers = [0];
    FailedFramesIndices = [];
    
    %Added Frame Comment Indices
    for FrameComment = 1:NumberOfFrameComments
        if isempty(str2num(NEV.Data.Comments.Text(FrameCommentIndices(FrameComment),7:end)))
            FailedFramesIndices = [FailedFramesIndices FrameComment];
        end
        FrameNumbers = [FrameNumbers str2num(NEV.Data.Comments.Text(FrameCommentIndices(FrameComment),7:end))];
    end
    FrameCommentIndices(FailedFramesIndices) = [];
    FrameNumbers = [FrameNumbers FinalFrameCount];
    
    %Experimental insert for max commented alignment
    %FrameNumbers = FrameNumbers(1:find(FrameNumbers>FinalFrameCount,1));
    
    %Added Frame Comment Indices
    FrameTimestamps = [0 NEV.Data.Comments.TimeStamp(FrameCommentIndices) length(handles.Data)*(NSx.MetaTags.TimeRes/NSx.MetaTags.SamplingFreq)];

    InterpolatedFrameTimestamps = [FrameTimestamps(1)];

    for n = 1:(length(FrameTimestamps)-1)
        MissingFrames = FrameNumbers(n+1)-FrameNumbers(n)-1;
        TimestampInterval = (FrameTimestamps(n+1) - FrameTimestamps(n))/MissingFrames;
        NewPiece = [FrameTimestamps(n)];
        for i = 1:MissingFrames
            NewPiece = [NewPiece NewPiece(i)+TimestampInterval];
        end
        NewPiece = [NewPiece(2:end) FrameTimestamps(n+1)];
        InterpolatedFrameTimestamps = [InterpolatedFrameTimestamps NewPiece];
    end

    handles.InterpolatedFrameTimestamps = InterpolatedFrameTimestamps*(NSx.MetaTags.SamplingFreq/NSx.MetaTags.TimeRes);
    handles.InterpolatedFrameNumbers = [1:FrameNumbers(end)];

    Max = max(diff(InterpolatedFrameTimestamps));
    Min = min(diff(InterpolatedFrameTimestamps));
    
    handles.DataWindowSize = NSx.MetaTags.SamplingFreq;

    handles.BeginDataWindow = 1;
    handles.EndDataWindow = handles.BeginDataWindow+handles.DataWindowSize;

    handles.DataReviewAxes;
    handles.DataPlot = plot([1 2 3 4]);

    %Create YAxis Labels
    handles.YLabels = {};
    for Title = 1:length(handles.ChannelIndexes)
        handles.YLabels{Title} = ['Channel',' ',num2str(handles.ChannelIndexes(Title))];
    end
    handles.YTicks = flipud(ScalingArray(:,1));
    if max(handles.YTicks) == 0
        handles.YTicks = sort(double(rand(1,length(handles.YTicks))));
    end
    set(handles.DataReviewAxes,'YTick',handles.YTicks)
    set(handles.DataReviewAxes,'YTickLabel',handles.YLabels);
        
    
    handles.AdvanceDirection = 1;
    handles.CurrentFrame = 0;
    set(handles.MovieAxes,'Visible','on');
    set(handles.DataReviewAxes,'Visible','on');
    handles.DataReviewAxes;
    guidata(hObject, handles);
    handles.ReviewTimer = timer('TimerFcn',{@Advance,hObject},'ExecutionMode','FixedDelay','Period',0.1);
    
    %handles.MovieFigure = figure();
    
    set(handles.TimeField,'String',datestr(handles.RecordingStartTime));
    
    %set(handles.ReviewSlider,'Max',length(handles.Data)-(handles.DataWindowSize/2));
    %set(handles.ReviewSlider,'Min',1+(handles.DataWindowSize/2));
    %set(handles.ReviewSlider,'SliderStep',[handles.DataWindowSize handles.DataWindowSize*10])
    
    Advance(1,1,hObject);
    Advance(1,-1,hObject);
    
    

guidata(hObject, handles);

function Play(hObject,handles)
handles = guidata(hObject);

%handles.DataReviewAxes;

if strcmpi(handles.ReviewTimer.Running,'off')
    start(handles.ReviewTimer);
    handles.AdvanceDirection = 1;
elseif strcmpi(handles.ReviewTimer.Running,'on')
    stop(handles.ReviewTimer);
    set(handles.PlayButton,'String','Play')
end





% function Pause(hObject,handles)
% handles = guidata(hObject);
% 
% stop(handles.ReviewTimer);
% 
% guidata(hObject,handles);

function Nav1(hObject,handles)
handles = guidata(hObject);

stop(handles.ReviewTimer);
set(handles.PlayButton,'String','Play')

handles.BeginDataWindow = 1;
handles.EndDataWindow = handles.BeginDataWindow+handles.DataWindowSize;

handles.CurrentFrame = handles.InterpolatedFrameNumbers(find(handles.InterpolatedFrameTimestamps>(handles.EndDataWindow-handles.DataWindowSize/2),1));
set(handles.FrameNumberField,'String',strcat('Frame:',num2str(handles.CurrentFrame)));

handles.MovFrame = read(handles.ReviewVideoReader,handles.CurrentFrame);

imshow(handles.MovFrame(:,:,:),[],'parent',handles.MovieAxes);

handles.DataReviewAxes;
%set(handles.DataPlot,'YData',handles.Data(1,handles.BeginDataWindow:handles.EndDataWindow));
%set(handles.DataPlot,'XData',[handles.BeginDataWindow:handles.EndDataWindow]);
handles.DataPlot = plot([handles.BeginDataWindow:handles.EndDataWindow],handles.Data(:,handles.BeginDataWindow:handles.EndDataWindow));
xlim([handles.BeginDataWindow handles.EndDataWindow]);
set(handles.DataReviewAxes,'YTick',handles.YTicks)
set(handles.DataReviewAxes,'YTickLabel',handles.YLabels);
set(handles.DataReviewAxes,'XTick',[handles.BeginDataWindow ((handles.BeginDataWindow+handles.EndDataWindow)/2) handles.EndDataWindow])
% set(handles.DataReviewAxes,'XTickLabel',[handles.BeginDataWindow/handles.SamplingFrequency ((handles.BeginDataWindow+handles.EndDataWindow)/2)/handles.SamplingFrequency handles.EndDataWindow/handles.SamplingFrequency] );
set(handles.DataReviewAxes,'XTickLabel',{datestr((handles.BeginDataWindow/handles.SamplingFrequency)/86400,'HH:MM:SS.FFF') datestr((((handles.BeginDataWindow+handles.EndDataWindow)/2)/handles.SamplingFrequency)/86400,'HH:MM:SS.FFF') datestr((handles.EndDataWindow/handles.SamplingFrequency)/86400,'HH:MM:SS.FFF')} );

set(handles.TimeField,'String',addtodate(datenum(handles.RecordingStartTime),((handles.BeginDataWindow+handles.EndDataWindow)/2)/handles.SamplingFrequency,'second'));

set(handles.ReviewSlider,'Value',(handles.BeginDataWindow+(handles.DataWindowSize/2))/length(handles.Data));

guidata(hObject,handles);

function Nav6(hObject,handles)
handles = guidata(hObject);

stop(handles.ReviewTimer);
set(handles.PlayButton,'String','Play')

handles.EndDataWindow = length(handles.Data);
handles.BeginDataWindow = handles.EndDataWindow-handles.DataWindowSize;

handles.CurrentFrame = handles.InterpolatedFrameNumbers(find(handles.InterpolatedFrameTimestamps>(handles.EndDataWindow-handles.DataWindowSize/2),1));
set(handles.FrameNumberField,'String',strcat('Frame:',num2str(handles.CurrentFrame)));

handles.MovFrame = read(handles.ReviewVideoReader,handles.CurrentFrame);

imshow(handles.MovFrame(:,:,:),[],'parent',handles.MovieAxes);

handles.DataReviewAxes;
%set(handles.DataPlot,'YData',handles.Data(1,handles.BeginDataWindow:handles.EndDataWindow));
%set(handles.DataPlot,'XData',[handles.BeginDataWindow:handles.EndDataWindow]);
handles.DataPlot = plot([handles.BeginDataWindow:handles.EndDataWindow],handles.Data(:,handles.BeginDataWindow:handles.EndDataWindow));
xlim([handles.BeginDataWindow handles.EndDataWindow]);
set(handles.DataReviewAxes,'YTick',handles.YTicks)
set(handles.DataReviewAxes,'YTickLabel',handles.YLabels);
set(handles.DataReviewAxes,'XTick',[handles.BeginDataWindow ((handles.BeginDataWindow+handles.EndDataWindow)/2) handles.EndDataWindow])
% set(handles.DataReviewAxes,'XTickLabel',[handles.BeginDataWindow/handles.SamplingFrequency ((handles.BeginDataWindow+handles.EndDataWindow)/2)/handles.SamplingFrequency handles.EndDataWindow/handles.SamplingFrequency] );
set(handles.DataReviewAxes,'XTickLabel',{datestr((handles.BeginDataWindow/handles.SamplingFrequency)/86400,'HH:MM:SS.FFF') datestr((((handles.BeginDataWindow+handles.EndDataWindow)/2)/handles.SamplingFrequency)/86400,'HH:MM:SS.FFF') datestr((handles.EndDataWindow/handles.SamplingFrequency)/86400,'HH:MM:SS.FFF')} );

set(handles.TimeField,'String',addtodate(datenum(handles.RecordingStartTime),((handles.BeginDataWindow+handles.EndDataWindow)/2)/handles.SamplingFrequency,'second'));

set(handles.ReviewSlider,'Value',(handles.BeginDataWindow+(handles.DataWindowSize/2))/length(handles.Data));

guidata(hObject,handles);

function Nav4(hObject,handles)
handles = guidata(hObject);

stop(handles.ReviewTimer);
set(handles.PlayButton,'String','Play')
handles.AdvanceDirection = 1;
guidata(hObject,handles);

Advance(1,1,hObject);



function Nav3(hObject,handles)
handles = guidata(hObject);

stop(handles.ReviewTimer);
set(handles.PlayButton,'String','Play')
handles.AdvanceDirection = -1;
guidata(hObject,handles);

Advance(1,-1,hObject);



function Nav5(hObject,handles)
handles = guidata(hObject);

stop(handles.ReviewTimer);
set(handles.PlayButton,'String','Play')
handles.AdvanceDirection = 1;
guidata(hObject,handles);

for i = 1:10
    Advance(1,1,hObject);
end



function Nav2(hObject,handles)
handles = guidata(hObject);

stop(handles.ReviewTimer);
set(handles.PlayButton,'String','Play')
handles.AdvanceDirection = -1;
guidata(hObject,handles);

for i = 1:10
    Advance(1,-1,hObject);
end



function Advance(~,Direction,hObject)
handles = guidata(hObject);

try
    if strcmpi(handles.ReviewTimer.Running,'off')
        set(handles.PlayButton,'String','Play')
    elseif strcmpi(handles.ReviewTimer.Running,'on')
        set(handles.PlayButton,'String','Pause')
    end
catch
    disp('Error')
end


handles.AdvanceDirection = Direction;
if isstruct(handles.AdvanceDirection)
    handles.AdvanceDirection = 1;
end

%Calculate real time
%set(handles.TimeField,'String',datestr(datenum(handles.RecordingStartTime) + seconds(round(((handles.BeginDataWindow+handles.EndDataWindow)/2)/handles.SamplingFrequency))));

%handles.DataReviewAxes;
%set(handles.DataPlot,'YData',handles.Data(:,handles.BeginDataWindow:handles.EndDataWindow));
%set(handles.DataPlot,'XData',[handles.BeginDataWindow:handles.EndDataWindow]);

handles.DataPlot = plot(handles.DataReviewAxes,[handles.BeginDataWindow:handles.EndDataWindow],handles.Data(:,handles.BeginDataWindow:handles.EndDataWindow));
%plot(handles.DataReviewAxes,[handles.BeginDataWindow handles.EndDataWindow],[0 0])

xlim(handles.DataReviewAxes,[handles.BeginDataWindow handles.EndDataWindow]);
set(handles.DataReviewAxes,'YTick',handles.YTicks)
set(handles.DataReviewAxes,'YTickLabel',handles.YLabels);
set(handles.DataReviewAxes,'XTick',[handles.BeginDataWindow ((handles.BeginDataWindow+handles.EndDataWindow)/2) handles.EndDataWindow])
set(handles.DataReviewAxes,'XTickLabel',{datestr((handles.BeginDataWindow/handles.SamplingFrequency)/86400,'HH:MM:SS.FFF') datestr((((handles.BeginDataWindow+handles.EndDataWindow)/2)/handles.SamplingFrequency)/86400,'HH:MM:SS.FFF') datestr((handles.EndDataWindow/handles.SamplingFrequency)/86400,'HH:MM:SS.FFF')} );

%Add current time in data set to initial recording time

set(handles.TimeField,'String',datestr(addtodate(datenum(handles.RecordingStartTime),round(((handles.BeginDataWindow+handles.EndDataWindow)/2)/handles.SamplingFrequency),'second')));



handles.BeginDataWindow = handles.BeginDataWindow+handles.AdvanceDirection*handles.DataWindowSize/(10*str2num(get(handles.DataWindowControl,'String')));
handles.EndDataWindow = handles.EndDataWindow+handles.AdvanceDirection*handles.DataWindowSize/(10*str2num(get(handles.DataWindowControl,'String')));

if handles.EndDataWindow > length(handles.Data)
    handles.EndDataWindow = length(handles.Data);
    handles.BeginDataWindow = handles.EndDataWindow-handles.DataWindowSize;
    stop(handles.ReviewTimer);
    set(handles.PlayButton,'String','Play')
elseif handles.BeginDataWindow < 1
    handles.BeginDataWindow = 1;
    handles.EndDataWindow = handles.BeginDataWindow+handles.DataWindowSize;
else
end

%handles.CurrentFrame = handles.CurrentFrame + 1;
handles.CurrentFrame = handles.InterpolatedFrameNumbers(find(handles.InterpolatedFrameTimestamps>(handles.EndDataWindow-handles.DataWindowSize/2),1));
set(handles.FrameNumberField,'String',strcat('Frame:',num2str(handles.CurrentFrame)));

handles.MovFrame = read(handles.ReviewVideoReader,handles.CurrentFrame);
%colormap(handles.MovieAxes,gray(256))
imshow(handles.MovFrame(:,:,:),[],'parent',handles.MovieAxes);
%imshow(handles.MovFrame(:,:,:),[],'parent',handles.MovieFigure);
set(handles.MovieAxes, 'LooseInset', [0,0,0,0]);

handles.AdvanceDirection = 1;


set(handles.ReviewSlider,'Value',(handles.BeginDataWindow+(handles.DataWindowSize/2))/length(handles.Data));

guidata(hObject, handles);

% function Comment(hObject,handles)
% handles = guidata(hObject);
% 
% 
% 
% guidata(hObject, handles);

function Connect(hObject,handles)
handles = guidata(hObject);

    cbmex('close');
    Connection = 0;
    try
        [Connection Instrument] = cbmex('open');
    catch
        LogAdd(hObject,handles,'Instrument not accessible!');
    end


    if Connection == 1
        LogAdd(hObject,handles,'Connected to Central!');
        handles.CentralConnect = 1;
    elseif Connection == 2
        LogAdd(hObject,handles,'Central not open. Not connected');
        handles.CentralConnect = 0;
        cbmex('close');
    else
        LogAdd(hObject,handles,'Failed to Connect!');
        handles.CentralConnect = 0;
    end


guidata(hObject, handles);

%Disconnect = CBMEX Close
function Disconnect(hObject,handles)
handles = guidata(hObject);
    cbmex('close');
    LogAdd(hObject,handles,'CBMEX Closed Succesfully');
guidata(hObject, handles);

%Search for Cameras and Calculate Frame Rates
function FindCameras(hObject,handles)

    global AppType
    handles = guidata(hObject);

%CBMEX Connection, exit if fail
    cbmex('close');
    Connection = 0;
    try
        [Connection Instrument] = cbmex('open');
    catch
        LogAdd(hObject,handles,'Instrument not accessible!');
        return
    end


    if Connection == 1
        LogAdd(hObject,handles,'Connected to Central!');
        handles.CentralConnect = 1;
    elseif Connection == 2
        LogAdd(hObject,handles,'Central not open. Not connected');
        handles.CentralConnect = 0;
        cbmex('close');
        return
    else
        LogAdd(hObject,handles,'Failed to Connect!');
        handles.CentralConnect = 0;
        return
    end

    VidStruct = imaqhwinfo('winvideo');
    CaptureTime = 30;
    ValidDeviceIDs = [];
    
%     for i = 1:length(VidStruct.DeviceIDs)
%         if(VidStruct.DeviceInfo(i).DeviceName(1:7) == 'Euresys')
%            ValidDeviceIDs = [ValidDeviceIDs i];
%         else
%             LogAdd(hObject,handles,['Device ID ' i ' not valid']);
%         end
%     end
    
    if AppType == 'V1';
        for i = 1:length(VidStruct.DeviceIDs)
    %     for i = 2:3:length(VidStruct.DeviceIDs)
            if(not(isempty(VidStruct.DeviceInfo(i).DeviceName(1:7))))
               ValidDeviceIDs = [ValidDeviceIDs VidStruct.DeviceInfo(i).DeviceID];
               disp(VidStruct.DeviceInfo(i).DefaultFormat)
            else
                LogAdd(hObject,handles,['Device ID ' i ' not valid']);
            end
        end
    elseif AppType == 'V2'
%         for i = 1:length(VidStruct.DeviceIDs)
        for i = 2:3:length(VidStruct.DeviceIDs)
            if(not(isempty(VidStruct.DeviceInfo(i).DeviceName(1:7))))
               ValidDeviceIDs = [ValidDeviceIDs VidStruct.DeviceInfo(i).DeviceID];
               disp(VidStruct.DeviceInfo(i).DefaultFormat)
            else
                LogAdd(hObject,handles,['Device ID ' i ' not valid']);
            end
        end
        
    end

    
    for i = 1:length(ValidDeviceIDs)
        %Specify format H264_704x576
        try
            handles.v(i) = videoinput('winvideo',ValidDeviceIDs(i),VidStruct.DeviceInfo(find(cell2mat(VidStruct.DeviceIDs)==ValidDeviceIDs(i))).SupportedFormats{21});
        catch Error
             disp(Error)
             handles.v(i) = videoinput('winvideo',ValidDeviceIDs(i),VidStruct.DeviceInfo(find(cell2mat(VidStruct.DeviceIDs)==ValidDeviceIDs(i))).SupportedFormats{1});
             LogAdd(hObject,handles,'Unrecognized camera type; camera still added.');
         end
         
        
        

            handles.framerate(i) = 10;


        
%         numframes = floor(CaptureTime * handles.framerate(i) / 1);

        set(handles.v(i),'LoggingMode','disk');

        LogMessage = strcat('Found Camera',num2str(i));
        LogAdd(hObject,handles,LogMessage);
        LogMessage = strcat('Camera ',num2str(i),' Framerate:',num2str(handles.framerate(i)));
        LogAdd(hObject,handles,LogMessage);
    end

    for idx = 1:i
        ActiveCameras{idx} = logical(1);
        AvailableCameras{idx} = strcat('Camera','-',num2str(idx));
        AvailableAnimals{idx} = strcat('Animal','-',num2str(idx));
        AvailableCameraNames{idx} = VidStruct.DeviceInfo(find(cell2mat(VidStruct.DeviceIDs)==ValidDeviceIDs(idx))).DeviceName;
        AvailableNumbers{idx} = {num2str([1+5*(idx-1),2+5*(idx-1),3+5*(idx-1),4+5*(idx-1),5+5*(idx-1)])};
    end

      set(handles.CameraListingTable,'ColumnFormat',{'logical' AvailableCameras AvailableCameraNames AvailableAnimals 'numeric'});

%     for n = 1:idx
%         ControlTableData(n,1) = {ActiveCameras{n}};
%         ControlTableData(n,2) = {AvailableCameras{n}};
%         ControlTableData(n,3) = {AvailableCameraNames{n}};
%         ControlTableData(n,4) = {AvailableAnimals{n}};
%         ControlTableData(n,5) = {num2str([1+5*(n-1),2+5*(n-1),3+5*(n-1),4+5*(n-1),5+5*(n-1)])};
%         %ControlTableData(n,5) = {5+5*(n-1)};
%     end
    
    for n = 1:idx
        ControlTableData(n,1) = {true};
        ControlTableData(n,2) = {AvailableCameras{n}};
        ControlTableData(n,3) = {AvailableCameraNames{n}};
        ControlTableData(n,4) = {AvailableAnimals{n}};
        ControlTableData(n,5) = {num2str([1+5*(n-1),2+5*(n-1),3+5*(n-1),4+5*(n-1),5+5*(n-1)])};
        %ControlTableData(n,5) = {5+5*(n-1)};
    end

    
%     'Data',{'False' 'Detect Cameras' 'Detect Cameras' 'Detect Cameras' 'Detect Cameras' }
    set(handles.CameraListingTable,'Data',ControlTableData);
    
    

    
    set(handles.CameraListingTable,'ColumnEditable',[true false false true true ])

    handles.NumberOfCameras = i;
    
    if(handles.NumberOfCameras < 1)
        LogAdd(hObject,handles,'No cameras found! Please ensure cameras are connected properly and retry.');
        return
    else
        set(handles.ExportButton,'Enable','on')
        set(handles.ImportButton,'Enable','on')
        set(handles.ExportScheduleButton,'Enable','on')
        set(handles.ImportScheduleButton,'Enable','on')
        set(handles.CameraListingTable,'Enable','on')
        %set(handles.SplitCheck,'Enable','on')
        set(handles.RecordButton,'Enable','on')
        set(handles.StopRecordButton,'Enable','on')
        set(handles.SchedulingTable,'Enable','on')
    end

    set(handles.v(i),'LoggingMode','disk');
    
    set(handles.SelectCamera,'String',AvailableCameras)
    
    handles.PreviewTimer = timer('TimerFcn',{@ShowFrame,hObject},'ExecutionMode','FixedDelay','Name','PreviewTimer','Period',0.25);
    start(handles.PreviewTimer);

guidata(hObject, handles);


function SelectCamera(hObject,handles)
handles = guidata(hObject);

if strcmpi(handles.PreviewTimer.Running,'off')
    start(handles.PreviewTimer);
elseif strcmpi(handles.PreviewTimer.Running,'on')
    %stop(handles.PreviewTimer);
end

guidata(hObject, handles);


function SelectSpeed(hObject,handles)
handles = guidata(hObject);

if strcmpi(handles.ReviewTimer.Running,'on')
    stop(handles.ReviewTimer);
    set(handles.PlayButton,'String','Play')
end

switch (get(handles.SelectSpeed,'Value'))
    case 1
        NewSpeed = 0.1;
        
    case 2
        NewSpeed = 0.05;
        
    case 3
        NewSpeed = 0.025;
        
    case 4
        NewSpeed = 0.1*(1/8);
        
end

set(handles.ReviewTimer,'Period',NewSpeed);

guidata(hObject, handles);

function JumpToTime(hObject,handles)
handles = guidata(hObject);

if strcmpi(handles.ReviewTimer.Running,'on')
    stop(handles.ReviewTimer);
    set(handles.PlayButton,'String','Play')
end

TimeStrings = strsplit(get(handles.JumpTimeSelect,'String'),':');
if length(TimeStrings) == 3
    TotalSeconds = str2num(TimeStrings{1})*60*60 + str2num(TimeStrings{2})*60 + str2num(TimeStrings{3});
    TimeStampTarget = TotalSeconds*handles.SamplingFrequency;
else
    LogAdd(hObject,handles,'Incorrect time format. Try h:m:s');
end

handles.BeginDataWindow = round(TimeStampTarget-handles.DataWindowSize/2);
handles.EndDataWindow = round(TimeStampTarget+handles.DataWindowSize/2);

if handles.EndDataWindow > length(handles.Data)
    handles.EndDataWindow = length(handles.Data);
    handles.BeginDataWindow = handles.EndDataWindow-handles.DataWindowSize;
    stop(handles.ReviewTimer);
    set(handles.PlayButton,'String','Play')
elseif handles.BeginDataWindow < 1
    handles.BeginDataWindow = 1;
    handles.EndDataWindow = handles.BeginDataWindow+handles.DataWindowSize;
else
end

guidata(hObject, handles);

Advance(1,1,hObject);
Advance(1,-1,hObject);

guidata(hObject, handles);


function SliderJumpToTime(hObject,handles)
handles = guidata(hObject);

if strcmpi(handles.ReviewTimer.Running,'on')
    stop(handles.ReviewTimer);
    set(handles.PlayButton,'String','Play')
end

DataTarget = round(get(hObject,'Value')*length(handles.Data));

handles.BeginDataWindow = round(DataTarget-handles.DataWindowSize/2);
handles.EndDataWindow = round(DataTarget+handles.DataWindowSize/2);

if handles.EndDataWindow > length(handles.Data)
    handles.EndDataWindow = length(handles.Data);
    handles.BeginDataWindow = handles.EndDataWindow-handles.DataWindowSize;
    stop(handles.ReviewTimer);
    set(handles.PlayButton,'String','Play')
elseif handles.BeginDataWindow < 1
    handles.BeginDataWindow = 1;
    handles.EndDataWindow = handles.BeginDataWindow+handles.DataWindowSize;
else
end

guidata(hObject, handles);

Advance(1,1,hObject);
Advance(1,-1,hObject);

guidata(hObject, handles);


function DataWindowSelect(hObject,handles)
handles = guidata(hObject);

if strcmpi(handles.ReviewTimer.Running,'on')
    stop(handles.ReviewTimer);
    set(handles.PlayButton,'String','Play')
end

handles.DataWindowSize = str2num(get(hObject,'String'))*handles.SamplingFrequency;

handles.EndDataWindow = handles.BeginDataWindow+handles.DataWindowSize;

if handles.EndDataWindow > length(handles.Data)
    handles.EndDataWindow = length(handles.Data);
    handles.BeginDataWindow = handles.EndDataWindow-handles.DataWindowSize;
    stop(handles.ReviewTimer);
    set(handles.PlayButton,'String','Play')
elseif handles.BeginDataWindow < 1
    handles.BeginDataWindow = 1;
    handles.EndDataWindow = handles.BeginDataWindow+handles.DataWindowSize;
else
end

%Experimental
if handles.EndDataWindow > length(handles.Data)
    handles.EndDataWindow = length(handles.Data);
    handles.BeginDataWindow = 1;
end



guidata(hObject, handles);

Advance(1,1,hObject);
Advance(1,-1,hObject);

guidata(hObject, handles);

function ShowFrame(~,~,hObject)
handles = guidata(hObject);

if(get(handles.Parent,'SelectedChild')==3)
    frame = getsnapshot(handles.v(get(handles.SelectCamera,'Value')));
    image(frame,'Parent',handles.CameraAxes)
    colormap(handles.CameraAxes,gray(256));
        set(handles.CameraAxes,'YTick',[])
        set(handles.CameraAxes,'XTick',[])
else
    %stop(handles.PreviewTimer);
end


function LogAdd(~,handles,NewEntry)
    disp(NewEntry)
    PreviousEntries = get(handles.Log,'String');
    FlippedEntries = flip(PreviousEntries);
    FlippedEntries{length(FlippedEntries)+1} = NewEntry;
    NewEntriesFlipped = flip(FlippedEntries);
    set(handles.Log,'String',NewEntriesFlipped);
    set(handles.LogLine,'String',NewEntry);
