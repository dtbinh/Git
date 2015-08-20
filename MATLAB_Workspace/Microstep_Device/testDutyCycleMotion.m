close all;
clear all;
clc;

step_size = 5.0;
insertion_speed = 0.5;
rotation_speed = 1.0;
duty_cycle = 0.5;

%% Start communication with the Raspberry Pi TCP/IP server

ustep_device = UStepDeviceHandler(2);

%% Read command from user

fprintf('Duty Cycle Test function\n\n');
while 1
    
    fprintf('Current parameters: \t S = %.2f mm \t V = %.2f mm/s \t W = %.2f rev/s \t DC = %.2f\n', step_size, insertion_speed, rotation_speed, duty_cycle);
    fprintf('Select one command:\n');
    command = input('1: Change S \n2: Change V \n3: Change W \n4: Change DC \n5: Perform one step\n');
    
    if(command == 1)
        new_step_size = input('Type the requested step size in mm\n');
        if(new_step_size <= 0)
            fprintf('Error: The step size must always be positive\n');
        else
            step_size = new_step_size;
        end
        
    elseif(command == 2)
        new_insertion_speed = input('Type the requested insertion speed in mm/s\n');
        if(new_insertion_speed < 0)
            fprintf('Error: The insertion speed must always be positive\n');
        elseif(new_insertion_speed > 15)
            fprintf('Error: The requested insertion speed is too high!\n');
        else
            insertion_speed = new_insertion_speed;
        end
        
    elseif(command == 3)
        new_rotation_speed = input('Type the requested rotation speed in rev/s\n');
        if(new_rotation_speed < 0)
            fprintf('Error: The rotation speed must always be positive\n');
        elseif(new_rotation_speed > 4)
            fprintf('Error: The requested rotation speed is too high!\n');
        else
            rotation_speed = new_rotation_speed;
        end
        
    elseif(command == 4)
        new_dc = input('Type the requested duty cycle\n');
        if(new_dc < 0 || new_dc > 1)
            fprintf('Error: The duty cycle must be between 0.0 and 1.0\n');
        else
            duty_cycle = new_dc;
        end
    elseif(command == 5)
        fprintf('Starting motion\n');
        ustep_device.moveDC(step_size, insertion_speed, rotation_speed, duty_cycle)
    else
        fprintf('Invalid option\n\n');
    end
    
    fprintf('\n');
end   
