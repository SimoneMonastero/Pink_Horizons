clear
close all
clc

%% 1) Importing data
load('GaitData.mat')
Fs=100;

%% 2) Plotting and manual segmentation
sub_in=1;
sub_fin=height(GaitData);
manualsegmentation=0; % yes = 1, no = 0

for i=sub_in:sub_fin
    
    string_line1=strcat('SUBJECT N.', num2str(i));
    string_line2=strcat('Age:',num2str(GaitData{i,1}.Age),', Gender: ', num2str(GaitData{i,1}.Gender), ', Weight:',num2str(GaitData{i,1}.Weight),' kg, Height:', num2str(GaitData{i,1}.Age),' cm, Wearable height: ', num2str(num2str(GaitData{i,1}.Wearable_Height)),'cm');

    figure()
    plot(GaitData{i, 1}.Acc.accV,'b')
    hold on
    plot(GaitData{i, 1}.Acc.accML,'g')
    plot(GaitData{i, 1}.Acc.accAP,'r')
    legend('V','ML','AP')
    xlabel('Samples')
    ylabel('Acc [m/s^2]')
    
    if manualsegmentation==1
        % Optional
        % identifiy the start and the end of each signal (ginput)
        [nsample, acc]=ginput(2);
        
        % save the start and the end point in the structure GaitData
        GaitData{i,1}.Start=round(nsample(1,1));
        GaitData{i,1}.Stop=round(nsample(2,1));
    end
    
    title(string_line1,string_line2)

end




%% 
% for all subjects
for i=sub_in:sub_fin
    
        string_title1=strcat('SUBJECT N.', num2str(i));   
        string_title2=strcat('Age:',num2str(GaitData{i,1}.Age),', Gender: ', num2str(GaitData{i,1}.Gender), ', Weight:',num2str(GaitData{i,1}.Weight),' kg, Height:', num2str(GaitData{i,1}.Age),' cm, Wearable height: ', num2str(num2str(GaitData{i,1}.Wearable_Height)),'cm');

        %% 3) Filtering
        if manualsegmentation==0
            accData=[GaitData{i, 1}.Acc.accV GaitData{i, 1}.Acc.accML GaitData{i, 1}.Acc.accAP];
        elseif manualsegmentation==1
            % optional yes
            accData=[GaitData{i, 1}.Acc.accV(GaitData{i, 1}.Start:GaitData{i, 1}.Stop,1) GaitData{i, 1}.Acc.accML(GaitData{i, 1}.Start:GaitData{i, 1}.Stop,1) GaitData{i, 1}.Acc.accAP(GaitData{i, 1}.Start:GaitData{i, 1}.Stop,1)];
        end

        orderFilter=4;
        freqFilter=15;

        % Use butter and filtfilt to filter all the axis 
        accData_filtered = filterAcc(accData,orderFilter, freqFilter,Fs);

        % Create a figure with 3 subplot  with in each the plot of an acceleration axis with and without filtering. 
        % Link the x axis
        figure()
        axis(1)=subplot(3,1,1)
        plot(accData(:,1));
        hold on
        plot(accData_filtered(:,1));
        xlabel('samples')
        ylabel('accV [m/s^2]')
        legend('V raw','V filtered')
        title(string_title1,string_title2)

        axis(2)=subplot(3,1,2)
        plot(accData(:,2));
        hold on
        plot(accData_filtered(:,2));
        legend('ML raw','ML filtered')
        xlabel('samples')
        ylabel('accML [m/s^2]')

        axis(3)=subplot(3,1,3)
        plot(accData(:,3));
        hold on
        plot(accData_filtered(:,3));
        xlabel('samples')
        ylabel('accAP [m/s^2]')
        legend('AP raw','AP filtered')

        linkaxes(axis,'x');

        %% 5) Acceleration correction to horizontal-vertical frame
        [accAPcorr, accMLcorr, accVcorr]=algo_Moe_Nilssen(accData(:,3),accData(:,2),accData(:,1),'tiltAndNoG');

        figure()
        axis(1)=subplot(3,1,1)
        plot(accData(:,1));
        hold on
        plot(accVcorr(:,1));
        xlabel('samples')
        ylabel('accV [m/s^2]')
        legend('V pre-correction','V post-correction')
        title(string_title1,string_title2)

        axis(2)=subplot(3,1,2)
        plot(accData(:,2));
        hold on
        plot(accMLcorr(:,1));
        legend('ML pre-correction','ML post-correction')
        xlabel('samples')
        ylabel('accML [m/s^2]')

        axis(3)=subplot(3,1,3)
        plot(accData(:,3));
        hold on
        plot(accAPcorr(:,1));
        xlabel('samples')
        ylabel('accAP [m/s^2]')
        legend('AP pre-correction','AP post-correction')

        linkaxes(axis,'x');

        %% 6) Integration and peak detection

        Integratedav=cumtrapz(1/Fs,accVcorr);
        S1=-cwt(Integratedav,10,'gaus1',1/Fs);%this because the CWT gives the negative derivative
        [Peaks1,Locations1]=findpeaks(-S1,'minPeakHeight',0.10);% this because I want to find the minima
        IC=Locations1;
        IC_t=IC./Fs;
        S2=-cwt(S1,10,'gaus1',1/Fs);% this because the CWT gives the negative derivative
        [Peaks2,Locations2]=findpeaks(S2,'minPeakHeight',2);
        FC=Locations2;
        FC_t=FC./Fs;

        figure
        plot(accVcorr,'b');
        hold on;
        plot(S1,'r');
        hold on;
        plot(Locations1,S1(Locations1),'ro');
        plot(S2,'g');
        plot(Locations2,S2(Locations2),'go');
        xlabel('samples')
        legend('acc','S1','IC','S2','FC');
        title(string_title1,string_title2)

        %A different figure
        figure
        ax(1)=subplot(2,1,1);
        plot(accVcorr);
        hold on
        plot(Locations1,accVcorr(Locations1),'ro');
        plot(Locations2,accVcorr(Locations2),'g*');
        xlabel('samples')
        title(string_title1,string_title2)
        legend('accVcorr','ICs','FCs');
        ax(2)=subplot(2,1,2);
        plot(S1,'r');
        hold on
        plot(Locations1,S1(Locations1),'ro');%because it is the minima
        plot(S2,'g')
        plot(Locations2,Peaks2,'g*')
        xlabel('samples')
        linkaxes(ax,'x');
        legend('S1','ICs','S2','FCs');

        %% 7) Calculating temporal gait characteristics from the IC/FC events
        %% 8) Integration and spatio-temporal estimations

        h=GaitData{1, 1}.Wearable_Height/100; % m
        [StepTime, StanceTime, StrideTime, SwingTime, StepLength, StepVelocity]=calculateSpatioTemporalGaitCharacteristics(IC,FC,accVcorr,h,Fs);
        GaitData{i,1}.StepTime=StepTime;
        GaitData{i,1}.StanceTime=StanceTime;
        GaitData{i,1}.StrideTime=StrideTime;
        GaitData{i,1}.SwingTime=SwingTime;
        GaitData{i,1}.StepLength=StepLength;
        GaitData{i,1}.StepVelocity=StepVelocity;
        GaitData{i,1}.Nsteps=length(GaitData{i,1}.StepTime);

        
        figure
        subplot(2,2,1)
        boxplot(StepTime);
        title('step time [s]')
        subplot(2,2,2)
        boxplot(StrideTime);
        title('stride time [s]')
        subplot(2,2,3)
        boxplot(StepLength*100);
        title('step length [cm]');
        subplot(2,2,4)
        boxplot(StepVelocity*3.6);
        title('step velocity [km/h]');

        %% 9) Variability and asymmetry calculations

        [StepTimeV, StepTimeA]=calculateVariabilityAndAsymmetry(StepTime);
        GaitData{i,1}.StepTimeV=StepTimeV;
        GaitData{i,1}.StepTimeA=StepTimeA;
        
end


%% 10) Analysis

% Plot subject's height vs step length and calculate the correlation
height5=[];
meanStepLength5=[];
figure()
for i=1:height(GaitData)
    if GaitData{i, 1}.Gender=="M"
        plot(GaitData{i,1}.Height,mean(GaitData{i, 1}.StepLength),'b*');
    else 
        plot(GaitData{i,1}.Height,mean(GaitData{i, 1}.StepLength),'r*');
    end
    height5=[height5; GaitData{i,1}.Height];
    meanStepLength5=[meanStepLength5;mean(GaitData{i, 1}.StepLength)];
    hold on
end
xlabel('height [cm]')
ylabel('mean step length [m]')
legend('M','F','Location','best')
xlim([min(height5)-2 max(height5)+2])

[rho,pval] = corr(height5,meanStepLength5);
