clear all;
close all;
fileID = fopen('testbed data/blockwrite_delay.txt','r');
[A] = fscanf(fileID, ['%d'])
A = A/10000; % from 10MHZ sample rate to milliseconds

Diff = [];
m = 1;
while (m+8)<numel(A)
    
    X = A(m);
    Y = A(m+7);
    diff = Y-X;
    m = m+8;
    Diff = [Diff diff];
end
hFig = figure(1)
h = histogram(Diff,'Normalization','probability');
h.NumBins = 20;

[muhat,sigmahat,muci,sigmaci] = normfit(Diff,0.01)
xlabel('Delay (ms)')
ylabel('Normalized num. of occurence')
set(gca,'FontSize',18)
set(hFig, 'Position', [0 0 600 300])
grid on

