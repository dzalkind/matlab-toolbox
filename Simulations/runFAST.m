%% runFAST.m
% This script is for running single matlab simulations, to mimic
% runFAST_pywrapper.py for tinkering & quick manual tuning

clear;


fast.FAST_exe          = '/Users/dzalkind/Tools/openfast/install/bin/openfast';
fast.FAST_SFuncDir     = '/Users/dzalkind/Tools/openfast-sim/glue-codes/simulink/src';  %%%% NEED FOR SIMULINK
fast.FAST_InputFile    = 'UM_DLC0_100.fst';   % FAST input file (ext=.fst)
fast.FAST_directory    = '/Users/dzalkind/Tools/WISDEM/UMaine/DLCs';   % Path to fst directory files
fast.FAST_runDirectory = '/Users/dzalkind/Tools/matlab-toolbox/Simulations/SaveData';

% Simulation Parameters
simu.Use_Simulink       = 1;
simu.SimModel           = '/Users/dzalkind/Tools/matlab-toolbox/Simulations/SimulinkModels/ROSCO';
simu.ParamScript        = '/Users/dzalkind/Tools/matlab-tools/Simulations/SimulinkModels/load_ROSCO_params';
simu.DebugSim           = 1;  % use when running/testing/editing main file

if 1 % give a specific name
    fast.FAST_namingOut = 'case100_sim';
else
    % give a datestr name
end

%% Edits
% edit.<module shortcut> = {'<label>',<val>}  with a row for each edit
% FA -> FAST
% ED -> ElastoDyn
% AD -> AeroDyn
% SD -> ServoDyn
% RO -> ROSCO
% HD -> HydroDyn


edits.FA = {
    'TMax',      100;
    };

edits.ED = {
%     'PtfmSgDOF',    'False';
%     'PtfmSwDOF',     'False';
%     'PtfmHvDOF',    'False';
%     'PtfmRDOF',     'False';
%     'PtfmPDOF',    'False';
%     'PtfmYDOF',      'False';
    };

edits.RO = {
%     'SS_VSGain', 2;
    };

edits.SD = {
    
    };



%% File Settings

copyAirfoils = 0;


%% Simulink Setup

if simu.Use_Simulink
    [ControlScriptPath,ControScript] = fileparts(simu.ParamScript);
    addpath(ControlScriptPath);
    
    % append edits.SD
    simedits    = {
        'PCMode',    4;
        'VSContrl',  4;
        'HSSBrMode',  4;
        'GenModel',  1;
        'GenTiStr',  'False';
        'GenTiStp',  'True';
        'SpdGenOn',  1;
        'YCMode',  4;
        
        };
    edits.SD = [edits.SD;simedits];
    
    % add SFunc path
    addpath(fast.FAST_SFuncDir);
    
    % copy simulink file being run
    copyfile([simu.SimModel,'.mdl'],[fast.FAST_runDirectory, filesep, fast.FAST_namingOut, '.mdl']);
    
end



%% Read and Write New Files

if ~exist(fast.FAST_runDirectory,'dir')
    mkdir(fast.FAST_runDirectory)
end

[P,F] = ReadWrite_FAST(fast,edits,copyAirfoils);

simu.dt     = GetFASTPar(P.FP,'DT');
simu.TMax   = GetFASTPar(P.FP,'TMax');
if simu.Use_Simulink
    eval(ControScript);        % Run as script for meow
end


%% Premake OutList for Simulink

OutList = {'Time'};
OutList = [OutList;
    P.IWP.OutList;
    P.EDP.OutList;
    P.ADP.OutList;
    P.SvDP.OutList;
    P.HDP.OutList;
    ];

for iOut = 2:length(OutList)
    OutList{iOut} = OutList{iOut}(2:end-1); %strip "s
end


%% Exectute FAST

if simu.Use_Simulink

    
    FAST_InputFileName = [fast.FAST_runDirectory,filesep,fast.FAST_namingOut,'.fst'];
    TMax               = simu.TMax;
    
    
    
    if 1
        SimulinkModel = simu.SimModel;
    else
        SimulinkModel = [fast.FAST_runDirectory, filesep, fast.FAST_namingOut];
    end
    
    Out         = sim(SimulinkModel, 'StopTime',num2str(GetFASTPar(P.FP,'TMax')));
    sigsOut     = get(Out,'sigsOut');
    
else
    system([fast.FAST_exe, ' ', fast.FAST_runDirectory, filesep, fast.FAST_namingOut,'.fst']);
    
    % rename ROSCO debug file
    movefile('DEBUG.dbg',fullfile(fast.FAST_runDirectory,[fast.FAST_namingOut,'.RO.out']));
end



%% Post Process

post.Scripts = {
    'A4_8_SetPlotChannels';
    'Signals = ROSCOout2Matlab(fullfile(fast.FAST_runDirectory,[fast.FAST_namingOut,''.RO.out'']));'
    'A4_GetSimSignals';
    'A4_8_Plot_Channels';
    'A4_8_Plot_Signals';
    'A4_8_SaveLite';
    };

% Plot
% PlotFASToutput(FASTfiles,FASTfilesDesc,ReferenceFile,Channels,ShowLegend,CustomHdr,PlotPSDs,OnePlot)
% 
% Channels = {'Wind1VelX','GenTq','BldPitch1','GenPwr','GenSpeed','RootMyb1','TwrBsMyt','PtfmPitch'};
% outdata = PlotFASToutput([fast.FAST_runDirectory,filesep,fast.FAST_namingOut,'.out'],{'test'},1,Channels);

% Get Out Data
if simu.Use_Simulink
    SFuncOutStr = '.SFunc';
else
    SFuncOutStr = '';
end

[OutData,OutList] = ReadFASTtext([fast.FAST_runDirectory,filesep,fast.FAST_namingOut,SFuncOutStr,'.out']);

PLOT = 1;

for iPP = 1:length(post.Scripts)
    eval(post.Scripts{iPP});
end




