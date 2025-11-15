clear, clc, close all

C=load('LabCOData.mat');
F=load('LabFLData.mat');
Fs=100;

namesC=fieldnames(C.allSubjectData);
namesF=fieldnames(F.allSubjectData);
lengthC=numel(namesC);
lengthF=numel(namesF);
gait_speed_co= zeros(lengthC, 1); % Initialize gait_speed array
gait_speed_fl= zeros(lengthF, 1); 
hsens=0.53; % From anthropometric table: lumbar-floor heigth
height_con=1.64; %+-0.06 heigth controls
height_fall=1.61; %+-0.09 heigth fallers

% bandpass filter creation
lowCut = 0.5; % Hz
highCut = 15; % Hz
order = 4;
Wn = [lowCut highCut] / (Fs/2);
[B_bp, A_bp] = butter(order, Wn, 'bandpass');

% bandpass filter creation for position
lowCut = 0.5; % Hz
highCut = 5; % Hz
order = 4;
Wn = [lowCut highCut] / (Fs/2);
[B_pos, A_pos] = butter(order, Wn, 'bandpass');

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
    
    [paAP,f]=pwelch(aAP, [], [], [], Fs);
    paAP=paAP(f>0.5 & f<3);
    f=f(f>0.5 & f<3);
    [ampl, ind]=max(paAP); % psd amplitude 
    passi_sec=f(ind); % Steps/second
    
    % filtering aV 
    aV = filtfilt(B_bp, A_bp, aV); 
    % velocity with cumtrapz
    velocity=cumtrapz(tm,aV);
    % filtering velocity 
    velocity=filtfilt(B_bp,A_bp,velocity);
    % position with cumtrapz
    position=cumtrapz(tm, velocity);
    % filtering position
    position = filtfilt(B_pos, A_pos, position); 
   
    h=max(position)-min(position); % h is the change in heigth of the COM
    l_con = hsens* height_con; % sensor elevation nonfallers
    
    step_length=2*sqrt(2*l_con*h - h^2); % meters/step
    gait_speed_co(i)=step_length * passi_sec;
end
%plot(position)
gait_speed_co=gait_speed_co';
MCO=mean(gait_speed_co);
SCO=std(gait_speed_co);
relerrCO = abs((MCO - 1.19)/1.19);
fprintf("gait speed controls: %f +- %f \n",MCO,SCO)
fprintf("relative error: %f \n", relerrCO)

% now fallers

for i=1:lengthF
    currentsubj=namesF{i};
    accData=F.allSubjectData.(currentsubj).data(:,1:3);
    tm=F.allSubjectData.(currentsubj).time;
   [aAP, aML, aV] = algo_Moe_Nilssen(accData(:,3), accData(:,2), accData(:,1) ,'tiltAndNoG');
    % Conversion from g to m/s^2:
    aAP = aAP*g;    aML = aML*g;    aV = aV*g;
    
    [paAP,f]=pwelch(aAP, [], [], [], Fs); 
    paAP=paAP(f>0.5 & f<3);
    f=f(f>0.5 & f<3);
    [ampl, ind]=max(paAP); % psd amplitude 
    passi_sec=f(ind); % Steps/second
    % bandpass filter already created
   
    % filtering aV 
    aV = filtfilt(B_bp, A_bp, aV); 
    % velocity with cumtrapz
    velocity=cumtrapz(tm,aV);
    % filtering velocity 
    velocity=filtfilt(B_bp,A_bp,velocity);
    % position with cumtrapz
    position=cumtrapz(tm, velocity);
    % filtering position
    position = filtfilt(B_pos, A_pos, position); 
   
    h=max(position)-min(position); % h is the change in heigth of the COM
    l_fall = hsens * height_fall; % sensor elevation fallers
    
    step_length=2*sqrt(2*l_fall*h - h^2); % meters/step
    gait_speed_fl(i)=step_length * passi_sec;
end
% plot(position)
gait_speed_fl=gait_speed_fl';
MFL=mean(gait_speed_fl);
SFL=std(gait_speed_fl);
relerrFL = abs((MFL - 0.97)/0.97);
fprintf("gait speed fallers: %f +- %f \n",MFL,SFL)
fprintf("relative error: %f \n", relerrFL)
