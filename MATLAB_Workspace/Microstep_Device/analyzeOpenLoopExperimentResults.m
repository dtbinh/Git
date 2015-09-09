%% Global parameters

% close all
% clc

% Starting position
starting_x =  282.00;
% starting_y = -120.00;
starting_y = -121.00;
starting_z = -142.50;


%% Process the experiment results and extract the performed trajectory

processExperimentResults

x_pos_measure = zeros(1, n_step+1);
y_pos_measure = zeros(1, n_step+1);
z_pos_measure = zeros(1, n_step+1);

x_aurora = zeros(1, n_step+1);
y_aurora = zeros(1, n_step+1);
z_aurora = zeros(1, n_step+1);

valid_pose_fw = needle_x_fw .^2 + needle_y_fw .^2 + needle_z_fw .^2;
valid_pose_bw = needle_x_bw .^2 + needle_y_bw .^2 + needle_z_bw .^2;
[~, c] = find(valid_pose_bw > 0);
first_valid_pose = c(1);
[~, c] = find(valid_pose_fw > 0);
first_valid_pose_fw = c(1);


for i_step = first_valid_pose:first_valid_pose_fw-1
    x_pos_measure(i_step) = starting_x - needle_y_bw(i_step);
    y_pos_measure(i_step) = -starting_y + needle_x_bw(i_step);
    z_pos_measure(i_step) = starting_z - needle_z_bw(i_step);
    
    x_aurora(i_step) = needle_y_bw(i_step);
    y_aurora(i_step) = needle_x_bw(i_step);
    z_aurora(i_step) = needle_z_bw(i_step);
end
for i_step = first_valid_pose_fw:n_step+1
    x_pos_measure(i_step) = starting_x - mean([needle_y_fw(i_step) needle_y_bw(i_step)]);
    y_pos_measure(i_step) = -starting_y + mean([needle_x_fw(i_step) needle_x_bw(i_step)]);
    z_pos_measure(i_step) = starting_z - mean([needle_z_fw(i_step) needle_z_bw(i_step)]);  
    
    x_aurora(i_step) = mean([needle_y_fw(i_step) needle_y_bw(i_step)]);
    y_aurora(i_step) = mean([needle_x_fw(i_step) needle_x_bw(i_step)]);
    z_aurora(i_step) = mean([needle_z_fw(i_step) needle_z_bw(i_step)]);  
end

%% Reproduce and plot the simulated trajectory

% Lets supose the EM sensor is 8 mm far from the needle tip
% Lets also represent the pre-insertion as an additional 8 mm step

dsensor = 14;
pre_insertion = 10.0;

step_size_tip      = [       pre_insertion    8    8    8    8    8    8    8    8    8    8    8    8    8    8   ];
duty_cycle_tip     = [       0.99             0.00 0.00 0.00 0.25 0.50 0.25 0.00 0.00 0.00 0.00 0.00 0.50 0.50 0.00];
rotation_steps_tip = [       0                0    0    0    0    1    0    0    0    0    0    0    0    0    0   ];

step_size_em       = [dsensor pre_insertion   8    8    8    8    8    8    8    8    8    8    8    8    2        ];    
duty_cycle_em      = [0.99999 0.99            0.00 0.00 0.00 0.25 0.50 0.25 0.00 0.00 0.00 0.00 0.00 0.50 0.50     ]; 
rotation_steps_em  = [0       0               0    0    0    0    1    0    0    0    0    0    0    0    0        ];    

[px_tip_simulated, py_tip_simulated, px_tip_steps, py_tip_steps] = simulateDutyCyclePlanarTrajectory(step_size_tip, duty_cycle_tip, rotation_steps_tip, 0.0);
[px_em_simulated , py_em_simulated , px_em_steps , py_em_steps ] = simulateDutyCyclePlanarTrajectory(step_size_em, duty_cycle_em, rotation_steps_em, 0.0);

% rx = range(px_tip_simulated);
% ry = range(py_tip_simulated);
% rmax = 1.2 * max(rx, ry);
% figure;
% plot(-py_tip_simulated, -px_tip_simulated, 'b-');
% xlim([-rmax/2 rmax/2]);
% ylim([-1.1*rmax 0.1*rmax]);

% hold on;
% plot(-py_em_simulated, -px_em_simulated+dsensor, 'b-');
% plot(-y_pos_measure(first_valid_pose:end), -x_pos_measure(first_valid_pose:end)+dsensor, 'r-');

% I = imread('TSD_01 (cropped).JPG');
% figure
% imshow(I);
% hold on;
% x_offset = 330;
% y_offset = 70;
% scale = 12;
% plot(x_offset - scale*py_tip                     , y_offset + scale*px_tip, 'g-');
% plot(x_offset - scale*py_em                      , y_offset + scale*(px_em-dsensor), 'b-');
% plot(x_offset - scale*y_pos(first_valid_pose:end), y_offset + scale*(x_pos(first_valid_pose:end)-dsensor), 'r-');

% I = imread('MSD_02 (cropped).JPG');
% figure
% imshow(I);
% hold on;
% x_offset = 520;
% y_offset = 100;
% scale = 12;
% plot(x_offset - scale*py_tip_simulated           , y_offset + scale*px_tip_simulated, 'b-');
% % plot(x_offset - scale*py_em_simulated            , y_offset + scale*(px_em_simulated-dsensor), 'b-');
% % plot(x_offset - scale*y_pos_measure(first_valid_pose:end), y_offset + scale*(x_pos_measure(first_valid_pose:end)-dsensor), 'g-');

% I = imread('MSD_03 (cropped).JPG');
% figure
% imshow(I);
% hold on;
% x_offset = 490;
% y_offset = 70;
% scale = 12;
% plot(x_offset - scale*py_tip_simulated           , y_offset + scale*px_tip_simulated, 'b-', 'LineWidth', 3);
% % plot(x_offset - scale*py_em_simulated            , y_offset + scale*(px_em_simulated-dsensor), 'b-');
% % plot(x_offset - scale*y_pos_measure(first_valid_pose:end), y_offset + scale*(x_pos_measure(first_valid_pose:end)-dsensor), 'g-');
% set(gca,'position',[0 0 1 1],'units','normalized')

I = imread('TSD_04 (cropped).JPG');
figure
imshow(I);
hold on;
x_offset = 470;
y_offset = 90;
scale = 12;
plot(x_offset - scale*py_tip_simulated           , y_offset + scale*px_tip_simulated, 'b-', 'LineWidth', 3);
plot(x_offset - scale*py_tip_steps(2:end)        , y_offset + scale*px_tip_steps(2:end), 'r*');
% plot(x_offset - scale*py_em_simulated            , y_offset + scale*(px_em_simulated-dsensor), 'b-');
% plot(x_offset - scale*y_pos_measure(first_valid_pose:end), y_offset + scale*(x_pos_measure(first_valid_pose:end)-dsensor), 'g-');
set(gca,'position',[0 0 1 1],'units','normalized')

%% Measure the experiment performance

error_x = x_pos_measure(end) - px_em_simulated(end);
error_y = y_pos_measure(end) - py_em_simulated(end);
error_z = z_pos_measure(end);
error_total = sqrt(error_x^2 + error_y^2 + error_z^2);

delta_z = z_pos_measure(first_valid_pose) - z_pos_measure(end);

if(exist('angle', 'var') == 0)
    delta_theta = -180 - mean([needle_correction_angle_fw(end) needle_correction_angle_fw(end)]);
else
    delta_theta = 999;
end

