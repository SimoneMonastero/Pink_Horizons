function  [stride_duration]=stride_duration_func(aAP,Fs)
   % Function to calculate stride duration from step frequency
   
    [paAP,f]=pwelch(aAP, 512,[],[], Fs);    % 512-sample window from the article (Weiss et al.) 
    % Segmenting between 1Hz and 3Hz (frequencies of interest)
    paAP=paAP(f>1 & f<3);
    f=f(f>1 & f<3);
    % Main peak identification
    [peak, ind]=max(paAP);
    FSs=f(ind); % Step frequency
    
    % Computation of the stride period (duration)
    step_period=1/FSs;  
    stride_duration = 2*step_period;  
    fprintf('Stride duration = %f s \n',stride_duration)

end