clear,clc,close all

disp('Es1')
load('final result.mat')
blCO = [2,3,13,16,28,40];
blFL = [47,50,51,55,58,59,66,68,70] -40;

walking_percentage_CO(blCO) = [];
walking_percentage_FL(blFL) = [];
walking_percentage_CO = walking_percentage_CO';
walking_percentage_FL = walking_percentage_FL';

total_steps_CO(blCO) = [];
total_steps_FL(blFL) = [];
stride_time_CO(blCO) = [];
stride_time_FL(blFL) = [];

% figure
% boxplot([walking_percentage_CO walking_percentage_FL],{'CTRL','FALLERS'});
% title('boxplot');
%by convention, we label as zero the control subjects (the negative class),
%and as 1 the subjects with disease (the positive class).
labels=[zeros(length(walking_percentage_CO),1);ones(length(walking_percentage_FL),1)];

%let'use 10 as threshold
threshold = 0.82979; % perc
[Sens,Spec,Acc, LRpos, LRneg]=computePerformanceThreshold([walking_percentage_CO;walking_percentage_FL],labels,threshold);
disp(['Sens= ' num2str(Sens) '; Spec= ' num2str(Spec) '; Acc= ' num2str(Acc)]);

figure
%custom version of ROC curve
[X1,Y1,T1,AUC1]=computeRoc(walking_percentage_CO,walking_percentage_FL);
 hold on
 %prepare data for matlab function
 disp(['custom AUC is ' num2str(AUC1)]); 
 datamv=[walking_percentage_CO;walking_percentage_FL];
 [X2,Y2,T2,AUC2] = perfcurve(labels,datamv,1);
 plot(X2,Y2,'--o');

  disp(['matlab AUC is ' num2str(AUC2)]);
 
 disp('Youden Index:')
 [YI, sensYI, specYI,threshYI]= computeYoudenIndex(X1,Y1,T1);
 disp(['the threshold value that maximizes YI is: ' num2str(threshYI)]);
 plot(1-specYI,sensYI,'ko','markersize',10);
  legend('custom','matlab','YI');

 