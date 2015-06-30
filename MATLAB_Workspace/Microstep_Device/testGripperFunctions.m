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

%% Start communication with the Raspberry Pi TCP/IP server

tcpip_client = tcpip('169.254.0.2',5555,'NetworkRole','Client');
set(tcpip_client,'InputBufferSize',7688);
set(tcpip_client,'Timeout',30);

%% Read command from user

while 1
    
    fprintf('Gripper Test functions. Select one command:\n');
    command = input('1: Open Front Gripper \n2: Close Front Gripper \n3: Open Back Gripper \n4: Close Back Gripper\n');
    
    fopen(tcpip_client);
    if(command == 1)
        fprintf('Sending the command OPEN_FRONT_GRIPPER to the device\n\n');
        fwrite(tcpip_client, CMD_OPEN_FRONT_GRIPPER);
        pause(0.5);
    elseif(command == 2)
        fprintf('Sending the command CLOSE_FRONT_GRIPPER to the device\n\n');
        fwrite(tcpip_client, CMD_CLOSE_FRONT_GRIPPER);
        pause(0.5);
    elseif(command == 3)
        fprintf('Sending the command OPEN_BACK_GRIPPER to the device\n\n');
        fwrite(tcpip_client, CMD_OPEN_BACK_GRIPPER);
        pause(0.5);
    elseif(command == 4)
        fprintf('Sending the command CLOSE_BACK_GRIPPER to the device\n\n');
        fwrite(tcpip_client, CMD_CLOSE_BACK_GRIPPER);
        pause(0.5);
    else
        fprintf('Invalid option\n\n');
    end
    fclose(tcpip_client);
    
    pause(1);
end
