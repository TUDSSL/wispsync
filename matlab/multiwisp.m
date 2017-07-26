function simulations
    clear all;
    close all;
    
    [x_all y_all x_2 y_2]= calculate_sync_error();
    
    hFig = figure('DefaultAxesFontSize',18);
    plot(x_all,y_all,':','DisplayName','Max. \gamma (3 Wisps)','LineWidth',2);
    hold on 
    plot(x_2,y_2,'DisplayName','Max. \gamma (2 Wisps)','LineWidth',1.5);
    hold on 
    plot(x_all,repmat(mean(y_all),numel(x_all),1),'--','DisplayName','Avg. \gamma (3 Wisps)','LineWidth',1);
    hold on
    plot(x_2,repmat(mean(y_2),numel(x_2),1),'-.','DisplayName','Avg. \gamma (2 Wisps)','LineWidth',1);
    xlabel('Time (second)')
    ylabel('\gamma (ms)')
    %set(gca,'YTick',[1:10]);
    grid on
    legend('show')
    set(hFig, 'Position', [0 0 600 300])
    ylim([0 10])
    xlim([4 max(x_all)])
    
    print(hFig,'multiwisp-experiments','-depsc2')
end

function [x1 y1 x2 y2] = calculate_sync_error()
    % Open the comma seperated data file - [Timestamp Ch1 Ch2 Ch3]
    fileID = fopen('testbed data/3w.csv');
    file = textscan(fileID,'%f %d %d %d', 'Delimiter', ',');
    fclose(fileID);

    timestamps = 1000.0*cell2mat(file(1,1)); % in ms
    wisp1 = cell2mat(file(1,2));
    wisp2 = cell2mat(file(1,3));
    wisp3 = cell2mat(file(1,4));

    % reset on and off times
    starts = zeros(3,1);
    ends =  zeros(3,1);

    x1 = [];
    y1 = [];
    
    x2 = [];
    y2 = [];

    for i = 1:size(timestamps)
        
        

        % save on and off times of the ports
        if(starts(1) == 0 && wisp1(i) == 1)
            starts(1) = timestamps(i);
        elseif (starts(1) > 0 && ends(1) == 0 && wisp1(i) == 0)
            ends(1) = timestamps(i);
        end

        if(starts(2) == 0 && wisp2(i) == 1)
            starts(2) = timestamps(i);
        elseif (starts(2) > 0 && ends(2) == 0 && wisp2(i) == 0)
            ends(2) = timestamps(i);
        end

         if(starts(3) == 0 && wisp3(i) == 1)
             starts(3) = timestamps(i);
         elseif (starts(3) > 0 && ends(3) == 0 && wisp3(i) == 0)
             ends(3) = timestamps(i);
         end


        % the point where all channels are 0
        if(wisp1(i) == 0 && wisp2(i)==0 && wisp3(i)==0)
            
            % always consider th 3rd unsynchronized wisp
            if(starts(3) ~=0 && ends(3)~=0)
                starts_all = starts(starts>0);
                ends_all = ends(ends>0);

                start_diff = max(max(abs(bsxfun(@minus,starts_all,starts_all.'))));
                end_diff = max(max(abs(bsxfun(@minus,ends_all,ends_all.'))));
                max_error = max(start_diff,end_diff);
                max_error = end_diff;

                if(numel(starts)>=2 && ~isempty(max_error))
                        x1 = [x1 round(timestamps(i)/1000)];
                        y1 = [y1 max_error];
                end
            end
            
           
            
            if(starts(1) ~=0 && ends(1)~=0 && starts(2) ~=0 && ends(2)~=0)
                % remove the last wisp 3
                starts = starts(1:end-1);
                ends = ends(1:end-1);

                starts_2 = starts(starts>0);
                ends_2 = ends(ends>0);

                start_diff = max(max(abs(bsxfun(@minus,starts_2,starts_2.'))));
                end_diff = max(max(abs(bsxfun(@minus,ends_2,ends_2.'))));
                max_error = max(start_diff,end_diff);
                max_error = end_diff;
                
                if(max_error<1)
                    max_error
                    i
                end
                

                if(numel(starts_2) >= 2 && ~isempty(max_error))
                        x2 = [x2 round(timestamps(i)/1000)];
                        y2 = [y2 max_error];
                end
            end
            
            

            % reset start and end times
            starts = zeros(3,1);
            ends =  zeros(3,1);
        end    
    end

end


