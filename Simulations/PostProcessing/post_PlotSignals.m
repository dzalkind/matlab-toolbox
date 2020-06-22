%% A4_8_Plot_Signals
% Plot signals in Signal.<> struct according to post_SetPlotChannels

% PLOT = 1;

for iFig = 1:length(PP.Signals)
    
    
    
    figure(600+iFig);
    
    
    for iSub = 1:length(PP.Signals{iFig})
        subplot(length(PP.Signals{iFig}),1,iSub);
        
        try
            dat = Signals.(PP.Signals{iFig}{iSub}{1});
            tt = Signals.Time;
            
            if PP.TimePlot.hold, hold on; end
            plot(tt,dat);
            if ~isempty('PP.TimePlot.Xlim'), xlim(PP.TimePlot.Xlim); end
            
            ylabel(PP.Signals{iFig}{iSub}{1})
        catch
            disp([(PP.Signals{iFig}{iSub}{1}),' not in Signals.<>']);
        end

        
    end
end

%% Cleanup

clearvars iFig iSub