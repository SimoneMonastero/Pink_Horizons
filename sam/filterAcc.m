function [accData] = filterAcc(accData,order, threshFrequency,Fs)
%output is the filtered data
Wn=threshFrequency/(Fs/2); 
[B,A]=butter(order, Wn);
accDataFiltered=[];
%now filter the three axes:
for i=1:size(accData,2)
    accDataFiltered = [accDataFiltered filtfilt(B,A,accData(:,i))];
end
accData=accDataFiltered;


