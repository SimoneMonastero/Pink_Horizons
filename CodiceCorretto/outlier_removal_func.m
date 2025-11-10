function [walking_percentage_CO, walking_percentage_FL, total_steps_CO, total_steps_FL, stride_time_CO, stride_time_FL] = ...
outlier_removal_func(walking_percentage_CO, walking_percentage_FL, total_steps_CO, total_steps_FL, stride_time_CO, stride_time_FL, nomiFile)

mask_pCO = isoutlier(walking_percentage_CO, "median");           % median is default method
mask_pFL = isoutlier(walking_percentage_FL, "median");
mask_stepCO = isoutlier(total_steps_CO, "median");
mask_stepFL = isoutlier(total_steps_FL, "median");
mask_strideCO = isoutlier(stride_time_CO, "median");
mask_strideFL = isoutlier(stride_time_FL, "median");

walking_percentage_CO = walking_percentage_CO .* ~mask_pCO;
walking_percentage_FL = walking_percentage_FL .* ~mask_pFL;
total_steps_CO = total_steps_CO .* ~mask_stepCO;
total_steps_FL = total_steps_FL .* ~mask_stepFL;
stride_time_CO = stride_time_CO .* ~mask_strideCO;
stride_time_FL = stride_time_FL .* ~mask_strideFL;


maskp = [mask_pCO, mask_pFL];
mask_step = [mask_stepCO, mask_stepFL];
mask_stride = [mask_strideCO, mask_strideFL];
disp('Outliers walking pergentage: ')
disp(nomiFile(maskp == 1))
disp('Outliers step count:')
disp(nomiFile(mask_step == 1))
disp('Outliers stride duration:')
disp(nomiFile(mask_stride == 1))
end