function qy = FuncExchangeF0(rcy, qy, wly, rcz, qz, wlz)
%x = E_Ctrl(y, rcy, qy, fy, wly, rz, rcz, qz, wlz, Fs)
%x = E_Ctrl(rcy, qy, fy, wly, rcz, qz, wlz)
%y:原音声 z:目的感情音声
%resampleを使用してf0の長さを調整
%f0を大きい変化と小さい変化に分解してから統合:smooth
%全体の長さを調節

    ly = length(qy.temporalPositions); % frame length
    lz = length(qz.temporalPositions);
    
    zf0Sample = FuncSmoothF0(qz.f0, rcz, wlz/lz, wlz); % Smoothing : analytic z's f0 components
    zf0Sample = zf0Sample(:);

    %tmp = qy.temporalPositions;
    %qy.temporalPositions = qy.temporalPositions*(lz/ly); 
    
    %zf0Sample = interp(zf0Sample, ly); % interpolation by 'interp'
    %zf0Sample = decimate(zf0Sample, lz); % decimation by 'decimate'
    zf0Sample = resample(zf0Sample, ly, lz);
    plot(zf0Sample)
    
    yf0Sample = FuncSmoothF0(qy.f0, rcy, wly/ly, wly); % Smoothing : analytic y's f0 components
    yf0Sample = yf0Sample(:);
    figure
    plot(yf0Sample)
    
    qy.f0 = qy.f0 - yf0Sample + zf0Sample; % integration

    num = find(qy.f0 < min(zf0Sample));
    for i = 1:length(num)
        qy.f0(num(i)) = min(zf0Sample);
    end
    
end