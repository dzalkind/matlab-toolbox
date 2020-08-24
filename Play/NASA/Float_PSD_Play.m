%% PSD Play


clear;

POST_PROCESS = 1;


%% Output Processing

TMD_Config = 'B';

fast.FAST_InputFile    = ['TMD_',TMD_Config,'_041'];   % FAST input file (no ext)
fast.FAST_directory    = ['/Users/dzalkind/Tools/SaveData/NASA/TMD_',TMD_Config,'/'];   % Path to fst directory files

% Get OutData

outfiles    = dir(fullfile(fast.FAST_directory,[fast.FAST_InputFile,'.out*']));
[~,~,ext]   = fileparts(outfiles(1).name);

if strcmp(ext,'.outb')
    [OutData,OutList] = ReadFASTbinary([fast.FAST_directory,filesep,fast.FAST_InputFile,'.outb']);
else
    [OutData,OutList] = ReadFASTtext([fast.FAST_directory,filesep,fast.FAST_InputFile,'.out']);
end


% Post Process
if POST_PROCESS
    
    post.Scripts = {
        'post_SetPlotChannels';
        'Signals = ROSCOout2Matlab(fullfile(fast.FAST_directory,[fast.FAST_InputFile,''.RO.out'']));'
        'post_GetSimSignals';
        'post_PlotChannels';
        'post_PlotSignals';
        'post_PSD';
        'post_SaveData';
        };
    
    % Plot
    % PlotFASToutput(FASTfiles,FASTfilesDesc,ReferenceFile,Channels,ShowLegend,CustomHdr,PlotPSDs,OnePlot)
    %
    % Channels = {'Wind1VelX','GenTq','BldPitch1','GenPwr','GenSpeed','RootMyb1','TwrBsMyt','PtfmPitch'};
    % outdata = PlotFASToutput([fast.FAST_runDirectory,filesep,fast.FAST_namingOut,'.out'],{'test'},1,Channels);
    
    
    
    PLOT = 1;
    
    for iPP = 1:length(post.Scripts)
        eval(post.Scripts{iPP});
    end
end


clearvars POST_PROCESS


%% PSD Set Up
% Using Old way, to get a feel for signals

tStart = 100;
Duration = 600;
iPSD = 1;

PP.PSD(iPSD).Signal = 'Wave1Elev';
PP.PSD(iPSD).Duration = 500;
PP.PSD(iPSD).TimeWindow = [tStart,tStart+Duration];
iPSD = iPSD + 1;

PP.PSD(iPSD).Signal = 'PtfmHeave';
PP.PSD(iPSD).Duration = 500;
PP.PSD(iPSD).TimeWindow = [tStart,tStart+Duration];
iPSD = iPSD + 1;

PP.PSD(iPSD).Signal = 'NcIMUTAzs';
PP.PSD(iPSD).Duration = 500;
PP.PSD(iPSD).TimeWindow = [tStart,tStart+Duration];
iPSD = iPSD + 1;


PP.PSD(iPSD).Signal = 'PtfmPitch';
PP.PSD(iPSD).Duration = 500;
PP.PSD(iPSD).TimeWindow = [tStart,tStart+Duration];
iPSD = iPSD + 1;

post_PSD;



%% Tinker with Nacelle IMU z accelleration

dt = 1/40;

[~,NcLPF] = Af_LPF(.8*2*pi,.707,dt);
[~,NcHPF] = Af_HPF(.05*2*pi,.707,dt,1);

NcHPF = 1;
d_int = tf([1],[1,0,0]);

HvFilt = c2d(d_int*NcLPF*NcHPF,dt);%,'method','tustin');

HvEst = lsim(HvFilt,Chan.NcIMUTAzs,Chan.tt);

figure(699);
bode(HvFilt);

figure(700);
subplot(311);
plot(Chan.tt,Chan.NcIMUTAzs);
xlim([tStart,tStart+Duration]);


subplot(312);
plot(Chan.tt,Chan.PtfmHeave);
xlim([tStart,tStart+Duration]);

subplot(313);
plot(Chan.tt,HvEst);



%% FFT vs. pwelch

if 0
    
    signal = Chan.PtfmHeave;
    % signal = Chan.Wave1Elev;
    
    tStart = 100;
    Duration = 600;
    
    
    indWindow = Chan.tt > tStart & Chan.tt < tStart + Duration;
    L = length(signal(indWindow));
    n = 2^(nextpow2(L)-1);
    
    
    y = fft(signal(indWindow),n);
    fs  = 1/dt;
    
    P2 = abs(y/L);
    P1 = P2(1:L/2+1);
    
    f = fs * (0:(L/2))/L;
    w = 2* pi * f;
    
    figure(7000);
    % loglog(w,P1)
    xlim([0,2]);
    
    
    % Filter
    
    n_filt = nextpow2(L);
    b = ones(n_filt,1)/n_filt;
    a = 1;
    
    P1_filt = filtfilt(b,a,P1);
    
    hold on;
    loglog(w,P1_filt);
    % hold off;
    
end

%% Sample Spectra

% Put things in rad/s, period
w = 2*pi*PP.PSD(1).Spec.ff;
T = 1./PP.PSD(1).Spec.ff;

signal_ind = 2;


hv_per = [8,15]; %heave excitation period
hv_w   = 2 * pi ./hv_per;

figure(800);
hs = loglog(w,PP.PSD(signal_ind).Spec.Power);
xlim([.1,10]);


ya = get(gca,'YLim');

hold on;
ht = plot(.81*[1,1],ya,'r');
hr1 = plot(hv_w(1)*[1,1],ya,'k');
hr2 = plot(hv_w(2)*[1,1],ya,'k');
hold off;


n_samps = 5;
range_freq = .5;  % rad/s
target_freq = .81; % rad/s

samp_freq = linspace(-range_freq/2,range_freq/2,n_samps) + target_freq;


P_samp  = interp1(w,PP.PSD(signal_ind).Spec.Power,samp_freq)

P_avg   = mean(P_samp)/n_samps

hold on;
h_samp = plot(samp_freq,P_samp,'kx','LineWidth',2,'MarkerSize',20);
hold off


legend([hs,ht,h_samp(1)],'Wave Spectra','Target Freq.','Sampled Freq.');


%% Test UMaine Function

C = nasa_control_cost([fast.FAST_directory,filesep,fast.FAST_InputFile,'.out'])

%% RAO Estimation

% first let's compute fft & filt over several signals
% work this into post_PSD soon

if 0
    
    PSD_Signals = {'Wave1Elev',
        'PtfmHeave'};
    
    
    Window = [100,700];
    
    PSD = struct;
    
    
    for iSignal = 1:length(PSD_Signals)
        
        signal = Chan.(PSD_Signals{iSignal});
        indWindow = Chan.tt > Window(1) & Chan.tt < Window(2);
        L = length(signal(indWindow));
        n = 2^nextpow2(L);
        
        y = fft(signal(indWindow),n);
        fs  = 1/dt;
        
        P2 = abs(y/L);
        P1 = P2(1:floor(L/2)+1);
        
        f = fs * (0:(L/2))/L;
        
        % Filter
        n_filt = nextpow2(L);
        b = ones(n_filt,1)/n_filt;
        a = 1;
        
        P1_filt = filtfilt(b,a,P1);
        
        PSD.f = f;
        PSD.w = 2*pi*f;
        PSD.T = 1./f;
        PSD.(PSD_Signals{iSignal}) = P1_filt;
        
        
    end
    
    
    % RAO Est
    
    RAO_Hv = PSD.PtfmHeave ./ PSD.Wave1Elev;
    
    
    
    figure(8000);
    subplot(311);
    loglog(PSD.w,PSD.Wave1Elev);
    xlim([.1,10]);
    hold on;
    ht = plot(.81*[1,1],ya,'r');
    hr1 = plot(hv_w(1)*[1,1],ya,'k');
    hr2 = plot(hv_w(2)*[1,1],ya,'k');
    hold off;
    
    
    subplot(312);
    loglog(PSD.w,PSD.PtfmHeave);
    xlim([.1,10]);
    hold on;
    ht = plot(.81*[1,1],ya,'r');
    hr1 = plot(hv_w(1)*[1,1],ya,'k');
    hr2 = plot(hv_w(2)*[1,1],ya,'k');
    hold off;
    
    subplot(313);
    loglog(PSD.w,RAO_Hv);
    xlim([.1,10]);
    hold on;
    ht = plot(.81*[1,1],ya,'r');
    hr1 = plot(hv_w(1)*[1,1],ya,'k');
    hr2 = plot(hv_w(2)*[1,1],ya,'k');
    hold off;
    
    
end

