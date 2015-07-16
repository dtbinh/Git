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

step_size = 20.0;
insertion_speed = 1.0;
rotation_speed = 0.4;
dc_value = 0.25;

%% Start communication with the Raspberry Pi TCP/IP server

tcpip_client = tcpip('169.254.0.2',5555,'NetworkRole','Client');
set(tcpip_client,'InputBufferSize',7688);
set(tcpip_client,'Timeout',30);

%% Read command from user

% fprintf('Duty Cycle Test function\n\n');
% while 1
%     
%     fprintf('Current parameters: \t S = %.2f mm \t V = %.2f mm/s \t W = %.2f rev/s \t DC = %.2f\n', step_size, insertion_speed, rotation_speed, dc_value);
%     fprintf('Select one command:\n');
%     command = input('1: Change S \n2: Change V \n3: Change W \n4: Change DC \n5: Perform one step\n');
%     
%     if(command == 1)
%         new_step_size = input('Type the requested step size in mm\n');
%         if(new_step_size <= 0)
%             fprintf('Error: The step size must always be positive\n');
%         else
%             step_size = new_step_size;
%         end
%         
%     elseif(command == 2)
%         new_insertion_speed = input('Type the requested insertion speed in mm/s\n');
%         if(new_insertion_speed < 0)
%             fprintf('Error: The insertion speed must always be positive\n');
%         elseif(new_insertion_speed > 15)
%             fprintf('Error: The requested insertion speed is too high!\n');
%         else
%             insertion_speed = new_insertion_speed;
%         end
%         
%     elseif(command == 3)
%         new_rotation_speed = input('Type the requested rotation speed in rev/s\n');
%         if(new_rotation_speed < 0)
%             fprintf('Error: The rotation speed must always be positive\n');
%         elseif(new_rotation_speed > 4)
%             fprintf('Error: The requested rotation speed is too high!\n');
%         else
%             rotation_speed = new_rotation_speed;
%         end
%         
%     elseif(command == 4)
%         new_dc = input('Type the requested duty cycle\n');
%         if(new_dc < 0 || new_dc > 1)
%             fprintf('Error: The duty cycle must be between 0.0 and 1.0\n');
%         else
%             dc_value = new_dc;
%         end
%     elseif(command == 5)
%         fprintf('Starting motion\n');
%         fopen(tcpip_client);
%         fwrite(tcpip_client, [CMD_MOVE_DC typecast(step_size, 'uint8') typecast(insertion_speed, 'uint8') typecast(rotation_speed, 'uint8') typecast(dc_value, 'uint8')]);
%         fclose(tcpip_client);
%     else
%         fprintf('Invalid option\n\n');
%     end
%     
%     fprintf('\n');
% end

%% Pre defined duty cycle test

step_size = 10.0;
insertion_speed = 1.0;
rotation_speed = 2.0;
dc_value = [0.0 0.25 0.5 0.75 1.0];
% dc_value = [1.0];

step_duration = 20.0;

n_test = length(dc_value);

pause(10.0);

for i_test = 1:n_test
    
    current_dc_value = dc_value(i_test);
    fprintf('Performing one duty cycle step with the following parameters\n');
    fprintf('S = %.2f mm, V = %.2f mm/s, W = %.2f rev/s, DC = %.2f\n', step_size, insertion_speed, rotation_speed, current_dc_value);
    
    fopen(tcpip_client);
    fwrite(tcpip_client, [CMD_MOVE_DC typecast(step_size, 'uint8') typecast(insertion_speed, 'uint8') typecast(rotation_speed, 'uint8') typecast(current_dc_value, 'uint8')]);
    fclose(tcpip_client);
    
    pause(step_duration);
end

    
