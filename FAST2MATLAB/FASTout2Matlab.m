%% FASTout2Matlab
% script to convert matlab outputs into Matlab domain
%
% start with outputs
% TODO: add input file parameters, copy from runFAST.


clear;

POST_PROCESS = 1;


%% Input Processing

fast.FAST_InputFile    = 'UM_DLC0_100';   % FAST input file (no ext)
fast.FAST_directory    = '/Users/dzalkind/Tools/WISDEM/UMaine/DLCs';   % Path to fst directory files



%% Read
FP = FAST2Matlab(fullfile(fast.FAST_directory,[fast.FAST_InputFile,'.fst']),2); %FP are Fast Parameters, specify 2 lines of header (FAST 8)

[EDP, EDFile]   = GetFASTPar_Subfile(FP, 'EDFile', fast.FAST_directory, fast.FAST_directory);
[IWP, IWFile]   = GetFASTPar_Subfile(FP, 'InflowFile', fast.FAST_directory, fast.FAST_directory);
[ADP, ADFile]   = GetFASTPar_Subfile(FP, 'AeroFile', fast.FAST_directory, fast.FAST_directory);
[SvDP, SvDFile] = GetFASTPar_Subfile(FP, 'ServoFile', fast.FAST_directory, fast.FAST_directory);
[HDP, HDFile]   = GetFASTPar_Subfile(FP, 'HydroFile', fast.FAST_directory, fast.FAST_directory,true);
% [SbDP, SbDFile] = GetFASTPar_Subfile(FP, 'SubFile', fast.FAST_directory, fast.FAST_directory);
% [MDP, MDFile]   = GetFASTPar_Subfile(FP, 'MooringFile', fast.FAST_directory, fast.FAST_directory);
% [IDP, IDFile] = GetFASTPar_Subfile(FP, 'IceFile', fast.FAST_directory, fast.FAST_directory);

% Get & Set Blade Files
% ED_BldFile              = GetFASTPar(EDP, 'BldFile1');
[ED_BldP, ED_BldFile]   = GetFASTPar_Subfile(EDP, 'BldFile1', fast.FAST_directory, fast.FAST_directory);

% Get & Set Tower File
[ED_TwrP, ED_TwrFile]   = GetFASTPar_Subfile(EDP, 'TwrFile', fast.FAST_directory, fast.FAST_directory);

% AeroDyn Blade
[AD_BldP, AD_BldFile]   = GetFASTPar_Subfile(ADP, 'ADBlFile(1)', fast.FAST_directory, fast.FAST_directory);

% HydroData
% PotFile                 = GetFASTPar(HDP,'PotFile');

% Airfoils

% Control Parameters
[~,SD_dllFile]          = GetFASTPar_Subfile(SvDP,'DLL_InFile',fast.FAST_directory, fast.FAST_directory);
SD_dllP                 = ROSCO2Matlab(SD_dllFile,2);

CpCtCqFile              = GetFASTPar(SD_dllP,'!PerfFileName');
%%% TODO: add processing here to look at/use Cx tables

% MoorDyn: let's just copy for meow
MDFile = GetFASTPar(FP,'MooringFile');





%% Write Outputs and Cleanup

% parameters
P.FP        = FP;
P.EDP       = EDP;
P.IWP       = IWP;
P.ADP       = ADP;
P.HDP       = HDP;
P.SvDP      = SvDP;
P.ED_BldP   = ED_BldP;
P.ED_TwrP   = ED_TwrP;
P.AD_BldP   = AD_BldP;
P.SD_dllP   = SD_dllP;

clearvars FP EDP IWP ADP HDP SvDP ED_BldP ED_TwrP AD_BldP SD_dllP


%% Post Process
if POST_PROCESS
    
    post.Scripts = {
        'A4_8_SetPlotChannels';
        'A4_8_Plot_Channels';
        'A4_8_SaveLite'
        };
    
    % Plot
    % PlotFASToutput(FASTfiles,FASTfilesDesc,ReferenceFile,Channels,ShowLegend,CustomHdr,PlotPSDs,OnePlot)
    %
    % Channels = {'Wind1VelX','GenTq','BldPitch1','GenPwr','GenSpeed','RootMyb1','TwrBsMyt','PtfmPitch'};
    % outdata = PlotFASToutput([fast.FAST_runDirectory,filesep,fast.FAST_namingOut,'.out'],{'test'},1,Channels);
    
    % Get Out Data
    [OutData,OutList] = ReadFASTtext([fast.FAST_directory,filesep,fast.FAST_InputFile,'.out']);
    
    PLOT = 1;
    
    for iPP = 1:length(post.Scripts)
        eval(post.Scripts{iPP});
    end
end


clearvars POST_PROCESS
