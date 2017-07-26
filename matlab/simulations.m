function plot()

    clear all;
    close all;
    

    
    %----------------------------------------------------
    % theory simulations consistency
    %----------------------------------------------------
    eta =0.0002;
    d = 0.00005;
    [x2,y2,error2] = theory_simulations(eta,d);
    eta = 0.0008;
    d = 0.00005;
    [x3,y3,error3] = theory_simulations(eta,d);
    
    hFig = figure(1);
    histogram(error2,'Normalization','cdf','DisplayName','Simulations \sigma_\eta=0.0002');
    hold on
    plot(x2,y2,'LineWidth',2,'DisplayName','Theory \sigma_\eta=0.0002');
    hold on 
    histogram(error3,'Normalization','cdf','DisplayName','Simulations \sigma_\eta=0.0008');
    hold on
    plot(x3,y3,'LineWidth',2,'DisplayName','Theory \sigma_\eta=0.0008');
    hold on 
    grid on
    set(gca,'FontSize',16);
    xlabel('\gamma');
    ylabel('CDF');
    xlim([-3 2]);
    legend('show')
    set(hFig, 'Position', [0 0 600 300])    
    %Save Figure
    %print(hFig,'sim-theory','-depsc2')
    
    eta = 8e-04;
    d = 41*(1e-5);
    eta_ss = eta^2;
    d_ss = d^2;
    %----------------------------------------------------
    % period vs variance
    %----------------------------------------------------
    hFig = figure(2);
    subplot(1,2,1);
    alpha = 1;
    period=[1:1:25];
    variance = get_variance(eta_ss,d_ss,period,alpha);
    plot(period,variance,'LineWidth',2);
    grid on
    set(gca,'FontSize',16);
    xlabel({'Communication period \tau (second)'});
    ylabel({'\sigma^2_\gamma (second^2)'});
    xlim([1 25]);
    ylim([0 15e-5])
    %set(gca,'XTick',[0:10:100]);
    %set(hFig, 'Position', [0 0 600 300]);
    
    % Save Figure
    print(hFig,'period-vs-variance','-depsc2')

    %----------------------------------------------------
    % alpha vs variance
    %----------------------------------------------------
    alpha=[0:0.01:2]
    period=1;
    variance = get_variance(eta_ss,d_ss,period,alpha);

    %hFig = figure(2);
    subplot(1,2,2);
    variance = get_variance(eta_ss/16,d_ss,period,alpha);
    plot(alpha,variance,'LineWidth',1.5,'DisplayName','\sigma_\eta=2e-04');
    hold on
    variance = get_variance(eta_ss,d_ss,period,alpha);
    plot(alpha,variance,':','LineWidth',1.5,'DisplayName','\sigma_\eta=8e-04');
    hold on
    variance = get_variance(eta_ss*16,d_ss,period,alpha);
    plot(alpha,variance,'LineWidth',1.5,'DisplayName','\sigma_\eta=32e-04');
    grid on
    set(gca,'FontSize',16);
    xlabel({'Integral Gain \beta'});
    ylabel({'\sigma^2_\gamma (second^2)'});
    ylim([0 15e-5])
    %set(gca,'xscale','log');
    set(hFig, 'Position', [0 0 1000 300])
    legend('show')
    % Save Figure
    print(hFig,'alpha-period-vs-variance','-depsc2')
    
    %----------------------------------------------------
    % alpha + period vs variance
    %----------------------------------------------------
    hFig = figure(3);
    period=[1:1:1000];
    alpha=logspace(-6,-3);
    [t,a]=meshgrid(period,alpha);
    variance = get_variance(eta_ss,d_ss,t,a);

    surf(a,t,variance);
    set(gca,'FontSize',16)
    ylabel({'Probability'});
    xlabel({'Integral Gain \beta'});
    zlabel({'Steady-State Variance (second^2)'});
    set(gca,'xscale','log');
    %colorbar('northoutside');
    colorbar;
    rotate3d on
    shading interp
    set(gca,'yscale','log');
    set(hFig, 'Position', [0 0 700 500]);
    
    % Save Figure
     %print(hFig,'alpha-period-vs-variance','-depsc2')     
end

function var = get_variance(var_eta,var_d,period,alpha)

    var = period.^2-alpha.*(period.^3)+(alpha.^2).*(period.^4)/3;
    var = var*var_eta;
    var = var + var_d*(alpha.^2).*period;
    var = var./(2*alpha-(alpha.^2).*period);
    var = var + 1/3*var_eta*(period.^3)+var_d;
end

function [x,y,error]=theory_simulations(eta_s,d_s)

    alpha = 0.000001;
    period=1;
     
    num_iterations = 1000;
    error = [];
    
    for i= 1:num_iterations
        error(i) = system_evolution(eta_s,d_s,period,alpha);
    end
        
    % normal plot of the error distribution
    sigma_error = sqrt(get_variance(eta_s^2,d_s^2,period,alpha))
    pd = makedist('Normal',0,sigma_error);    
    x = [-sigma_error*5:.0001:sigma_error*5];
    y = cdf(pd,x);
end

function result = system_evolution(eta_s,d_s,d,beta)

    num_iterations = 100;
    theta = [0];
    delta = [0];
    
    for i = 1:num_iterations
        [phi_h, omega_h] = generate_random_vars(eta_s);
        epsilon = d_s.*randn(1);
        delta(i+1) = (1-beta*d)*delta(i)-beta*(omega_h+epsilon)+phi_h;
        theta(i+1) = delta(i)*d+omega_h + epsilon;
    end
    
    result = theta(num_iterations);
end

function [phi_h, omega_h] = generate_random_vars(s_eta)
    num_integral_iterations = 100; 
    
    eta_matrix = s_eta.*randn(1,num_integral_iterations);
    phi_h = sum(eta_matrix);
    
    omega_h = 0;
    for i = 1:num_integral_iterations
        omega_h = omega_h + sum(eta_matrix(1:i));
    end
end