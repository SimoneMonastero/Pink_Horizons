function [total_steps]=number_steps(B_lp,A_lp,Fs,window,min_bout_duration_sec,bout_starts,bout_ends,bout_durations,aAP,aAP_filt)
    total_steps = 0; % Initialize total steps counter
    aAP_filt=filtfilt(B_lp,A_lp,aAP_filt);
    bout_starts=bout_starts(bout_durations>min_bout_duration_sec);
    bout_ends=bout_ends(bout_durations>min_bout_duration_sec);
    bout_durations=bout_durations(bout_durations>min_bout_duration_sec);
    
    [paAP,f]=pwelch(aAP, [],[],[], Fs);
    paAP=paAP(f>0.5 & f<3);
    f=f(f>0.5 & f<3);
    [peak, ind]=max(paAP);
    FSs=f(ind);
    min_peak_distance=floor(Fs/FSs*0.9); % 10% variability due to physiological variability

    for k=1:length(bout_durations)
        start_sample= (bout_starts(k)-1)*window +1;
        end_sample= (bout_ends(k)*window);
        signal_bout=aAP_filt(start_sample:end_sample);
        min_peak_height=max(signal_bout)/2;
        [pks,loks]=findpeaks(signal_bout,'MinPeakDistance',min_peak_distance,'MinPeakHeight',min_peak_height);
        %[pks,loks]=findpeaks(signal_bout,'MinPeakHeight',min_peak_height);
        steps_in_bout=length(pks);
        total_steps=total_steps+steps_in_bout;
    end
        
    fprintf('total steps = %d \n',total_steps)
end

