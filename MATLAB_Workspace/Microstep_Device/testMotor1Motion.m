close all;
clear all;
clc;

global CMD_SET_ENABLE;
global CMD_OPEN_FRONT_GRIPPER;		
global CMD_CLOSE_FRONT_GRIPPER;		
global CMD_OPEN_BACK_GRIPPER;		
global CMD_CLOSE_BACK_GRIPPER;
global CMD_ROTATE;
global CMD_TRANSLATE;
global CMD_MOVE_DC;
global CMD_MOVE_BACK;
global CMD_MOVE_MOTOR;
global CMD_MOVE_MOTOR_STEPS;
global CMD_SET_DIRECTION;
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

speed = 1.0;

%% Start communication with the Raspberry Pi TCP/IP server

tcpip_client = tcpip('169.254.0.2',5555,'NetworkRole','Client');
set(tcpip_client,'InputBufferSize',7688);
set(tcpip_client,'Timeout',30);

%% Read command from user

while 1
    
    fprintf('Motor 1 motion test - moving motor 1 at the speed of %f mm/s\n', speed);
    displacement = input('Type the required displacement in mm. If you want to change the speed, type 0\n');
    
    if(displacement == 0)
        speed = input('Type the requested speed in mm/s\n');
        
%     elseif(displacement > 0)
%         fopen(tcpip_client);
%         fwrite(tcpip_client, [CMD_SET_DIRECTION MOTOR_INSERTION DIRECTION_FORWARD]);
%         pause(0.5);
%         displacement_value = displacement;
%         fwrite(tcpip_client, [CMD_MOVE_MOTOR MOTOR_INSERTION typecast(displacement_value, 'uint8') typecast(speed, 'uint8')]);
%         fclose(tcpip_client);
%         
%     else
%         fopen(tcpip_client);
%         fwrite(tcpip_client, [CMD_SET_DIRECTION MOTOR_INSERTION DIRECTION_BACKWARD]);
%         pause(0.5);
%         displacement_value = -displacement;
%         fwrite(tcpip_client, [CMD_MOVE_MOTOR MOTOR_INSERTION typecast(displacement_value, 'uint8') typecast(speed, 'uint8')]);
%         fclose(tcpip_client);
%     end
        
    else
        fopen(tcpip_client);
        fwrite(tcpip_client, [CMD_TRANSLATE typecast(displacement, 'uint8') typecast(speed, 'uint8')]);
        fclose(tcpip_client);
    end
    
    
    fprintf('\n');
    pause(1);
end
