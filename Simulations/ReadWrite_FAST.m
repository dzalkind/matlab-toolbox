function [P,F] = ReadWrite_FAST(fast,edits,varargin)
% fast should have the following fields:
%  .FAST_directory - where files come from
%  .FAST_InputFile - main input file (.fst)
%  .FAST_runDirectory - where new files will be run from
%
%  Outputs:
%   P - parameter structure
%   F - filename structure

%% Input handling
if nargin < 3
    copyAirfoils = 0;
else
    copyAirfoils = varargin{1};
end

%% Read
FP = FAST2Matlab(fullfile(fast.FAST_directory,fast.FAST_InputFile),2); %FP are Fast Parameters, specify 2 lines of header (FAST 8)

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
EDP                     = SetFASTPar(EDP,'BldFile1',[fast.FAST_namingOut,'_ElastoDyn_blade.dat']);
EDP                     = SetFASTPar(EDP,'BldFile2',[fast.FAST_namingOut,'_ElastoDyn_blade.dat']);
EDP                     = SetFASTPar(EDP,'BldFile3',[fast.FAST_namingOut,'_ElastoDyn_blade.dat']);

% Get & Set Tower File
% ED_TwrFile = GetFASTPar(EDP, 'TwrFile');
[ED_TwrP, ED_TwrFile]   = GetFASTPar_Subfile(EDP, 'TwrFile', fast.FAST_directory, fast.FAST_directory);
EDP                     = SetFASTPar(EDP,'TwrFile',[fast.FAST_namingOut,'_ElastoDyn_tower.dat']);

% AeroDyn Blade
[AD_BldP, AD_BldFile]   = GetFASTPar_Subfile(ADP, 'ADBlFile(1)', fast.FAST_directory, fast.FAST_directory);
ADP                     = SetFASTPar(ADP,'ADBlFile(1)',[fast.FAST_namingOut,'_AeroDyn15_blade.dat']);
ADP                     = SetFASTPar(ADP,'ADBlFile(2)',[fast.FAST_namingOut,'_AeroDyn15_blade.dat']);
ADP                     = SetFASTPar(ADP,'ADBlFile(3)',[fast.FAST_namingOut,'_AeroDyn15_blade.dat']);

% HydroData
PotFile                 = GetFASTPar(HDP,'PotFile');
if ~exist(fullfile(fast.FAST_runDirectory,'HydroData'),'dir')
    mkdir(fullfile(fast.FAST_runDirectory,'HydroData'))
end
copyfile(fullfile([PotFile(2:end-1),'*']),fullfile(fast.FAST_runDirectory,'HydroData'));
HDP                     = SetFASTPar(HDP,'PotFile',PotFile);

% Airfoils
if copyAirfoils
    if ~exist(fullfile(fast.FAST_runDirectory,'Airfoils'))
        mkdir(fullfile(fast.FAST_runDirectory,'Airfoils'))
    end
    
    disp('Copying airfoils')
    system(['cp -R ',fullfile(fast.FAST_directory,'Airfoils'),' ',fullfile(fast.FAST_runDirectory,'Airfoils')]);
    disp('Finished copying')
    
end

% Control Parameters
[~,SD_dllFile]          = GetFASTPar_Subfile(SvDP,'DLL_InFile',fast.FAST_directory, fast.FAST_directory);
SD_dllP                 = ROSCO2Matlab(SD_dllFile,2);
SvDP                    = SetFASTPar(SvDP,'DLL_InFile',['"',fast.FAST_runDirectory,filesep,fast.FAST_namingOut,'_DISCON.IN"']);

% CpCtCqFile              = GetFASTPar(SD_dllP,'!PerfFileName');
% Hard code since this fa
copyfile(fullfile(fast.FAST_directory,SD_dllP.Val{61}(2:end-1)),fullfile(fast.FAST_runDirectory,[fast.FAST_namingOut,'_Cp_Ct_Cq.txt']))
SD_dllP                 = SetFASTPar(SD_dllP,'PerfFileName',['"',fast.FAST_runDirectory,filesep,fast.FAST_namingOut,'_Cp_Ct_Cq.txt"']);

% MoorDyn: let's just copy for meow
MDFile = GetFASTPar(FP,'MooringFile');
copyfile(fullfile(fast.FAST_directory,MDFile(2:end-1)),fullfile(fast.FAST_runDirectory,[fast.FAST_namingOut,'_MoorDyn.dat']))

%% Edits

% Set new input files
FP = SetFASTPar(FP,'EDFile',['"',fast.FAST_namingOut,'_ElastoDyn.dat','"']);
FP = SetFASTPar(FP,'InflowFile',['"',fast.FAST_namingOut,'_InflowFile.dat','"']);
FP = SetFASTPar(FP,'AeroFile',['"',fast.FAST_namingOut,'_AeroDyn15.dat','"']);
FP = SetFASTPar(FP,'HydroFile',['"',fast.FAST_namingOut,'_HydroDyn.dat','"']);
FP = SetFASTPar(FP,'ServoFile',['"',fast.FAST_namingOut,'_ServoDyn.dat','"']);
FP = SetFASTPar(FP,'MooringFile',['"',fast.FAST_namingOut,'_MoorDyn.dat','"']);

% FAST
if isfield(edits,'FA')
    for iEdit = 1:size(edits.FA,1)
        FP = SetFASTPar(FP,edits.FA{iEdit,1},edits.FA{iEdit,2});
    end
end

% ElastoDyn
if isfield(edits,'ED')
    for iEdit = 1:size(edits.ED,1)
        EDP = SetFASTPar(EDP,edits.ED{iEdit,1},edits.ED{iEdit,2});
    end
end

% AeroDyn
if isfield(edits,'AD')
    for iEdit = 1:size(edits.AD,1)
        ADP = SetFASTPar(ADP,edits.AD{iEdit,1},edits.AD{iEdit,2});
    end
end

% ServoDyn
if isfield(edits,'SD')
    for iEdit = 1:size(edits.SD,1)
        SvDP = SetFASTPar(SvDP,edits.SD{iEdit,1},edits.SD{iEdit,2});
    end
end

% ROSCO
if isfield(edits,'RO')
    for iEdit = 1:size(edits.RO,1)
        SD_dllP = SetFASTPar(SD_dllP,edits.RO{iEdit,1},edits.RO{iEdit,2});
    end
end

% InflowWind
if isfield(edits,'IW')
    for iEdit = 1:size(edits.IW,1)
        IWP = SetFASTPar(IWP,edits.IW{iEdit,1},edits.IW{iEdit,2});
    end
end

% HydroDyn
if isfield(edits,'HD')
    for iEdit = 1:size(edits.HD,1)
        HDP = SetFASTPar(HDP,edits.HD{iEdit,1},edits.HD{iEdit,2});
    end
end

%% Write
Matlab2FAST(FP,fullfile(fast.FAST_directory,fast.FAST_InputFile),fullfile(fast.FAST_runDirectory,[fast.FAST_namingOut,'.fst']), 2); %contains 2 header lines
Matlab2FAST(EDP,EDFile,  fullfile(fast.FAST_runDirectory,[fast.FAST_namingOut,'_ElastoDyn.dat']), 2); %contains 2 header lines
Matlab2FAST(IWP,IWFile,  fullfile(fast.FAST_runDirectory,[fast.FAST_namingOut,'_InflowFile.dat']), 2); %contains 2 header lines
Matlab2FAST(ADP,ADFile,  fullfile(fast.FAST_runDirectory,[fast.FAST_namingOut,'_AeroDyn15.dat']), 2); %contains 2 header lines
Matlab2HD(HDP,HDFile,  fullfile(fast.FAST_runDirectory,[fast.FAST_namingOut,'_HydroDyn.dat']), 2); %contains 2 header lines
Matlab2FAST(SvDP,SvDFile,  fullfile(fast.FAST_runDirectory,[fast.FAST_namingOut,'_ServoDyn.dat']), 2); %contains 2 header lines
% Matlab2FAST(MDP,MDFile,  fullfile(fast.FAST_runDirectory,[fast.FAST_namingOut,'_MoorDyn.dat']), 2); %contains 2 header lines
% Matlab2FAST(IDP,IDFile,  fullfile(fast.FAST_directory,[fast.FAST_namingOut,'_.dat']), 2); %contains 2 header lines

Matlab2FAST(ED_BldP,ED_BldFile,fullfile(fast.FAST_runDirectory,[fast.FAST_namingOut,'_ElastoDyn_blade.dat']), 2); %contains 2 header lines
Matlab2FAST(ED_TwrP,ED_TwrFile,fullfile(fast.FAST_runDirectory,[fast.FAST_namingOut,'_ElastoDyn_tower.dat']), 2); %contains 2 header lines

Matlab2FAST(AD_BldP,AD_BldFile,fullfile(fast.FAST_runDirectory,[fast.FAST_namingOut,'_AeroDyn15_blade.dat']), 2); %contains 2 header lines
Matlab2ROSCO(SD_dllP,SD_dllFile,fullfile(fast.FAST_runDirectory,[fast.FAST_namingOut,'_DISCON.IN']), 2); %contains 2 header lines


%% Write Outputs

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

% files in
F.Out.FA        = [fast.FAST_namingOut,'.fst'];
F.Out.ED        = [fast.FAST_namingOut,'_ElastoDyn.dat'];
F.Out.IW        = [fast.FAST_namingOut,'_InflowFile.dat'];
F.Out.AD        = [fast.FAST_namingOut,'_AeroDyn15.dat'];
F.Out.HD        = [fast.FAST_namingOut,'_HydroDyn.dat'];
F.Out.SD        = [fast.FAST_namingOut,'_ServoDyn.dat'];
F.Out.ED_bld    = [fast.FAST_namingOut,'_ElastoDyn_blade.dat'];
F.Out.ED_twr    = [fast.FAST_namingOut,'_ElastoDyn_tower.dat'];
F.Out.AD_bld    = [fast.FAST_namingOut,'_AeroDyn15_blade.dat'];
F.Out.RO        = [fast.FAST_namingOut,'_DISCON.IN'];
F.Out.Cx        = [fast.FAST_namingOut,'_Cp_Ct_Cq.txt'];

F.In.FA         = fast.FAST_InputFile;
F.In.ED         = EDFile;
F.In.IW         = IWFile;
F.In.AD         = ADFile;
F.In.HD         = HDFile;
F.In.SD         = SvDFile;
F.In.ED_bld     = ED_BldFile;
F.In.ED_twr     = ED_TwrFile;
F.In.AD_bld     = AD_BldFile;
F.In.RO         = SD_dllFile;
F.In.Cx         = SD_dllP.Val{61}(2:end-1);


