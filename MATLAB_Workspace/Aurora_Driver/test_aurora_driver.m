clear all

device = AuroraDriver('/dev/ttyUSB0');
device.openSerialPort();

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

device.INIT()
device.TSTART('80');
[reply, error] = device.BX('0001');


device.closeSerialPort();
delete(device);
clear device