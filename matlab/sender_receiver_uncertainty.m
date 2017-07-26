clear all;
close all;
fileID = fopen('testbed data/sender_receiver_uncertainty.txt','r');
[A] = fscanf(fileID, ['%d']);
A = A/10000; % from 10MHZ sample rate to milliseconds

hFig = figure(1);

h = histogram(A,'Normalization','probability');
h.NumBins = 50;
xlim([1.80 2.4]);

hold on 
A(A > 2.1) = [];
A(A < 1.8) = [];

[muhat,sigmahat,muci,sigmaci] = normfit(A,0.01)
pd = fitdist(A,'Normal');
x_values = 1.4:0.001:2.4;
y = pdf(pd,x_values);
y = y ./h.NumBins;
plot(x_values,y,'LineWidth',2)

ylim([0 0.5]);

xlabel('Delay (ms)')
ylabel('Normalized num. of occurence')
legend('Frequency of the transmission delay', 'Normal fit function')
set(gca,'FontSize',18)
set(hFig, 'Position', [0 0 600 300])
grid on