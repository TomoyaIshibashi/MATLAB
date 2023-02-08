function FuncReplace_temPos()
% x1:変換後音声(Replace_temPos), y1:原音声(チャンク), z1:目的感情音声(チャンク), Cy_timetable:原音声の時間情報(チャンク),
% Cz_timetable:目的感情音声の時間情報(チャンク), timepchip:resample後のtemporalPositions

close all; 
clear;

OriginalvoiceFolder = uigetdir('','Select original voice set');

if OriginalvoiceFolder == 0
    disp('Quit, as session selection cancelled.');
    close;
    return;
end

TargetvoiceFolder = uigetdir('','Select target voice set');

if TargetvoiceFolder == 0
    disp('Quit, as session selection cancelled.');
    close;
    return;
end

directoryBase = uigetdir('','Select destination folder to save');

fileList_original = dir([OriginalvoiceFolder  filesep '*.lab']);
    
while isempty(fileList_original)
        
    drssnButton = questdlg('Session not found. Try again?','','Yes','Quit','Yes');
        
    if strcmp(drssnButton,'Yes')
        directorySession = uigetdir;
        
        if directorySession == 0
            disp('Quit, as session selection cancelled.');
            close;
            return;
        end
        
        
        [~, ~ ,~] = fileparts(OriginalvoiceFolder);
        
        fileList = dir([OriginalvoiceFolder filesep '*.wav']);
            
    else
        disp('Quit, as session selection cancelled.');
        close;
        return;
    end
            
end

fileList_target = dir([TargetvoiceFolder filesep '*.lab']);

for fileCtr = 1:size(fileList_original) % Main loop

    fileNameYlab = fileList_original(fileCtr).name;
    fileNameZlab = fileList_target(fileCtr).name;
    fnComposY = strsplit(fileNameYlab,'_');
    fnComposZ = strsplit(fileNameZlab,'_');
    sentenceIdy = [fnComposY{1,1} '_' fnComposY{1,2} '_' fnComposY{1,3} '_' fnComposY{1,4}];
    sentenceIdx = [fnComposY{1,1} '_' fnComposY{1,2} '_' fnComposY{1,3} '_' fnComposZ{1,3} '_Rt_' fnComposY{1,4}]; 
              
    [~, fileIdy, ~] = fileparts(sentenceIdy); % fileId : filename except for extension
    [~, fileIdx, ~] = fileparts(sentenceIdx);
        
    fileNameYwav = [fileIdy '.wav'];
    fileNameXwav = [fileIdx '.wav'];   
        
    inputFilePath = [OriginalvoiceFolder filesep fileNameYlab];   
    fileID = fopen(inputFilePath);
    Cy = textscan(fileID, '%f %f %s');
    fclose(fileID);
    
    inputFilePath = [OriginalvoiceFolder filesep fileNameYwav];
    [y, Fs] = audioread(inputFilePath);
        
    [Cy_timeset, tby, tey] = extract_chunk(Cy); % チャンクの時間情報系列を抽出
    Cy_timetable = Cy_timeset{1,1} - Cy_timeset{1,1}(1,1); % 時間情報の先頭を0にする

    inputFilePath = [TargetvoiceFolder filesep fileNameZlab];
    fileID = fopen(inputFilePath);
    Cz = textscan(fileID, '%f %f %s');
    fclose(fileID);
        
    [Cz_timeset, ~, ~] = extract_chunk(Cz); % チャンクの時間情報系列を抽出 timeset:時刻情報と音素
    Cz_timetable = Cz_timeset{1,1} - Cz_timeset{1,1}(1,1); % 時間情報の先頭を0にする timetable:時刻情報のみ
        
        
    if length(Cy_timetable) ~= length(Cz_timetable)
        disp('Error : Length of two elements is different')
        disp(fnComposY{1,4})
        clearvars -except OriginalvoiceFolder TargetvoiceFolder directoryBase fileCtr fileList_original fileList_target
        continue
    end
        
    y1 = cutting(y, tby, tey, Fs); % 原音声のチャンク抽出
        
    [ry, ~, qy, fy, ~] = FuncAnalysisTandemStraight(y1, Fs, 0, 0);
        
    timeset = FuncExtimeset_linear(Cy_timetable, Cz_timetable, ry); % linear/pchip/makima
        
    if timeset == 0
        disp(fnComposY{1,4})
        clearvars -except OriginalvoiceFolder TargetvoiceFolder directoryBase fileCtr fileList_original fileList_target
        continue
    end
        
    qy.temporalPositions = timeset;
        
    [~, x1] = FuncSynthesisTandemStraight(qy,fy); % resynthesis

    cd '~/'
    cd (directoryBase)
    audiowrite(fileNameXwav, x1, Fs);     
    clearvars -except OriginalvoiceFolder TargetvoiceFolder directoryBase fileCtr fileList_original fileList_target
        
end % End of main loop
    
end