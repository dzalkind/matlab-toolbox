%% Load ROSCO Controller Parameters
% This script is required to load ROSCO control parameters into workspace
% Uses *.IN file parameters as input via P.SD_dllP  (ServoDyn Dll params)


% keyboard;


%% Simulation and controller setup


% Load old files until fully transitioned
addpath(genpath('/Users/dzalkind/Tools/TurbineControllers/SimulinkControllers/TSR_Tracking/'));        
ContParam = Pre_ContParam_TSR_DTU10MW;


%% Turbine Parameters

R.RotorRad = GetFASTPar(P.EDP,'TipRad');        % Rotor radius
R.GBRatio = GetFASTPar(P.EDP,'GBRatio');        % Gearbox ratio

R.GenEff    = GetFASTPar(P.SvDP,'GenEff')/100;


%% Torque Control Parameters

R.VS_RefSpd     = GetFASTPar(P.SD_dllP,'VS_RefSpd');  % reference speed for torque control
R.VS_MinOMSpd   = GetFASTPar(P.SD_dllP,'VS_MinOMSpd');  % Minimum rotor speed

R.VS_TSRopt     = GetFASTPar(P.SD_dllP,'VS_TSRopt');  % Minimum rotor speed

R.VS_KP         = GetFASTPar(P.SD_dllP,'VS_KP');        % PI gain schedule
R.VS_KP         = GetFASTPar(P.SD_dllP,'VS_KP');        % PI gain schedule
R.VS_KI         = GetFASTPar(P.SD_dllP,'VS_KI');

R.VS_MaxTq      = GetFASTPar(P.SD_dllP,'VS_MaxTq');      % max torque
R.VS_RtTq       = GetFASTPar(P.SD_dllP,'VS_RtTq');      % rated torque
R.VS_MaxRat     = GetFASTPar(P.SD_dllP,'VS_MaxRat');    % max torque rate

R.VS_Rgn3MP     = deg2rad(3); %GetFASTPar(P.SD_dllP,'VS_Rgn3MP');        % torque ratchet? not in .IN file, hard code for now


%% Pitch Control Parameters

R.PC_RefSpd     = GetFASTPar(P.SD_dllP,'PC_RefSpd');
R.PC_GS_angles     = GetFASTPar(P.SD_dllP,'PC_GS_angles');
R.PC_GS_KP     = GetFASTPar(P.SD_dllP,'PC_GS_KP');
R.PC_GS_KI     = GetFASTPar(P.SD_dllP,'PC_GS_KI');


R.PC_MaxPit     = GetFASTPar(P.SD_dllP,'PC_MaxPit');
R.PC_MinPit     = GetFASTPar(P.SD_dllP,'PC_MinPit');
R.PC_MaxRat     = GetFASTPar(P.SD_dllP,'PC_MaxPit');


%% Setpoint Smoothing Control Parameters

R.SS_VSGain     = GetFASTPar(P.SD_dllP,'SS_VSGain');
R.SS_PCGain     = GetFASTPar(P.SD_dllP,'SS_PCGain');

%% Filter Parameters

F_GBFilt        = Af_LPF(ContParam.HSSfilt_omn,1,simu.dt,1);
F_Wind          = Af_LPF(ContParam.WindSpeedEstfilt_omn,1,simu.dt,1);

F_HSS       = Af_LPF(GetFASTPar(P.SD_dllP,'F_LPFCornerFreq'),GetFASTPar(P.SD_dllP,'F_LPFDamping'),simu.dt);
F.HSS.b      = F_HSS.num{1};
F.HSS.a      = F_HSS.den{1};

F_SS            = Af_LPF(GetFASTPar(P.SD_dllP,'F_SSCornerFreq'),1,simu.dt,1);
F.F_SS.b        = F_GBFilt.num{1};
F.F_SS.a        = F_GBFilt.den{1};

Filt.Wind.b     = F_Wind.num{1};
Filt.Wind.a     = F_Wind.den{1};


%% Wind Speed Estimator Parameters
% Only the EKF is implemented, for meow

R.WE_BladeRadius    = GetFASTPar(P.SD_dllP,'WE_BladeRadius');
R.WE_CP_n           = GetFASTPar(P.SD_dllP,'WE_CP_n');
R.WE_CP             = GetFASTPar(P.SD_dllP,'WE_CP');
R.WE_Gamma          = GetFASTPar(P.SD_dllP,'WE_Gamma');
R.WE_GearboxRatio   = GetFASTPar(P.SD_dllP,'WE_GearboxRatio');
R.WE_Jtot           = GetFASTPar(P.SD_dllP,'WE_Jtot');
R.WE_RhoAir         = GetFASTPar(P.SD_dllP,'WE_RhoAir');
R.PerfFileName      = GetFASTPar(P.SD_dllP,'PerfFileName');
R.PerfTableSize     = GetFASTPar(P.SD_dllP,'PerfTableSize');
R.WE_FOPoles_N      = GetFASTPar(P.SD_dllP,'WE_FOPoles_N');
R.WE_FOPoles_v      = GetFASTPar(P.SD_dllP,'WE_FOPoles_v');
R.WE_FOPoles        = GetFASTPar(P.SD_dllP,'WE_FOPoles');

% Cp Surface
Cx                  = Pre_LoadRotPerf(fullfile(fast.FAST_runDirectory,F.Out.Cx));

% Initial condition
R.WE_v0             = 12;
R.WE_om0            = GetFASTPar(P.EDP,'RotSpeed') * R.WE_GearboxRatio;

% %% Load CpSurface 
% % cpscan = load('/Users/nabbas/Documents/TurbineModels/DTU_10MW/DTU10MWRWT/CpScan/CpScan.mat');
% 
% 
% TSRvec = cpscan.TSR;
% zind = find(cpscan.BlPitch == 0);
% Cpvec = cpscan.Cpmat(:,zind)';
% TSR_opt = TSRvec(Cpvec == max(Cpvec));


% % Betavec = cpscan.BlPitch(zind:end);
% % Cpmat = cpscan.Cpmat(:,zind:end);

%% Find plant parameters

cpscan = Cx;
[Avec,Bbvec,GS,Beta_op,vv] = Pre_TSRtracking_GS(ContParam,cpscan);
ContParam.GS = GS;

% Trim for BldPitch Controller
Bopind = find(Beta_op>0);
Avec_BPC = Avec(Bopind(1):end);
Bbvec_BPC = Bbvec(Bopind(1):end);
Betaop_BPC = Beta_op(Bopind(1):end);
vv_bpc = vv(Bopind(1):end);



%% Load Outlist
% OutName = 'DTU_10MW_OO_GoM.SFunc.out';
% SFunc_OutfileName = [ModDir filesep OutName];


% OutList = Post_LoadOutlist(SFunc_OutfileName); 
% %% Run Simulation
% % % TSR_opt = TSRvec(Cpvec == max(Cpvec));
% sim('TSR_Tracking_v2.mdl',[0,TMax]);
% 
% for i = 1:length(OutList)
%     try
%         simout.(OutList{i}) = FAST_Out.Data(:,i);
%     catch
%         warning(['Outlist Parameter ' OutList{i} ' was not loaded from the fast.out file.'])
%     end
% end
% simout.VSparams_a = VS_params.signals.values(:,1);
% simout.VSparams_rotspeederr = VS_params.signals.values(:,2);
% simout.VSparams_Ki = VS_params.signals.values(:,3);
% simout.VSparams_Kp = VS_params.signals.values(:,4);
% simout.TSR = simout.RotSpeed./simout.Wind1VelX * ContParam.RotorRad * pi/30;
% simout.VSparams_omopt = Om_opt.Data;
% 
% simout.PCparams_a = PC_params.signals.values(:,1);
% simout.PCparams_rotspeederr = PC_params.signals.values(:,2);
% simout.PCparams_Ki = PC_params.signals.values(:,3);
% simout.PCparams_Kp = PC_params.signals.values(:,4);
% simout.PCparams_B_ss = PC_params.signals.values(:,5);
% 
% simout.ContParam = ContParam;
%% Plots, if you want them
% Pl_FastPlots(simout);

% % Setpoint smoothing
% delplots = 1;
% if delplots
%     figure(1)
%     myplot(DelOmega); hold on
%     title('DelOmega')
%     figure(2)
%     myplot(Omega_tg_ref); hold on
%     title('Torque Reference')
%     figure(3)
%     myplot(Omega_bg_ref); hold on
%     title('BldPitch Reference')
% end
% 
% figure
% myplot(Omega_tg_ref); hold on
% myplot(Omega_bg_ref);
% myplot(simout.Time, simout.GenSpeed*pi/30);
% legend('Torque Ref','BldPitch Ref', 'GenSpeed')

