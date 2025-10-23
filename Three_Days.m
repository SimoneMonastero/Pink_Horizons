clear, clc, close all

[signal, Fs, tm] = rdsamp('data/CO001');

aV = signal(:,1);

% Signal filtering
threshFrequency = 15;
order = 4;                  
Wn=threshFrequency/(Fs/2); 
[B,A]=butter(order, Wn);

aV_f = filtfilt(B,A,aV);

% plot(aV,'b')
% hold on
plot(aV_f, 'r')

k = Fs*60; % &0 seconds window
aaa = movmedian(aV_f, k);
hold on
plot(aaa,'g')

