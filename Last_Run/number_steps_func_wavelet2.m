function [total_steps, StrideTime] = number_steps_func_wavelet2(B_lp, A_lp, Fs, window, min_bout_duration_sec, bout_starts, bout_ends, bout_durations, aV, aV_filt_HP)
    % Function to estimate total steps and stride time using wavelet analysis
    % NOTE: 'aV_filt_HP' corresponds to the High-Passed signal passed from the main script
    
    total_steps = 0; 
    
    % CORRECTION 1: Apply Low-Pass to the ALREADY High-Passed signal.
    % This creates a Band-Pass (0.5Hz - 15Hz) which is ideal for integration.
    aV_bandpass = filtfilt(B_lp, A_lp, aV_filt_HP);
    
    % Filter bout indices based on duration
    valid_indices = bout_durations > min_bout_duration_sec;
    bout_starts = bout_starts(valid_indices);
    bout_ends = bout_ends(valid_indices);
    
    scale = 10; % Scale 10 at Fs=100Hz target approx 2Hz (Correct)
    StrideTime = [];
    
    for k = 1:length(bout_starts)
        % Extract the bout
        start_sample = (bout_starts(k)-1)*window + 1;
        end_sample = (bout_ends(k)*window);
        
        % Safety check for indices
        if end_sample > length(aV_bandpass)
            end_sample = length(aV_bandpass);
        end
        
        signal_bout = aV_bandpass(start_sample:end_sample);
        
        % Integrate acceleration to get velocity
        int_aV = cumtrapz(1/Fs, signal_bout);
        
        % CORRECTION 2: Remove linear trend caused by integration drift
        int_aV = detrend(int_aV); 
        
        % Continuous Wavelet Transform
        S1 = -cwt(int_aV, scale, 'gaus1', 1/Fs);
        [~, IC] = findpeaks(-S1);
        S2 = -cwt(S1, scale, 'gaus1', 1/Fs);
        [~, FC] = findpeaks(S2);
        
        % --- Alignment Logic (Same as before) ---
        if isempty(IC) || isempty(FC) 
            continue; % Skip this bout if no peaks found
        end
        
        if FC(1) < IC(1)
            FC(1) = [];
        end
        
        min_len = min([length(FC); length(IC)]);
        FC = FC(1:min_len);
        IC = IC(1:min_len);
        
        i = 1;
        while i <= length(FC) && i <= length(IC)
            diff_val = FC(i) - IC(i); % renamed variable to avoid conflict with diff()
            if diff_val < 0
                FC(i) = [];
                if i < length(IC) && (IC(i+1) - IC(i) > 20) % 20 samples = 0.2s check
                    IC(i) = [];
                end
            else
                i = i + 1;
            end
        end
        
        min_len = min([length(FC); length(IC)]);
        FC = FC(1:min_len);
        IC = IC(1:min_len);
        
        total_steps = total_steps + length(IC);
        
        % Calculate Stride Time if we have at least 3 steps (1 stride cycle)
        if length(IC) >= 3
            temp = mean((IC(3:end) - IC(1:end-2)) / Fs);
            StrideTime = [StrideTime, temp];
        end
    end
    
    % CORRECTION 3: Final NaN check
    if isempty(StrideTime)
        StrideTime = NaN; % Return NaN instead of crashing or incorrect mean
    else
        StrideTime = mean(StrideTime);
    end
end