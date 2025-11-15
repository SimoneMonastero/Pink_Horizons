function output_func(walking_percentage_CO, walking_percentage_FL, total_steps_CO, total_steps_FL, ...
    stride_time_CO, stride_time_FL, valid_bouts_CO, valid_bouts_FL, ...
    avg_range_CO, avg_range_FL, total_minutes_CO, total_minutes_FL)

% Function to display summary statistics for walking metrics

    % Walking percentage
    mean_walkingCO=mean(walking_percentage_CO);
    std_walkingCO=std(walking_percentage_CO);
    mean_walkingFL=mean(walking_percentage_FL);
    std_walkingFL=std(walking_percentage_FL);
    fprintf("mean walking percentage controls: %f +- %f %% \n",mean_walkingCO,std_walkingCO)
    fprintf("mean walking percentage fallers: %f +- %f %% \n",mean_walkingFL,std_walkingFL)

    % Total steps
    mean_stepsCO=mean(total_steps_CO);
    std_stepsCO=std(total_steps_CO);
    mean_stepsFL=mean(total_steps_FL);
    std_stepsFL=std(total_steps_FL);
    fprintf("mean number of steps controls: %f +- %f steps \n",mean_stepsCO,std_stepsCO)
    fprintf("mean number of steps fallers: %f +- %f steps \n",mean_stepsFL,std_stepsFL)

    % Stride duration
    mean_stridetimeCO=mean(stride_time_CO);
    std_stridetimeCO=std(stride_time_CO);
    mean_sridetimeFL=mean(stride_time_FL);
    std_stridetimeFL=std(stride_time_FL);
    fprintf("mean stride time controls: %f +- %f seconds \n",mean_stridetimeCO,std_stridetimeCO)
    fprintf("mean stride time fallers: %f +- %f seconds \n",mean_sridetimeFL,std_stridetimeFL)

    % Valid bouts
    mean_valid_bouts_CO = mean(valid_bouts_CO);
    std_valid_bouts_CO = std(valid_bouts_CO);
    mean_valid_bouts_FL = mean(valid_bouts_FL);
    std_valid_bouts_FL = std(valid_bouts_FL);
    fprintf("mean valid bouts controls: %f +- %f bouts \n", mean_valid_bouts_CO, std_valid_bouts_CO)
    fprintf("mean valid bouts fallers: %f +- %f bouts \n", mean_valid_bouts_FL, std_valid_bouts_FL)

    % Average range
    mean_avg_range_CO = mean(avg_range_CO);
    std_avg_range_CO = std(avg_range_CO);
    mean_avg_range_FL = mean(avg_range_FL);
    std_avg_range_FL = std(avg_range_FL);
    fprintf("mean average range controls: %f +- %f g \n", mean_avg_range_CO, std_avg_range_CO)
    fprintf("mean average range fallers: %f +- %f g \n", mean_avg_range_FL, std_avg_range_FL)

    % Total minutes
    mean_minutesCO = mean(total_minutes_CO);
    std_minutesCO = std(total_minutes_CO);
    mean_minutesFL = mean(total_minutes_FL);
    std_minutesFL = std(total_minutes_FL);
    fprintf("mean total minutes controls: %f +- %f minutes \n", mean_minutesCO, std_minutesCO)
    fprintf("mean total minutes fallers: %f +- %f minutes \n", mean_minutesFL, std_minutesFL)

end

