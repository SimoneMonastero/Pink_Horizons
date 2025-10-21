clc, clear, close all

C=load('LabCOData.mat');
F=load('LabFLData.mat');
Fs=100;

namesC=fieldnames(C.allSubjectData);
namesF=fieldnames(F.allSubjectData);
lengthC=numel(namesC);
lengthF=numel(namesF);
for i=1:lengthC
    currentsubj=namesC{i};
    accData=C.allSubjectData.(currentsubj).data(:,1:3);
    tm=C.allSubjectData.(currentsubj).time;
   [aAP, aML, aV] = algo_Moe_Nilssen(accData(:,3), accData(:,2), accData(:,1) ,'tiltAndNoG');
    % Conversion from g to m/s^2:
    g = 9.81;
    aAP = aAP*g;
    aML = aML*g;
    aV = aV*g;
    
    % [paV,f]=pwelch(aV);
    [paV,f]=pwelch(aV, [], [], [], Fs);    % Pwelch vuole anche la sampling frequency, se no di default è 1Hz
    paV=paV(f>0.5 & f<3);
    f=f(f>0.5 & f<3);
    [ampl, ind]=max(paV); % amplitude psd che è passi/secondo
    passi_sec=f(ind); %passi al secondo
    
    
    % a=find(abs(ampl/2 - paV)==min(abs(ampl/2 - paV)));
    % b=find(abs(ampl/2 - paV(a+1:end))==min(abs(ampl/2 - paV(a+1:end))))+a;
    % figure
    % x=ampl/2 - paV;
    % plot(f,paV, f(a),paV(a),'r*',f(b),paV(b),'r*')
    % 
    % width=f(b)-f(a); %Hz
    
    %filtrare con filtro passaalto
    threshFrequency = 0.5;
    order = 4;
    Wn=threshFrequency/(Fs/2); 
    [B,A]=butter(order, Wn,'high');
    aV=filtfilt(B,A,aV);

    % siccome abbiamo l'altezza usiamo il pendolo inverso per stimare la step length 
    % detrend -> cumtrapz -> cumtrapz -> h obtained
    aV_detrended=detrend(aV);
    velocity=cumtrapz(tm,aV_detrended);
    
    % filter again the velocity ??
    velocity=filtfilt(B,A,velocity);
    position=cumtrapz(tm, velocity);

    % Filtro passa-banda per la posizione
    lowCut = 0.5; % Hz
    highCut = 5; % Hz
    order = 4;
    Wn = [lowCut highCut] / (Fs/2);
    [B_bp, A_bp] = butter(order, Wn, 'bandpass');
    position = filtfilt(B_bp, A_bp, position); 

    h=max(position)-min(position); % h è il cambiamento dell'altezza del COM
    % height_fall=1.61; %+-0.09 altezza fallers
    height_con=1.64; %+-0.06 altezza nonfallers
    hsens=0.53; %da tabella antropometrica la lunghezza suolo-lombari è 0.53H
    % l_fall = hsens * height_fall; % altezza sensore fallers
    l_con = hsens* height_con; % altezza sensore nonfallers
    
    step_length=2*sqrt(2*l_con*h - h^2); % metri/passo
    
    gait_speed(i)=step_length * passi_sec;
    
    % plot(position)
end

mean(gait_speed)
std(gait_speed)