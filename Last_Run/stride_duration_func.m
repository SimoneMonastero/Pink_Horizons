function  [stride_duration]=stride_duration_func(aAP,Fs)
   % Function to calculate stride duration from step frequency
   
   [paAP,f]=pwelch(aAP, [],[],[], Fs);
   paAP=paAP(f>0.5 & f<3);
   f=f(f>0.5 & f<3);
   [~, ind]=max(paAP);
   FSs=f(ind);

   step_period=1/FSs;  
   stride_duration = 2*step_period;  
   fprintf('stride duration = %f s \n',stride_duration)

end

