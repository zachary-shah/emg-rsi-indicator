function [] = analyzeEmgData(inputFile, lowFreq, highFreq, binsPerSecond, emgCount, samplesPerPoint, outputFile) 
    
    %ANALYZEEMGDATA converts a Raw EMG into the time-series representation of a mean PSD of a specific frequency band
    %
    % inputFile: name of input csv file with EMG signal in first column,
    % time data in second column (needs to be in subfolder called RawEMG)
    %
    % lowFreq: parameter for the lower frequency in the passband select
    % region for power analysis
    %
    % highFreq: parameter for the higher frequency in the passband select
    % region for power analysis
    %
    % binsPerSecond: number of frequency bins desired per second for FFT
    % analysis (assume 1 if you are not sure what to put - this will
    % calculate a unique FFT for each 1-second length segment in the signal
    %
    % emgCount: number of distinct EMGs in data file
    %
    % samplesPerPoint: number of elements desired to be averaged into one sample 
    %
    % outputFile:name of output csv file with time (in sec) in first column,
    % and the frequency band power at that time in the second column (must
    % have folder called FrequencyOut for file to be written into)
    %
    % EXAMPLE COMMAND PROMPT: 
    % fatigueCalc('S01_2Emg60Seconds.csv', 24, 28, 1, 1, 'S01_2Emg60SecondFrequency24-48Hz.csv')
    % This reads in a file at '_data/RawEMG/S01_2Emg60Seconds.csv', analyzes 
    % band power from 24 to 48 Hz with one frequency bin per second, 
    % and writes to file at '_data/FrequencyOut/S01_2Emg60SecondFrequency24-48Hz.csv'.

    import utils.*

    % extract data from table
    table = readtable(fullfile("_data", "RawEMG",inputFile),'PreserveVariableNames',true);
    data = [];
    headers = {};
    for n = 0:(emgCount-1)
        
        signal = (table.(2*n+1))';
        time = (table.(2*n+2))';

        % get sampling rate and total length of signal, in seconds 
        T = mean(time) * 1e-6;
        fs = 1/T;
        timeLen = round(length(signal)/fs, 0);

        % convert timestep to cumulative time passed
        time = cumsum(time) .* 10e-6 / 10;

        % normalize time data to start at 0 and end as close as possible to timeLen
        time = time - (time(end) - timeLen);
        time = time - time(1);
        timeLen = timeLen - 1;

        % initialize frequency bins array
        frequencyBins = zeros(1, timeLen*binsPerSecond);

        % high frequency band cutoff must not exceed fs/(binsPerSecond*2)
        if (highFreq > (fs/(binsPerSecond*2)))
            fprintf('High frequency band cutoff must not exceed fs/(binsPerSecond*2)');
            return;
        elseif (lowFreq >= highFreq) 
            fprintf('High frequency band parameter must exceed low frequency band parameter.');
            return;
        end

        % calculate fft for each frequency bin
        for c = 1:length(frequencyBins)

            % get signal piece
            sigBin = signal(((c-1)*round(fs/binsPerSecond, 0) + 1):(c*round(fs/binsPerSecond, 0)));

            % run FFT on signal
            [fftResult, frequenciesHz] = utils.SimpleFFT(sigBin, 1);

            % mask for frequency band
            freqMask = ((frequenciesHz <= highFreq) & (frequenciesHz >= lowFreq));

            % find powers at each frequency in signal
            powers = abs(fftResult).^2 / ((length(sigBin))^2);

            % get vector of only frequencies in freq band mask
            frequencyBin = powers(freqMask);

            % sum elements in band to get absolute band power 
            frequencyBins(c) = (sum(frequencyBin));

        end
        
        data = [data, (0:(length(frequencyBins)-1))', frequencyBins'];
        headers = [headers strcat('Time #', num2str((n+1)), ' (s)'), strcat('Signal #', num2str(n+1), '- ', num2str(lowFreq),'-',num2str(highFreq),'Hz Frequency Power')];
    end
    
    % create export csv for data analysis
    dataOut = num2cell(data);
    output = [headers;dataOut];
    T = cell2table(output(2:end,:),'VariableNames',output(1,:));
    writetable(T,fullfile("_data", "FrequencyOut", string(outputFile)));

end


