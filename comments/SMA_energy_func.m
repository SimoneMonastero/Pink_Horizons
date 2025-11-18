function  [SMA, energy]=SMA_energy_func(window,aV_filt, aML_filt, aAP_filt, Fs, limit)
    % we followed the paper:
    % 1 sec window
    % segmentation of the signal 
    SMA = zeros(limit, 1);
    energy = zeros(limit, 1);
       
    
    for i = 0:(limit-1)
        start_idx = window*i + 1;
        end_idx = window*(i+1);
        
        aVw = aV_filt(start_idx:end_idx);
        aMLw = aML_filt(start_idx:end_idx);
        aAPw = aAP_filt(start_idx:end_idx);
        
        % SMA computation
        SMA(i+1) = mean(abs(aVw) + abs(aMLw) + abs(aAPw));
    
        % Energy computation (pwelch)
        nfft = 2^nextpow2(window); % the number of discrete Fourier transform (DFT) points to use in the PSD estimate --> default
        % power spectral analysis
        % pwelch with hamming window (default) of the windowed AP acceleration
        [paAPw, f] = pwelch(aAPw, hamming(floor(window/4)), [], nfft, Fs);
        % extraction of the band of interest (the wanking relevant frequencies)
        % paAPw_band = paAPw(f > 1 & f < 3);
        % f_band = f(f > 1 & f < 3);
        % integration of the psd with trapz
        % energy(i+1) = trapz(f_band, paAPw_band);
        paAPw = paAPw(f > 1);
        f = f(f > 1);
        energy(i+1) = trapz(f, paAPw);
    end
end


