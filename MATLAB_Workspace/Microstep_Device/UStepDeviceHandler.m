classdef UStepDeviceHandler < handle
    
    %
    %   This class is just a wrapper for communicating with the UStepDevice
    %   via TCP/IP
    %
    
    % Author: André Augusto Geraldes
    % Email: andregeraldes@lara.unb.br
    % August 2015; Last revision:
    
    % Constants
    properties (Constant)
        
        % TCP/IP parameters
        server_address = '169.254.0.2';
        server_port = 5555;
        tcpip_buffer_size = 7688;
        tcpip_timeout = 180;
        
        %
        pose_saving_delay = 1.0;
        
        % Communication protocol table (taken from the C++ code)
        CMD_OPEN_FRONT_GRIPPER	= 1;
        CMD_CLOSE_FRONT_GRIPPER	= 2;
        CMD_OPEN_BACK_GRIPPER	= 3;
        CMD_CLOSE_BACK_GRIPPER	= 4;
        CMD_ROTATE              = 5;
        CMD_TRANSLATE           = 6;
        CMD_MOVE_DC             = 7;
        CMD_MOVE_FORWARD        = 8;
        CMD_MOVE_BACKWARD       = 9;
        
        CMD_DONE                = 42;
        CMD_SHUT_DOWN           = 255;
        
        CMD_MOVE_MOTOR          = 101;  % DISABLED COMMAND
        CMD_MOVE_MOTOR_STEPS    = 102;  % DISABLED COMMAND
        CMD_SET_DIRECTION       = 103;  % DISABLED COMMAND
        CMD_SET_ENABLE          = 104;  % DISABLED COMMAND
        
        % Low level communication table (taken from the C++ code)
        % Used only by the disabled commands
        MOTOR_INSERTION             = 1;
        MOTOR_ROTATION              = 2;
        MOTOR_FRONT_GRIPPER         = 3;
        MOTOR_BACK_GRIPPER          = 4;
        
        DIRECTION_FORWARD           = 0;
        DIRECTION_BACKWARD          = 1;
        DIRECTION_CLOCKWISE         = 0;
        DIRECTION_COUNTER_CLOCKWISE = 1;
        DIRECTION_OPENING           = 1;
        DIRECTION_CLOSING           = 0;
        
        ENABLE_MOTOR                = 0;
        DISABLE_MOTOR               = 1;
        
    end
    
    properties (GetAccess = public, SetAccess = private)
        
        % TCP/IP client object
        tcpip_client;       
        
        % Number of steps (used to pre-allocate the pose and command vectors)
        n_step;             
        
        % Needle poses measured when moving forward and backward
        % These vectors should have n_step+1 elements for storing initial
        % and final pose
        needle_pose_fw;     
        needle_pose_bw; 
        
        % Set of commands sent for each DC motion - should have n_step
        % elements
        command_sent;       
        
        % Rotation angle in CW direction applied to the needle tip between
        % each pair of steps - should have n_step-1 elements
        interstep_rotation; 

    end
    
    
    % Public methods
    methods (Access = public)
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %             CONSTRUCTOR              %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = UStepDeviceHandler(n_step)
            
            % Configure the TCP/IP client object 
            obj.tcpip_client = tcpip(obj.server_address, obj.server_port,'NetworkRole','Client');
            set(obj.tcpip_client,'InputBufferSize', obj.tcpip_buffer_size);
            set(obj.tcpip_client,'Timeout', obj.tcpip_timeout);
            
            % Pre-alocate the vectors for storing the needle pose
            obj.n_step = n_step;

            pose_fw(1, n_step+1) = PoseMeasurement();
            pose_bw(1, n_step+1) = PoseMeasurement();
            obj.needle_pose_fw = pose_fw;
            obj.needle_pose_bw = pose_bw;          
              
            % Pre-alocate the vectors for storing all the DCcommands sent
            % to the device
            obj.interstep_rotation = zeros(1, n_step-1);
            command(1, n_step) = DCCommand();
            obj.command_sent = command;
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %    FUNCTIONS FOR SENDING COMMANDS    %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function rotateNeedleDegrees(obj, angle, preparation_rotation_speed)
            revolutions = angle / 360.0;
            fopen(obj.tcpip_client);
            fwrite(obj.tcpip_client, [obj.CMD_ROTATE typecast(revolutions, 'uint8') typecast(preparation_rotation_speed, 'uint8')]);
            fread(obj.tcpip_client, 1);
            fclose(obj.tcpip_client);
        end        
        
        function moveForward(obj, distance, speed)
            fopen(obj.tcpip_client);
            fwrite(obj.tcpip_client, [obj.CMD_MOVE_FORWARD typecast(distance, 'uint8') typecast(speed, 'uint8')]);
            fread(obj.tcpip_client, 1);
            fclose(obj.tcpip_client);
        end
           
        function moveBackward(obj, distance, speed)
            fopen(obj.tcpip_client);
            fwrite(obj.tcpip_client, [obj.CMD_MOVE_BACKWARD typecast(distance, 'uint8') typecast(speed, 'uint8')]);
            fread(obj.tcpip_client, 1);
            fclose(obj.tcpip_client);
        end
        
        function moveDC(obj, step_size, insertion_speed, rotation_speed, duty_cycle)
            fopen(obj.tcpip_client);
            fwrite(obj.tcpip_client, [obj.CMD_MOVE_DC typecast(step_size, 'uint8') typecast(insertion_speed, 'uint8') typecast(rotation_speed, 'uint8') typecast(duty_cycle, 'uint8')]);
            fread(obj.tcpip_client, 1);
            fclose(obj.tcpip_client);
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % FUNCTIONS FOR SAVING THE NEEDLE POSE %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
        function savePoseForward(obj, aurora_device, i_step)
            pause(obj.pose_saving_delay);
            aurora_device.updateSensorDataAll();
            if(aurora_device.isSensorAvailable())
                trans = aurora_device.port_handles(1,1).trans;
                rot = quatinv(aurora_device.port_handles(1,1).rot);
                error = aurora_device.port_handles(1,1).error;
                
                obj.needle_pose_fw(i_step).x = trans(1);
                obj.needle_pose_fw(i_step).y = trans(2);
                obj.needle_pose_fw(i_step).z = trans(3);
                obj.needle_pose_fw(i_step).orientation = rot;
                obj.needle_pose_fw(i_step).error = error;
            end  
        end
        
        function savePoseBackward(obj, aurora_device, i_step)
            pause(obj.pose_saving_delay);
            aurora_device.updateSensorDataAll();
            if(aurora_device.isSensorAvailable())
                trans = aurora_device.port_handles(1,1).trans;
                rot = quatinv(aurora_device.port_handles(1,1).rot);
                error = aurora_device.port_handles(1,1).error;
                
                obj.needle_pose_bw(i_step).x = trans(1);
                obj.needle_pose_bw(i_step).y = trans(2);
                obj.needle_pose_bw(i_step).z = trans(3);
                obj.needle_pose_bw(i_step).orientation = rot;
                obj.needle_pose_bw(i_step).error = error;
            end
        end
        
        function saveCommandsDC(obj, i_step, step_size, insertion_speed, rotation_speed, duty_cycle)
            obj.command_sent(i_step).step_size = step_size;
            obj.command_sent(i_step).insertion_speed = insertion_speed;
            obj.command_sent(i_step).rotation_speed = rotation_speed;
            obj.command_sent(i_step).duty_cycle = duty_cycle;
        end
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %      FUNCTIONS FOR PLOTING DATA      %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
        function [x_fw, x_bw] = plotNeedleX(obj)
            N = obj.n_step+1;
            x_fw = zeros(1, N);
            x_bw = zeros(1, N);
            for i_step = 1:N
                x_fw(i_step) = obj.needle_pose_fw(i_step).x;
                x_bw(i_step) = obj.needle_pose_bw(i_step).x;
            end
            
            hold on;
            plot(1:N, x_fw, 'r-');
            plot(1:N, x_bw, 'b-');
        end
        
        function [y_fw, y_bw] = plotNeedleY(obj)
            N = obj.n_step+1;
            y_fw = zeros(1, N);
            y_bw = zeros(1, N);
            for i_step = 1:N
                y_fw(i_step) = obj.needle_pose_fw(i_step).y;
                y_bw(i_step) = obj.needle_pose_bw(i_step).y;
            end
            
            hold on;
            plot(1:N, y_fw, 'r-');
            plot(1:N, y_bw, 'b-');
        end
        
       function [z_fw, z_bw] = plotNeedleZ(obj)
            N = obj.n_step+1;
            z_fw = zeros(1, N);
            z_bw = zeros(1, N);
            for i_step = 1:N
                z_fw(i_step) = obj.needle_pose_fw(i_step).z;
                z_bw(i_step) = obj.needle_pose_bw(i_step).z;
            end
            
            hold on;
            plot(1:N, z_fw, 'r-');
            plot(1:N, z_bw, 'b-');
        end        
        
        
    end
    
end