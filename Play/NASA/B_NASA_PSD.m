%% B_NASA_PSD
% Loop through NASA TMD simulations and extract PSD info
clear;


fast.FAST_directory    = '/Users/dzalkind/Tools/SaveData/NASA/DLC_1/TMD_/';   % Path to fst directory files

%% File Processing
% Rename MD out files for now, so they don't interfere

outMD_files = dir([fast.FAST_directory,'*.MD.out']);

% rename MD.out files
for iFile = 1:length(outMD_files)
    fname = outMD_files(iFile).name;
    new_fname = regexprep(fname,'.MD.out','.MDout');
    movefile(fullfile(outMD_files(iFile).folder,fname), ...
        fullfile(outMD_files(iFile).folder,new_fname));
end

outRO_files = dir([fast.FAST_directory,'*.RO.out']);
% rename RO.out files
for iFile = 1:length(outRO_files)
    fname = outRO_files(iFile).name;
    new_fname = regexprep(fname,'.RO.out','.ROout');
    movefile(fullfile(outRO_files(iFile).folder,fname), ...
        fullfile(outRO_files(iFile).folder,new_fname));
end

% find files
out_files = dir([fast.FAST_directory,'*.out']);


%% Loop Through Files and Collect Info
POST_PROCESS = 1;
PLOT = 0;

B_Outs  = {'Wave_P_Max', 'PP.PSD(1).SpecMax';
             'Wave_F_Max', 'PP.PSD(1).FreqMax';
             'Hv_P_Max', 'PP.PSD(2).SpecMax';
             'Hv_F_Max', 'PP.PSD(2).FreqMax';
             };

for iFile = 1:length(out_files)
    
    outfiles    = dir(fullfile(fast.FAST_directory,[out_files(iFile).name]));
    [~,~,ext]   = fileparts(out_files(1).name);
    fast.FAST_InputFile = regexprep(out_files(1).name,'.out','.fst');
    
    if strcmp(ext,'.outb')
        [OutData,OutList] = ReadFASTbinary(fullfile(fast.FAST_directory,[out_files(iFile).name]));
    else
        [OutData,OutList] = ReadFASTtext(fullfile(fast.FAST_directory,[out_files(iFile).name]));
    end
    
    
    % Post Process
    if POST_PROCESS
        
        post.Scripts = {
            'post_SetPlotChannels';
%             'Signals = ROSCOout2Matlab(fullfile(fast.FAST_directory,[fast.FAST_InputFile,''.RO.out'']));'
%             'post_GetSimSignals';
            'post_PlotChannels';
%             'post_PlotSignals';
            'post_PSD';
            'post_SaveData';
            };
        
        for iPP = 1:length(post.Scripts)
            eval(post.Scripts{iPP});
        end
        
        
        for iOut = 1:size(B_Outs,1)
            B.(B_Outs{iOut,1})(iFile) = eval(B_Outs{iOut,2});            
        end
        
        
        
    end
        
end

clearvars POST_PROCESS