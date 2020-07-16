%% Look at Floating Pitch Command

figure(700);
plot(Chan.tt,Signals.FA_Acc,Chan.tt,Signals.FA_AccF)
% ylim([-.05,.05]);

figure(701);
plot(Chan.tt,Signals.FA_AccF);


for it = 1:length(Chan.tt)
    if it == 1
        FA_vel(it) = 0;
    else
    
        FA_vel(it) = FA_vel(it-1) + simu.dt * Signals.FA_AccF(it);
    end
end

figure(702);
plot(Chan.tt,Signals.FA_AccF);
hold on;
plot(Chan.tt, FA_vel);
hold off;

figure(703);
plot(Chan.tt,-FA_vel * -9.3635, Chan.tt, Signals.Fl_Pitcom);


%%
% iChan = length(PP.Channels) + 1;
% 
% PP.Channels{iChan}          =  {
%     {'NcIMURAys',           []}
%     };
%     
% PLOT = 0;
% 
% post_PlotChannels;
% 
% figure(704);
% plot(Chan.tt,deg2rad(Chan.NcIMURAys));
% 
% hold on;
% plot(Chan.tt,Signals.FA_Acc);
% hold off;
