% Numeric code for referring to each of the motors
MOTOR_INSERTION     = 1;
MOTOR_ROTATION      = 2;
MOTOR_FRONT_GRIPPER = 3;
MOTOR_BACK_GRIPPER  = 4;

% Commands exchanged with the Matlab client
CMD_MOVE_MOTOR = 1;
CMD_SHUT_DOWN  = 255;






CMD = 1;
motor = 1;
displacement = 150;
speed = 0.2;
data_bytes = typecast(data, 'uint8')

fwrite(tcpipClient, [CMD motor typecast(displacement, 'uint8') typecast(speed, 'uint8')]);

pause(1);
fwrite(tcpipClient, 255);

fclose(tcpipClient);