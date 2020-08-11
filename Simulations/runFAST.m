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
        fast.FAST_InputFile    = 'UM_DLC0_100.fst';   % FAST input file (ext=.fst)
        fast.FAST_directory    = '/Users/dzalkind/Tools/SaveData/Float_Test';   % Path to fst directory files
        fast.FAST_runDirectory = '/Users/dzalkind/Tools/matlab-toolbox/Simulations/SaveData/';
        
        % Simulation Parameters
        simu.Use_Simulink       = 1;
        simu.SimModel           = '/Users/dzalkind/Tools/matlab-toolbox/Simulations/SimulinkModels/ROSCO';
        simu.ParamScript        = '/Users/dzalkind/Tools/matlab-toolbox/Simulations/SimulinkModels/load_ROSCO_params';
        simu.DebugSim           = 1;  % use when running/testing/editing main file
        
        
    case 2
        % NASA Floater with ROSCO
        
        fast.FAST_exe          = '/Users/dzalkind/Tools/openfast/install-old/bin/openfast';
        fast.FAST_SFuncDir     = '/Users/dzalkind/Tools/openfast-sim/glue-codes/simulink/src';  %%%% NEED FOR SIMULINK
        fast.FAST_InputFile    = 'UM_DLC0_100.fst';   % FAST input file (ext=.fst)
        fast.FAST_directory    = '/Users/dzalkind/Tools/WISDEM/UMaine/DLCs';   % Path to fst directory files
        fast.FAST_runDirectory = '/Users/dzalkind/Tools/matlab-toolbox/Simulations/SaveData';
        
        % Simulation Parameters
        simu.Use_Simulink       = 1;
        
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
        
    case 4
        % IEA 15 MW with ROSCO/f/pitchActuator
        
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
        
    case 5
        % IEA 15 MW with APC
        
        fast.FAST_exe          = '/Users/dzalkind/Tools/openfast/install/bin/openfast';
        fast.FAST_SFuncDir     = '/Users/dzalkind/Tools/openfast-sim/glue-codes/simulink/src';  %%%% NEED FOR SIMULINK
        fast.FAST_InputFile    = 'UM_DLC0_100.fst';   % FAST input file (ext=.fst)
        fast.FAST_directory    = '/Users/dzalkind/Tools/SaveData/Testing/PowerControl';   % Path to fst directory files
        fast.FAST_runDirectory = '/Users/dzalkind/Tools/matlab-toolbox/Simulations/SaveData';
        
        % Simulation Parameters
        simu.Use_Simulink       = 1;
        simu.SimModel           = '/Users/dzalkind/Tools/matlab-toolbox/Simulations/SimulinkModels/ROSCO';
        simu.ParamScript        = '/Users/dzalkind/Tools/matlab-tools/Simulations/SimulinkModels/load_ROSCO_params';
        simu.DebugSim           = 1;  % use when running/testing/editing main file
        
    case 10
        % SUMR-D initial
        
        fast.FAST_exe          = '/Users/dzalkind/Tools/openfast/install-old/bin/openfast';
        fast.FAST_SFuncDir     = '/Users/dzalkind/Tools/openfast-sim/glue-codes/simulink/src';  %%%% NEED FOR SIMULINK
        fast.FAST_InputFile    = 'DLC_60.fst';   % FAST input file (ext=.fst)
        fast.FAST_directory    = '/Users/dzalkind/Tools/SaveData/SUMR-D/FullDLC';   % Path to fst directory files
        fast.FAST_runDirectory = '/Users/dzalkind/Tools/matlab-toolbox/Simulations/SaveData/SUMR-D';
        
        % Simulation Parameters
        simu.Use_Simulink       = 1;
        simu.SimModel           = '/Users/dzalkind/Tools/SUMR-D/CART_Controller';
        simu.ParamScript        = '/Users/dzalkind/Tools/SUMR-D/C_AD_SUMR_D.m';
        simu.DebugSim           = 1;  % use when running/testing/editing main file
end

%% Simulation Parameters
simu.TMax   = 600;


%% Save Name
% Give the input/output files a specific name or a datestring name

if 1 % give a specific name
    fast.FAST_namingOut = 'sim100_PwC';
else
    % give a datestr name
    fast.FAST_namingOut = datestr(now,'mmddyy_HHMMSS');
end


%% Define Wind Input

if 0  % Define Wind Input
    
    if 1  % User Defined Wind Input
        
        % Disturbance (D) Parameters
        Dist.TMax            = simu.TMax;
        Dist.U_ref           = 2;         % Steady wind speed
        Dist.U_max           = 7;
        
        Dist.Type            = 'ramp';
        Dist.TStart          = 200;
        Dist.Step            = 1;
        
        Dist.Vmin            = 2;
        Dist.Vmax            = 7;
        
        Dist.TEnd            = simu.TMax;
        
        [windFileOut, W] = Af_MakeWind(fast,Dist,simu,1);
        
        edits.IW = {
            'WindType',     2;
            'FilenameT2',   ['"',windFileOut,'"']
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
        
%         'FlapDOF1',    'False';
%         'FlapDOF2',    'False';
%         'EdgeDOF',    'False';
%         'TwFADOF1',    'False';
%         'TwFADOF2',    'False';
%         'TwSSDOF1',    'False';
%         'TwSSDOF2',    'False';
%         'PtfmSgDOF',    'False';
%         'PtfmSgDOF',    'False';
%         'PtfmSwDOF',     'False';
%         'PtfmHvDOF',    'False';
%         'PtfmRDOF',     'False';
%         'PtfmPDOF',    'True';
%         'PtfmYDOF',      'False';
% 'BlPitch(1)', 0;
% 'BlPitch(2)', 0;
% 'BlPitch(3)', 0;
% 'RotSpeed',    7.55;

    };

edits.RO = {
        'LoggingLevel', 2;
    };

edits.SD = {
    'GenTiStr',  'False';
        'GenTiStp',  'True';
        'SpdGenOn',  0;
};



%% File Settings

% copying the airfoils to the save directory takes a while, recommended to
% do this the first time and not thereafter
copyAirfoils = 0;


%% Simulink Setup

if simu.Use_Simulink
    [ControlScriptPath,ControlScript] = fileparts(simu.ParamScript);
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
    models_in_dir       = dir([simu.SimModel,'*']);
    [~,~,model_ext]     = fileparts(models_in_dir(1).name);
    if ~exist(fast.FAST_runDirectory)
        mkdir(fast.FAST_runDirectory)
    end
    copyfile([simu.SimModel,model_ext],[fast.FAST_runDirectory, filesep, fast.FAST_namingOut, model_ext]);
    
end



%% Read and Write New Files

if ~exist(fast.FAST_runDirectory,'dir')
    mkdir(fast.FAST_runDirectory)
end

[Param,F,Cx] = ReadWrite_FAST(fast,edits,copyAirfoils);

simu.dt     = GetFASTPar(Param.FP,'DT');
if simu.Use_Simulink
    try  % to run as function
        [R,F] = feval(ControlScript,Param,simu);        % Run as script for meow
    catch
        eval(ControlScript);
    end
end


%% Premake OutList for Simulink

if GetFASTPar(Param.FP,'CompAero') == 1
    Param.ADP.OutList = {};
end

if ~GetFASTPar(Param.FP,'CompHydro')
    Param.HDP.OutList = {};
end

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
%     movefile('DEBUG.dbg',fullfile(fast.FAST_runDirectory,[fast.FAST_namingOut,'.RO.out']));
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





