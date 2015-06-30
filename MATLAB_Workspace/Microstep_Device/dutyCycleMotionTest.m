close all;
clear all;
clc;

global CMD_MOVE_MOTOR;
global CMD_MOVE_MOTOR_STEPS;
global CMD_MOVE_DC;
global CMD_SET_DIRECTION;
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

communicationProtocolTable

insertion_speed = 2.0;
rotation_speed = 3.0;
dc_value = 0.0;

%% Start communication with the Raspberry Pi TCP/IP server

tcpip_client = tcpip('169.254.0.2',5555,'NetworkRole','Client');
set(tcpip_client,'InputBufferSize',7688);
set(tcpip_client,'Timeout',30);

%% Read command from user

while 1
    
    fprintf('Testing the duty cycle function without rotation \t--\t speed = %f mm/s\n', insertion_speed);
    displacement = input('Type the step size in mm. If you want to change the speed, type 0\n');
    
    if(displacement == 0)
        insertion_speed = input('Type the requested speed in mm/s\n');
    
    elseif(displacement > 0)
        fopen(tcpip_client);
        
        fwrite(tcpip_client, [CMD_MOVE_DC typecast(displacement, 'uint8') typecast(insertion_speed, 'uint8') typecast(rotation_speed, 'uint8') typecast(dc_value, 'uint8') ]);
        pause(0.5);
        fclose(tcpip_client);
    
    else
        fprintf('Error - The step size must always be positive\n');
    end
    
    fprintf('\n');
    pause(1);
end
