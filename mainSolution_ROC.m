clear
close all

disp('Es1')
load StaticPosturography.mat

%we only show results for MV in this solution
figure; 
plot(ones(length(mv_ctrl),1),mv_ctrl,'og');
hold on
plot(ones(length(mv_pd),1),mv_pd,'xr');
legend('CTRL','PD');
title('scatter plot');

figure
boxplot([mv_ctrl mv_pd],{'CTRL','PD'});
title('boxplot');
%by convention, we label as zero the control subjects (the negative class),
%and as 1 the subjects with disease (the positive class).
labels=[zeros(length(mv_ctrl),1);ones(length(mv_pd),1)];

%let'use 10 as threshold
[Sens,Spec,Acc, LRpos, LRneg]=computePerformanceThreshold([mv_ctrl;mv_pd],labels,10);
disp(['Sens= ' num2str(Sens) '; Spec= ' num2str(Spec) '; Acc= ' num2str(Acc)]);

figure
%custom version of ROC curve
[X1,Y1,T1,AUC1]=computeRoc(mv_ctrl,mv_pd);
 hold on
 %prepare data for matlab function
 disp(['custom AUC is ' num2str(AUC1)]); 
 datamv=[mv_ctrl;mv_pd];
 [X2,Y2,T2,AUC2] = perfcurve(labels,datamv,1);
 plot(X2,Y2,'--o');

  disp(['matlab AUC is ' num2str(AUC2)]);
 
 disp('Youden Index:')
 [YI, sensYI, specYI,threshYI]= computeYoudenIndex(X1,Y1,T1);
 disp(['the threshold value that maximizes YI is: ' num2str(threshYI)]);
 plot(1-specYI,sensYI,'ko','markersize',10);
  legend('custom','matlab','YI');

 