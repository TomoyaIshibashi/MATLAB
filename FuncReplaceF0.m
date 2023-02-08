function FuncReplaceF0()
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

fileList_original = dir([OriginalvoiceFolder filesep '*.lab']);
    
while isempty(fileList_original)
        
    drssnButton = questdlg('Session not found. Try again?','','Yes','Quit','Yes');
        
    if strcmp(drssnButton,'Yes')
        directorySession = uigetdir;
        
        if directorySession == 0
            disp('Quit, as session selection cancelled.');
            close;
            return;
        end
        
        
        [path, sessionId ,ext] = fileparts(OriginalvoiceFolder);
        
        fileList_original = dir([OriginalvoiceFolder filesep '*.wav']);
            
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
    sentenceIdz = [fnComposZ{1,1} '_' fnComposZ{1,2} '_' fnComposZ{1,3} '_' fnComposZ{1,4}];
    sentenceIdx = [fnComposY{1,1} '_' fnComposY{1,2} '_' fnComposY{1,3} '_' fnComposZ{1,3} '_RF_' fnComposY{1,4}]; 
              
    [path, fileIdy, ext] = fileparts(sentenceIdy); % fileId : filename except for extension
    [path, fileIdz, ext] = fileparts(sentenceIdz);
    [path, fileIdx, ext] = fileparts(sentenceIdx);
        
    fileNameYwav = [fileIdy '.wav'];
    fileNameZwav = [fileIdz '.wav'];
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
    
    inputFilePath = [TargetvoiceFolder filesep fileNameZwav];
    [z, Fs] = audioread(inputFilePath);
        
    [Cz_timeset, tbz, tez] = extract_chunk(Cz); % チャンクの時間情報系列を抽出 timeset:時刻情報と音素
    Cz_timetable = Cz_timeset{1,1} - Cz_timeset{1,1}(1,1); % 時間情報の先頭を0にする timetable:時刻情報のみ
        
        
    if length(Cy_timetable) ~= length(Cz_timetable)
        disp('error')
        disp(fnComposY{1,4})
        clearvars -except OriginalvoiceFolder TargetvoiceFolder directoryBase fileCtr fileList_original fileList_target
        continue
    end
        
    y1 = cutting(y, tby, tey, Fs); % 原音声のチャンク抽出
    z1 = cutting(z, tbz, tez, Fs);
        
    [rz, rcz, qz, fz, wlz] = FuncAnalysisTandemStraight(z1, Fs, 0, 0);
    clearvars -except OriginalvoiceFolder TargetvoiceFolder directoryBase fileCtr fileList_original fileList_target rcz qz wlz y1 Fs fileNameXwav
    [ry, rcy, qy, fy, wly] = FuncAnalysisTandemStraight(y1, Fs, 0, 0);
    qy = FuncExchangeF0(rcy, qy, wly, rcz, qz, wlz); % replace F0
    [x, x1] = FuncSynthesisTandemStraight(qy,fy); % resynthesis

    cd '~/'
    cd (directoryBase)
    audiowrite(fileNameXwav, x, Fs);     
    clearvars -except OriginalvoiceFolder TargetvoiceFolder directoryBase fileCtr fileList_original fileList_target
        
end % End of main loop
    
end