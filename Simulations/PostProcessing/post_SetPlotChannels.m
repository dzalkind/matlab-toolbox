%% post_SetPlotChannels
if exist('P','var')
    Param = P;
end

if exist('Param','var')
    PP.TimePlot.Xlim        =   [20,GetFASTPar(Param.FP,'TMax')];
else
    PP.TimePlot.Xlim        =   [20,2000];
end
PP.TimePlot.hold        =   1;

pp=1;

%% Calculated Channels

iChan = 1;
PP.CalcCh(iChan).name       = 'RootMyb0';
PP.CalcCh(iChan).eval       = '1/2*($RootMyb1$ + $RootMyb2$)';
iChan=iChan+1;

PP.CalcCh(iChan).name       = 'RootMybD';
PP.CalcCh(iChan).eval       = '1/2*($RootMyb1$ - $RootMyb2$)';
iChan=iChan+1;

PP.CalcCh(iChan).name       = 'RootMyb_Mag';
PP.CalcCh(iChan).eval       = 'sqrt($RootMyb1$.^2 + $RootMxb1$.^2)';
iChan=iChan+1;

PP.CalcCh(iChan).name       = 'TipBendM';
PP.CalcCh(iChan).eval       = 'sqrt($LSSTipMya$.^2 + $LSSTipMza$.^2)';
iChan=iChan+1;

PP.CalcCh(iChan).name       = 'YawBrM';
PP.CalcCh(iChan).eval       = 'sqrt($YawBrMzp$.^2 + $YawBrMyp$.^2)';
iChan=iChan+1;

PP.CalcCh(iChan).name       = 'TwrBsM';
PP.CalcCh(iChan).eval       = 'sqrt($TwrBsMyt$.^2 + $TwrBsMyt$.^2)';
iChan=iChan+1;

%% Plot Channels

if isfield(PP,'Channels')
    PP = rmfield(PP,'Channels');
end

iChan = 1;
PP.Channels{iChan}          =   {
    {'Wind1VelX',        []}
    {'GenTq',        []}
    {'BldPitch1',        []}
    {'GenPwr',        [1e-3]}
    {'GenSpeed',        []}
%     {'RootMyb1',        [1e-3]}
    {'TwrBsMyt',        [1e-3]}
    {'PtfmPitch',           []}
    }; iChan=iChan+1;

% PP.Channels{iChan}          =   {
%     {'GenSpeed',        []}
%     {'GenTq',           []}
%     {'BldPitch1',        []}
%     }; iChan=iChan+1;
% 
% PP.Channels{iChan}          =   {
%     {'RootMyc1',        []}
%     {'RootMyc2',           []}
%     {'RootMxc1',        []}
%     {'RootMxc2',        []}
%     }; iChan=iChan+1;
% 
% PP.Channels{iChan}          =  {
%     {'RotTorq',           []}
%     {'HSShftTq',           []}
%     {'LSSTipMya',           []}
%     {'LSSTipMza',           []}
%     {'TipBendM',           []}
%     }; iChan=iChan+1;
% 
% PP.Channels{iChan}          =  {
%     {'LSSTipMys',           []}
%     {'LSSTipMzs',           []}
%     }; iChan=iChan+1;
% 
% PP.Channels{iChan}          =   {
%     {'YawBrMzp',        []}
%     {'YawBrMyp',        []}
%     {'YawBrMxp',        []}
%     {'YawBrM',          []}
%     {'NacYaw',          []}
%     }; iChan=iChan+1;
% 
% PP.Channels{iChan}          =   {
%     {'TwrBsMyt',        []}
%     {'TwrBsMxt',        []}
%     {'TwrBsM',          []}
%     {'TTDspFA',          []}
%     {'TTDspSS',          []}
%     {'PtfmPitch',       []}
%     }; iChan=iChan+1;
% 
% PP.Channels{iChan}          =  {
%     {'Wind1VelX',           []}
%     {'Wave1Elev',           []}
%     {'GenSpeed',           []}
%     {'NcIMUTVxs',          []}
%     {'PtfmRVyt',           []}
%     {'BldPitch1',             []}
%     {'GenTq',           []}
%     {'PtfmPitch',           []}
%     }; iChan=iChan+1;
% 
% %
% %     PP.Channels{iChan}          =   {
% %         {'RtVAvgxh'        []}
% % %         {'Wind1VelY'        []}
% % %         {'BldPitch1',       []}
% % %         {'GenSpeed',        []}
% %         }; iChan=iChan+1;
% 
% 
% PP.Channels{iChan}          =  {
%     {'GenSpeed',           []}
%     {'BldPitch1',             []}
%     {'TwrBsMyt',           [1e-3]}
%     }; iChan=iChan+1;
% 
% PP.Channels{iChan}          =  {
%     {'RtVAvgxh',           []}
%     {'RotSpeed',             []}
%     {'TSR',           [1e-3]}
%     {'BldPitch1',             []}
%     {'RotPwr',        []}
%     }; iChan=iChan+1;
% %
% PP.Channels{iChan}          =  {
%     {'PtfmRVyt',          []}
%     {'TwrBsMyt',           []}
%     {'PtfmPitch',           []}
%     {'PtfmSurge',           []}
%     }; iChan=iChan+1;
% 
% PP.Channels{iChan}          =  {
%     {'TwrClrnc1',           []}
%     {'TwrClrnc2',           []}
%     {'TwrClrnc3',           []}
%     }; iChan=iChan+1;
% %
% PP.Channels{iChan}          =  {
%     {'Wind1VelX',           []}
%     {'GenSpeed',           []}
%     {'GenTq',           []}
%     {'BldPitch1',           []}
%     }; iChan=iChan+1;
% %
% PP.Channels{iChan}          =  {
%     {'OoPDefl1',           []}
%     {'OoPDefl2',           []}
%     {'OoPDefl3',           []}
%     %         {'RootMyb0',           []}
%     %         {'RootMybD',             []}
%     }; iChan=iChan+1;
% %
% PP.Channels{iChan}          =  {
%     {'GenSpeed',           []}
% %     {'GenTq',           []}
%     {'BldPitch1',       []}
%     {'PtfmPitch',             []}
%     {'TwrBsMyt',           [1e-3]}
% %     {'TwrBsMxt',           []}
%     }; iChan=iChan+1;
% 
% PP.Channels{iChan}          =  {
%     {'Wind1VelX',       []}
%     {'BldPitch1',       []}
%     {'GenSpeed',           []}
%     {'RootMyc0',           [1e-3]}
%     }; iChan=iChan+1;
% 
% PP.Channels{iChan}          =   {
%     {'RootMyc1',        []}
%     {'RootMyc2',           []}
%     {'RootMyc0',           []}
%     {'RootMxc1',        []}
%     {'RootMxc2',        []}
%     {'RootMxc0',        []}
%     }; iChan=iChan+1;
% 

PP.Channels{iChan}          =   {
    {'PtfmRVyt',           []}
    {'RtVAvgxh',           []}
    }; iChan=iChan+1;

PP.Channels{iChan}          =   {
    {'PtfmHeave',           []}
    {'PtfmPitch',           []}
    {'PtfmRoll',           []}
    {'PtfmSurge',           []}
    {'PtfmSway',           []}
    {'PtfmYaw',           []}
    }; iChan=iChan+1;



%% Signals

iSig = 1;
PP.Signals{iSig}             = {
    {'WE_Vw',    [],         [],     []}
    {'om_t0',    [],         [],     []}
    {'FA_AccR',    [],         [],     []}
    {'FA_AccF',    [],         [],     []}
    {'Fl_Pitcom',    [],         [],     []}
    {'SS_dOmF',    [],         [],     []}
    };iSig = iSig + 1;

PP.Signals{iSig}             = {
    {'Vhatf',    [],         [],     []}
    {'PC_MinPit',    [],         [],     []}
    {'APC_Pit',    [],         [],     []}
    {'WE_Cp',    [],         [],     []}
    };iSig = iSig + 1;

PP.Signals{iSig}             = {
    {'WE_w',    [],         [],     []}
    {'WE_t',    [],         [],     []}
    {'WE_b',    [],         [],     []}
    {'WE_Vw',    [],         [],     []}
    {'WE_D',    [],         [],     []}
    };iSig = iSig + 1;


%% Cleanup

clearvars pp iSig iChan