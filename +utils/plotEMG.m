function [] = plotEMG(data)
    %%%
    % Plots an EMG time series signal with the current centered at 0
    %%%
    figure;
    load(data, 'dataArray');
    v = dataArray(:,1);
    t = dataArray(:,2);
    t = t / 60;
    v = v - 128;
    v = v ./ 256 .* 5;
    plot(t,v);
    title('Sample EMG');
    xlabel('Time (min)');
    ylabel('Signal (V)');
end