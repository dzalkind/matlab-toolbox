function [C,PSD] = nasa_control_cost(outfile)
% read output file, compute psd, sample and output cost
%
%   input: outfile - (string) full output file name from FAST simulation
%


%% Parameters
% we'll define here for now, can edit and add to input if you want

% signals to compute psd on
Signals = {
    'Wave1Elev';
    'PtfmHeave';
    'PtfmPitch';
    'NcIMUTAzs';
    };

trim_time   = 60;         % amount of time removed from beginning of simulation
n_filt      = 3;            % number of taps in fir filter of fft, more -> smoother
PLOT        = 1;            % plot spectra and samples
HOLD        = 0;            % hold plot between successive function calls

% sampling parameters
n_samps     = 5;             % number of freqs to sample at
range_freq  = .5;            % frequency range to sample over (rad/s)
target_freq = .81;           % center of frequency samples rad/s

%% Find PSD of Signals

% Get OutData

[~,~,ext]   = fileparts(outfile);

if strcmp(ext,'.outb')
    [OutData,OutList] = ReadFASTbinary(outfile);
else
    [OutData,OutList] = ReadFASTtext(outfile);
end


for iSignal = 1:length(Signals)
    signalIndex = strcmp(Signals{iSignal},OutList);
    
    % check if in OutList
    if isempty(signalIndex)
        disp([Signals{iSignal},' isnt in OutList']);
        
    else
        
        %% Collect & trim time domain data
        
        time_ind = OutData(:,1) > trim_time;
        
        time    = OutData(time_ind,1);
        dat     = OutData(time_ind,signalIndex);
        
        DT      = time(2) - time(1);
        
        %% FFT
        % Params
        L       = length(time);
        Fs      = 1/DT;
        NFFT    = 2^(nextpow2(L)+2); % Next power of 2 from length of y
        
        [S,FF]  =  pwelch(dat,[],[],NFFT,Fs) ;
        F       = 0:0.01:8;     % Hz
        w       = 2 * pi * F;   % rad/s
        Pow     = interp1(FF,S,F);
        
        %% Smoothing
        % Filter FFT in both directions
        
        b           = ones(n_filt,1)/n_filt;
        PowSmooth   = filtfilt(b,1,Pow);
        
        %% Analysis
        % Max
        % Hard code window for now
        fWindow = [.1,1.2];
        
        fInd =  F > fWindow(1) & F < fWindow(2);
        ffInd = F(fInd);
        [maxPow,maxInd] = max(PowSmooth(fInd));
        
        PSD.(Signals{iSignal}).SpecMax = maxPow;
        PSD.(Signals{iSignal}).FreqMax = ffInd(maxInd);
        
        %% Sample
        % Sample frequency spectra at samp_freq
        
        
        samp_freq = linspace(-range_freq/2,range_freq/2,n_samps) + target_freq;
        
        
        P_samp  = interp1(w,PowSmooth,samp_freq);
        P_avg   = mean(P_samp)/n_samps;
        
        
        
        %% Plot
        % if you want
        if PLOT
            figure(90+iSignal);
            if HOLD, hold on; end
            h=semilogy(w,PowSmooth);
            set(gca,'YScale','log'); set(gca,'XScale','log');
            
            xlim([0,8]);
            xlabel('Frequency (rad/s)')
            ylabel(Signals{iSignal})
            
            ya = get(gca,'YLim');
            
            hv_per = [8,15]; %heave excitation period
            hv_w   = 2 * pi ./hv_per;
            
            
            
            hold on;
            ht      = plot(.81*[1,1],ya,'r');
            hr1     = plot(hv_w(1)*[1,1],ya,'k');
            hr2     = plot(hv_w(2)*[1,1],ya,'k');
            
            cInd = get(gca,'ColorOrderIndex');
            set(gca,'ColorOrderIndex',mod(cInd-2,7)+1);
            h_samp  = plot(samp_freq,P_samp,'x','LineWidth',3,'MarkerSize',12);
            
            if HOLD, hold off; end
            
            
            
            legend([hr1,ht,h_samp(1)],'Heave Range','Target Freq.','Sampled Freq.');
            
            
            
        end
        
        
        %% Save to Struct
        PSD.(Signals{iSignal}).Spec.ff           = F;
        PSD.(Signals{iSignal}).Spec.ww           = F * 2 * pi;
        PSD.(Signals{iSignal}).Spec.Power        = PowSmooth;
        
        PSD.(Signals{iSignal}).samp_freq        = samp_freq;
        PSD.(Signals{iSignal}).P_samp           = P_samp;
        PSD.(Signals{iSignal}).P_avg            = P_avg;
        
        
        
        
    end   
    
end


%% Cost
% Here, we can iterate to figure out what cost value gives the best
% results for choosing TMD params

C = PSD.NcIMUTAzs.P_avg;

% C = P_avg;
%         C = 10*log(PSD.NcIMUTAzs.P_avg);
