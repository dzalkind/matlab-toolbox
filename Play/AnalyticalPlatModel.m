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
ptfm_freq   = 0.213;

Ng          = 1;  % gearbox ratio
% Platform: these are hard to determine and are technically frequency
% dependent.  Perhaps we can do a sys id for them

A_phi = 1.65e10;
B_phi = A_phi / 11;
C_phi = A_phi * ptfm_freq / 2 /pi;  %should be M^2, but this works better


%% Select Wind Speeds
% Choose indices of wind speeds to linearize at
% Suggestion: one above rated, near rated, and below-rated

indWS = 25;


%% Open Loop Model

iSys = 1;

P = cell(1,length(indWS));

for ind = indWS
    
    A = [A_om(ind),                     0,                                      -b_wind(ind) * l_T;
        0,                              0,                                      1;
        l_T * Pi_omega(ind) / A_phi,    -(C_phi)/A_phi,  -(B_phi+ + l_T^2 * Pi_wind(ind))/A_phi];
    
    B = [b_theta(ind),                 b_tau(ind),     b_wind(ind);
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
        uu(:,3) = 1;
        
        yy = lsim(P{1},uu,tt);
        
        figure(1000);
        subplot(211);
        plot(tt,yy(:,1));
        
        subplot(212);
        plot(tt,yy(:,2));
    end
    
    
end


%% Closed-Loop Model
% Pitch Control First`  
% No platform feedback

for ind = indWS
    
    k_P     = -pc_Kp(ind)/10;
    k_I     = -pc_Ki(ind)/10;
    k_phi   = 0;  % this round
    
    A_CL = [0,                                 1,                                                      0,              0;
        b_theta(ind)*k_I,                   A_om(ind) + b_theta(ind)*k_P,                                       0,              b_theta(ind) * k_phi - b_wind(ind) * l_T;
        0,                                  0,                                                      0,              1;
        l_T * Pi_theta(ind) * k_I / A_phi,  (l_T/A_phi) * (Pi_omega(ind) + Pi_theta(ind) * k_P),   -C_phi/A_phi,    -(1/A_phi) * (B_phi+ + l_T^2 * Pi_wind(ind) + l_T * Pi_theta(ind) * k_phi)];
    
%     B = [b_theta(ind),                 b_tau(ind),     b_wind(ind);
%         0,                             0,              0;
%         l_T * Pi_theta(ind) / A_phi,   0,              l_T * Pi_wind(ind) / A_phi];
%     
%     C = [Ng,    0,  0;
%         0,      1,  0];
%     
%     D = zeros(2,3);
%     
%     P{iSys} = ss(A,B,C,D);
%     
%     P{iSys}.InputName = {'Pitch','Torque','Wind'};
%     P{iSys}.OutputName = {'GenSpeed','PtfmPitch'};
%     
%     
%     iSys = iSys + 1;
%     
%     %% test response to step wind
%     if 1
%         dt = 1/80;
%         tt = 0:dt:100;
%         uu = zeros(length(tt),3);
%         uu(:,3) = 1;
%         
%         yy = lsim(P{1},uu,tt);
%         
%         figure(1000);
%         subplot(211);
%         plot(tt,yy(:,1));
%         
%         subplot(212);
%         plot(tt,yy(:,2));
%     end
    
    
end








