close all;
clear all;
clc;

% global CMD_SET_ENABLE;
% global CMD_OPEN_FRONT_GRIPPER;		
% global CMD_CLOSE_FRONT_GRIPPER;		
% global CMD_OPEN_BACK_GRIPPER;		
% global CMD_CLOSE_BACK_GRIPPER;
% global CMD_ROTATE;
% global CMD_TRANSLATE;
% global CMD_MOVE_DC;
% global CMD_MOVE_BACK;
% global CMD_MOVE_MOTOR;
% global CMD_MOVE_MOTOR_STEPS;
% global CMD_SET_DIRECTION;
% global CMD_SHUT_DOWN;
% 
% global MOTOR_INSERTION;
% global MOTOR_ROTATION;
% global MOTOR_FRONT_GRIPPER;
% global MOTOR_BACK_GRIPPER;
% 
% global DIRECTION_FORWARD;
% global DIRECTION_BACKWARD;
% global DIRECTION_CLOCKWISE;
% global DIRECTION_COUNTER_CLOCKWISE;
% global DIRECTION_OPENING;
% global DIRECTION_CLOSING;
% 
% global ENABLE_MOTOR;
% global DISABLE_MOTOR;
% 
% communicationProtocolTable

%% Global parameters


% sensor_angle_inside_needle = 49.0;
sensor_angle_inside_needle = 29.0;


% Needle initial orientation
needle_V0 = [0 0 1];
needle_N0 = [-sind(sensor_angle_inside_needle) cosd(sensor_angle_inside_needle) 0];

maximum_aurora_error = 0.1;

preparation_step_size = 20;
preparation_insertion_speed = 3.0;
preparation_rotation_speed = 0.1;

% Insertion trajectory
n_step = 4;
step_size = 6;
insertion_speed = 1.0;
rotation_speed = 2.0;

duty_cycle = 0.5;

% %% Variables for storing the results
% 
% % Forward steps
% needle_x_fw           = zeros(1, n_step+1);
% needle_y_fw           = zeros(1, n_step+1);
% needle_z_fw           = zeros(1, n_step+1);
% needle_orientation_fw = zeros(4, n_step+1);
% needle_error_fw       = zeros(1, n_step+1);
% 
% % Backward steps
% needle_x_bw           = zeros(1, n_step+1);
% needle_y_bw           = zeros(1, n_step+1);
% needle_z_bw           = zeros(1, n_step+1);
% needle_orientation_bw = zeros(4, n_step+1);
% needle_error_bw       = zeros(1, n_step+1);
% 

%% Configure the TCP/IP client for communicating with the Raspberry Pi

ustep_device = UStepDeviceHandler(n_step);
% tcpip_client = tcpip('169.254.0.2',5555,'NetworkRole','Client');
% set(tcpip_client,'InputBufferSize',7688);
% set(tcpip_client,'Timeout', 180);

%% Configure the Aurora sensor object

aurora_device = AuroraDriver('/dev/ttyUSB0');
aurora_device.openSerialPort();
aurora_device.init();
aurora_device.detectAndAssignPortHandles();
aurora_device.initPortHandleAll();
aurora_device.enablePortHandleDynamicAll();
aurora_device.startTracking();

%% Set file name for storing the results

fprintf('Duty Cycle Experiment - DC = %.2f\n', duty_cycle);
output_file_name = input('Type the name of the file for saving the results\n','s');

%% Adjust the needle starting position

fprintf('Place the needle inside the device \nMake sure to align the needle tip to the end of the device\n');
input('When you are done, hit ENTER to close the front gripper\n\n');

% Moving the needle forward until it gets detected by the Aurora system
fprintf('Adjusting the needle initial orientation\n');
n_preparation_step = 0;
aurora_error = aurora_device.getError();
while(aurora_error > 10*maximum_aurora_error)
    
    fprintf('Cant read the needle EM sensor. Moving the needle %.2f mm forward \n', preparation_step_size);
    ustep_device.moveForward(preparation_step_size, preparation_insertion_speed);
    n_preparation_step = n_preparation_step + 1;
    aurora_error = aurora_device.getError();
    
%     fopen(tcpip_client);  
%     fwrite(tcpip_client, [CMD_MOVE_DC typecast(preparation_step_size, 'uint8') typecast(preparation_insertion_speed, 'uint8') typecast(3.0, 'uint8') typecast(0.0, 'uint8')]);
%     fread(tcpip_client, 1);
%     fclose(tcpip_client);
end

% Adjusting the needle orientation
aurora_device.updateSensorDataAll();
needle_quaternion = quatinv(aurora_device.port_handles(1,1).rot);
correction_angle = measureNeedleCorrectionAngle(needle_quaternion, needle_N0);

fprintf('Needle found! Correction angle = %.2f degrees \n', correction_angle);
ustep_device.rotateNeedleDegrees(correction_angle, preparation_rotation_speed);

% revolutions = correction_angle / 360.0;
% fopen(tcpip_client);
% fwrite(tcpip_client, [CMD_ROTATE typecast(revolutions, 'uint8') typecast(preparation_rotation_speed, 'uint8')]);
% fread(tcpip_client, 1);
% fclose(tcpip_client);

% Moving the needle backward
for i_preparation_step = 1:n_preparation_step
    ustep_device.moveBackward(preparation_step_size, preparation_insertion_speed);
%     fopen(tcpip_client);
%     fwrite(tcpip_client, [CMD_MOVE_BACK typecast(preparation_step_size, 'uint8') typecast(preparation_insertion_speed, 'uint8')]);
%     fread(tcpip_client, 1);
%     fclose(tcpip_client);
end

%% Perform forward steps

fprintf('\nPreparing to start the experiment. Place the gelatin\n');
input('Hit ENTER when you are ready\n');

for i_step = 1:n_step
    fprintf('\nPerforming step %d/%d: S = %.2f, V = %.2f, W = %.2f, DC = %.2f\n', i_step, n_step, step_size, insertion_speed, rotation_speed, duty_cycle);
    
    % Measure needle pose before moving
    ustep_device.savePoseForward(aurora_device, i_step);
    
%     pause(1);
%     aurora_device.updateSensorDataAll();
%     aurora_error = aurora_device.getError();
%     if(aurora_error < 10*maximum_aurora_error)
%         trans = aurora_device.port_handles(1,1).trans;
%         needle_x_fw(i_step) = trans(1);
%         needle_y_fw(i_step) = trans(2);
%         needle_z_fw(i_step) = trans(3);
%         needle_orientation_fw(:, i_step) = quatinv(aurora_device.port_handles(1,1).rot)';
%         needle_error_fw(i_step) = aurora_device.port_handles(1,1).error;
%     end
    
    % Move needle
    ustep_device.moveDC(step_size, insertion_speed, rotation_speed, duty_cycle);
    ustep_device.saveCommandsDC(i_step, step_size, insertion_speed, rotation_speed, duty_cycle);
%     fopen(tcpip_client);
%     fwrite(tcpip_client, [CMD_MOVE_DC typecast(step_size, 'uint8') typecast(insertion_speed, 'uint8') typecast(rotation_speed, 'uint8') typecast(duty_cycle, 'uint8')]);
%     fread(tcpip_client, 1);
%     fclose(tcpip_client);
end

% Measure the final needle pose
ustep_device.savePoseForward(aurora_device, n_step+1);

% pause(1);
% aurora_device.updateSensorDataAll();
% aurora_error = aurora_device.getError();
% if(aurora_error < 10*maximum_aurora_error)
%     trans = aurora_device.port_handles(1,1).trans;
%     needle_x_fw(n_step+1) = trans(1);
%     needle_y_fw(n_step+1) = trans(2);
%     needle_z_fw(n_step+1) = trans(3);
%     needle_orientation_fw(:, n_step+1) = quatinv(aurora_device.port_handles(1,1).rot)';
%     needle_error_fw(n_step+1) = aurora_device.port_handles(1,1).error;
% end

%% Perform backward steps

fprintf('\nNeedle insertion complete!\n');
input('Hit ENTER to start retreating the needle\n');

% Measure the final needle pose
ustep_device.savePoseBackward(aurora_device, n_step+1);

% pause(1);
% aurora_device.updateSensorDataAll();
% aurora_error = aurora_device.getError();
% if(aurora_error < 10*maximum_aurora_error)
%     trans = aurora_device.port_handles(1,1).trans;
%     needle_x_bw(n_step+1) = trans(1);
%     needle_y_bw(n_step+1) = trans(2);
%     needle_z_bw(n_step+1) = trans(3);
%     needle_orientation_bw(:, n_step+1) = quatinv(aurora_device.port_handles(1,1).rot)';
%     needle_error_bw(n_step+1) = aurora_device.port_handles(1,1).error;
% end

for i_step = n_step:-1:1
    fprintf('\nPerforming backward step %d/%d\n', i_step, n_step);
    
    % Move needle
    ustep_device.moveBackward(step_size, insertion_speed);
%     fopen(tcpip_client);
%     fwrite(tcpip_client, [CMD_MOVE_BACK typecast(step_size, 'uint8') typecast(insertion_speed, 'uint8')]);
%     fread(tcpip_client, 1);
%     fclose(tcpip_client);
    
    % Measure needle pose before retreating
    ustep_device.savePoseBackward(aurora_device, i_step);
    
%     pause(1);
%     aurora_device.updateSensorDataAll();
%     aurora_error = aurora_device.getError();
%     if(aurora_error < 10*maximum_aurora_error)
%         trans = aurora_device.port_handles(1,1).trans;
%         needle_x_bw(i_step) = trans(1);
%         needle_y_bw(i_step) = trans(2);
%         needle_z_bw(i_step) = trans(3);
%         needle_orientation_bw(:, i_step) = quatinv(aurora_device.port_handles(1,1).rot)';
%         needle_error_bw(i_step) = aurora_device.port_handles(1,1).error;
%     end
end

% Close the aurora system
aurora_device.stopTracking();
delete(aurora_device);

% Save experiment results
save(sprintf('%s.mat',output_file_name));