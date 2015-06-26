function moveMotor(motor, direction, displacement, speed)

global CMD_MOVE_MOTOR;
global CMD_SET_DIRECTION;

%% Start communication with the Raspberry Pi TCP/IP server

tcpipClient = tcpip('169.254.0.2',5555,'NetworkRole','Client');
set(tcpipClient,'InputBufferSize',7688);
set(tcpipClient,'Timeout',30);
fopen(tcpipClient);

%% Send the command setDirectiom

fwrite(tcpipClient, [CMD_SET_DIRECTION motor direction]);
pause(0.5);

%% Send the command moveMotor

fwrite(tcpipClient, [CMD_MOVE_MOTOR motor typecast(displacement, 'uint8') typecast(speed, 'uint8')]);

%% Stop the communication

fclose(tcpipClient);