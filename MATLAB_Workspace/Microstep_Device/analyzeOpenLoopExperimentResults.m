%% Global parameters

% Starting position
pre_insertion = 10.0;
starting_x =  276.70 + pre_insertion;
starting_y = -124.00;
% starting_z = -153.00;
starting_z = -144.00;


%% Process the experiment results and extract the performed trajectory

processExperimentResults

x_pos = zeros(1, n_step);
y_pos = zeros(1, n_step);
z_pos = zeros(1, n_step);

valid_pose_fw = needle_x_fw .^2 + needle_y_fw .^2 + needle_z_fw .^2;
valid_pose_bw = needle_x_bw .^2 + needle_y_bw .^2 + needle_z_bw .^2;
[~, c] = find(valid_pose_bw > 0);
first_valid_pose = c(1);
[~, c] = find(valid_pose_fw > 0);
first_valid_pose_fw = c(1);


for i_step = first_valid_pose:first_valid_pose_fw-1
    x_pos(i_step) = starting_x - needle_y_bw(i_step);
    y_pos(i_step) = starting_y - needle_x_bw(i_step);
    z_pos(i_step) = starting_z - needle_z_bw(i_step);
end
for i_step = first_valid_pose_fw:n_step
    x_pos(i_step) = starting_x - mean([needle_y_fw(i_step) needle_y_bw(i_step)]);
    y_pos(i_step) = starting_y - mean([needle_x_fw(i_step) needle_x_bw(i_step)]);
    z_pos(i_step) = starting_z - mean([needle_z_fw(i_step) needle_z_bw(i_step)]);    
end

%% Reproduce and plot the simulated trajectory

duty_cycle        = [0.00 0.00 0.00 0.25 0.50 0.25 0.00 0.00 0.00 0.00 0.00 0.50 0.50 0.00];
rotation_steps    = [0    0    0    0    1    0    0    0    0    0    0    0    0    0];
[px, py] = simulateDutyCyclePlanarTrajectory(duty_cycle, rotation_steps, pre_insertion);
[px_nop, py_nop] = simulateDutyCyclePlanarTrajectory(duty_cycle, rotation_steps, 0.0);

rx = range(px);
ry = range(py);
rmax = 1.1 * max(rx, ry);

figure;
plot(py, -px);
xlim([-rmax/2 rmax/2]);
ylim([-rmax 0]);

hold on;
plot(py_nop, -px_nop, 'g-');
plot(-y_pos(first_valid_pose:end), -x_pos(first_valid_pose:end), 'r-');

final_z = z_pos(end)