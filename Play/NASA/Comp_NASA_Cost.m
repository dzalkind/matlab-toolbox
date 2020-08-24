%% CompNASA_Cost

clear;
close all;

%% Select Out Files


if 1   % manual
    
    % Different TMDs
    outfiles = {
        '/Users/dzalkind/Tools/SaveData/NASA/DLC_1/TMD_/TMD__126.out';        
        '/Users/dzalkind/Tools/SaveData/NASA/DLC_1/TMD_A/TMD_A_126.out';
%         '/Users/dzalkind/Tools/SaveData/NASA/DLC_1/TMD_B/TMD_B_126.out';
%         '/Users/dzalkind/Tools/SaveData/NASA/DLC_1/TMD_C/TMD_C_126.out';
        };
    
%     % different wind speeds
%     outfiles = {
%         '/Users/dzalkind/Tools/SaveData/NASA/DLC_1/TMD_A/TMD_A_126.out';        % ETM, 24 m/s
%         '/Users/dzalkind/Tools/SaveData/NASA/DLC_1/TMD_A/TMD_A_120.out';        % ETM, 22 m/s
%         '/Users/dzalkind/Tools/SaveData/NASA/DLC_1/TMD_A/TMD_A_114.out';        % ETM, 20 m/s
%         '/Users/dzalkind/Tools/SaveData/NASA/DLC_1/TMD_A/TMD_A_108.out';        % ETM, 18 m/s
%         };
    
%     % different wind/wave seeds, 24 m/s
%     outfiles = {
%         '/Users/dzalkind/Tools/SaveData/NASA/DLC_1/TMD_A/TMD_A_126.out';        % ETM, 24 m/s
%         '/Users/dzalkind/Tools/SaveData/NASA/DLC_1/TMD_A/TMD_A_127.out';        % ETM, 22 m/s
%         '/Users/dzalkind/Tools/SaveData/NASA/DLC_1/TMD_A/TMD_A_128.out';        % ETM, 20 m/s
%         '/Users/dzalkind/Tools/SaveData/NASA/DLC_1/TMD_A/TMD_A_129.out';        % ETM, 18 m/s
%         };
    
else
    out_file_struct = dir('/Users/dzalkind/Tools/SaveData/NASA/DLC_1/TMD_/*.out');
    
    for iFile = 1:length(out_file_struct)
        outfiles{iFile} = fullfile(out_file_struct(iFile).folder,out_file_struct(iFile).name);
    end
    
end



%% Run nasa_control_cost on all & compare



for iFile = 1:length(outfiles)
    
    
    [C(iFile),PSD] = nasa_control_cost(outfiles{iFile});
    
    
    
    
end


