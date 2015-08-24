% Script for processing the results of an experiment
% It assumes the experiment data will be loaded into the workspace

needle_correction_angle_fw = zeros(1, n_step+1);
needle_correction_angle_bw = zeros(1, n_step+1);

measurement_error_fw = zeros(1, n_step+1);
measurement_error_bw = zeros(1, n_step+1);

for i_step = 1:n_step+1
    quaternion_fw = ustep_device.needle_pose_fw(i_step).orientation;
    if(quatnorm(quaternion_fw) == 0)
        needle_correction_angle_fw(i_step) = 999;
    else
        needle_correction_angle_fw(i_step) = measureNeedleCorrectionAngle(quaternion_fw, needle_N0);
    end
    
    quaternion_bw = ustep_device.needle_pose_bw(i_step).orientation;
    if(quatnorm(quaternion_bw) == 0)
        needle_correction_angle_bw(i_step) = 999;
    else
        needle_correction_angle_bw(i_step) = measureNeedleCorrectionAngle(quaternion_bw, needle_N0);
    end
    
    measurement_error_fw(i_step) = ustep_device.needle_pose_fw(i_step).error;
    measurement_error_bw(i_step) = ustep_device.needle_pose_bw(i_step).error;
    
end

radius_of_curvature_fw = zeros(n_step);
radius_of_curvature_bw = zeros(n_step);

for i_step = 1:n_step
    for j_step = i_step:n_step
        radius_of_curvature_fw(i_step, j_step) = measureNeedleCurvature(ustep_device.needle_pose_fw(i_step), ustep_device.needle_pose_fw(j_step+1));
        radius_of_curvature_bw(i_step, j_step) = measureNeedleCurvature(ustep_device.needle_pose_bw(i_step), ustep_device.needle_pose_bw(j_step+1));
    end
end

