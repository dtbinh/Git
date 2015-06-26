function setDirection(motor, direction)

global CMD_SET_DIRECTION;

tcpipClient = tcpip('169.254.0.2',5555,'NetworkRole','Client');
set(tcpipClient,'InputBufferSize',7688);
set(tcpipClient,'Timeout',30);
fopen(tcpipClient);

%% Send the command moveMotor

fwrite(tcpipClient, [CMD_SET_DIRECTION motor direction]);

%% Stop the communication

fclose(tcpipClient);