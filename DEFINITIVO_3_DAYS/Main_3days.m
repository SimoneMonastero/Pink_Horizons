clc, clear, close all
% Folder containing the data
miaCartella = 'data';
% miaCartella = 'long-term-movement-monitoring-database-1.0.0\3days'; 
% Create search pattern (all .hea files within the specified folder)
pattern = fullfile(miaCartella, '*.hea');
% Retrieve all matching files and folders
elencoStruct = dir(pattern);
% Extract file names into a cell array
nomiFile = {elencoStruct.name};    % {'file1.hea', 'file2.hea', 'file3.hea'}
% Subject exclusion
nomiFile([1,2,13,14,25,26,29,47,51,58,63,66,68]) = []; 

walking_percentage_CO=[]; % Walking percentage for control group
walking_percentage_FL=[]; % Walking percentage for faller group

total_steps_CO=[]; % Total number of steps (control)
total_steps_FL=[]; % Total number of steps (fallers)

stride_time_CO=[]; % Stride time (control)
stride_time_FL=[]; % Stride time (fallers)

valid_bouts_CO = []; % Valid bouts (control)
valid_bouts_FL = []; % Valid bouts (fallers)

avg_range_CO = []; % average aAP range (control)
avg_range_FL = []; % average aAP range (fallers)

total_minutes_CO = []; % total minutes of activity (control)
total_minutes_FL = []; % total minutes of activity (fallers)

% Analysis Parameters
Fs = 100; % Sampling frequency
window_sec = 1; % Analysis window for SMA and Energy
window = Fs * window_sec; % Samples per 1-second window
min_bout_duration_sec = 60; % Minimum walking bout duration
threshold_SMA_min = 0.135;
threshold_SMA_max = 0.8;
threshold_en = 0.05;

% High-pass filter
Wn = 0.5 / (Fs / 2);
order = 4;
[B_hp, A_hp] = butter(order, Wn, 'high');
% Low-pass filter for step detection
Wn = 15 / (Fs / 2);
[B_lp, A_lp] = butter(order, Wn);

for k = 1:length(nomiFile)
    record_name = char(nomiFile(k));
    record_name = record_name(1:5);
    record_name = ['data\' record_name];   % Set the correct file path
    % record_name = ['long-term-movement-monitoring-database-1.0.0\3days\' record_name];

    % Load data
    disp(['Caricamento dati da: ', record_name, '...']);
    [signal, Fs, tm] = rdsamp(record_name);
    
    % Compute AP, ML, and V components corrected for tilt and gravity
    col_V = 1;  % Vertical axis column index
    col_ML = 2; % Medio-lateral axis column index
    col_AP = 3; % Antero-posterior axis column index
    [aAP, aML, aV] = algo_Moe_Nilssen(signal(:,col_AP), signal(:,col_ML), signal(:,col_V), 'tiltAndNoG');
    
    % Pre-processing (filtering)
    aV_filt = filtfilt(B_hp, A_hp, aV);
    aML_filt = filtfilt(B_hp, A_hp, aML);
    aAP_filt = filtfilt(B_hp, A_hp, aAP);
    limit = floor(length(aV_filt) / window);
   
   [SMA, energy] = SMA_energy_func(window,aV_filt, aML_filt, aAP_filt, Fs, limit);

    % Walking detection (OR logic)
    walking = ((SMA > threshold_SMA_min) & (SMA < threshold_SMA_max)) | (energy > threshold_en);
    
    [p_walking, bout_starts, bout_ends, bout_durations, valid_bouts, avg_range, total_minutes]=percentage_walking_func(walking, min_bout_duration_sec, limit, aAP, Fs);
    [total_steps]=number_steps_func_wavelet(B_lp,A_lp,Fs,window,min_bout_duration_sec,bout_starts,bout_ends,bout_durations,aV,aV_filt);
    [stride_duration]=stride_duration_func(aAP,Fs);
   
    if record_name(end-4) == 'C'
        walking_percentage_CO = [walking_percentage_CO, p_walking]; % Store walking percentage for the current control file
        total_steps_CO=[total_steps_CO, total_steps];
        stride_time_CO=[stride_time_CO, stride_duration];
        valid_bouts_CO = [valid_bouts_CO, valid_bouts];
        avg_range_CO = [avg_range_CO, avg_range];
        total_minutes_CO = [total_minutes_CO, total_minutes];
    else
        walking_percentage_FL = [walking_percentage_FL, p_walking]; % Store walking percentage for the current faller file
        total_steps_FL=[total_steps_FL, total_steps];
        stride_time_FL=[stride_time_FL, stride_duration];
        valid_bouts_FL = [valid_bouts_FL, valid_bouts];
        avg_range_FL = [avg_range_FL, avg_range];
        total_minutes_FL = [total_minutes_FL, total_minutes];
    end

end

output_func(walking_percentage_CO, walking_percentage_FL, total_steps_CO, total_steps_FL, ...
    stride_time_CO, stride_time_FL, valid_bouts_CO, valid_bouts_FL, ...
    avg_range_CO, avg_range_FL, total_minutes_CO, total_minutes_FL)

save('Final results')
