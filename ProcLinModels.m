%% CompLinModels


clear;

%% Gather Models

LinearPath = '/Users/dzalkind/Tools/WISDEM/UMaine/Linear';

outPrefix = 'testing';
outSuffix = '.outb';
outFiles    = dir(fullfile(LinearPath,[outPrefix,'*',outSuffix]));
nLinCases = length(outFiles);

MBC         = cell(1,nLinCases);
matData     = cell(1,nLinCases);
P           = cell(1,nLinCases);

% Operating Point Init
SS_OpNames = {'Wind1VelX'  
              'OoPDefl'
              'IPDefl'
              'BlPitch1'
              'RotSpeed'
              'TTDspFA'
              'TTDspSS'
              'PtfmSurge'
              'PtfmSway'
              'PtfmHeave'
              'PtfmRoll'
              'PtfmYaw'
              'PtfmPitch'};
          
WindSpeed   = zeros(1,nLinCases);
for iOp = 1:length(SS_OpNames)
    SS_Ops.(SS_OpNames{iOp}) = zeros(1,nLinCases);
end

PitchDesc   = 'ED Extended input: collective blade-pitch command, rad';
WindDesc    = 'IfW Extended input: horizontal wind speed (steady/uniform wind), m/s';
GenDesc     = 'ED GenSpeed, (rpm)';
TwrDesc     = 'ED TwrBsMyt, (kN-m)';
AzDesc      = 'ED Variable speed generator DOF (internal DOF index = DOF_GeAz), rad';


for iCase = 1:nLinCases
    %% Process .lin files
    
    LinFilesS{iCase} = dir(fullfile(LinearPath,[outPrefix,'_',num2str(iCase-1,'%02d'),'.*.lin']));
    
    for iFile = 1:length(LinFilesS{iCase})
        LinFiles{iFile} = fullfile(LinearPath,LinFilesS{iCase}(iFile).name);
    end
    
    [MBC{iCase},matData{iCase}] = fx_mbc3(LinFiles);
    

    %% Get Wind Speed, Operating Points
    FSTName = fullfile(LinearPath,[outPrefix,'_',num2str(iCase-1,'%02d'),'.fst']);
    FP = FAST2Matlab(FSTName,2); %FP are Fast Parameters, specify 2 lines of header (FAST 8)

    [IfWP, InflowFile] = GetFASTPar_Subfile(FP, 'InflowFile', LinearPath, LinearPath);
    [EdP, ElastoFile]  = GetFASTPar_Subfile(FP, 'EDFile', LinearPath, LinearPath);
    
    WindSpeed(iCase)   = GetFASTPar(IfWP, 'HWindSpeed');
        
    % Loop through operating points  
    for iOp = 1:length(SS_OpNames)
        if iOp == 1
            SS_Ops.(SS_OpNames{iOp})(iCase) = WindSpeed(iCase);
        else
            if strcmp(SS_OpNames{iOp},'BlPitch1') % pitch is a special name case
                SS_Ops.BlPitch1(iCase) = GetFASTPar(EdP,'BlPitch(1)'); 
            else
                SS_Ops.(SS_OpNames{iOp})(iCase) = GetFASTPar(EdP,SS_OpNames{iOp});
            end 
        end
    end
    
    %% Form Systems
    % Set desired inputs and outputs here
    % Indices
    indPitch    = find(strcmp(PitchDesc,matData{iCase}.DescCntrlInpt));
    indWind     = find(strcmp(WindDesc,matData{iCase}.DescCntrlInpt));
    indTwr      = find(strcmp(TwrDesc,matData{iCase}.DescOutput));
    indGen      = find(strcmp(GenDesc,matData{iCase}.DescOutput));
    indAz       = strcmp(AzDesc,matData{iCase}.DescStates);
    
    % Set inputs/outputs
    indOuts     = [indGen,indTwr];
    indInps     = [indWind,indPitch];
    
    % Remove azimuth state
    indStates   = 1:length(matData{iCase}.DescStates); indStates(indAz) = [];
    
    % Form ss system
    P{iCase} = ss(MBC{iCase}.AvgA(indStates,indStates),MBC{iCase}.AvgB(indStates,indInps),...
        MBC{iCase}.AvgC(indOuts,indStates),MBC{iCase}.AvgD(indOuts,indInps));
    
    % Name inputs and outputs
    P{iCase}.OutputName    = {'GenSpeed','TwrBsMyt'};
    P{iCase}.InputName     = {'WindSpeed','BldPitch'};
    
end

