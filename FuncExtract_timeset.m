function timeset = FuncExtract_timeset(Cy_timetable, Cz_timetable, ry)
%変化の仕方がCzで長さがCyのtemporalPositionsを作成する

temPos = 0:.005:Cy_timetable(end); % 0.005刻み。末尾にはCy_timeset(end)を切り捨てた値が入る

%以下3つから選択
timeset = pchip(Cy_timetable, Cz_timetable, temPos); % pchip
%timeset = makima(Cy_timetable, Cz_timetable, temPos); % makima
%timeset = interp1(Cy_timetable, Cz_timetable, temPos, 'linear');

ly = length(ry.temporalPositions);
lp = length(timeset);

if lp ~= ly  % 長さの微調整
    if lp > ly
        overlen = lp - ly;
        timeset = timeset(1:end-overlen);
        %temPos = temPos(1:end-overlen);
    else
        disp('length error')
        timeset = 0;
        %temPos = 0;
        return
    end
end
    
end