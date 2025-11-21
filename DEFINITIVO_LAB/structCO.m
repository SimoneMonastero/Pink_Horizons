clear, clc, close all

folderPath = 'long-term-movement-monitoring-database-1.0.0\LabWalks'; % Path to the folder
filePattern = 'co*_base.hea'; % Pattern to find header files (assuming one per subject/recording)

% Find all .hea files in the folder
heaFiles = dir(fullfile(folderPath, filePattern)); 
% Initialize struct
allSubjectData = struct();

% Loop over each .hea file found
for i = 1:length(heaFiles)
    heaFileName = heaFiles(i).name;
    % Extract the base record name (without .hea extension)
    [~, baseRecordName, ~] = fileparts(heaFileName);
    % Build full path for rdsamp (without extension)
    recordPath = fullfile(folderPath, baseRecordName);
        % Read data for the current record
        [signalData, Fs, tm] = rdsamp(recordPath);
        
        % Save data in the main structure
        allSubjectData.(baseRecordName).data = signalData;
        allSubjectData.(baseRecordName).fs = Fs;
        allSubjectData.(baseRecordName).time = tm;
end


save('LabCOData',"allSubjectData")
