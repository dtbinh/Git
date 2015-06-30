close all;
clear all;
clc;

global CMD_MOVE_MOTOR;
global CMD_MOVE_MOTOR_STEPS;
global CMD_MOVE_DC;
global CMD_MOVE_SPIN;
global CMD_SET_DIRECTION;
global CMD_SET_ENABLE;
global CMD_OPEN_FRONT_GRIPPER;		
global CMD_CLOSE_FRONT_GRIPPER;		
global CMD_OPEN_BACK_GRIPPER;		
global CMD_CLOSE_BACK_GRIPPER;
global CMD_SHUT_DOWN;

global MOTOR_INSERTION;
global MOTOR_ROTATION; 
global MOTOR_FRONT_GRIPPER;
global MOTOR_BACK_GRIPPER;

global DIRECTION_FORWARD;
global DIRECTION_BACKWARD;    
global DIRECTION_CLOCKWISE;
global DIRECTION_COUNTER_CLOCKWISE;
global DIRECTION_OPENING;
global DIRECTION_CLOSING;

global ENABLE_MOTOR;
global DISABLE_MOTOR;

communicationProtocolTable

rotation_speed = 0.1;

%% Start communication with the Raspberry Pi TCP/IP server

tcpip_client = tcpip('169.254.0.2',5555,'NetworkRole','Client');
set(tcpip_client,'InputBufferSize',7688);
set(tcpip_client,'Timeout',30);

%% Read command from user

while 1
    fprintf('Testing the needle rotation \t--\t speed = %f rev/s\n', rotation_speed);
    angle = input('Type the rotation angle in degrees. If you want to change the speed, type 0\n');
    
    if(angle == 0)
        rotation_speed = input('Type the requested speed in rev/s\n');
    
    elseif(angle > 0)
        fopen(tcpip_client);
        fwrite(tcpip_client, [CMD_SET_DIRECTION MOTOR_ROTATION DIRECTION_CLOCKWISE]);
        pause(0.5);
        revolutions = angle / 360.0;
        fwrite(tcpip_client, [CMD_MOVE_SPIN typecast(revolutions, 'uint8') typecast(rotation_speed, 'uint8')]);
        fclose(tcpip_client);
    
    else
        fopen(tcpip_client);
        fwrite(tcpip_client, [CMD_SET_DIRECTION MOTOR_ROTATION DIRECTION_COUNTER_CLOCKWISE]);
        pause(0.5);
        revolutions = -angle / 360.0;
        fwrite(tcpip_client, [CMD_MOVE_SPIN typecast(revolutions, 'uint8') typecast(rotation_speed, 'uint8')]);
        fclose(tcpip_client);
    end
    
    fprintf('\n');
    pause(1);
end


%% High speed rotation test
% 
% revolutions = 1.0;
% rotation_speed = 4.5;
% 
% while 1
%     fopen(tcpip_client);
%     fwrite(tcpip_client, [CMD_SET_DIRECTION MOTOR_ROTATION DIRECTION_CLOCKWISE]);
%     pause(0.5);
%     fwrite(tcpip_client, [CMD_MOVE_SPIN typecast(revolutions, 'uint8') typecast(rotation_speed, 'uint8')]);
%     pause(0.5);
%     fclose(tcpip_client);
%     
% %     pause(0.5);
%     
%     fopen(tcpip_client);
%     fwrite(tcpip_client, [CMD_SET_DIRECTION MOTOR_ROTATION DIRECTION_COUNTER_CLOCKWISE]);
%     pause(0.5);
%     fwrite(tcpip_client, [CMD_MOVE_SPIN typecast(revolutions, 'uint8') typecast(rotation_speed, 'uint8')]);
%     pause(0.5);
%     fclose(tcpip_client);
%     
% %     pause(0.5);
% end
    