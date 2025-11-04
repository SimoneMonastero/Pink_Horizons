clc, clear, close all
% Folder that contains the data
% miaCartella = 'data'; 
 miaCartella = 'long-term-movement-monitoring-database-1.0.0\3days'; 
% Creation of the search criterion (all the file .hea inside the specified folder)
pattern = fullfile(miaCartella, '*.hea');
% 3. Trova tutti i file e le cartelle che corrispondono
elencoStruct = dir(pattern);
% 5. Estrai i nomi in un "vettore" (specificamente, un cell array)
nomiFile = {elencoStruct.name};    % {'file1.hea', 'file2.hea', 'file3.hea'}
pwalkingCO=[];
pwalkingFL=[];

total_stepsCO=[];
total_stepsFL=[];

% Parametri dell'Analisi
Fs = 100; % Sampling frequency
window_sec = 1; % Finestra di analisi per SMA ed Energia
window = Fs * window_sec; % Campioni per finestra da 1s
min_bout_duration_sec = 60; % Durata minima bout di cammino
threshold_SMA_min = 0.135;
threshold_SMA_max = 0.8;

threshold_en = 0.05;

% Filtro passa-alto
Wn = 0.5 / (Fs / 2);
order = 4;
[B_hp, A_hp] = butter(order, Wn, 'high');
% Filtro passa-basso per numero passi
Wn=5/(Fs/2);
[B_lp, A_lp] = butter(order, Wn);


for k = 1:1%length(nomiFile)
    record_name = char(nomiFile(k));
    record_name = record_name(1:5);
    % record_name = ['data\' record_name];                % Per settare il file path corretto
     record_name = ['long-term-movement-monitoring-database-1.0.0\3days\' record_name];   
    % Caricamento dati
    disp(['Caricamento dati da: ', record_name, '...']);
    [signal, Fs, tm] = rdsamp(record_name);
    
    % Calcola le componenti AP, ML, V corrette per tilt e gravità
    col_V = 1; % Indice colonna Verticale
    col_ML = 2; % Indice colonna Medio-Laterale
    col_AP = 3; % Indice colonna Antero-Posteriore
    [aAP, aML, aV] = algo_Moe_Nilssen(signal(:,col_AP), signal(:,col_ML), signal(:,col_V), 'tiltAndNoG');
    
    % Pre-Processing (Filtraggio)
    % disp('Filtraggio dei segnali (filtfilt)...');
    aV_filt = filtfilt(B_hp, A_hp, aV);
    aML_filt = filtfilt(B_hp, A_hp, aML);
    aAP_filt = filtfilt(B_hp, A_hp, aAP);
    
    % Classificazione in finestre da 1s
    limit = floor(length(aV_filt) / window);
    % % if limit < min_bout_duration_sec
    % %     warning('File %s troppo corto (%d sec) per l''analisi. Interruzione.', record_name, limit);
    % %     return;
    % % end
    
    SMA = zeros(limit, 1);
    energy = zeros(limit, 1);
    
    % fprintf('Analisi di %d finestre da %d secondo...\n', limit, window_sec);
    
    % % print_every = 5000; % Stampa un aggiornamento ogni 5000 finestre (circa 1.4 ore di dati)
    
    for i = 0:(limit-1)
        start_idx = window*i + 1;
        end_idx = window*(i+1);
        
        aVw = aV_filt(start_idx:end_idx);
        aMLw = aML_filt(start_idx:end_idx);
        aAPw = aAP_filt(start_idx:end_idx);
        
        % Calcolo SMA
        SMA(i+1) = mean(abs(aVw) + abs(aMLw) + abs(aAPw));
    
       
        % % if mod(i, print_every) == 0 && i > 0
        % %     fprintf('... Finestra %d di %d (%.1f %%)\n', i, limit, (i/limit)*100);
        % % end
    
        % Calcolo Energia (pwelch)
        
        nfft = 2^nextpow2(window);
        % Parametri pwelch robusti per finestre corte
        [paAPw, f] = pwelch(aAPw, hamming(floor(window/4)), [], nfft, Fs);
        
        paAPw_band = paAPw(f > 0.5 & f < 3);
        f_band = f(f > 0.5 & f < 3);
        
        % % if ~isempty(f_band)
            energy(i+1) = trapz(f_band, paAPw_band);
        % % else
        % %     energy(i+1) = 0;
        % % end
        
    end
    
    % Stampa il completamento finale
    % % fprintf('... Finestra %d di %d (100 %%)\n', limit, limit); 
    % % fprintf('Calcolo SMA ed Energia completato.\n');
    
    
    % --- 5. Decisione cammino (Logica OR) ---
    walking = ((SMA > threshold_SMA_min(k)) & (SMA < threshold_SMA_max(k))) | (energy > threshold_en);
    
    % --- 7. Bout validi (>60s) ---
    % % disp('Identificazione bout validi...');
    % Trova transizioni 0->1 (start) e 1->0 (end)
    d = diff([0; walking; 0]);
    bout_starts = find(d == 1);
    bout_ends = find(d == -1) - 1;
    bout_durations = bout_ends - bout_starts + 1; % Durata in secondi (finestre da 1s)
    
    walking_final = zeros(limit, 1);
    % % valid_bouts = 0;

    for j = 1:length(bout_durations)
        if bout_durations(j) > min_bout_duration_sec
            walking_final(bout_starts(j):bout_ends(j)) = 1;
            % % valid_bouts = valid_bouts + 1;
        end
    end
    
    % % fprintf('Trovati %d bout di cammino > %d secondi.\n', valid_bouts, min_bout_duration_sec);
    
    % --- 8. Percentuale cammino ---
    p_walking = sum(walking_final) / length(walking_final) * 100;
    
    % % fprintf('\n--- RISULTATO ---\n');
    % % fprintf('File: %s\n', record_name);
    % % fprintf('Durata totale analizzata: %.1f minuti (%.1f ore)\n', limit / 60, limit / 3600);
    fprintf('Percentuale cammino finale (bout > %ds): %.2f %%\n', min_bout_duration_sec, p_walking);
    total_steps=number_steps(B_lp,A_lp,Fs,window,min_bout_duration_sec,bout_starts,bout_ends,bout_durations,aAP,aAP_filt);
   
    record_name = record_name(6:end);
    if record_name(1) == 'C'
        pwalkingCO = [pwalkingCO, p_walking]; % Store the percentage of walking for current file
        total_stepsCO=[total_stepsCO, total_steps];
    else
        pwalkingFL = [pwalkingFL, p_walking]; % Store the percentage of walking for other files
        total_stepsFL=[total_stepsFL, total_steps];
    end
end

mean_walkingCO=mean(pwalkingCO);
std_walkingCO=std(pwalkingCO);
mean_walkingFL=mean(pwalkingFL);
std_walkingFL=std(pwalkingFL);
fprintf("mean walking percentage controls: %f +- %f m/s \n",mean_walkingCO,std_walkingCO)
fprintf("mean walking percentage fallers: %f +- %f m/s \n",mean_walkingFL,std_walkingFL)

mean_stepsCO=mean(total_stepsCO);
std_stepsCO=std(total_stepsCO);
mean_stepsFL=mean(total_stepsFL);
std_stepsFL=std(total_stepsFL);
fprintf("mean walking percentage controls: %f +- %f m/s \n",mean_stepsCO,std_stepsCO)
fprintf("mean walking percentage fallers: %f +- %f m/s \n",mean_stepsFL,std_stepsFL)

