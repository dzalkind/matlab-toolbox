%% CompLinModels


clear;

%% Gather Models

LinearPath = '/Users/dzalkind/Tools/WISDEM/UMaine/Linear_HydroOff';
LinearPaths = {'/Users/dzalkind/Tools/WISDEM/UMaine/Linear_Hydro';
    '/Users/dzalkind/Tools/WISDEM/UMaine/Linear_HydroOff'
    };



outPrefix = 'testing';
outSuffix = '.outb';
outFiles    = dir(fullfile(LinearPath,[outPrefix,'*',outSuffix]));
nLinCases = length(outFiles);


LinFiles = cell(1,nLinCases);


% MBC = struct(length(LinearPaths),nLinCases);

for iOrder = 1:length(LinearPaths)
    for iCase = 1
        LinFilesS = dir(fullfile(LinearPaths{iOrder},[outPrefix,'_',num2str(iCase-1,'%01d'),'.*.lin']));
        
        for iFile = 1:length(LinFiles)
            LinFiles{iFile} = fullfile(LinearPaths{iOrder},LinFilesS(iFile).name);
        end
        
        [MBC(iOrder),matData(iOrder)] = fx_mbc3(LinFiles);
        
        
    end
end



%% Form Systems

PitchDesc   = 'ED Extended input: collective blade-pitch command, rad';
WindDesc    = 'IfW Extended input: horizontal wind speed (steady/uniform wind), m/s';
GenDesc     = 'ED GenSpeed, (rpm)';
TwrDesc     = 'ED TwrBsMyt, (kN-m)';
AzDesc      = 'ED Variable speed generator DOF (internal DOF index = DOF_GeAz), rad';

for iOrder = 1:length(LinearPaths)
    indPitch    = find(strcmp(PitchDesc,matData(iOrder).DescCntrlInpt));
    indWind     = find(strcmp(WindDesc,matData(iOrder).DescCntrlInpt));
    indTwr      = find(strcmp(TwrDesc,matData(iOrder).DescOutput));
    indGen      = find(strcmp(GenDesc,matData(iOrder).DescOutput));
    indAz       = strcmp(AzDesc,matData(iOrder).DescStates);
    
    indOuts     = [indGen,indTwr];
    indInps     = [indWind,indPitch];
    indStates   = 1:length(matData(iOrder).DescStates); indStates(indAz) = [];

    P{iOrder} = ss(MBC(iOrder).AvgA(indStates,indStates),MBC(iOrder).AvgB(indStates,indInps),...
        MBC(iOrder).AvgC(indOuts,indStates),MBC(iOrder).AvgD(indOuts,indInps));
    
    P{iOrder}.OutputName    = {'GenSpeed','TwrBsMyt'};
    P{iOrder}.InputName     = {'WindSpeed','BldPitch'};
    
    
    
end

%% Reduce Hydro States

Pmin = minreal(P{1});

%% Bode

figure(100);
bodemag(P{1},Pmin,P{2});



%% Step Wind Input

tt = (0:1/100:100)';
uu = [zeros(length(tt),1),ones(length(tt),1)];
uu = [ones(length(tt),1),zeros(length(tt),1)];

figure(101);
subplot(311);
plot(tt,uu(:,1),'linewidth',2);

for iOrder = 1:length(LinearPaths)
    yy{iOrder} = lsim(P{iOrder},uu,tt);
    
    subplot(312);
    plot(tt,yy{iOrder}(:,1),'linewidth',2);
    hold on;
    ylabel('Gen Speed');
    
    subplot(313);
    plot(tt,yy{iOrder}(:,2),'linewidth',2);
    hold on;
    ylabel('TwrBsMyt');

end

subplot(312);hold off;
subplot(313);hold off;



%% PI Control

% Copy ROSCO GS table in

PC = [0.064065  0.091441  0.113134  0.131901  0.148787  0.164298  0.178797  0.192476  0.205467  0.217906  0.229898  0.241557  0.252756  0.263645  0.274434  0.284672  0.294952  0.304789  0.314694  0.324122  0.333781  0.342816  0.352034  0.361052  0.369784  0.378753  0.387278  0.395688]; %                ! PC_GS_angles	    - Gain-schedule table: pitch angles
KP = [-1.273191  -1.100149  -0.958278  -0.839852  -0.739503  -0.653385  -0.578671  -0.513238  -0.455456  -0.404058  -0.358041  -0.316603  -0.279092  -0.244975  -0.213811  -0.185234  -0.158933  -0.134648  -0.112155  -0.091262  -0.071805  -0.053641  -0.036645  -0.020708  -0.005734  0.008362  0.021655  0.034212];           %     ! PC_GS_KP		- Gain-schedule table: pitch controller kp gains
KI = [-0.132832  -0.119684  -0.108904  -0.099906  -0.092281  -0.085737  -0.080060  -0.075088  -0.070698  -0.066792  -0.063296  -0.060147  -0.057297  -0.054705  -0.052337  -0.050165  -0.048167  -0.046322  -0.044612  -0.043025  -0.041547  -0.040166  -0.038875  -0.037664  -0.036526  -0.035455  -0.034445  -0.033491];        %        ! PC_GS_KI		- Gain-schedule table: pitch controller ki gains

pc = deg2rad(10);
kp = interp1(PC,KP,pc);
ki = interp1(PC,KI,pc);

s = tf('s');
C_PI = kp + ki/s;
C_PI.InputName  = 'GenSpeed';
C_PI.OutputName = 'BldPitch';   

figure(200);
plot(rad2deg(PC),[KP;KI]);

for iOrder = 1:length(LinearPaths)
    P_CL{iOrder} = connect(P{iOrder},-C_PI,'WindSpeed',{'GenSpeed','TwrBsMyt'});
    
    
    [yy{iOrder},~,xx{iOrder}] = lsim(P_CL{iOrder},uu(:,1),tt);
    
    subplot(311);
    plot(tt,xx{iOrder}(:,4),'linewidth',2);
    hold on;
    
    subplot(312);
    plot(tt,yy{iOrder}(:,1),'linewidth',2);
    hold on;
    
    subplot(313);
    plot(tt,yy{iOrder}(:,2),'linewidth',2);
    hold on;

end

subplot(311);hold off;
subplot(312);hold off;
subplot(313);hold off;
