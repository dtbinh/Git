classdef AuroraDriver
    
    %
    %   CLASS DESCRIPTION
    %
    
    % Author: André Augusto Geraldes
    % Email: andregeraldes@lara.unb.br
    % July 2015; Last revision:
    
    
    % PENDING LIST
    
    % Add other parameters to the serial port
    % Convert format 2 commands to format 1 with CRC
    % Check CRC from read messages
    
    % Implement public methods for wraping the API functions
    % These methods must set the parameters correctly and treat the
    % obtained reply.
    % These methods should comprise: init, start, stop, read, etc
    
    
    % Read-only member variables
    properties (GetAccess = public, SetAccess = private)
        serial_port;        % Serial port object  
    end
    
    
    % Public methods
    methods (Access = public)
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %             CONSTRUCTOR              %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = AuroraDriver(serial_port)
            obj.serial_port = serial(serial_port);
            obj.serial_port.Terminator = 'CR';
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %        SERIAL COMM FUNCTIONS         %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function openSerialPort(obj)
            if(strcmp(obj.serial_port.Status, 'closed'))
                fopen(obj.serial_port);
            end
        end
        
        function closeSerialPort(obj)
            if(strcmp(obj.serial_port.Status, 'open'))
                fclose(obj.serial_port);
            end
        end
        
    end
    
    
    % Private methods
    methods (Access = private)

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %    SERIAL COMM AUXILIAR FUNCTIONS    %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % Wrapper funtion for sending commands over the serial port
        % The parameter is a string containing an entire command in
        % format 2 (without the CRC)
        function sendCommand(obj, command)
            % Format 1 - Add CRC
            % PENDING
            % Format 2 - Send without CRC
            fprintf(obj.serial_port, command);
        end
        
        function reply = sendCommandAndGetReply(obj, command)
            sendCommand(obj, command)
            reply = fgetl(obj.serial_port);
        end           
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %            API COMMANDS              %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % Implement the serial communication for all the API commands.
        % Since all these functions are private, the arguments are never
        % verified. They are assumed to be already verified by the caller.
        
        % The replies are returned integrally and are supposed to be
        % treated by the caller function.
        
        
        % OBS: The API Guide tells me to add a CR in the end of the
        % command, but I realized this does not need to be added. Maybe
        % the Matlab is adding it automatically
        
        
        %%%%%%%%%%%%%%% All mode commands %%%%%%%%%%%%%%%
        
        function reply = APIREV(obj)
            reply = sendCommandAndGetReply(obj, 'APIREV ');
        end
        
        function reply = BEEP(obj, n_beep)
            reply = sendCommandAndGetReply(obj, sprintf('BEEP %s', n_beep));
        end
        
        function [reply_body, error_checking] = BX(obj, reply_option)
            sendCommand(obj, sprintf('BX %s', reply_option));
            
            start_sequence = fread(obj.serial_port, 1, 'uint16');
            reply_length = fread(obj.serial_port, 1, 'uint16');
            header_CRC = fread(obj.serial_port, 1, 'uint16');
            reply_body = fread(obj.serial_port, reply_length, 'uint8');
            crc = fread(obj.serial_port, 1, 'uint16');
            
            % OBS: The start sequence and both CRC are being returned in
            % integer format. They can be visualized as hex using 'dec2hex'
            error_checking = [start_sequence; header_CRC; crc];
        end
        
        function reply = COMM(obj, baud_rate, data_bits, parity, stop_bits, hardware_handshaking)
            reply = sendCommandAndGetReply(obj, sprintf('COMM %s%s%s%s%s', baud_rate, data_bits, parity, stop_bits, hardware_handshaking));
        end
        
        function reply = ECHO(obj, message)
            reply = sendCommandAndGetReply(obj, sprintf('ECHO %s', message));
        end
        
        function reply = GET(obj, user_parameter_name)
            reply = sendCommandAndGetReply(obj, sprintf('GET %s', user_parameter_name));
        end
        
        function reply = INIT(obj)
            reply = sendCommandAndGetReply(obj, 'INIT ');
        end
        
        function reply = LED(obj, port_handle, led_number, state)
            reply = sendCommandAndGetReply(obj, sprintf('LED %s%s%s', port_handle, led_number, state));
        end
        
        function reply = PDIS(obj, port_handle)
            reply = sendCommandAndGetReply(obj, sprintf('PDIS %s', port_handle));
        end
        
        function reply = PENA(obj, port_handle, tool_tracking_priority)
            reply = sendCommandAndGetReply(obj, sprintf('PENA %s%s', port_handle, tool_tracking_priority));
        end
        
        function reply = PHF(obj, port_handle)
            reply = sendCommandAndGetReply(obj, sprintf('PHF %s', port_handle));
        end
        
        function reply = PHINF(obj, port_handle, reply_option)
            reply = sendCommandAndGetReply(obj, sprintf('PHINF %s%s', port_handle, reply_option));
        end
        
        function reply = PHSR(obj, reply_option)
            reply = sendCommandAndGetReply(obj, sprintf('PHSR %s', reply_option));
        end
        
        function reply = PINIT(obj, port_handle)
            reply = sendCommandAndGetReply(obj, sprintf('PINIT %s', port_handle));
        end
        
        function reply = PPRD(obj, port_handle, srom_device_address)
            reply = sendCommandAndGetReply(obj, sprintf('PPRD %s%s', port_handle, srom_device_address));
        end
        
        function reply = PPWR(obj, port_handle, srom_device_address, srom_device_data)
            reply = sendCommandAndGetReply(obj, sprintf('PPWR %s%s%s', port_handle, srom_device_address, srom_device_data));
        end
        
        function reply = PSEL(obj, port_handle, tool_srom_device_id)
            reply = sendCommandAndGetReply(obj, sprintf('PSEL %s%s', port_handle, tool_srom_device_id));
        end
        
        function reply = PSOUT(obj, port_handle, gpio_1_state, gpio_2_state, gpio_3_state)
            reply = sendCommandAndGetReply(obj, sprintf('PSOUT %s%s%s%s', port_handle, gpio_1_state, gpio_2_state, gpio_3_state));
        end
        
        function reply = PSRCH(obj, port_handle)
            reply = sendCommandAndGetReply(obj, sprintf('PSRCH %s', port_handle));
        end
        
        function reply = PURD(obj, port_handle, user_srom_device_address)
            reply = sendCommandAndGetReply(obj, sprintf('PURD %s%s', port_handle, user_srom_device_address));
        end
        
        function reply = PUWR(obj, port_handle, user_srom_device_address, user_srom_device_data)
            reply = sendCommandAndGetReply(obj, sprintf('PUWR %s%s%s', port_handle, user_srom_device_address, user_srom_device_data));
        end
        
        function reply = PVWR(obj, port_handle, start_address, tool_definition_data)
            reply = sendCommandAndGetReply(obj, sprintf('PUWR %s%s%s', port_handle, start_address, tool_definition_data));
        end
        
        function reply = RESET(obj, reset_option)
            reply = sendCommandAndGetReply(obj, sprintf('RESET %s', reset_option));
        end
        
        function reply = SFLIST(obj, reply_option)
            reply = sendCommandAndGetReply(obj, sprintf('SFLIST %s', reply_option));
        end
        
        function reply = TSTART(obj, reply_option)
            reply = sendCommandAndGetReply(obj, sprintf('TSTART %s', reply_option));
        end
        
        function reply = TSTOP(obj)
            reply = sendCommandAndGetReply(obj, 'TSTOP ');
        end
        
        function reply = TTCFG(obj, port_handle)
            reply = sendCommandAndGetReply(obj, sprintf('TTCFG %s', port_handle));
        end
        
        function reply = TX(obj, reply_option)
            reply = sendCommandAndGetReply(obj, sprintf('TX %s', reply_option));
        end
        
        function reply = VER(obj, reply_option)
            reply = sendCommandAndGetReply(obj, sprintf('VER %s', reply_option));
        end
        
        function reply = VSEL(obj, volume_number)
            reply = sendCommandAndGetReply(obj, sprintf('VSEL %s', volume_number));
        end
         
    end
    
  
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %             DESTRUCTOR               %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    methods
        function delete(obj)
            delete(obj.serial_port);
        end
    end
    
end