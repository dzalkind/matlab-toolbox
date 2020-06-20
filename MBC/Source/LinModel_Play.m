%% Matrix Play
% Mimic runCampbell.m, but with python running linearization cases




clear;


% LinearPath = '/Users/dzalkind/Tools/WISDEM/UMaine/Linear_LowOrder';
LinearPath = '/Users/dzalkind/Tools/WISDEM/UMaine/Linear';


nLinCases = 23;

outPrefix = 'testing';

LinFiles = cell(1,nLinCases);


for iCase = 20
    LinFilesS = dir(fullfile(LinearPath,[outPrefix,'_',num2str(iCase,'%02d'),'.*.lin']));
    
    for iFile = 1:length(LinFiles)
        LinFiles{iFile} = fullfile(LinearPath,LinFilesS(iFile).name);
    end
    
    [MBC,matData] = fx_mbc3(LinFiles);
    
    
end


%% Descriptions
GenDesc     = 'ED First time derivative of Variable speed generator DOF (internal DOF index = DOF_GeAz), rad/s';
Twr1Desc    = {'ED 1st tower fore-aft bending mode DOF (internal DOF index = DOF_TFA1), m',
                'ED First time derivative of 1st tower fore-aft bending mode DOF (internal DOF index = DOF_TFA1), m/s'};


% Inputs
PitchDesc   = 'ED Extended input: collective blade-pitch command, rad';
TorqDesc    = 'ED Generator torque, Nm';
WindDesc    = 'IfW Extended input: horizontal wind speed (steady/uniform wind), m/s';

%% Indices

indGen      = strcmp(GenDesc,MBC.DescStates);
indPitch    = strcmp(PitchDesc,matData.DescCntrlInpt);
indWind     = strcmp(WindDesc,matData.DescCntrlInpt);


%% Generator Only


A = MBC.AvgA(indGen,indGen)
B = MBC.AvgB(indGen,indPitch | indWind)


%% Gen & Tower


%% Compare Low vs High Order Simulation Outputs

PLOT = 1;


[OutDataM,OutList] = ReadFASTbinary(fullfile('/Users/dzalkind/Tools/WISDEM/UMaine/Linear',...
    [outPrefix,'_',num2str(iCase,'%02d'),'.outb']));


OutData.time = OutDataM(:,1);
OutData.signals.values = OutDataM;
Simulation.TMax = OutData.time(end);

A4_8_SetPlotChannels;
A4_8_Plot_Channels


%% Try Campbell Stuff

BladeLen = 120;
TowerLen = 150;

newFSTName = fullfile('/Users/dzalkind/Tools/WISDEM/UMaine/Linear',...
    [outPrefix,'_',num2str(iCase,'%02d')]);

[CampbellData] = campbell_diagram_data(MBC, BladeLen, TowerLen, strrep(newFSTName,'.fst','.MBD.sum'));

    
