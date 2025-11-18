function [total_steps] = number_steps_func_wavelet(B_lp, A_lp, Fs, window, min_bout_duration_sec, bout_starts, bout_ends, bout_durations, aV, aV_filt_HP)
    % for the step detection we adapted an already existing function that we picked form a previous workshop.
    % in brief the function exploits continuous wavelet transform to detect
    % IC and FC starting from a bandpassed (0.5, 15) version of the vertical
    % acceleration signal. the total number of steps is then computed as
    % the sum of all the ICs detected IC in every valid bout
    
    % NOTE: 'aV_filt_HP' corresponds to the High-Passed signal passed from the main script
    
    total_steps = 0; 
    
    % Apply Low-Pass to the ALREADY High-Passed signal --> bandpass filter
    % to smooth the signal to simplify the peaks finding
    aV_bandpass = filtfilt(B_lp, A_lp, aV_filt_HP);
    
    % Filter bout indices based on duration
    valid_indices = bout_durations > min_bout_duration_sec;
    bout_starts = bout_starts(valid_indices);
    bout_ends = bout_ends(valid_indices);
    
    scale = 10; % Scale 10 at Fs=100Hz target approx 2Hz
    % IC and FC taken in the interesting bouts. we look at every valid bout
    for k = 1:length(bout_starts)
        % Extract the bout
        start_sample = (bout_starts(k)-1)*window + 1;
        end_sample = (bout_ends(k)*window);
        
        % Safety check for indices
        if end_sample > length(aV_bandpass)
            end_sample = length(aV_bandpass);
        end
        % acc for every valid bout
        signal_bout = aV_bandpass(start_sample:end_sample);
        
        % Integrate acceleration to get velocity
        int_aV = cumtrapz(1/Fs, signal_bout);
        
        % Remove linear trend caused by integration drift
        int_aV = detrend(int_aV); 
        
        % Continuous Wavelet Transform
        S1 = -cwt(int_aV, scale, 'gaus1', 1/Fs);
        [~, IC] = findpeaks(-S1);
        S2 = -cwt(S1, scale, 'gaus1', 1/Fs);
        [~, FC] = findpeaks(S2);
        
        % Alignment Logic
        if isempty(IC) || isempty(FC) 
            continue; % Skip this bout if no peaks found
        end
        
        while FC(1) < IC(1)
            FC(1) = [];
        end
        
        min_len = min([length(FC); length(IC)]);
        FC = FC(1:min_len);
        IC = IC(1:min_len);
        
        i = 1;
        while i <= length(FC) && i <= length(IC)
            diff_val = FC(i) - IC(i);
            if diff_val < 0 % If FC comes before IC
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
    end

    fprintf('Total number of steps: %f steps \n', total_steps)

end
