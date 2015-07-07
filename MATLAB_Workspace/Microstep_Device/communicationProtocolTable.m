%% Communication protocol table (taken from the C++ code)

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

% Commands exchanged with the Matlab client
CMD_MOVE_MOTOR          = 1;
CMD_MOVE_MOTOR_STEPS    = 2;
CMD_MOVE_DC             = 3;
CMD_MOVE_BACK           = 4;
CMD_MOVE_SPIN           = 5;
CMD_SET_DIRECTION       = 6;
CMD_SET_ENABLE          = 7;
CMD_OPEN_FRONT_GRIPPER 	= 8;	
CMD_CLOSE_FRONT_GRIPPER = 9;	
CMD_OPEN_BACK_GRIPPER	= 10;	
CMD_CLOSE_BACK_GRIPPER  = 11;
CMD_SHUT_DOWN           = 255;

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

% Values that must be set to the enable ports for enabling/disabling the motors
ENABLE_MOTOR  = 0;
DISABLE_MOTOR = 1;