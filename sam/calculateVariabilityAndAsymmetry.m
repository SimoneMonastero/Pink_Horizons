function [StepTimeV, StepTimeA]=calculateVariabilityAndAsymmetry(StepTime)
ind_Left=[1:2:length(StepTime)-1];
ind_Right=[2:2:length(StepTime)];
StepTimeLeft=StepTime(:,ind_Left);
StepTimeRight=StepTime(:,ind_Right);
% variability
StepTimeV=std(StepTime);
% asymmetry
StepTimeA=abs(mean(StepTimeLeft)-mean(StepTimeRight));