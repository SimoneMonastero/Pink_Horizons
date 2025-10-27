clear, clc, close all

[signal, Fs, tm] = rdsamp('data/CO004');

[aAP, aML, aV]=algo_Moe_Nilssen(signal(:,3),signal(:,2),signal(:,1),'tiltAndNoG');

g = 9.81;
threshold_SMA = 0.135;
% threshold_SMA = 0.35;
threshold_en = 0.05;

% bandpass filter creation
% % % lowCut = 0.5; % Hz
% % % highCut = 15; % Hz
% % % order = 4;
% % % Wn = [lowCut highCut] / (Fs/2);
% % % [B, A] = butter(order, Wn, 'bandpass');

% highpass filter creation
Wn = 0.5 / (Fs/2); % Hz
order = 4;
[B, A] = butter(order, Wn, 'high');

% Filter the acceleration components
aV = filtfilt(B, A, aV);
aML = filtfilt(B, A, aML);
aAP = filtfilt(B, A, aAP);

window = Fs*1;
limit = floor(length(aV)/window);

SMA = zeros(limit,1);
energy  = zeros(limit,1);
for i = 0:(limit-1)
    aVw = aV(window*i +1 : window*(i+1));
    aMLw = aML(window*i +1 : window*(i+1));
    aAPw = aAP(window*i +1 : window*(i+1));
    timew = tm(window*i +1 : window*(i+1));

    SMA(i+1) = mean(abs(aVw) + abs(aMLw) + abs(aAPw));
%     SMA(i+1) = (1/(timew(end)-timew(1))) * (trapz(timew,abs(aVw)) + trapz(timew,abs(aMLw)) + trapz(timew,abs(aAPw)));
    % [paAPw,f]=pwelch(aAPw, hamming(32), [], [], Fs);
    [paAPw,f]=pwelch(aAPw, hamming(floor(window/4)), [], 2^nextpow2(window), Fs);
    paAPw=paAPw(f>0.5 & f<3);
    f=f(f>0.5 & f<3);

    energy(i+1) = trapz(f,paAPw);
end

walking = (SMA > threshold_SMA) | (energy > threshold_en);
% walking = (SMA > mean(SMA)) | (energy > threshold_en);
% [peaks,pos] = findpeaks(SMA);
% walking = (SMA > mean(peaks)) | (energy > threshold_en);

%%

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

p_walking = sum(walking>0)/length(walking) * 100
plot(walking)

%%
[paV, f] = pwelch(aV, [], [], [], Fs);
paV=paV(f>0.5 & f<3);
f=f(f>0.5 & f<3);

[ampl, pos] = max(paV);
step_freq = f(pos);
step_duration = 1/step_freq;

