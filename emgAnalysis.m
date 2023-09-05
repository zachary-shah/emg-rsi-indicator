%{
Script to get all subject's data and generate summative plots of the EMGs in various frequency bands

NOTE: The data pulled for this analysis is removed from the public repository for large file storage reasons.

%}

close all;

% list of subjects whose data is in .mat files in current folder
participants = {'S01', 'S02', 'S03', 'S04', 'S05', 'S06', 'S07', 'S08', 'S09', 'S10', 'S11', 'S12'};
n = length(participants);

% initialize figures
figure;
hold on;
subplot(3,2,1)
title("Extensor 136-400Hz Power for Continuous Gaming");
xlabel("time (min)");
ylabel("Power (Normalized)");
subplot(3,2,2)
title("Flexor 136-400Hz Power for Continuous Gaming");
xlabel("time (min)");
ylabel("Power (Normalized)");
subplot(3,2,3)
title("Extensor 136-400Hz Power for Interspersed Gaming");
xlabel("time (min)");
ylabel("Power (Normalized)");
subplot(3,2,4)
title("Flexor 136-400Hz Power for Interspersed Gaming");
xlabel("time (min)");
ylabel("Power (Normalized)");
subplot(3,2,5)
title("Extensor 136-400Hz Power for Control Group");
xlabel("time (min)");
ylabel("Power (Normalized)");
subplot(3,2,6)
title("Flexor 136-400Hz Power for Control Group");
xlabel("time (min)");
ylabel("Power (Normalized)");

% initialize data arrays
exContinuous = zeros(15,length(participants));
exInterspersed = zeros(15,length(participants));
exControl = zeros(15,length(participants));
flContinuous = zeros(15,length(participants));
flInterspersed = zeros(15,length(participants));
flControl = zeros(15,length(participants));

% get normalized data for each participant, plot in subplot figure, and
% save into individual arrays
for i = 1:n
    
    fileName = strcat('PowerOut/powerOut',participants{i},'Continuous','.xlsx');
    table = xlsread(fileName);
    time = table(:,1);
    exContinuous(:,i) = table(:,2);
    flContinuous(:,i) = table(:,4);
    
    fileName = strcat('PowerOut/powerOut',participants{i},'Interspersed','.xlsx');
    table = xlsread(fileName);
    exInterspersed(:,i) = table(:,2);
    flInterspersed(:,i) = table(:,4);
    
    fileName = strcat('PowerOut/powerOut',participants{i},'Control','.xlsx');
    table = xlsread(fileName);
    exControl(:,i) = table(:,2);
    flControl(:,i) = table(:,4);
    
    maxE = max([max(exContinuous(:,i)), max(exInterspersed(:,i)), max(exControl(:,i))]);
    maxF = max([max(flContinuous(:,i)), max(flInterspersed(:,i)), max(flControl(:,i))]);
    
    exContinuous(:,i) = exContinuous(:,i) / maxE;
    flContinuous(:,i) = flContinuous(:,i) / maxF;
    subplot(3,2,1)
    hold on;
    plot(time, exContinuous(:,i));
    subplot(3,2,2)
    hold on;
    plot(time, flContinuous(:,i));
    
    exInterspersed(:,i) = exInterspersed(:,i) / maxE;
    flInterspersed(:,i) = flInterspersed(:,i) / maxF;
    subplot(3,2,3)
    hold on;
    plot(time, exInterspersed(:,i));
    subplot(3,2,4)
    hold on;
    plot(time, flInterspersed(:,i));
    
    exControl(:,i) = exControl(:,i) / maxE;
    flControl(:,i) = flControl(:,i) / maxF;
    subplot(3,2,5)
    hold on;
    plot(time, exControl(:,i));
    subplot(3,2,6)
    hold on;
    plot(time, flControl(:,i));
   
end
hold off; 

% means for each group
exContinuousMean = mean(exContinuous,2);
exInterspersedMean = mean(exInterspersed, 2);
exControlMean = mean(exControl, 2);
flContinuousMean = mean(flContinuous, 2);
flInterspersedMean = mean(flInterspersed, 2);
flControlMean = mean(flControl, 2);

% extract relevant fearues from interspersed group 

exInterspersedNoRest = exInterspersed([1 2 3 6 7 8 11 12 13],:);
flInterspersedNoRest = flInterspersed([1 2 3 6 7 8 11 12 13],:);
timesInterspersed = [0 1 2 5 6 7 10 11 12];
exInterspersedNoRestMean = mean(exInterspersedNoRest, 2);
flInterspersedNoRestMean = mean(flInterspersedNoRest, 2);

% subplots of interspersed data with rests removed
figure;
subplot(2,2,1)
hold on;
title("Extensor 136-400Hz Power for Interspersed Gaming");
xlabel("time (min)");
ylabel("Power (Normalized)");
ylim([0 1]);
subplot(2,2,2)
hold on;
title("Flexor 136-400Hz Power for Interspersed Gaming");
xlabel("time (min)");
ylabel("Power (Normalized)");
ylim([0 1]);

for i = 1:length(timesInterspersed) 
    subplot(2,2,1)
    hold on;
    plot(timesInterspersed, exInterspersedNoRest(:, i));
    subplot(2,2,2)
    hold on; 
    plot(timesInterspersed, flInterspersedNoRest(:, i));
end
hold off;

% subplots of interspersed gaming
subplot(2,2,3)
title("Extensor 136-400Hz Power for Interspersed Gaming");
xlabel("time (min)");
ylabel("Power (Normalized)");
ylim([0 1]);
eINRerr = std(exInterspersedNoRest, 0, 2)/sqrt(length(exInterspersedNoRest));
errorbar(timesInterspersed, exInterspersedNoRestMean, eINRerr);
subplot(2,2,4)
title("Flexor 136-400Hz Power for Interspersed Gaming");
xlabel("time (min)");
ylabel("Power (Normalized)");
ylim([0 1]);
fINRerr = std(flInterspersedNoRest, 0, 2)/sqrt(length(flInterspersedNoRest));
errorbar(timesInterspersed, flInterspersedNoRestMean, fINRerr);


% mean subplots with error bars
figure;
subplot(3,2,1)
hold on;
title("Extensor 136-400Hz Power for Continuous Gaming");
xlabel("time (min)");
ylabel("Power (Normalized)");
ylim([0 0.9]);
eCuerr = std( exContinuous , 0, 2)/sqrt(length( exContinuous ));
errorbar(time, exContinuousMean , eCuerr);
subplot(3,2,2)
hold on;
title("Flexor 136-400Hz Power for Continuous Gaming");
xlabel("time (min)");
ylabel("Power (Normalized)");
ylim([0 0.9]);
fCuerr = std( flContinuous , 0, 2)/sqrt(length( flContinuous ));
errorbar(time, flContinuousMean , fCuerr);
subplot(3,2,3)
hold on;
title("Extensor 136-400Hz Power for Interspersed Gaming");
xlabel("time (min)");
ylabel("Power (Normalized)");
ylim([0 0.9]);
eIerr = std( exInterspersed , 0, 2)/sqrt(length( exInterspersed ));
errorbar(time, exInterspersedMean , eIerr);
subplot(3,2,4)
hold on;
title("Flexor 136-400Hz Power for Interspersed Gaming");
xlabel("time (min)");
ylabel("Power (Normalized)");
ylim([0 0.9]);
fIerr = std( flInterspersed , 0, 2)/sqrt(length( flInterspersed ));
errorbar(time, flInterspersedMean , fIerr);
subplot(3,2,5)
hold on;
title("Extensor 136-400Hz Power for Control Group");
xlabel("time (min)");
ylabel("Power (Normalized)");
ylim([0 0.9]);
eCoerr = std( exControl , 0, 2)/sqrt(length( exControl ));
errorbar(time, exControlMean , eCoerr);
subplot(3,2,6)
hold on;
title("Flexor 136-400Hz Power for Control Group");
xlabel("time (min)");
ylabel("Power (Normalized)");
ylim([0 0.9]);
fCoerr = std( flControl , 0, 2)/sqrt(length( flControl ));
errorbar(time, flControlMean , fCoerr);

% mean subplots with error bars - interspersed has rests removed
lt = 1; %line thickness
figure;
subplot(1,2,1)
hold on;
title("Extensor Radialis Brevis 136-400Hz Mean EMG Power v. Time");
xlabel("Time (min)");
ylabel("Power (Normalized)");
ylim([0 1]);
eCuerr = std( exContinuous , 0, 2)/sqrt(length( exContinuous ));
errorbar(time, exContinuousMean , eCuerr, 'b');
eINRerr = std(exInterspersedNoRest, 0, 2)/sqrt(length(exInterspersedNoRest));
errorbar(timesInterspersed, exInterspersedNoRestMean, eINRerr, 'r');
eCoerr = std( exControl , 0, 2)/sqrt(length( exControl ));
errorbar(time, exControlMean , eCoerr, 'k');
coeffs1 = polyfit(time , exContinuousMean, 1);
yFitted1 = polyval(coeffs1, time);
plot(time, yFitted1, 'b:', 'LineWidth', lt);
coeffs2 = polyfit(timesInterspersed , exInterspersedNoRestMean, 1);
yFitted2 = polyval(coeffs2, time);
plot(time, yFitted2, 'r:', 'LineWidth', lt);
coeffs3 = polyfit(time , exControlMean, 1);
yFitted3 = polyval(coeffs3, time);
plot(time, yFitted3, 'k:', 'LineWidth', lt);
legend('Continuous Gaming','Interspersed Gaming', 'Control Group', 'Continuous Linear Fit (p = 0.00012)', 'Interspersed Linear Fit (p = 0.746)', 'Control Linear Fit (p = 0.135)', 'Location','northeast')

hold off;
subplot(1,2,2)
hold on;
title("Flexor Digitorum Superficialis 136-400Hz Mean EMG Power v. Time");
xlabel("Time (min)");
ylabel("Power (Normalized)");
ylim([0 1]);
fCuerr = std( flContinuous , 0, 2)/sqrt(length( flContinuous ));
errorbar(time, flContinuousMean , fCuerr, 'b');
fINRerr = std(flInterspersedNoRest, 0, 2)/sqrt(length(flInterspersedNoRest));
errorbar(timesInterspersed, flInterspersedNoRestMean, fINRerr, 'r');
fCoerr = std( flControl , 0, 2)/sqrt(length( flControl ));
errorbar(time, flControlMean , fCoerr, 'k');
coeffs1 = polyfit(time , flContinuousMean, 1);
yFitted1 = polyval(coeffs1, time);
plot(time, yFitted1, 'b:', 'LineWidth', lt);
coeffs2 = polyfit(timesInterspersed , flInterspersedNoRestMean, 1);
yFitted2 = polyval(coeffs2, time);
plot(time, yFitted2, 'r:', 'LineWidth', lt);
coeffs3 = polyfit(time , flControlMean, 1);
yFitted3 = polyval(coeffs3, time);
plot(time, yFitted3, 'k:', 'LineWidth', lt);
legend('Continuous Gaming','Interspersed Gaming', 'Control Group', 'Continuous Linear Fit (p = 0.00025)', 'Interspersed Linear Fit (p = 0.664)', 'Control Linear Fit (p = 0.411)', 'Location','northeast')


% linear model regression
mdlflContinuous = fitlm(time, flContinuousMean)
mdlexContinuous = fitlm(time, exContinuousMean)
mdlflInterspersed = fitlm(timesInterspersed, flInterspersedNoRestMean)
mdlexInterspersed = fitlm(timesInterspersed, exInterspersedNoRestMean)
mdlflControl = fitlm(time, flControlMean)
mdlexControl = fitlm(time, exControlMean)

flContinuousT = array2table(flContinuous);
exContinuousT = array2table(exContinuous);
flInterspersedNoRestT = array2table(flInterspersedNoRest);
exInterspersedNoRestT = array2table(exInterspersedNoRest);
flControlT = array2table(flControl);
exControlT = array2table(exControl);

writetable(flContinuousT,'finalData.xlsx','Sheet',1);
writetable(exContinuousT,'finalData.xlsx','Sheet',2);
writetable(flInterspersedNoRestT,'finalData.xlsx','Sheet',3);
writetable(exInterspersedNoRestT,'finalData.xlsx','Sheet',4);
writetable(flControlT,'finalData.xlsx','Sheet',5);
writetable(exControlT,'finalData.xlsx','Sheet',6);


