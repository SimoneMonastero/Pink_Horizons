clc, clear, close all
% 1. Specifica la cartella di destinazione
miaCartella = 'long-term-movement-monitoring-database-1.0.0\3days'; 
% 2. Crea il pattern di ricerca (tutti i file .hea in quella cartella)
pattern = fullfile(miaCartella, '*.hea');
% 3. Trova tutti i file e le cartelle che corrispondono
elencoStruct = dir(pattern);
% 5. Estrai i nomi in un "vettore" (specificamente, un cell array)
nomiFile = {elencoStruct.name};    % {'file1.hea', 'file2.hea', 'file3.hea'}
pwalkingCO=[];
pwalkingFL=[];
    
g = 9.81;
threshold_SMA = 0.135;
% threshold_SMA = 0.35;
threshold_en = 0.05;
Fs=100;
window = Fs*1;
% highpass filter creation
Wn = 0.5 / (Fs/2); % Hz
order = 4;
[B, A] = butter(order, Wn, 'high');
    

for k = 1: length(nomiFile)
    asd=char(nomiFile(k));
    asd=asd(1:5);
    [signal, Fs, tm]=rdsamp(asd);
    
    [aAP, aML, aV]=algo_Moe_Nilssen(signal(:,3),signal(:,2),signal(:,1),'tiltAndNoG');
    
    % Filter the acceleration components
    aV = filtfilt(B, A, aV);
    aML = filtfilt(B, A, aML);
    aAP = filtfilt(B, A, aAP);
    
    limit = floor(length(aV)/window);
    
    SMA = zeros(limit,1);
    energy  = zeros(limit,1);

    for i = 0:(limit-1)
        aVw = aV(window*i +1 : window*(i+1));
        aMLw = aML(window*i +1 : window*(i+1));
        aAPw = aAP(window*i +1 : window*(i+1));
        timew = tm(window*i +1 : window*(i+1));
        
        SMA(i+1) = mean(abs(aVw) + abs(aMLw) + abs(aAPw));

        [paAPw,f]=pwelch(aAPw, [] , [] , [] , Fs);
        paAPw=paAPw(f>0.5 & f<3);
        f=f(f>0.5 & f<3);
        
        energy(i+1) = trapz(f,paAPw);
    end
    
    walking = (SMA > threshold_SMA) | (energy > threshold_en);

    i = 1;
    while i < length(walking)
        if all(walking(i: min([i+59, length(walking)])))
            i = i+1;
            while all(walking(i: min([i+60, length(walking)]))) && i < length(walking)
                i = i+1;
            end
            i = i+59;
        else
            walking(i) = 0;
        end
        i = i+1;
    end
    
    p_walking = sum(walking>0)/length(walking) * 100;
    if asd(1) == 'C'
        pwalkingCO = [pwalkingCO, p_walking]; % Store the percentage of walking for current file
    else
        pwalkingFL = [pwalkingFL, p_walking]; % Store the percentage of walking for other files
    end

end

meanCO=mean(pwalingCO);
stdCO=std(pwalkingCO);
meanFL=mean(pwalkingFL);
stdFL=std(pwalkingFL);
fprintf("mean walking percentage controls: %f +- %f m/s \n",meanCO,stdCO)
fprintf("mean walking percentage fallers: %f +- %f m/s \n",meanFL,stdFL)