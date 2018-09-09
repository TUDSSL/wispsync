clear all;
close all;
fid = fopen('testbed data/stable_voltage.txt','r');

Period = 7086.0;   % Period of the event
Elapsed = 0.0;  % The hardware time of the next event

alpha = 1.0;     % Integral gain
beta = 0.0001;

m=1;

while(~feof(fid))
  A = fgetl(fid);
  HC = hex2dec(A(1:4));     % Read hardware clock 
 
  Elapsed = HC;  % Expected next event time
   
  for k = 6:6
      
    HC = hex2dec(A(k*4+1:k*4+4));   % The hardware time of current event
    
    if(HC < Elapsed)
        Elapsed = HC + 2^16 - Elapsed;
    else
        Elapsed = HC - Elapsed;
    end
    
    E(m) = Period - Elapsed;             % The error between expected and actual time
    
    E1(m) = alpha*Elapsed - Period;
    alpha = alpha - beta*E1(m) ;    
    
    m=m+1;
    
    end
end

E = abs(E);
E1 = abs(E1);
E1(E1 > 65000) = [];
m1 = mean(E)
m2 = mean(E1)

hFig = figure(1);
plot(E,'r--o','LineWidth',1);
hold on
plot(E1,'r-.','LineWidth',1);
hold on

fid = fopen('testbed data/unstable_voltage.txt','r');


Period = 7118.0;   % Period of the event
Elapsed = 0.0;  % The hardware time of the next event

alpha = 1.0;     % Integral gain
beta = 0.0001;

m=1;

while(~feof(fid))
  A = fgetl(fid);
  HC = hex2dec(A(1:4));     % Read hardware clock 
 
  Elapsed = HC;  % Expected next event time
   
  for k = 6:6
      
    HC = hex2dec(A(k*4+1:k*4+4));   % The hardware time of current event
    
    if(HC < Elapsed)
        Elapsed = HC + 2^16 - Elapsed;
    else
        Elapsed = HC - Elapsed;
    end
    
    E(m) = Period - Elapsed;             % The error between expected and actual time
    
    E1(m) = alpha*Elapsed - Period;
    alpha = alpha - beta*E1(m);     
    
    m=m+1;
    
    end
end

E = abs(E);
E1 = abs(E1);
E1(E1 > 65000) = [];
m3 = mean(E)
m4 = mean(E1)

figure(1);
hold on
plot(E,'b-o','LineWidth',1);
hold on
plot(E1,'b','LineWidth',1);

hold on
plot(repmat(m1,numel(E),1),'r-.','LineWidth',1);
hold on
plot(repmat(m2,numel(E),1),'r-.','LineWidth',1);
hold on
plot(repmat(m3,numel(E),1),'b','LineWidth',1);
hold on
plot(repmat(m4,numel(E),1),'b','LineWidth',1);

xlim([2 80]);
ylim([0 250]);

xlabel('Samples');
ylabel('\gamma (clock ticks)');
%ylabel(sprintf('Synchronization error \n (clock ticks)'));
h_legend = legend('w/o Synch.', 'Sync.','w/o Synch. (RF)', 'Sync. (RF)',...
    'Orientation','horizontal','Location','northoutside');
set(h_legend,'FontSize',15);

set(gca,'FontSize',18);
set(hFig, 'Position', [0 0 600 400]);
grid on

% Save Figure
print(hFig,'synchronization_accuracy','-depsc2')