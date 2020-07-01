%% Analytical_PlatModel

clear;

% Linear Model File
linModFile = 'IEA15MW_LinMod.dat';


%% Get Linear Data

fid = fopen(linModFile);

headerLine  = fgetl(fid);
C           = textscan(headerLine,'%s');
Headers     = C{1};

M = dlmread(linModFile,'\t',1,0);


for iHead = 1:length(Headers)
    eval([Headers{iHead},'=M(:,iHead);']);
end

%% Set Additional Linear Info

l_T         = 150;  %hub height
ptfm_freq   = 0.17296;

Ng          = 1;  % gearbox ratio
% Platform: these are hard to determine and are technically frequency
% dependent.  Perhaps we can do a sys id for them

A_phi = 0.96698e11;
B_phi = A_phi / 20;
C_phi = A_phi * (ptfm_freq / 2 /pi);  %should be freq^2, but this works better

% I think b_wind is off
b_w = b_wind * 1;

% Select Wind Speeds
% Choose indices of wind speeds to linearize at
% Suggestion: one above rated, near rated, and below-rated

indWS = 25;


% Open Loop Model

iSys = 1;

P = cell(1,length(indWS));

for ind = indWS
    
    A = [A_om(ind),                     0,                                      -b_w(ind) * l_T;
        0,                              0,                                      1;
        l_T * Pi_omega(ind) / A_phi,    -(C_phi)/A_phi,  -(B_phi+ + l_T^2 * Pi_wind(ind))/A_phi];
    
    B = [b_theta(ind),                 b_tau(ind),     b_w(ind);
        0,                             0,              0;
        l_T * Pi_theta(ind) / A_phi,   0,              l_T * Pi_wind(ind) / A_phi];
    
    C = [Ng,    0,  0;
        0,      1,  0];
    
    D = zeros(2,3);
    
    P{iSys} = ss(A,B,C,D);
    
    P{iSys}.InputName = {'Pitch','Torque','Wind'};
    P{iSys}.OutputName = {'GenSpeed','PtfmPitch'};
    
    
    iSys = iSys + 1;
    
    %% test response to step wind
    if 1
        dt = 1/80;
        tt = 0:dt:100;
        uu = zeros(length(tt),3);
        uu(:,3) = 4;
        
        yy = lsim(P{1},uu,tt);
        
        figure(1000);
        subplot(211);
        plot(tt,yy(:,1));
        
        subplot(212);
        plot(tt,yy(:,2));
    end
    
    
end

CompNL = 1;

if CompNL
    load('/Users/dzalkind/Tools/matlab-toolbox/Simulations/SaveData/u14_step.mat','Chan')
end


% Closed-Loop Model
% Pitch Control First`
% No platform feedback

iSys = 1;
for ind = indWS
    
    gainFact = 1;
    k_P     = -pc_Kp(ind)/gainFact;
    k_I     = -pc_Ki(ind)/gainFact;
    k_phi   = -9;
    
    A_CL = [0,                                 1,                                                      0,              0;
        b_theta(ind)*k_I,                   A_om(ind) + b_theta(ind)*k_P,                                       0,              b_theta(ind) * k_phi - b_w(ind) * l_T;
        0,                                  0,                                                      0,              1;
        l_T * Pi_theta(ind) * k_I / A_phi,  (l_T/A_phi) * (Pi_omega(ind) + Pi_theta(ind) * k_P),   -C_phi/A_phi,    -(1/A_phi) * (B_phi+ + l_T^2 * Pi_wind(ind) - l_T * Pi_theta(ind) * k_phi)];
    
    B_CL = [0,                                 0,              0;
        A_om(ind) - 1,                      -b_tau(ind),    b_w(ind);
        0,                                  0,              0;
        l_T * Pi_omega(ind) / A_phi,        0,              l_T * Pi_wind(ind) / A_phi];
    
    C_CL = [0,     Ng,    0,  0;
        0,      0,     1,  0;
        k_I,    k_P,    0,  0];
    
    D_CL = zeros(3,3);
    
    P_CL{iSys} = ss(A_CL,B_CL,C_CL,D_CL);
    
    P_CL{iSys}.InputName = {'GenRef','Torque','Wind'};
    P_CL{iSys}.OutputName = {'GenSpeed','PtfmPitch','BldPitch'};
    
    
    %     iSys = iSys + 1;
    
    % test response to step wind
    if 1
        endtime = 200;
        dt = 1/80;
        tt = 0:dt:endtime;
        uu = zeros(length(tt),3);
        uu(:,3) = 1;
        
        if CompNL
            NL_startTime = 200;
            phi_0   = Chan.PtfmPitch(Chan.tt == NL_startTime);
            
            om_0    = Chan.GenSpeed(Chan.tt == NL_startTime);
            dphi_0  = Chan.PtfmRVyt(Chan.tt == NL_startTime);
            
            x0 = [0;rpm2radps(om_0);deg2rad(phi_0);deg2rad(dphi_0)] - [0;rpm2radps(7.55);deg2rad(1.98);0];
        end
        
        if CompNL
            yy = lsim(P_CL{1},uu,tt);
        end
        
        figure(1001);
        subplot(311);
        plot(tt,yy(:,3));
        if CompNL
            hold on;
            plot(Chan.tt-NL_startTime,deg2rad(Chan.BldPitch1 - 9.95));
            hold off;
            xlim([0,endtime]);
        end        
        
        subplot(312);
        plot(tt,yy(:,1));
        if CompNL
            hold on;
            plot(Chan.tt-NL_startTime,rpm2radps(Chan.GenSpeed - 7.55));
            hold off;
            xlim([0,endtime]);
        end
        
        subplot(313);
        plot(tt,yy(:,2));
        if CompNL
            hold on;
            plot(Chan.tt-NL_startTime,deg2rad(Chan.PtfmPitch - 1.9));
            hold off;
            xlim([0,endtime]);
        end
    end
    
    
end








