clc

COOO=[stride_time_CO',total_steps_CO',valid_bouts_CO',walking_percentage_CO',zeros(34,1)];
FLLL=[stride_time_FL',total_steps_FL',valid_bouts_FL',walking_percentage_FL',ones(22,1)];

% Combine the two matrices
combined_data = [COOO; FLLL];

% Define column titles
column_titles = {'Stride Time', 'Total Steps', 'Valid Bouts', 'Walking Percentage', 'Class'};

% Create a table from the combined data
data_table = array2table(combined_data, 'VariableNames', column_titles);

% Save the table as a CSV file
writetable(data_table, 'combined_data.csv');
