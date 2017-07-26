function frequency_testbed
    clear all;
    close all;

    % Open the comma seperated data file - [Timestamp Port]
    fileID = fopen('testbed data/w1_DC.csv');
    file = textscan(fileID,'%f %d', 'Delimiter', ',');
    fclose(fileID);

    wisp1_DC_t  = cell2mat(file(1,1));
    
    fileID = fopen('testbed data/w2_DC.csv');
    file = textscan(fileID,'%f %d', 'Delimiter', ',');
    fclose(fileID);
    
    wisp2_DC_t  = cell2mat(file(1,1));

    fileID = fopen('testbed data/w1_RF.csv');
    file = textscan(fileID,'%f %d', 'Delimiter', ',');
    fclose(fileID);

    wisp1_RF_t  = cell2mat(file(1,1));
    
    fileID = fopen('testbed data/w2_RF.csv');
    file = textscan(fileID,'%f %d', 'Delimiter', ',');
    fclose(fileID);

    wisp2_RF_t  = cell2mat(file(1,1));
    %------------------------------------------------------

    drift_dc = get_drift(wisp1_DC_t);
    drift_rf = get_drift(wisp1_RF_t);
    
    freq_dc = get_freq(wisp1_DC_t);
    freq_rf = get_freq(wisp1_RF_t);
    
    freq_dc_2 = get_freq(wisp2_DC_t);
    freq_rf_2 = get_freq(wisp2_RF_t);
    
    %------------------------------------------------------
    hFig = figure('DefaultAxesFontSize',18);
    subplot(1,2,2);
    plot(1:size(drift_dc),drift_dc,'DisplayName','DC Voltage','LineWidth',1.5);
    %hold on
    %plot(1:size(drift_rf),drift_rf,'DisplayName','RF Power','LineWidth',1.5);
    xlabel('Time (second)')
    ylabel('Drift (microsec.)')
    xlim([1 100])   
    %set(gca,'YTick',[1:10]); 
    grid on
    %legend('show')
    %set(hFig, 'Position', [0 0 600 300])
    
    subplot(1,2,1);
    %hFig = figure('DefaultAxesFontSize',18);
    plot(1:size(freq_dc),freq_dc,'DisplayName','DC Voltage','LineWidth',1.5);
    hold on
    plot(1:size(freq_rf),freq_rf,'DisplayName','RF Power','LineWidth',1.5);
    xlabel('Time (second)')
    ylabel('Freq (Hz)')
    %set(gca,'YTick',[1:10]); 
    grid on
    legend('show')
    set(hFig, 'Position', [0 0 1000 300])
    %ylim([0 10])
    xlim([1 100])   
    
    %------------------------------------------------------
    % RF vs DC clock frequency
    %------------------------------------------------------    
    hFig = figure('DefaultAxesFontSize',18);
    plot(1:size(freq_dc),freq_dc,'DisplayName','DC Voltage','LineWidth',1.5);
    hold on
    plot(1:size(freq_rf),freq_rf,'DisplayName','RF Power','LineWidth',1.5);
    xlabel('Time (second)')
    ylabel('Frequency (Hz)')
    grid on
    legend('show')
    set(hFig, 'Position', [0 0 600 300])
    %ylim([0 10])
    %xlim([1 ])   
    print(hFig,'clock_frequency_dc_rf','-depsc2')
    
    mean(freq_dc)
    mean(freq_rf)
    std(freq_dc)
    std(freq_rf)
    
    %------------------------------------------------------
    % 2 WISP Tags related plots - relative clock freq
    %------------------------------------------------------
    hFig = figure('DefaultAxesFontSize',18);
    subplot(1,2,1);
    %hFig = figure('DefaultAxesFontSize',18);
    plot(1:size(freq_rf),freq_rf,'DisplayName','WISP 1','LineWidth',1.5);
    hold on
    plot(1:size(freq_rf_2),freq_rf_2,'DisplayName','WISP 2','LineWidth',1.5);
    xlim([1 130]);
    xlabel('Time (second)')
    ylabel('Frequency (Hz)')
    %set(gca,'YTick',[1:10]); 
    grid on
    legend('show')
    
    subplot(1,2,2);
    relative_f = freq_rf(1:end-1)./freq_rf_2-1;
    %hFig = figure('DefaultAxesFontSize',18);
    plot(1:size(relative_f),relative_f,'DisplayName','Realtive Freq.','LineWidth',1.5);
    xlim([1 130]);
    xlabel('Time (second)')
    ylabel('Relative Frequency')
    grid on
    set(hFig, 'Position', [0 0 1000 300])
    
    print(hFig,'relative_clock_frequency','-depsc2')    
    
    %fit the values into normal distribution
    [muhat,sigmahat,muci,sigmaci] = normfit(relative_f,0.01)
    
    mean(freq_rf)
    mean(freq_rf_2)
    std(freq_rf)
    std(freq_rf_2)
    
end
%-----------------------------------------
% calculates the clock drift
%-----------------------------------------
function drift = get_drift(wisp_t)
    % calculate the pairwise difference
    period = wisp_t(2:end);
    period = period-wisp_t(1:end-1);
    period = period(2:end);
    % calculate the pairwise difference of pairwise differences
    drift = period(2:end);
    drift = 1000000*(drift-period(1:end-1));
    drift = drift-mean(drift);
end

%-----------------------------------------
% calculates the clock frequency
%-----------------------------------------
function freq = get_freq(wisp_t)
    % calculate the pairwise difference
    period = wisp_t(2:end);
    period = period-wisp_t(1:end-1);
    period = period(2:end);
    freq = 1./period;
end

