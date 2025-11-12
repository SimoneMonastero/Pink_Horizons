function  [stride_duration]=stride_duration_func(FSs)
   % Function to calculate stride duration from step frequency
   
    step_period=1/FSs;  
    stride_duration = 2*step_period;  
    fprintf('stride duration = %d \n',stride_duration)

end

