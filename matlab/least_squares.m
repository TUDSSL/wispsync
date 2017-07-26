clear all;
close all;

[X Y] = textread('testbed data/least_squares.txt', '%d %d', 'delimiter', ' ')

mean_delay = 59; % the mean transmission delay we measured

Error = [];
m = 9;
while (m+8)<numel(X)
    
    A = X(m:m+7);
    B = Y(m:m+7);
    p = polyfit(A,B,1);
    error = Y(m+8)-polyval(p,X(m+8))
    m = m+8;
    Error = [Error error];
end
Error(Error > 10) = [];
Error(Error < -10) = [];

hFig = figure(1)

histogram(Error);

xlabel('Synchronization error (clock ticks)')
ylabel('Num. of occurence')
set(gca,'FontSize',18)
ylim([0 90]);
set(hFig, 'Position', [0 0 600 300])
grid on
