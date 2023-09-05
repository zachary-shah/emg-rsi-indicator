function [] = collectEmgData(usbPortName, subjectName, expGroup)
    %COLLECTDATA collects a 15 minute EMG sample from an Arduino aquisition circuit connected to the USB port of the local computer
    %
    % usbPortName: string name of the usb port to which the Arduino is connected
    %
    % subjectName: string name of subject tested
    %       - make sure to capitalize name / keep consistent between groups
    %
    % expGroup: string experimental group type for subject's data 
    %       - must be either 'Control', 'Interspersed', or 'Continuous'. 
    %       - make sure to capitalize first letter
    %
    % EXAMPLE COMMAND PROMPT: 
    % [d, e] = collectData("/dev/cu.usbserial-1110", 'S01', 'Control');
    % This writes all 15 mins of data to 'rawS01Control.mat'
    
    % Initialize timing factors
    numMins = 15;
    timeLength = numMins*60; %number of seconds for recording
    baudrate = 500000;
    fs = 2400; % assume this is approximately correct
    
    % Initialize array output and row position
    dataRowLength = 4;
    dataRowCount = timeLength * fs;
    dataArray = zeros(dataRowCount, dataRowLength);
    dataRow = 1;
    
    % Set up serial (usb) connection and initialize (consecutive) timeout count
    % and errorArray
    arduino = serialport(usbPortName, baudrate, "Timeout", 5);
    timeouts = 0;
    errorArray = cell(1000,3);
    errorRow = 1;

    % Print message initializations
    time = timeLength;
    count = dataRowCount;
    fprintf('Starting in 3...');
    pause(1);
    fprintf('2...');
    pause(1);
    fprintf('1...');
    pause(1);
    fprintf('\nStarting recording... \n');
    
    % Loop until all data collected or maximum number of timeouts exceeded
    while timeouts < 5 && dataRow <= dataRowCount
        
        %Read a single line (data point) from the Arduino
        line = readline(arduino);

        % Check that the line isn't empty (timeout)
        if isstring(line)

            % Received data --> reset timeouts
            timeouts = 0;

            % Split data into relevant pieces and convert to each piece to a
            % number (double)
            data = str2double(split(line, ','));

            % Check that the data element count is correct
            if length(data) == dataRowLength

                % Assign data to dataArray at proper location
                dataArray(dataRow, :) = data;

                % Increment dataRow
                dataRow = dataRow + 1;
                
                % Update time remaining in Command Window
                if (mod(count, fs) == 0) 
                    time = time - 1;
                    printString = strcat('Time remaining: ',num2str(time),'\n');
                    fprintf(printString);
                end
                count = count - 1;
        
            elseif length(data) < dataRowLength

                % Missing data: improperly formatted and possibly a timeout
                errorArray{errorRow} = {dataRow, 'improper format and possible timeout', data};
                errorRow = errorRow + 1;
            else

                % Extraneous data: improperly formatted
                errorArray{errorRow} = {dataRow, 'improper format', data};
                errorRow = errorRow + 1;
            end
        else

            % No data --> timeout
            % Track timeout and associated error
            timeouts = timeouts + 1;
            errorArray(errorRow,:) = {dataRow, 'timeout', NaN};
            errorRow = errorRow + 1;
        end
        
        
        
    end
    
    % Trim dataArray and errorArray to actual size of collected information
    dataArray = dataArray(1:dataRow-1,:);

    % plot signal over time
    dataArray(:,2) =  dataArray(:,2) * 4;
    dataArray(:,4) =  dataArray(:,4) * 4;
    dataArray(:,2) = cumsum(dataArray(:,2) * 1e-6);
    dataArray(:,4) = cumsum(dataArray(:,4) * 1e-6);
    
    % save data
    outputDataString = strcat('raw',subjectName, expGroup, '.mat');
    save(outputDataString, 'dataArray');

end