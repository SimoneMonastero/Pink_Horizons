clear, clc, close all

[accData, Fs, tm] = rdsamp('long-term-movement-monitoring-database-1.0.0\LabWalks\co004_base');
t=tm(end);

[aAP, aML, aV] = algo_Moe_Nilssen(accData(:,3), accData(:,2), accData(:,1) ,'tiltAndNoG');

[paV,f]=pwelch(aV);
plot(f,paV)
paV=paV(f>0.5 & f<3);
f=f(f>0.5 & f<3);
figure 
plot(f,paV)

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
velocity=cumtrapz(tm,aV);

% filter again the velocity ??
velocity=filtfilt(B,A,velocity);

position=cumtrapz(tm, velocity);
h=max(position)-min(position); % h è il cambiamento dell'altezza del COM
height_fall=1.61; %+-0.09 altezza fallers
height_con=1.64; %+-0.06 altezza nonfallers
l_fall = 0.53 * height_fall; % altezza sensore fallers
l_con = 0.53 * height_con; % altezza sensore nonfallers

step_length=2*sqrt(2*l_con*h - h^2); % metri/passo

gait_speed=step_length * passi_sec

plot(position)
