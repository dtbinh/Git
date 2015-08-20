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

%% Global parameters

preparation_step_size = 20;
preparation_insertion_speed = 4.0;
preparation_rotation_speed = 0.1;

maximum_aurora_error = 0.1;

% Needle initial orientation
sensor_angle_inside_needle = 49.0;
needle_V0 = [0 0 1];
needle_N0 = [-sind(sensor_angle_inside_needle) cosd(sensor_angle_inside_needle) 0];

n_step = 6;
step_size = 15;
insertion_speed = 2.0;

needle_x = zeros(1, n_step);
needle_y = zeros(1, n_step);
needle_z = zeros(1, n_step);
needle_error = zeros(1, n_step);

plot_figure = 1;

%% Configure the TCP/IP client for communicating with the Raspberry Pi

tcpip_client = tcpip('169.254.0.2',5555,'NetworkRole','Client');
set(tcpip_client,'InputBufferSize',7688);
set(tcpip_client,'Timeout', 180);

%% Configure the Aurora sensor object

aurora_device = AuroraDriver('/dev/ttyUSB0');
aurora_device.openSerialPort();
aurora_device.init();
aurora_device.detectAndAssignPortHandles();
aurora_device.initPortHandleAll();
aurora_device.enablePortHandleDynamicAll();
aurora_device.startTracking();

%% Adjust the needle starting position

fprintf('Place the needle inside the device\n');
fprintf('Make sure to align the needle tip the end of the device\n');
input('When you are done, hit ENTER to close the front gripper\n\n');

% Moving the needle forward until it gets detected by the Aurora system
fprintf('Adjusting the needle initial orientation\n');
aurora_error = aurora_device.getError();
n_preparation_step = 0;
while(aurora_error > maximum_aurora_error)
    
    fprintf('Cant read the needle EM sensor. Moving the needle %.2f mm forward \n', preparation_step_size);
    fopen(tcpip_client);  
    fwrite(tcpip_client, [CMD_MOVE_DC typecast(preparation_step_size, 'uint8') typecast(preparation_insertion_speed, 'uint8') typecast(3.0, 'uint8') typecast(0.0, 'uint8')]);
    fread(tcpip_client, 1);
    fclose(tcpip_client);

    n_preparation_step = n_preparation_step + 1;
    aurora_error = aurora_device.getError();
end

% Adjusting the needle orientation
aurora_device.updateSensorDataAll();
needle_quaternion = quatinv(aurora_device.port_handles(1,1).rot);
correction_angle = measureNeedleCorrectionAngle(needle_quaternion, needle_N0);
fprintf('Needle found! Correction angle = %.2f degrees \n', correction_angle);

revolutions = correction_angle / 360.0;
fopen(tcpip_client);
fwrite(tcpip_client, [CMD_ROTATE typecast(revolutions, 'uint8') typecast(preparation_rotation_speed, 'uint8')]);
fread(tcpip_client, 1);
fclose(tcpip_client);

% Moving the needle backward
for i_preparation_step = 1:n_preparation_step
    fopen(tcpip_client);
    fwrite(tcpip_client, [CMD_MOVE_BACK typecast(preparation_step_size, 'uint8') typecast(preparation_insertion_speed, 'uint8')]);
    fread(tcpip_client, 1);
    fclose(tcpip_client);
end

%% Perform the open loop trajectory

fprintf('\n');
fprintf('Preparing to start the experiment. Place the gelatin\n');
input('Hit ENTER when you are ready\n');

for i_step = 1:n_step
    fprintf('\nPerforming step %d/%d: inserting %.2f mm\n', i_step, n_step, step_size);
    fopen(tcpip_client);
    fwrite(tcpip_client, [CMD_MOVE_DC typecast(step_size, 'uint8') typecast(insertion_speed, 'uint8') typecast(3.0, 'uint8') typecast(0.0, 'uint8')]);
    fread(tcpip_client, 1);
    fclose(tcpip_client);
    
    pause(1);
    aurora_device.updateSensorDataAll();
    aurora_error = aurora_device.getError();
    if(aurora_error < 10*maximum_aurora_error)
        trans = aurora_device.port_handles(1,1).trans;
        needle_x(i_step) = trans(1);
        needle_y(i_step) = trans(2);
        needle_z(i_step) = trans(3);
        needle_error(i_step) = aurora_device.port_handles(1,1).error;
        
        figure(plot_figure);
        subplot(3,1,1); plot(needle_x);
        subplot(3,1,2); plot(needle_y);
        subplot(3,1,3); plot(needle_z);
        pause(0.5);
    end
end

aurora_device.stopTracking();
delete(aurora_device);