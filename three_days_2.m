clear, clc, close all

[signal, Fs, tm] = rdsamp('data/CO001');
fc=0.5;
order=4;
[b,a]=butter(order,fc/(Fs/2),'high');
signal=filtfilt(b,a,signal);
g = 9.81;
threshold_SMA = 0.135;
threshold_en = 0.05;
aV = signal(:,1);
aML = signal(:,2);
aAP = signal(:,3);

window = Fs*1;
p_overlap = 0.5;

limit = floor(length(aV)/window);
% limit = floor(length(aV)/(window*p_overlap)) - 1;
SMA = zeros(limit,1);
energy  = zeros(limit,1);
for i = 0:(limit-1)
    aVw = aV(window*i +1 : window*(i+1));
    aMLw = aML(window*i +1 : window*(i+1));
    aAPw = aAP(window*i +1 : window*(i+1));
%     aVw = aV(window*p_overlap*i +1 : window*p_overlap*i + window);
%     aMLw = aML(window*p_overlap*i +1 : window*p_overlap*i + window);
%     aAPw = aAP(window*p_overlap*i +1 : window*p_overlap*i + window);

    SMA(i+1) = mean(abs(aVw) + abs(aMLw) + abs(aAPw));
    [paAPw,f]=pwelch(aAPw, hanning(length(aAPw)), 0, [], Fs); 
    paAPw=paAPw(f>0.5 & f<3);
    f=f(f>0.5 & f<3);

    energy(i+1) = trapz(f,paAPw);
end

walking = (SMA > threshold_SMA) | (energy > threshold_en);
%%

i = 1;
while i < length(walking)
    if all(walking(i: min([i+59, length(walking)])))
        i = i+1;
        while all(walking(i: min([i+60, length(walking)])))
            i = i+1;
        end
        i = i+59;
    else
        walking(i) = 0;
    end
    i = i+1;
end

sum(walking>0)/length(walking) * 100
plot(walking)

