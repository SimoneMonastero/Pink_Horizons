function  [stride_duration, width]=stride_durationANDwidth_func(aAP,Fs)
   % Function to calculate stride duration from step frequency
   
    [paAP,f]=pwelch(aAP, [],[],[], Fs);
    paAP=paAP(f>0.5 & f<3);
    f=f(f>0.5 & f<3);
    [~, ind]=max(paAP);
    FSs=f(ind);
    
    half_search = paAP - peak/2;
    mask = sign(half_search);
    changes = diff(mask);
    xleft = find(abs(changes(1:ind-1)) == 2, 1, "last");
    xright = find(abs(changes(ind:end)) == 2, 1, "first") + ind - 1;

    [~,x] = min(abs( half_search(xleft:xleft+1) ));
    xleft = x + xleft - 1;
    fleft = f(xleft);
%     yleft = paAP(xleft);
    [~,x] = min(abs( half_search(xright:xright+1) ));
    xright = x + xright -1;
    fright = f(xright);
%     yright = paAP(xright);

    step_period=1/FSs;  
    stride_duration = 2*step_period;  
    fprintf('stride duration = %f s \n',stride_duration)
    width = fright - fleft;
    fprintf('Width = %f Hz \n',width)

%     plot(f,paAP,'r', fleft,yleft,'bo', fright,yright,'b*')
%     xline(f(ind))   
end