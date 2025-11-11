function [total_steps, StrideTime]=number_steps_func_wavelet(B_lp,A_lp,Fs,window,min_bout_duration_sec,bout_starts,bout_ends,bout_durations,aV,aV_filt)
    %    definition of the function
    total_steps = 0; % Initialize total steps counter
    aV_filt=filtfilt(B_lp,A_lp,aV);
    bout_starts=bout_starts(bout_durations>min_bout_duration_sec);
    bout_ends=bout_ends(bout_durations>min_bout_duration_sec);
    bout_durations=bout_durations(bout_durations>min_bout_duration_sec);

    scale = 10;
    StrideTime = [];
    for k=1:length(bout_durations)
        start_sample= (bout_starts(k)-1)*window +1;
        end_sample= (bout_ends(k)*window);
        signal_bout=aV_filt(start_sample:end_sample);
        
        int_aV = cumtrapz(1/Fs, signal_bout);
        S1 = -cwt(int_aV, scale, 'gaus1', 1/Fs);
        [~,IC] = findpeaks(-S1);
        S2 = -cwt(S1, scale, 'gaus1', 1/Fs);
        [~,FC] = findpeaks(S2);
        
        % everything should start with an IC
        if FC(1)<IC(1)
            FC(1)=[];
        end
        
        % n_IC = n_FC
        min_len=min([length(FC);length(IC)]);
        if length(FC)~=length(IC)
            FC=FC(1:min_len);
            IC=IC(1:min_len);
        end
        
        % check IC->FC->IC
        i = 1;
        while i <= length(FC) && i <= length(IC)
            diff = FC(i) - IC(i);
            if diff < 0
                FC(i) = [];
                if i < length(IC) && IC(i+1) - IC(i) > 20
                    IC(i) = [];
                end
                % non incrementare i, perché la lista è cambiata
            else
                i = i + 1;
            end
        end
        
        % n_IC = n_FC
        if length(FC)~=length(IC)
            min_len=min([length(FC);length(IC)]);
            FC=FC(1:min_len);
            IC=IC(1:min_len);
        end
        
        total_steps = total_steps + length(IC);
        temp = mean(( IC(3:end) - IC(1:end-2) ) / Fs);
        StrideTime = [StrideTime, temp];
    end
    StrideTime = mean(StrideTime);
end

