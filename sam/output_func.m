
function output_func(walking_percentage_CO, walking_percentage_FL, total_steps_CO, total_steps_FL, stride_time_CO, stride_time_FL)

    mean_walkingCO=mean(walking_percentage_CO);
    std_walkingCO=std(walking_percentage_CO);
    mean_walkingFL=mean(walking_percentage_FL);
    std_walkingFL=std(walking_percentage_FL);
    fprintf("mean walking percentage controls: %f +- %f m/s \n",mean_walkingCO,std_walkingCO)
    fprintf("mean walking percentage fallers: %f +- %f m/s \n",mean_walkingFL,std_walkingFL)
    
    mean_stepsCO=mean(total_steps_CO);
    std_stepsCO=std(total_steps_CO);
    mean_stepsFL=mean(total_steps_FL);
    std_stepsFL=std(total_steps_FL);
    fprintf("mean number of steps controls: %f +- %f steps \n",mean_stepsCO,std_stepsCO)
    fprintf("mean number of steps fallers: %f +- %f steps \n",mean_stepsFL,std_stepsFL)
    
    mean_stridetimeCO=mean(stride_time_CO);
    std_stridetimeCO=std(stride_time_CO);
    mean_sridetimeFL=mean(stride_time_FL);
    std_stridetimeFL=std(stride_time_FL);
    fprintf("mean stride time controls: %f +- %f seconds \n",mean_stridetimeCO,std_stridetimeCO)
    fprintf("mean stride time fallers: %f +- %f seconds \n",mean_sridetimeFL,std_stridetimeFL)
    
end