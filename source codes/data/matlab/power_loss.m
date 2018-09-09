clear all;
close all;
fid = fopen('testbed data/stable_voltage.txt','r');

Period = 7086.0;   % Period of the event
Elapsed = 0.0;  % The hardware time of the next event

alpha = 1.0;     % Integral gain
alpha2 = 1.0;     % Integral gain
beta = 0.0001;
sample = 0;

m=1;

while(~feof(fid))
  A = fgetl(fid);
  HC = hex2dec(A(1:4));     % Read hardware clock 
 
  Elapsed = HC;  % Expected next event time
  sample = sample + 1;
  if((10<sample && sample<20) ||(30<sample && sample<40))
      E1(m) = 0;
      m=m+1;
      alpha2 = 1.0;
      continue
  end
   
  for k = 6:6
      
    HC = hex2dec(A(k*4+1:k*4+4));   % The hardware time of current event
    
    if(HC < Elapsed)
        Elapsed = HC + 2^16 - Elapsed;
    else
        Elapsed = HC - Elapsed;
    end
        
    E1(m) = alpha*Elapsed - Period;
    E2(m) = alpha2*Elapsed - Period;
    alpha = alpha - beta*E1(m) ;    
    alpha2 = alpha2 - beta*E2(m) ;    
    
    m=m+1;
    
  end
end

E1 = abs(E1);
E1(E1 > 65000) = [];
mean(E1)
E2 = abs(E2);
E2(E2 > 65000) = [];
mean(E2)


hFig = figure(1);

plot(E2,'r-.','LineWidth',1.7),
hold on
plot(E1,'b');
hold on;
text(11,5,'Power Loss','FontSize',13)
hold on
text(30.5,5,'Power Loss','FontSize',13)


xlim([0 50]);
ylim([0 120]);

xlabel('Samples');
ylabel('\gamma (clock ticks)');
h_legend = legend('w/o State Recovery', 'State Recovery');
set(h_legend,'FontSize',15);
grid on
set(gca,'FontSize',18);
set(hFig, 'Position', [0 0 600 300]);

print(hFig,'power_loss','-depsc2')
