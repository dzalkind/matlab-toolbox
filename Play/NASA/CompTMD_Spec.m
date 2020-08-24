%% Compare TMD Configs

clear;

Sims = {
    '/Users/dzalkind/Tools/SaveData/NASA/TMD_/TMD__126.out'
    '/Users/dzalkind/Tools/SaveData/NASA/TMD_B/TMD_B_126.out'
    };


%% Loop Through Sims and Compare

B_Outs  = {'Wave_P_Max', 'PP.PSD(1).SpecMax';
    'Wave_F_Max', 'PP.PSD(1).FreqMax';
    'Hv_P_Max', 'PP.PSD(2).SpecMax';
    'Hv_F_Max', 'PP.PSD(2).FreqMax';
    };


for iSim = 1:length(Sims)
    
    % Get OutData
    
    [~,~,ext]   = fileparts(Sims{iSim});
    
    if strcmp(ext,'.outb')
        [OutData,OutList] = ReadFASTbinary(Sims{iSim});
    else
        [OutData,OutList] = ReadFASTtext(Sims{iSim});
    end
    
    
    % Post Process
    if 1
        
        post.Scripts = {
            'post_SetPlotChannels';
%             'Signals = ROSCOout2Matlab(fullfile(fast.FAST_directory,[fast.FAST_InputFile,''.RO.out'']));'
%             'post_GetSimSignals';
            'post_PlotChannels';
%             'post_PlotSignals';
%             'post_SaveData';
            'post_PSD';
            };
        
        
        PLOT = 1;
        
        for iPP = 1:length(post.Scripts)
            eval(post.Scripts{iPP});
        end
    end
    
    for iOut = 1:size(B_Outs,1)
        B.(B_Outs{iOut,1})(iSim) = eval(B_Outs{iOut,2});
    end
    
    
    
end
