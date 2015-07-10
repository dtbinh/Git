close all;
clear all;
clc;

global CMD_MOVE_MOTOR;
global CMD_MOVE_MOTOR_STEPS;
global CMD_MOVE_DC;
global CMD_MOVE_BACK;
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

%% Global parameters

preparation_step_size = 15;
preparation_insertion_speed = 3.0;
preparation_rotation_speed = 0.1;


%% Open Loop Trajectory

% Trajectory 1 - 15 cm divided in 30 steps, V = 1, no spin

constant_step_size = 9.0;
constant_insertion_speed = 1.5;
constant_rotation_speed = 3.0;
constant_duty_cycle = 0.1;

n_step = 15;

step_size       = constant_step_size        *  ones(1, n_step);
insertion_speed = constant_insertion_speed  *  ones(1, n_step);
rotation_speed  = constant_rotation_speed   *  ones(1, n_step);
duty_cycle      = constant_duty_cycle       *  ones(1, n_step);

correction_angles = zeros(1, n_step);

%% Configure the TCP/IP client for communicating with the Raspberry Pi

tcpip_client = tcpip('169.254.0.2',5555,'NetworkRole','Client');
set(tcpip_client,'InputBufferSize',7688);
set(tcpip_client,'Timeout',30);

%% Adjust the needle starting position

% Grasping the needle
fprintf('Open Loop Insertion Test\n');
fprintf('Initializing device\n');
fprintf('\n!!! Please verify that the device has been calibrated and both grippers are OPEN !!! \n\n');

pause(3);

output_file_name = input('Type the name of the file for saving the results\n','s');

fprintf('Place the needle inside the device\n');
fprintf('Make sure to align the needle tip the end of the device\n');
input('When you are done, hit ENTER to close the front gripper\n\n');

% Moving the needle forward
fopen(tcpip_client);
fwrite(tcpip_client, [CMD_MOVE_DC typecast(preparation_step_size, 'uint8') typecast(preparation_insertion_speed, 'uint8') typecast(3.0, 'uint8') typecast(0.0, 'uint8')]);
fclose(tcpip_client);


% Adjusting the needle orientation
fprintf('Adjusting the needle initial orientation\n');
while 1
    angle = input('Type the amount of degrees, in CW direction, to reach the starting orientation\n');
    
    if(angle == 0)
        break;
    
    elseif(angle > 0)
        fopen(tcpip_client);
        fwrite(tcpip_client, [CMD_SET_DIRECTION MOTOR_ROTATION DIRECTION_CLOCKWISE]);
        pause(0.5);
        revolutions = angle / 360.0;
        fwrite(tcpip_client, [CMD_MOVE_SPIN typecast(revolutions, 'uint8') typecast(preparation_rotation_speed, 'uint8')]);
        fclose(tcpip_client);
    
    else
        fopen(tcpip_client);
        fwrite(tcpip_client, [CMD_SET_DIRECTION MOTOR_ROTATION DIRECTION_COUNTER_CLOCKWISE]);
        pause(0.5);
        revolutions = -angle / 360.0;
        fwrite(tcpip_client, [CMD_MOVE_SPIN typecast(revolutions, 'uint8') typecast(preparation_rotation_speed, 'uint8')]);
        fclose(tcpip_client);
    end
end

% Moving the needle backward
fopen(tcpip_client);
fwrite(tcpip_client, [CMD_MOVE_BACK typecast(preparation_step_size, 'uint8') typecast(preparation_insertion_speed, 'uint8')]);
fclose(tcpip_client);

%% Perform the open loop trajectory

fprintf('\n');
fprintf('Preparing to start the open loop trajectory\n');
input('Hit ENTER when you are ready\n');

for i_step = 1:n_step
    fprintf('\nPerforming step %d/%d: S = %.2f, V = %.2f, W = %.2f, DC = %.2f\n', i_step, n_step, step_size(i_step), insertion_speed(i_step), rotation_speed(i_step), duty_cycle(i_step));
    
    fopen(tcpip_client);
    fwrite(tcpip_client, [CMD_MOVE_DC typecast(step_size(i_step), 'uint8') typecast(insertion_speed(i_step), 'uint8') typecast(rotation_speed(i_step), 'uint8') typecast(duty_cycle(i_step), 'uint8')]);
    fclose(tcpip_client);
    
    while 1
        angle = input('Needle orientation correction - Type required anle, in CW direction\n');
        
        % Checking if ENTER was hit without typing any number
        if(isempty(angle))
            continue
        end
        
        correction_angles(i_step) = correction_angles(i_step) + angle;
        
        if(angle == 0)
            break;
            
        elseif(angle > 0)
            fopen(tcpip_client);
            fwrite(tcpip_client, [CMD_SET_DIRECTION MOTOR_ROTATION DIRECTION_CLOCKWISE]);
            pause(0.5);
            revolutions = angle / 360.0;
            fwrite(tcpip_client, [CMD_MOVE_SPIN typecast(revolutions, 'uint8') typecast(preparation_rotation_speed, 'uint8')]);
            fclose(tcpip_client);
            
        else
            fopen(tcpip_client);
            fwrite(tcpip_client, [CMD_SET_DIRECTION MOTOR_ROTATION DIRECTION_COUNTER_CLOCKWISE]);
            pause(0.5);
            revolutions = -angle / 360.0;
            fwrite(tcpip_client, [CMD_MOVE_SPIN typecast(revolutions, 'uint8') typecast(preparation_rotation_speed, 'uint8')]);
            fclose(tcpip_client);
        end
    end
end

save(sprintf('%s.mat',output_file_name));