function FuncCutting()
%{
#313,#318,#325,#326,#330,#337,#384,#389    
%}

close all;
clear;

directorySession = uigetdir('','Select sentencer set');

if directorySession == 0
    disp('Quit, as session selection cancelled.');
    close;
    return;
end

directoryBase = uigetdir('','Select destination folder to save');

%directorySession = '/Users/tomoya/Documents/MATLAB/balance_F02';

[path, sessionId, ext] = fileparts(directorySession); % sessionId : filename except for extension 

%fileList = dir([directorySession filesep 'balance_F02_A' filesep '*.lab']); % filesep = '/'
fileList = dir([directorySession filesep '*.lab']);

while isempty(fileList) % comfirm whether folder is empty
        
    drssnButton = questdlg('Session not found. Try again?','','Yes','Quit','Yes');
    
    if strcmp(drssnButton,'Yes')
        directorySession = uigetdir;
        
        if directorySession == 0
            disp('Quit, as session selection cancelled.');
            close;
            return;
        end
        
        
        [path, sessionId ,ext] = fileparts(directorySession);
        
        fileList = dir([directorySession filesep '*.lab']);
            
    else
        disp('Quit, as session selection cancelled.');
        close;
        return;
    end
            
end

%%

for fileCtr = 1:size(fileList) % Main loop
         
    if fileCtr == 313 || fileCtr == 318 || fileCtr == 325 || fileCtr == 326 || fileCtr == 330 || fileCtr == 337 || fileCtr == 384 || fileCtr == 389 % Anger
        continue;
    end
        
        
    fileNameZlab = fileList(fileCtr).name;      
    fnCompos = strsplit(fileNameZlab,'_');
    sentenceId = [fnCompos{1,1} '_' fnCompos{1,2} '_' fnCompos{1,3} '_' fnCompos{1,4}];
    sentenceIdc = [fnCompos{1,1} '_' fnCompos{1,2} '_' fnCompos{1,3} '_cut_' fnCompos{1,4}];
    
    [path, fileId, ext] = fileparts(sentenceId);
    [path, fileIdc, ext] = fileparts(sentenceIdc);

    fileNameZwav = [fileId '.wav'];
    fileNameCwav = [fileIdc '.wav'];      
        
    inputFilePath = [directorySession filesep fileNameZlab];   
    fileID = fopen(inputFilePath);
    Cz = textscan(fileID, '%f %f %s');
    fclose(fileID);
    
    inputFilePath = [directorySession filesep fileNameZwav];
    [z, Fs] = audioread(inputFilePath);
        
    [Cz_timeset, tbz, tez] = extract_chunk(Cz);
    z1 = cutting(z, tbz, tez, Fs);
        
    cd ~/
    cd (directoryBase)
    audiowrite(fileNameCwav, z1, Fs);
        
end % End of main loop

end