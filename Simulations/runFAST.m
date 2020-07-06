%% runFAST.m
% This script is for running single matlab simulations, to mimic
% runFAST_pywrapper.py for tinkering & quick manual tuning

clear;

simu.Configuration    = 1;


switch simu.Configuration
    
    case 1
        % IEA 15 MW with ROSCO
        
        fast.FAST_exe          = '/Users/dzalkind/Tools/openfast/install/bin/openfast';
        fast.FAST_SFuncDir     = '/Users/dzalkind/Tools/openfast-sim/glue-codes/simulink/src';  %%%% NEED FOR SIMULINK
        fast.FAST_InputFile    = 'IEA-15-240-RWT-UMaineSemi.fst';   % FAST input file (ext=.fst)
        fast.FAST_directory    = '/Users/dzalkind/Tools/IEA-15-240-RWT/OpenFAST/IEA-15-240-RWT-UMaineSemi';   % Path to fst directory files
        fast.FAST_runDirectory = '/Users/dzalkind/Tools/matlab-toolbox/Simulations/SaveData/StepPlay';
        
        % Simulation Parameters
        simu.Use_Simulink       = 0;
        simu.SimModel           = '/Users/dzalkind/Tools/matlab-toolbox/Simulations/SimulinkModels/ROSCO';
        simu.ParamScript        = '/Users/dzalkind/Tools/matlab-tools/Simulations/SimulinkModels/load_ROSCO_params';
        simu.DebugSim           = 1;  % use when running/testing/editing main file
        
        
    case 2
        % NASA Floater with ROSCO
        
        fast.FAST_exe          = '/Users/dzalkind/Tools/openfast/install-old/bin/openfast';
        fast.FAST_SFuncDir     = '/Users/dzalkind/Tools/openfast-sim/glue-codes/simulink/src';  %%%% NEED FOR SIMULINK
        fast.FAST_InputFile    = 'UM_DLC0_100.fst';   % FAST input file (ext=.fst)
        fast.FAST_directory    = '/Users/dzalkind/Tools/WISDEM/UMaine/DLCs';   % Path to fst directory files
        fast.FAST_runDirectory = '/Users/dzalkind/Tools/matlab-toolbox/Simulations/SaveData';
        
        % Simulation Parameters
        simu.Use_Simulink       = 0;
        
    case 3
        % IEA 15 MW with New ROSCO
        
        fast.FAST_exe          = '/Users/dzalkind/Tools/openfast/install/bin/openfast';
        fast.FAST_SFuncDir     = '/Users/dzalkind/Tools/openfast-sim/glue-codes/simulink/src';  %%%% NEED FOR SIMULINK
        fast.FAST_InputFile    = 'RO_DLC_12.fst';   % FAST input file (ext=.fst)
        fast.FAST_directory    = '/Users/dzalkind/Tools/SaveData/ROSCO/Baseline/';   % Path to fst directory files
        fast.FAST_runDirectory = '/Users/dzalkind/Tools/matlab-toolbox/Simulations/SaveData';
        
        % Simulation Parameters
        simu.Use_Simulink       = 0;
        simu.SimModel           = '/Users/dzalkind/Tools/matlab-toolbox/Simulations/SimulinkModels/ROSCO';
        simu.ParamScript        = '/Users/dzalkind/Tools/matlab-tools/Simulations/SimulinkModels/load_ROSCO_params';
        simu.DebugSim           = 1;  % use when running/testing/editing main file
end

%% Simulation Parameters
simu.TMax   = 300;


%% Save Name
% Give the input/output files a specific name or a datestring name

if 1 % give a specific name
    fast.FAST_namingOut = 'U14_step';
else
    % give a datestr name
    fast.FAST_namingOut = datestr(now,'mmddyy_HHMMSS');
end


%% Define Wind Input

if 1  % Define Wind Input
    
    if 1  % User Defined Wind Input
        
        % Disturbance (D) Parameters
        Dist.TMax            = simu.TMax;
        Dist.U_ref           = 14;         % Steady wind speed
        
        Dist.Type            = 'step';
        Dist.TStart          = 200;
        Dist.Step            = 1;
        
        [windFileOut, W] = Af_MakeWind(fast,Dist,simu,1);
        
        edits.IW = {
            'WindType',     2;
            'Filename',   ['"',windFileOut,'"']
            };
        
    else  % point to pre-made wind input
        
    end
    
    
    
    
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
    'TMax',      simu.TMax;
    };

edits.ED = {
        
        'FlapDOF1',    'False';
        'FlapDOF2',    'False';
        'EdgeDOF',    'False';
        'TwFADOF1',    'False';
        'TwFADOF2',    'False';
        'TwSSDOF1',    'False';
        'TwSSDOF2',    'False';
        'PtfmSgDOF',    'False';
        'PtfmSgDOF',    'False';
        'PtfmSwDOF',     'False';
        'PtfmHvDOF',    'False';
        'PtfmRDOF',     'False';
        'PtfmPDOF',    'True';
        'PtfmYDOF',      'False';
    };

edits.RO = {
    %     'SS_VSGain', 2;
    };

edits.SD = {
    
};



%% File Settings

% copying the airfoils to the save directory takes a while, recommended to
% do this the first time and not thereafter
copyAirfoils = 1;


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

[Param,F] = ReadWrite_FAST(fast,edits,copyAirfoils);

simu.dt     = GetFASTPar(Param.FP,'DT');
if simu.Use_Simulink
    [R,F,Cx] = feval(ControScript,fast,Param,simu);        % Run as script for meow
end


%% Premake OutList for Simulink

OutList = {'Time'};
OutList = [OutList;
    Param.IWP.OutList;
    Param.EDP.OutList;
    Param.ADP.OutList;
    Param.SvDP.OutList;
    Param.HDP.OutList;
    ];

for iOut = 2:length(OutList)
    OutList{iOut} = OutList{iOut}(2:end-1); %strip "s
end


%% Exectute FAST

% Using Simulink/S_Func
if simu.Use_Simulink
    
    
    FAST_InputFileName = [fast.FAST_runDirectory,filesep,fast.FAST_namingOut,'.fst'];
    TMax               = simu.TMax;
    
    
    if simu.DebugSim
        SimulinkModel = simu.SimModel;
    else %run local, copied file
        SimulinkModel = [fast.FAST_runDirectory, filesep, fast.FAST_namingOut];
    end
    
    Out         = sim(SimulinkModel, 'StopTime',num2str(GetFASTPar(Param.FP,'TMax')));
    sigsOut     = get(Out,'sigsOut');   %internal control signals
    
else  % Run dll/Fast executable
    system([fast.FAST_exe, ' ', fast.FAST_runDirectory, filesep, fast.FAST_namingOut,'.fst']);
    
    % rename ROSCO debug file
    movefile('DEBUG.dbg',fullfile(fast.FAST_runDirectory,[fast.FAST_namingOut,'.RO.out']));
end

%% Get Out Data

if simu.Use_Simulink
    SFuncOutStr = '.SFunc';
else
    SFuncOutStr = '';
end

% Try text first, then binary
[OutData,OutList] = ReadFASTtext([fast.FAST_runDirectory,filesep,fast.FAST_namingOut,SFuncOutStr,'.out']);
if isempty(OutData)
    [OutData,OutList] = ReadFASTbinary([fast.FAST_runDirectory,filesep,fast.FAST_namingOut,SFuncOutStr,'.outb']);
end



% Post Process

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





