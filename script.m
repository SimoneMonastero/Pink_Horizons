clear, clc, close all

[signal, Fs, tm] = rdsamp('data/LabWalks/co004_base');

% subplot(221)
% plot(tm, signal(:,1), 'r')
% xlabel('time [s]')
% ylabel('g')
% subplot(222)
% plot(tm, signal(:,2), 'g')
% xlabel('time [s]')
% ylabel('g')
% subplot(223)
% plot(tm, signal(:,3), 'b')
% xlabel('time [s]')
% ylabel('g')

% Signal filtering
threshFrequency = 3;
order = 4;

Wn=threshFrequency/(Fs/2); 

[B,A]=butter(order, Wn);
accData=[];
%now filter the three axes:
for i=1:3
    accData = [accData filtfilt(B,A,signal(:,i))];
end

figure
subplot(221)
plot(tm, accData(:,1), 'r')
xlabel('time [s]')
ylabel('g')
subplot(222)
plot(tm, accData(:,2), 'g')
xlabel('time [s]')
ylabel('g')
subplot(223)
plot(tm, accData(:,3), 'b')
xlabel('time [s]')
ylabel('g')

% Correction of sensor misalignments
[aAP, aML, aV] = algo_Moe_Nilssen(accData(:,3), accData(:,2), accData(:,1) ,'tiltAndNoG');

[peaks, pos] = findpeaks(aV);

figure
subplot(221)
plot(tm, aV, 'r', tm(pos),peaks,'b*')
xlabel('time [s]')
ylabel('g')
title('Vertical acceleration')
subplot(222)
plot(tm, aML, 'g')
xlabel('time [s]')
ylabel('g')
title('Medio-lateral acceleration')
subplot(223)
plot(tm, aAP, 'b')
xlabel('time [s]')
ylabel('g')
title('Antero-posterior acceleration')
