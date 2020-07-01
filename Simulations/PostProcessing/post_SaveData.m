%% A4_8_SaveData
% Inputs: fast, 
%    parameters to be saved: Chan, P, OutData, OutDataM, OutList, fast,
%    edits, 
%  TO ADD: sigsOut

if ~isfield(fast,'FAST_runDirectory')  % write output to input directory
    fast.FAST_runDirectory = fast.FAST_directory;
end


if ~isfield(fast,'FAST_namingOut')  % keep output name
    fast.FAST_namingOut = fast.FAST_InputFile;
end

if ~exist('R','var')
    R = [];
end

if ~exist('F','var')
    F = [];
end

if ~exist('sigsOut','var')
    sigsOut = [];
end

if ~exist('Dist','var')
    Dist = [];
end

if ~exist('Param','var')
    if exist('P','var')
        Param = P;
    else
        Param = [];
    end
end

save(fullfile(fast.FAST_runDirectory,[fast.FAST_namingOut,'.mat']),...
    'Param','Dist','R','F','post','Chan','OutData','OutList','fast','sigsOut','Signals');

    
%         save(fullfile(fast.FAST_runDirectory,[fast.FAST_namingOut,'.mat']),...
%         'Simulation','Parameters','Disturbance','PP','Chan','OutData','OutList',...
%         'TorqueControlParams','PitchControlParams','OLControlParams','DOF','sigsOut');


