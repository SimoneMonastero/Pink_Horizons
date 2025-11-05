function     [walking_percentage_CO, walking_percentage_FL, total_steps_CO, total_steps_FL, stride_time_CO, stride_time_FL]=sorting_func(record_name, p_walking, total_steps, stride_duration, walking_percentage_CO, walking_percentage_FL, total_steps_CO, total_steps_FL, stride_time_CO, stride_time_FL)
    %    definition of the function    
    record_name = record_name(6:end);
    if record_name(end-4) == 'C'
        walking_percentage_CO = [walking_percentage_CO, p_walking]; % Store the percentage of walking for current file
        total_steps_CO=[total_steps_CO, total_steps];
        stride_time_CO=[stride_time_CO, stride_duration];
    else
        walking_percentage_FL = [walking_percentage_FL, p_walking]; % Store the percentage of walking for other files
        total_steps_FL=[total_steps_FL, total_steps];
        stride_time_FL=[stride_time_FL, stride_duration];
    end
end
