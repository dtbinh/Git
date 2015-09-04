close all;
clear all;
clc;

%% Global parameters

% Starting position
pre_insertion = 10.0;
starting_x =  276.70 + pre_insertion;
starting_y = -124.00;
starting_z = -153.00;

% Target position
target_x = 121.042099;
target_y = -8.055793;
target_z = 0.0;

% Result files for the Micro Step mode
MSD_file{1} = 'Results_150826_OL02_01.mat';
MSD_file{2} = 'Results_150826_OL02_02.mat';
MSD_file{3} = 'Results_150826_OL02_04.mat';
MSD_file{4} = 'Results_150826_OL02_05.mat';
MSD_file{5} = 'Results_150826_OL02_06.mat';
n_MSD_file = length(MSD_file);

% Result files for the 
TSD_file{1} = 'Results_150830_TSD01_01.mat';
TSD_file{2} = 'Results_150830_TSD01_02.mat';
TSD_file{3} = 'Results_150830_TSD01_03.mat';
TSD_file{4} = 'Results_150830_TSD01_04.mat';
TSD_file{5} = 'Results_150830_TSD01_05.mat';
n_TSD_file = length(TSD_file);


MSD_z = zeros(1, n_MSD_file);
TSD_z = zeros(1, n_TSD_file);

for i_MSD_file = 1:n_MSD_file
    load(MSD_file{i_MSD_file});
    analyzeOpenLoopExperimentResults
    MSD_z(i_MSD_file) = final_z;
end

for i_TSD_file = 1:n_TSD_file
    load(TSD_file{i_TSD_file});
    analyzeOpenLoopExperimentResults
    TSD_z(i_TSD_file) = final_z;
end


% %% Extract the final position of all MSD experiments
% 
% MSD_x = zeros(1, n_MSD_file);
% MSD_y = zeros(1, n_MSD_file);
% MSD_z = zeros(1, n_MSD_file);
% 
% for i_MSD_file = 1:n_MSD_file
%     
%     file_data = load(MSD_file{i_MSD_file});
%     
%     final_pose_fw = file_data.ustep_device.needle_pose_fw(end);
%     final_pose_bw = file_data.ustep_device.needle_pose_bw(end);
%     
%     MSD_x(i_MSD_file) = starting_x - mean([final_pose_fw.y final_pose_bw.y]);
%     MSD_y(i_MSD_file) = starting_y - mean([final_pose_fw.x final_pose_bw.x]);
%     MSD_z(i_MSD_file) = starting_z - mean([final_pose_fw.z final_pose_bw.z]);
% end
% 
% 
% 
% 
% %% Extract the final position of all TSD experiments
% 
% TSD_x = zeros(1, n_TSD_file);
% TSD_y = zeros(1, n_TSD_file);
% TSD_z = zeros(1, n_TSD_file);
% 
% for i_TSD_file = 1:n_TSD_file
%     
%     file_data = load(TSD_file{i_TSD_file});
%     
%     final_pose_fw = file_data.ustep_device.needle_pose_fw(end);
%     final_pose_bw = file_data.ustep_device.needle_pose_bw(end);
%     
%     TSD_x(i_TSD_file) = starting_x - mean([final_pose_fw.y final_pose_bw.y]);
%     TSD_y(i_TSD_file) = starting_y - mean([final_pose_fw.x final_pose_bw.x]);
%     TSD_z(i_TSD_file) = starting_z - mean([final_pose_fw.z final_pose_bw.z]);
% end
% 
% %% Calculate the mean and the standard deviation of the experiments
% 
% % MSD_x_error = (starting_x - MSD_x) - target_x;
% % MSD_y_error = (starting_y - MSD_y) - target_y;
% % MSD_z_error = (starting_z - MSD_z) - target_z;
% 
% MSD_x_mean = mean(MSD_x)
% MSD_y_mean = mean(MSD_y)
% MSD_z_mean = mean(MSD_z)
% 
% MSD_x_std = std(MSD_x)
% MSD_y_std = std(MSD_y)
% MSD_z_std = std(MSD_z)
% 
% TSD_x_mean = mean(TSD_x)
% TSD_y_mean = mean(TSD_y)
% TSD_z_mean = mean(TSD_z)
% 
% TSD_x_std = std(TSD_x)
% TSD_y_std = std(TSD_y)
% TSD_z_std = std(TSD_z)
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
