% clear all
% 
% device = AuroraDriver('/dev/ttyUSB0');
% device.openSerialPort();
% 
% rep1 = device.ECHO('Hello World!')
% 
% rep2 = device.APIREV()
% 
% rep3 = device.BEEP('1')
% pause(1);
% rep4 = device.BEEP('2')
% pause(1);
% rep5 = device.BEEP('7')
% pause(2);
% rep6 = device.BEEP('9')
% 
% % device.INIT()
% % 
% % % TSTART needs INIT
% % device.TSTART('80');
% % 
% % % BX needs to be in Tracking mode
% % [reply, error] = device.BX('0001');
% 
% 
% device.closeSerialPort();
% delete(device);
% clear device

clear all

%device.setBaudRate(57600);

device = AuroraDriver('/dev/ttyUSB0');
device.openSerialPort();
device.init();
device.detectAndAssignPortHandles();
device.initPortHandleAll();
device.enablePortHandleDynamicAll();
  

% Start tracking mode
device.TSTART('80')
% print '\nStarting tracking mode...'
% polaris_driver.startTracking(polaris_driver.TSTART_RESET_FRAMECOUNT)
% print 'Tracking mode started successfully.'

% Read data
[reply, error] = device.BX('0001')
% for i in range(10):
%     polaris_driver.getToolTransformations()
%     #polaris_driver._beep(1)
%     print ''

% Stop tracking
device.TSTOP();
% print '\nStop tracking mode...'
% polaris_driver.stopTracking()
% print 'Tracking mode started successfully.'

% Close serial port
device.closeSerialPort();
delete(device);
clear device