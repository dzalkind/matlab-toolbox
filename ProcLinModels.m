%% CompLinModels


clear;

%% Linear Model Options

LinearPath = '/Users/dzalkind/Tools/SaveData/SweepPtfmMass/LinearPitch';

% Perform minreal() to get rid of most hydrodynamic states that have little
% effect
ReduceModel = 1;

%% FAST Parameters

outPrefix   = 'lin';
outSuffix   = '.outb';
outFiles    = dir(fullfile(LinearPath,[outPrefix,'*',outSuffix]));
nLinCases   = length(outFiles);

if nLinCases <= 10
    numstring = '%01d';
else
    numstring = '%02d';
end

%% Initialize

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

PitchDesc       = 'ED Extended input: collective blade-pitch command, rad';
WindDesc        = 'IfW Extended input: horizontal wind speed (steady/uniform wind), m/s';
GenDesc         = 'ED GenSpeed, (rpm)';
TwrDesc         = 'ED TwrBsMyt, (kN-m)';
AzDesc          = 'ED Variable speed generator DOF (internal DOF index = DOF_GeAz), rad';
PltPitchDesc    = 'ED PtfmPitch, (deg)';
NacIMUFADesc    = 'ED NcIMURAxs, (deg/s^2)';

for iCase = 1:nLinCases
    %% Process .lin files
    
    LinFilesS{iCase} = dir(fullfile(LinearPath,[outPrefix,'_',num2str(iCase-1,numstring),'.*.lin']));
    
    if isempty(LinFilesS{1})
        disp('WARNING: Didn''t find any linear files');
        return;
    end
    
    for iFile = 1:length(LinFilesS{iCase})
        LinFiles{iFile} = fullfile(LinearPath,LinFilesS{iCase}(iFile).name);
    end
    
    [MBC{iCase},matData{iCase}] = fx_mbc3(LinFiles);
    
    
    %% Get Wind Speed, Operating Points
    FSTName = fullfile(LinearPath,[outPrefix,'_',num2str(iCase-1,numstring),'.fst']);
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
    
    % Input, State, and Output Operating Points (avearaged over azimuth)
    u_ops{iCase} = mean(matData{iCase}.uop,2);
    y_ops{iCase} = mean(matData{iCase}.yop,2);
    x_ops{iCase} = mean(matData{iCase}.xop,2);
    
    %% Form Systems
    % Set desired inputs and outputs here
    % Indices
    indPitch        = find(strcmp(PitchDesc,matData{iCase}.DescCntrlInpt));
    indWind         = find(strcmp(WindDesc,matData{iCase}.DescCntrlInpt));
    indTwr          = find(strcmp(TwrDesc,matData{iCase}.DescOutput));
    indGen          = find(strcmp(GenDesc,matData{iCase}.DescOutput));
    indAz           = strcmp(AzDesc,matData{iCase}.DescStates);
    indPltPitch     = find(strcmp(PltPitchDesc,matData{iCase}.DescOutput));
    indNacIMU       = find(strcmp(NacIMUFADesc,matData{iCase}.DescOutput));
    
    % Set inputs/outputs
    indOuts     = [indGen,indTwr,indPltPitch,indNacIMU];
    indInps     = [indWind,indPitch];
    
    % Remove azimuth state
    indStates   = 1:length(matData{iCase}.DescStates); indStates(indAz) = [];
    
    % Form ss system
    P{iCase} = ss(MBC{iCase}.AvgA(indStates,indStates),MBC{iCase}.AvgB(indStates,indInps),...
        MBC{iCase}.AvgC(indOuts,indStates),MBC{iCase}.AvgD(indOuts,indInps));
    
    if ReduceModel
        P{iCase} = minreal(P{iCase});
    end
    
    % Name inputs and outputs
    P{iCase}.OutputName    = {'GenSpeed','TwrBsMyt','PltPitch','NacIMU'};
    P{iCase}.InputName     = {'WindSpeed','BldPitch'};
    
end


%% Open Loop Step


% Choose Case(s) Here, reference case_matrix.yaml
linCases = [1,5];

figure(100);
subplot(211); hold off;
subplot(212); hold off;

for indLin = linCases
    % Inputs
    tt = 0:1/80:100;
    uu = zeros(length(tt),2);
    uu(:,1) = 1;
    
    % Linear Simulation
    yy = lsim(P{indLin},uu,tt);
    
    
    figure(100);
    set(gcf,'Name','Open Loop Step');
    
    subplot(211);
    plot(tt,yy(:,1)); hold on;
    ylabel('Gen Speed (rpm)');
    
    subplot(212);
    plot(tt,yy(:,2)); hold on;
    ylabel('Twr Bs FA (kNm)');
    
end

%% Closed Loop Control

figure(101);
subplot(311); hold off;
subplot(312); hold off;
subplot(313); hold off;


for indLin = linCases
    
    % PI Control (ROSCO) Parameters
    [SvDP, SvDFile]         = GetFASTPar_Subfile(FP, 'ServoFile', LinearPath, LinearPath);
    [~,SD_dllFile]          = GetFASTPar_Subfile(SvDP,'DLL_InFile', LinearPath, LinearPath);
    SD_dllP                 = ROSCO2Matlab(SD_dllFile,2);
    
    PC_GS_angles          = GetFASTPar(SD_dllP,'PC_GS_angles');
    PC_GS_KP              = GetFASTPar(SD_dllP,'PC_GS_KP');
    PC_GS_KI              = GetFASTPar(SD_dllP,'PC_GS_KI');
    
    kp = -interp1(PC_GS_angles,PC_GS_KP,u_ops{indLin}(9));
    ki = -interp1(PC_GS_angles,PC_GS_KI,u_ops{indLin}(9));
    
    
    % Form Controller
    s = tf('s');
    C_PI = (kp + ki/s) * rpm2radps(1);
    C_PI.InputName = 'GenSpeed';
    C_PI.OutputName = 'C_Pitch';
    
    % Platform Feedback
    Fl_Gain     = -9;
    Fl_Enable   = 1;
    Fl_Bw       = .226;
    
    [~,Fl_LPF] = Af_LPF(Fl_Bw,1,1/80);
    C_Fl        = Fl_LPF / s * Fl_Gain * Fl_Enable;
    C_Fl.InputName = 'NacIMU';
    C_Fl.OutputName = 'Fl_Pitch';
    
    S = sumblk('PitchCmd = C_Pitch + Fl_Pitch');
    
    
    % Pitch Actuator
    om_act =  2*pi*0.125;  %actuator bandwidth
    
    Act = tf(om_act^2,[1,2*.707*om_act,om_act^2]);
    Act.InputName = 'PitchCmd';
    Act.OutputName = 'BldPitch';
    
    
    % Connect Everything
    P_CL = connect(C_PI,C_Fl,S,Act,P{indLin},'WindSpeed',{'BldPitch','GenSpeed','TwrBsMyt'});
    
    % Linear Simulation
    yy = lsim(P_CL,uu(:,1),tt');
    
    
    figure(101);
    set(gcf,'Name','Closed Loop Step');
    
    subplot(311);
    plot(tt,yy(:,1)); hold on;
    ylabel('Bld Pitch (deg.)');
    
    subplot(312);
    plot(tt,yy(:,2)); hold on;
    ylabel('Gen Speed (rpm)');
    
    subplot(313);
    plot(tt,yy(:,3)); hold on;
    ylabel('Twr Bs FA (kNm)');
    
    
    % Compare Nonlinear
    % Not supported for multiple model comparison
    
    CompNL = 0;
    endtime = 100;
    
    
    if CompNL
        
        %% Load NL Sim & Get Initial Conditions
        load('/Users/dzalkind/Tools/matlab-toolbox/Simulations/SaveData/StepPlay/U14_step.mat','Chan')
        
        NL_startTime = 200;
        phi_0   = Chan.PtfmPitch(Chan.tt == NL_startTime);
        
        om_0    = Chan.GenSpeed(Chan.tt == NL_startTime);
        %     dphi_0  = Chan.PtfmRVyt(Chan.tt == NL_startTime);
        
        x0 = [0;rpm2radps(om_0);deg2rad(phi_0);deg2rad(0)] - [0;rpm2radps(7.55);deg2rad(1.98);0];
        
        BldPitch_0      = Chan.BldPitch1(Chan.tt == NL_startTime);
        Gen_0           = Chan.GenSpeed(Chan.tt == NL_startTime);
        PltPitch_0      = Chan.PtfmPitch(Chan.tt == NL_startTime);
        TwrBsMyt_0      = Chan.TwrBsMyt(Chan.tt == NL_startTime);
        
        
        figure(101);
        subplot(311);
        hold on;
        plot(Chan.tt-NL_startTime,deg2rad(Chan.BldPitch1 - BldPitch_0));
        hold off;
        xlim([0,endtime]);
        
        subplot(312);
        hold on;
        plot(Chan.tt-NL_startTime,Chan.GenSpeed - Gen_0);
        hold off;
        xlim([0,endtime]);
        
        subplot(313);
        hold on;
        plot(Chan.tt-NL_startTime,1000* (Chan.TwrBsMyt - TwrBsMyt_0));
        hold off;
        xlim([0,endtime]);
        
    end
    
end