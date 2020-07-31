%% SolveLinModels
% Solve linear systems generated using ProcLinModels.m

clear;
close all;

%% Load Models

save_dir = '/Users/dzalkind/Tools/matlab-toolbox/Simulations/SaveData/LinearModels';

save_name = 'PitTwr';

load(fullfile(save_dir,save_name));


%%  Define Distrubance input
%

dist_type = 2;

switch dist_type
    
    case 1  % step
        load('/Users/dzalkind/Tools/matlab-toolbox/Simulations/SaveData/StepPlay/U14_step.mat','Chan')
        
        NL_startTime = 200;
        u_h     = [1;1];
        t_d     = [0;1000];
        
        Lin_TMax    = 100;
        
        % reference sim
        
    case 2  % turbulent input, 16 m/s
        load('/Users/dzalkind/Tools/matlab-toolbox/Simulations/SaveData/072720_183300.mat')
        NL_startTime    = 450;
        Lin_TMax        = 150;
        
        lin_inds        = Chan.tt >= NL_startTime & Chan.tt <= NL_startTime + Lin_TMax;
        
        u_h     = Chan.RtVAvgxh(lin_inds) - mean(Chan.RtVAvgxh);        % might want to filter, do we want mean over lin_inds? I don't think so
        t_d     = Chan.tt(lin_inds);
        
        
        
end


%% Choose Linear Model

choose_type = 3;

switch choose_type
    
    case 1      % based on mean wind speed of window
        uh_op = mean(Chan.RtVAvgxh(lin_inds));
        
        
    case 2      % based on starting wind speed of window
        [~,start_ind] = min(abs(Chan.tt - NL_startTime));
        uh_op   = Chan.RtVAvgxh(start_ind);
        
        u_h     = Chan.RtVAvgxh(lin_inds) - uh_op;
        
    case 3      % wind based on starting wind speed, sys based on avg
        [~,start_ind] = min(abs(Chan.tt - NL_startTime));
        uh_op   = mean(Chan.RtVAvgxh(lin_inds));
        
        u_h     = Chan.RtVAvgxh(lin_inds) - Chan.RtVAvgxh(start_ind);
end

% u_h_op = 14;

AA = zeros(length(P{1}.A),length(P{1}.A),length(P));
BB = zeros(size(P{1}.B,1),size(P{1}.B,2),length(P));
CC = zeros(size(P{1}.C,1),size(P{1}.C,2),length(P));
DD = zeros(size(P{1}.D,1),size(P{1}.D,2),length(P));

uh_ops  = zeros(size(P{1}.A,1),1);
u_opsM  = zeros(length(indInps),length(P));
y_opsM  = zeros(length(indOuts),length(P));


for iSys = 1:length(P)
    s               = size(P{iSys}.A);
    nStates(iSys)   = s(1);
    
    uh_ops(iSys)     = u_ops{iSys}(indWind);
    
    u_opsM(:,iSys)       = u_ops{iSys}(indInps);
    y_opsM(:,iSys)       = y_ops{iSys}(indOuts);
    %     x_opsM(:,iSys)       = x_ops{iSys};
    
    AA(:,:,iSys)    = P{iSys}.A;
    BB(:,:,iSys)    = P{iSys}.B;
    CC(:,:,iSys)    = P{iSys}.C;
    DD(:,:,iSys)    = P{iSys}.D;
end

AA_p = permute(AA,[3,1,2]);
BB_p = permute(BB,[3,1,2]);
CC_p = permute(CC,[3,1,2]);
DD_p = permute(DD,[3,1,2]);

% Interpolate System Matrices & Operating Points
A_op    = squeeze(interp1(uh_ops,AA_p,uh_op));
B_op    = squeeze(interp1(uh_ops,BB_p,uh_op));
C_op    = squeeze(interp1(uh_ops,CC_p,uh_op));
D_op    = squeeze(interp1(uh_ops,DD_p,uh_op));

P_op    = ss(A_op,B_op,C_op,D_op);

% Same Names for inputs and outputs
P_op.OutputName    = {'GenSpeed','TwrBsMyt','PltPitch','NacIMU'};
P_op.InputName     = {'WindSpeed','BldPitch'};


u_op    = interp1(uh_ops,u_opsM',uh_op)';
y_op    = interp1(uh_ops,y_opsM',uh_op)';
% x_op    = interp1(uh_ops,x_opsM',uh_op)';     % skip states because not
% reduced
% b_op


%% Open Loop Step


% Choose Case(s) Here, reference case_matrix.yaml

figure(100);
subplot(211); hold off;
subplot(212); hold off;

% Inputs
tt = 0:1/80:Lin_TMax;
uu = zeros(length(tt),2);

u_lin   = interp1(t_d-NL_startTime,u_h,tt);
uu(:,1) = u_lin;

% Linear Simulation
yy = lsim(P_op,uu,tt);


figure(100);
set(gcf,'Name','Open Loop Step');

subplot(511);
plot(tt,u_lin + u_op(1));

subplot(512);
plot(tt,yy(:,1)+y_op(1)); hold on;
ylabel('Gen Speed (rpm)');

subplot(513);
plot(tt,yy(:,2)+y_op(2)); hold on;
ylabel('Twr Bs FA (kNm)');

subplot(514);
plot(tt,yy(:,3)+y_op(3)); hold on;
ylabel('Ptfm Pitch (kNm)');


%% Closed Loop Control

figure(101);
subplot(511); hold off;
subplot(512); hold off;
subplot(513); hold off;
subplot(514); hold off;
subplot(515); hold off;



% PI Control (ROSCO) Parameters
[SvDP, SvDFile]         = GetFASTPar_Subfile(FP, 'ServoFile', LinearPath, LinearPath);
[~,SD_dllFile]          = GetFASTPar_Subfile(SvDP,'DLL_InFile', LinearPath, LinearPath);
SD_dllP                 = ROSCO2Matlab(SD_dllFile,2);

PC_GS_angles          = GetFASTPar(SD_dllP,'PC_GS_angles');
PC_GS_KP              = GetFASTPar(SD_dllP,'PC_GS_KP');
PC_GS_KI              = GetFASTPar(SD_dllP,'PC_GS_KI');

kp = -interp1(PC_GS_angles,PC_GS_KP,u_op(2),'linear','extrap');
ki = -interp1(PC_GS_angles,PC_GS_KI,u_op(2),'linear','extrap');


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
om_act =  1.00810; %2*pi*0.125;  %actuator bandwidth

Act = tf(om_act^2,[1,2*.707*om_act,om_act^2]);
Act.InputName = 'PitchCmd';
Act.OutputName = 'BldPitch';


% Connect Everything
P_CL = connect(C_PI,C_Fl,S,Act,P_op,'WindSpeed',{'BldPitch','GenSpeed','TwrBsMyt','PltPitch'});

% Linear Simulation
yy = lsim(P_CL,uu(:,1),tt');


figure(101);
set(gcf,'Name','Closed Loop');

subplot(511);
plot(tt+NL_startTime,uu(:,1)+u_op(1)); hold on;
plot(Chan.tt,u_op(1)*ones(size(Chan.tt)),'k--')
ylabel('Wind Dist. (m/s)');

subplot(512);
plot(tt+NL_startTime,yy(:,1)+u_op(2)); hold on;
plot(Chan.tt,u_op(2) * ones(size(Chan.tt)),'k--')
ylabel('Bld Pitch (rad.)');

subplot(513);
h_lin   = plot(tt+NL_startTime,yy(:,2)+y_op(1)); hold on;
h_op    = plot(Chan.tt,y_op(1) * ones(size(Chan.tt)),'k--');
ylabel('Gen Speed (rpm)');

subplot(514);
plot(tt+NL_startTime,yy(:,3)+y_op(2)); hold on;
plot(Chan.tt,y_op(2) * ones(size(Chan.tt)),'k--')
ylabel('Twr Bs FA (kNm)');

subplot(515);
plot(tt+NL_startTime,yy(:,4)+y_op(3)); hold on;
plot(Chan.tt,y_op(3) * ones(size(Chan.tt)),'k--')
ylabel('Ptfm Pitch (deg.)');


% Compare Nonlinear
% Not supported for multiple model comparison

CompNL = 1;


if CompNL
    
    %% Load NL Sim & Get Initial Conditions
    
    %     phi_0   = Chan.PtfmPitch(Chan.tt == NL_startTime);
    %
    %     om_0    = Chan.GenSpeed(Chan.tt == NL_startTime);
    %     %     dphi_0  = Chan.PtfmRVyt(Chan.tt == NL_startTime);
    %
    %     x0 = [0;rpm2radps(om_0);deg2rad(phi_0);deg2rad(0)] - [0;rpm2radps(7.55);deg2rad(1.98);0];
    %
    %     if 0  % use initial states
    %         BldPitch_0      = Chan.BldPitch1(Chan.tt == NL_startTime);
    %         Gen_0           = Chan.GenSpeed(Chan.tt == NL_startTime);
    %         PltPitch_0      = Chan.PtfmPitch(Chan.tt == NL_startTime);
    %         TwrBsMyt_0      = Chan.TwrBsMyt(Chan.tt == NL_startTime);
    %
    %     else % use average states
    %         BldPitch_0      = mean(Chan.BldPitch1(lin_inds));
    %         Gen_0           = mean(Chan.GenSpeed(lin_inds));
    %         PltPitch_0      = mean(Chan.PtfmPitch(lin_inds));
    %         TwrBsMyt_0      = mean(Chan.TwrBsMyt(lin_inds));
    %     end
    %
    
    t_buff = -1; %100;
    
    if NL_startTime < t_buff
        t_buff = NL_startTime;
    end
    
    figure(101);
    subplot(511);
    plot(Chan.tt,Chan.RtVAvgxh);
    if t_buff > 0
        xlim([NL_startTime-t_buff,NL_startTime+Lin_TMax+t_buff]);
    end
    ylabel('Rot. Avg. Wind (m/s)');
    
    subplot(512);
    hold on;
    plot(Chan.tt,deg2rad(Chan.BldPitch1));
    hold off;
    if t_buff > 0
        xlim([NL_startTime-t_buff,NL_startTime+Lin_TMax+t_buff]);
    end
    
    subplot(513);
    hold on;
    h_nl = plot(Chan.tt,Chan.GenSpeed );
    hold off;
    if t_buff > 0
        xlim([NL_startTime-t_buff,NL_startTime+Lin_TMax+t_buff]);
    end
    
    hl = legend([h_lin,h_nl,h_op],'Linear','Nonlinear','Op. Point');
    
    subplot(514);
    hold on;
    plot(Chan.tt,1000* (Chan.TwrBsMyt));
    hold off;
    if t_buff > 0
        xlim([NL_startTime-t_buff,NL_startTime+Lin_TMax+t_buff]);
    end
    
    subplot(515);
    hold on;
    plot(Chan.tt,(Chan.PtfmPitch));
    hold off;
    if t_buff > 0
        xlim([NL_startTime-t_buff,NL_startTime+Lin_TMax+t_buff]);
    end
    
end



%% Formatting & Printing

% if 1
%
%
hl.Position = [0.1721 0.5376 0.0946 0.0501];



