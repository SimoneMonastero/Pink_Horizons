function  [SMA, energy]=SMA_energy_func(window,aV_filt, aML_filt, aAP_filt, Fs, limit)
    
    SMA = zeros(limit, 1);
    energy = zeros(limit, 1);
   
    for i = 0:(limit-1)
        start_idx = window*i + 1;
        end_idx = window*(i+1);
        
        aVw = aV_filt(start_idx:end_idx);
        aMLw = aML_filt(start_idx:end_idx);
        aAPw = aAP_filt(start_idx:end_idx);
        
        % Calcolo SMA
        SMA(i+1) = mean(abs(aVw) + abs(aMLw) + abs(aAPw));
    
        % Calcolo Energia (pwelch)
        nfft = 2^nextpow2(window);
        % Parametri pwelch robusti per finestre corte
        [paAPw, f] = pwelch(aAPw, hamming(floor(window/4)), [], nfft, Fs);
        
        paAPw_band = paAPw(f > 0.5 & f < 3);
        f_band = f(f > 0.5 & f < 3);
        
        energy(i+1) = trapz(f_band, paAPw_band);
    end
end