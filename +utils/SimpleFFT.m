function [fftResult, frequenciesHz] = SimpleFFT(signal, duration)
    %%%
    % fftResult: the signal fft (frequency domain information)
    % frequencies: the associated frequencies
    % signal: input signal (time domain)
    % duration: timespan over which signal occurred (seconds)
    %%%

    fftResult = fft(signal);

    %Initialize frequencies
    nonzeroFrequencyCount = floor((length(signal)-1)/2);
    frequenciesHz = zeros(1,length(signal));
    baseFrequency = 1/duration;
    for i = 1:nonzeroFrequencyCount
        frequency = i * baseFrequency;
        frequenciesHz(i+1) = frequency;
        frequenciesHz(end+1-i) = frequency;
    end

    %Check for missing center frequency
    if mod(length(signal),2)==0
        %Set missing frequency value
        frequenciesHz(1 + length(signal)/2) = (1 + nonzeroFrequencyCount) * baseFrequency;
    end
end