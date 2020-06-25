%% post_All
% Set up and run all the post processing scripts you want

post.Scripts = {
    'post_SetPlotChannels';
    'Signals = ROSCOout2Matlab(fullfile(fast.FAST_runDirectory,[fast.FAST_namingOut,''.RO.out'']));'
    'post_GetSimSignals';
    'post_PlotChannels';
    'post_PlotSignals';
    'post_SaveData';
    };

% Plot
% PlotFASToutput(FASTfiles,FASTfilesDesc,ReferenceFile,Channels,ShowLegend,CustomHdr,PlotPSDs,OnePlot)
% 
% Channels = {'Wind1VelX','GenTq','BldPitch1','GenPwr','GenSpeed','RootMyb1','TwrBsMyt','PtfmPitch'};
% outdata = PlotFASToutput([fast.FAST_runDirectory,filesep,fast.FAST_namingOut,'.out'],{'test'},1,Channels);


PLOT = 1;

for iPP = 1:length(post.Scripts)
    eval(post.Scripts{iPP});
end
