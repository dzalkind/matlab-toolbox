%% post_WSE_Metrics

DT = simu.dt;

% if ~exist('Signals','var') || ~isfield(Signals,'WE_Vw')
%     Signals.WE_Vw = interp1(Disturbance.tt,Disturbance.u_rot,Chan.tt);
%     Signals.tt = Chan.tt;
% end

if ~isfield(Chan,'RtVAvgxh')
    iChan = length(PP.Channels) + 1;
    
    PP.Channels{iChan}          =  {
        {'RtVAvgxh',           []}
        };
    
    PLOT = 0;
    
    post_PlotChannels;
end

if 1
    figure(800);
    plot(Chan.tt, Chan.RtVAvgxh, Chan.tt, Signals.WE_Vw);
    legend('RtVAvgxh','WSE');
end

indMeas = Chan.tt > 100;

MWS = mean(Signals.WE_Vw);

PP.WSE.eps = Signals.WE_Vw(indMeas) - Chan.RtVAvgxh(indMeas);

PP.WSE.meanError   = mean(PP.WSE.eps);
PP.WSE.varError    = std(PP.WSE.eps)^2;
PP.WSE.meanSqErr   = mean(PP.WSE.eps.^2);
PP.WSE.RDE         = (1- (PP.WSE.varError + PP.WSE.meanError^2)./std(Signals.WE_Vw(indMeas))^2) * 100;


PP.WSE.delay       = finddelay(Signals.WE_Vw(indMeas) - MWS, Chan.RtVAvgxh(indMeas) - MWS) * DT;


%     PP.WSE.meanError   = nan;
%     PP.WSE.varError    = nan;
%     PP.WSE.meanSqErr   = nan;
%     PP.WSE.RDE         = nan;
%
%     PP.WSE.delay       = nan;

