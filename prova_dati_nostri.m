clc
clear all
close all
data_table = readtable('combined_data.csv');

model = fitglm(data_table, 'Class ~ StrideTime + TotalSteps + ValidBouts + WalkingPercentage', 'Distribution', 'binomial'); % logistic regression model
% fitglm: Fits a Generalized Linear Model (GLM)
% Used with 'Distribution','binomial', it performs logistic regression to predict the probability of 'label'

disp(model.Coefficients); 
% Displays estimated coefficients (log-odds), standard errors, t-statistics, and p-values indicating the statistical significance of each predictor

scores = model.Fitted.Probability; % Predicted probabilities (0-1) from the model
labels = data_table.Class;         % True labels (0 or 1)

% The '.' says "Open the 'model' box, then open the 'Fitted' sub-box, and take only the file called 'Probability'"
[X2,Y2,T2,AUC2] = perfcurve(labels, scores, 1);
disp(['AUC = ' num2str(AUC2)]);

[YI, sensYI, specYI_X, threshYI] = computeYoudenIndex(X2, Y2, T2);
% Finds the optimal threshold (threshYI) by maximizing Sensitivity (sensYI) and Specificity (specYI).

specYI = 1 - specYI_X;
% specYI_X is the value on the X-axis of the ROC curve, we are converting the False Positive Rate (specYI_X) into Specificity (specYI).

disp(['The optimal probability threshold is: ' num2str(threshYI)]);
disp(['Sensitivity (Sens) = ' num2str(sensYI)]);
disp(['Specificity (Spec) = ' num2str(specYI)]);

figure;
plot(X2, Y2, 'b-', 'LineWidth', 2);
hold on;
plot([0 1], [0 1], 'k--'); % Random guess line (AUC = 0.5)
title(['ROC of Combined Model (AUC = ' num2str(AUC2) ')']);
xlabel('1 - Specificity');
ylabel('Sensitivity');
legend('Model (our data)', 'Random Guess', 'Location', 'SouthEast');

% Calculate global p-value using the deviance test
tbl = devianceTest(model);

% The test compares the full model against a constant model (intercept only).
% The p-value is usually found in the second row of the resulting table.
global_p_value = tbl.pValue(2);

disp('--------------------------------------------------');
disp(['Global p-value of the model: ' num2str(global_p_value)]);

if global_p_value < 0.05
    disp('The model is globally significant (p < 0.05).');
else
    disp('The model is not globally significant.');
end