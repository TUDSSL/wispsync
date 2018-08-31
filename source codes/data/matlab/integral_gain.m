clear all;
fid = fopen('testbed data/stable_voltage.txt','r');


Period = 7118.0;   % Period of the event
Elapsed = 0.0;  % The hardware time of the next event

alpha1 = 1.0;     % Integral gain
beta1 = 0.0002;

alpha2 = 1.0;     % Integral gain
beta2 = 0.0001;

alpha3 = 1.0;     % Integral gain
beta3 = 0.00005;

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
    
    E1(m) = alpha1*Elapsed - Period;
    alpha1 = alpha1 - beta1*E1(m)     
    
    E2(m) = alpha2*Elapsed - Period;
    alpha2 = alpha2 - beta2*E2(m)     
    
    E3(m) = alpha3*Elapsed - Period;
    alpha3 = alpha3 - beta3*E3(m)    
    
    m=m+1;
       
    end
end

E = abs(E);
E1 = abs(E1);
E2 = abs(E2);
E3 = abs(E3);

hFig = figure(1)
plot(E1,'r--','LineWidth',1.5);
hold on
plot(E2,'b','LineWidth',1.5);
hold on
plot(E3,':','LineWidth',2);




xlim([0 50]);
ylim([0 80]);

xlabel('Samples')
ylabel('\gamma (clock ticks)');
%ylabel(sprintf('$\gamma$ \n (clock ticks)'))
legend('beta=0.0002', 'beta=0.0001','beta=0.00005')
set(gca,'FontSize',18)
set(hFig, 'Position', [0 0 600 300])
grid on

% Save Figure
print(hFig,'integral_gain','-depsc2')