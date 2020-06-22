%% Plot Channels
% This is a terrible script, should be commented

TIGHT = 0;  %create tighter subplots for presentations, etc.
% PLOT = 1;   %to hide plot if 0

WARNING = 0;

nPlots = length(PP.Channels);
h = cell(1,nPlots);
if ~exist('Chan')
    Chan = struct;
end

%initialize figHandles
if ~exist('figHandles')
    figHandles = gobjects(1,nPlots);
elseif sum(isvalid(figHandles)) ~= nPlots
    figHandles = gobjects(1,nPlots);
end

if ~exist('OutData')
    OutData = struct;
    disp('OutData is not loaded, either have CART data or you will have a bad time');
    OutData.signals.values(:,1) = Chan.tt;
end

if ~exist('OutList')
    OutList = {};
end

% Reformulate OutData if raw matrix
if isnumeric(OutData)
    OutDataM = OutData;
    OutData = struct();
    OutData.time = OutDataM(:,1);
    OutData.signals.values = OutDataM;
end

Chan.tt = OutData.signals.values(:,1);
for iPlot = 1:nPlots
    nChannels = length(PP.Channels{iPlot});
    if TIGHT && PLOT
        % create figure or set figure(iPlot) to current figure without
        % bringing it up
        if  ~isgraphics(figHandles(iPlot))
            figHandles(iPlot) = figure(iPlot);
        else
            set(0,'CurrentFigure',figHandles(iPlot));
        end
        
        if ~PP.TimePlot.hold || isempty(get(gcf,'Children'))
            h{iPlot}=tight_subplot(nChannels,1,.015,.1,.15);
        else
            h{iPlot} = flipud(get(gcf,'Children'));
        end
    end
    for iChannel = 1:nChannels
        if PLOT
            if ~TIGHT
                % create figure or set figure(iPlot) to current figure without
                % bringing it up
                if ~isgraphics(figHandles(iPlot))
                    figHandles(iPlot) = figure(iPlot);
                else
                    set(0,'CurrentFigure',figHandles(iPlot));
                end
                subplot(nChannels,1,iChannel);
            else
                axes(h{iPlot}(iChannel));
            end
        end
        
        %% Collect Data & Plot
        dat_ind = strmatch(PP.Channels{iPlot}{iChannel}{1},OutList,'exact');
        if isempty(dat_ind) %&& isempty(PP.Channels{iPlot}{iChannel}{2})
            if WARNING
                disp([PP.Channels{iPlot}{iChannel}{1},' isnt in OutList']);
            end
            if isfield(Chan,PP.Channels{iPlot}{iChannel}{1})
                if WARNING
                    disp(['but it has been calculated...plotting']);
                end
                
                
                if isempty(PP.Channels{iPlot}{iChannel}{2})
                    eval(['dat=Chan.',PP.Channels{iPlot}{iChannel}{1},';'])
                else
                    eval(['dat=Chan.',PP.Channels{iPlot}{iChannel}{1},'*PP.Channels{iPlot}{iChannel}{2};'])
                end
                
                %copy of later code, functions not available in current
                %matlab version
                if PLOT
                    plot(Chan.tt,dat,'LineWidth',2);
                    ylabel(PP.Channels{iPlot}{iChannel}{1});
                    if ~isempty('PP.TimePlot.Xlim'), xlim(PP.TimePlot.Xlim); end
                    if PP.TimePlot.hold, hold on; end
                    if iChannel ~= nChannels
                        set(gca,'XTickLabel',{})
                    end
                    
                end
                if TIGHT && PLOT
                    axis tight;
                    if ~isempty('PP.TimePlot.Xlim'), xlim(PP.TimePlot.Xlim); end
                    if PP.TimePlot.hold, hold on; end
                    if iChannel ~= nChannels
                        set(gca,'XTickLabel',{})
                    end
                end
                
                grid on;
            end
            
        else
            if isempty(PP.Channels{iPlot}{iChannel}{2})
                dat = OutData.signals.values(:,dat_ind);
            else
                dat = OutData.signals.values(:,dat_ind)*PP.Channels{iPlot}{iChannel}{2};
            end
            eval(['Chan.',PP.Channels{iPlot}{iChannel}{1},'=','dat;'])
            %% Do Plotting
            if PLOT
                %             plot(tt,dat);
                plot(Chan.tt,dat,'LineWidth',2);
                if TIGHT
                    axis tight;
                else
                    ylabel(PP.Channels{iPlot}{iChannel}{1});
                end
                if iChannel ~= nChannels
                    set(gca,'XTickLabel',{})
                end
                %             grid on;
                if ~isempty('PP.TimePlot.Xlim'), xlim(PP.TimePlot.Xlim); end
                if PP.TimePlot.hold, hold on; end
            end
        end
        
    end %iChannel
    if PLOT
        xlabel('Time [s]');
    end
end %iPlot


%% Cleanup
clearvars dat dat_ind iChan iChannel iPlot nChannels nPlots WARNING TIGHT
