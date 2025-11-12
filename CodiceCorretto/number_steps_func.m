function [total_steps, FSs]=number_steps_func(B_lp,A_lp,Fs,window,min_bout_duration_sec,bout_starts,bout_ends,bout_durations,aAP,aAP_filt)
   % Function to compute the total number of steps from antero-posterior acceleration

    total_steps = 0; % Initialize total steps counter
    % Apply low-pass filter
    aAP_filt=filtfilt(B_lp,A_lp,aAP_filt);
    
    % Keep only bouts longer than minimum duration
    bout_starts=bout_starts(bout_durations>min_bout_duration_sec);
    bout_ends=bout_ends(bout_durations>min_bout_duration_sec);
    bout_durations=bout_durations(bout_durations>min_bout_duration_sec);

    % Estimate dominant step frequency from PSD
    [paAP,f]=pwelch(aAP, [],[],[], Fs);
    paAP=paAP(f>0.5 & f<3);
    f=f(f>0.5 & f<3);
    [peak, ind]=max(paAP);
    FSs=f(ind); % Dominant step frequency

     % Minimum distance between peaks in samples (allowing 10% physiological variability)
    min_peak_distance=floor(Fs/FSs*0.9); % 10% variability due to physiological variability

    % Count steps in each bout
    for k=1:length(bout_durations)
        start_sample= (bout_starts(k)-1)*window +1;
        end_sample= (bout_ends(k)*window);
        signal_bout=aAP_filt(start_sample:end_sample);
        % min_peak_height=max(signal_bout)/2;

        % Minimum peak height set to 75th percentile of the bout signal
        min_peak_height = prctile(signal_bout, 75);

        % Detect peaks corresponding to steps
        [pks,loks]=findpeaks(signal_bout,'MinPeakDistance',min_peak_distance,'MinPeakHeight',min_peak_height);
        %[pks,loks]=findpeaks(signal_bout,'MinPeakHeight',min_peak_height);
        
        steps_in_bout=length(pks);
        total_steps=total_steps+steps_in_bout;
    end
        fprintf('total steps = %d \n',total_steps)
end


