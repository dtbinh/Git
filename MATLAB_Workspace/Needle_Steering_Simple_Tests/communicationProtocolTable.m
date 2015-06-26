%% Communication protocol table (taken from the C++ code)

global CMD_MOVE_MOTOR;
global CMD_SET_DIRECTION;
global CMD_SHUT_DOWN;

% Commands exchanged with the Matlab client
CMD_MOVE_MOTOR    = 1;
CMD_SET_DIRECTION = 2;
CMD_SHUT_DOWN     = 255;

% Numeric code for referring to each of the motors
MOTOR_INSERTION     = 1;
MOTOR_ROTATION      = 2;
MOTOR_FRONT_GRIPPER = 3;
MOTOR_BACK_GRIPPER  = 4;

% Directions that must be set to the motors for moving the end effector correctly
DIRECTION_FORWARD           = 0;
DIRECTION_BACKWARD          = 1;
DIRECTION_CLOCKWISE         = 0;
DIRECTION_COUNTER_CLOCKWISE = 1;
DIRECTION_OPENING           = 1;
DIRECTION_CLOSING           = 0;