clear, clc, close all

% --- Impostazioni ---
folderPath = 'long-term-movement-monitoring-database-1.0.0\LabWalks'; % Percorso della cartella
filePattern = 'co*_base.hea'; % Pattern per trovare i file header (assumiamo uno per soggetto/registrazione)

% --- Trova tutti i file .hea nella cartella ---
heaFiles = dir(fullfile(folderPath, filePattern)); 
% --- Inizializza una struttura per contenere i dati di tutti i soggetti ---
allSubjectData = struct();

% --- Ciclo su ogni file .hea trovato ---
for i = 1:length(heaFiles)
    heaFileName = heaFiles(i).name;
    % Estrai il nome base del record (senza estensione .hea)
    [~, baseRecordName, ~] = fileparts(heaFileName);
    % Costruisci il percorso completo per rdsamp (senza estensione)
    recordPath = fullfile(folderPath, baseRecordName);
        % Leggi i dati per il record corrente
        [signalData, Fs, tm] = rdsamp(recordPath);
        
        % Salva i dati nella struttura principale
        allSubjectData.(baseRecordName).data = signalData;
        allSubjectData.(baseRecordName).fs = Fs;
        allSubjectData.(baseRecordName).time = tm;
end

save('LabCOData',"allSubjectData")