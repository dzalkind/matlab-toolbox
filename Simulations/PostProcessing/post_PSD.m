%% A4_8_PSD
% Inputs        PP.PSD(i).
%                        .Signal       name of signal to be computed
%                        .Duration     duration of signal used from end of
%                                      time simulation
%                        .TimeWindow       (optional) time window to compute
%
% Outputs       PP.PSD(i).Spec.ff      frequency
%                        .Spec.Power       power
%                        .Spec.Amplitude

%% Settings
DB = 1;     % or power (unused)
FREQ = 1;   % or period
SMOOTH_ONLY = 1;
HOLD =  1;
DT = 1/40;
ALT = 0;
TRIM = 60; %sec
USE_ATLAS = 1;
LOGLOG = 1;
SMOOTH = 1;

% WINDOW = [450,550];

nSignals = length(PP.PSD);     %number of bsd signals..

%% Loop over Signals

for iSignal = 1:nSignals
    signalIndex = strmatch(PP.PSD(iSignal).Signal,OutList,'exact');
    
    if isempty(signalIndex) && ~isfield(Chan,PP.PSD(iSignal).Signal) && ~isfield(Signals,PP.PSD(iSignal).Signal)
        disp([PP.PSD(iSignal).Signal,' isnt in OutList or calculated']);
        
    elseif PP.PSD(iSignal).Duration > max(Chan.tt)
        disp('Steady state data duration greater than sim. time');
        
    else    %do FFT
        %% Time-Domain Data
        if isfield(PP.PSD(iSignal),'Window')
            time_ind    = OutData.time > PP.PSD(iSignal).TimeWindow(1) & OutData.time < PP.PSD(iSignal).TimeWindow(2);
        else
            time_ind    = OutData.time > 60;
        end
        
        if isfield(Chan,PP.PSD(iSignal).Signal)
            dat = Chan.(PP.PSD(iSignal).Signal)(time_ind);
        elseif isfield(Signals,PP.PSD(iSignal).Signal)
            dat = Signals.(PP.PSD(iSignal).Signal)(time_ind);
        else
            dat = OutData.signals.values(time_ind,strcmp(OutList,PP.PSD(iSignal).Signal));
        end
        
        %         eval(['dat=Chan.',PP.PSD(iSignal).Signal,'(Chan.tt>TRIM);'])
        time        = OutData.time(time_ind);
        
        if ~exist('dat','var')
            dat = [];
            
            if isempty(dat)
                dat = nan(size(time));
                disp([PP.PSD(iSignal).Signal,' not found']);
            end
        end
        
        %% FFT
        % Params
        L       = length(time);
        Fs      = 1/DT;
        NFFT    = 2^(nextpow2(L)+2); % Next power of 2 from length of y
        
        window = ones(floor(length(dat)/5),1);
        overlap = floor(length(window)/1.25);
        
        if USE_ATLAS
            [S,FF] =  pwelch(dat,[],[],NFFT,Fs) ; % smoothen more with lower window sizes
            F = 0:0.01:8;
            Pow = interp1(FF,S,F);
        else
            NFFT = 2^nextpow2(L);
            
            y = fft(dat,NFFT);
            fs  = 1/DT;
            
            P2 = abs(y/L);
            Pow = P2(1:floor(L/2)+1);
            
            F = fs * (0:floor(L/2))/L;
        end
        
        %% Smoothing
        if SMOOTH
            n_filt = nextpow2(L)-2;
            n_filt = 3;
        else
            n_filt = 1;
        end
        
        b = ones(n_filt,1)/n_filt;
        
        PowSmooth = filtfilt(b,1,Pow);
        
        %% Plotting
        if PLOT
            figure(70+iSignal);
            if FREQ
                if ~SMOOTH_ONLY
                    if HOLD hold on; end;
                    h=semilogy(F,Pow,F,PowSmooth);
                    set(gca,'YScale','log');
                    set(gca,'XScale','log');
                    if HOLD hold off; end;
                else
                    if HOLD hold on; end;
                    h=semilogy(F,PowSmooth);
                    set(gca,'YScale','log');
                    set(gca,'XScale','log');
                    if HOLD hold on; end;
                    
                end
                xlim([0,8]);
                xlabel('Frequency [Hz]')
            elseif ALT
                
                if HOLD hold on; end;
                h=semilogx(2*pi*(F-fShift),5*log10(PowSmooth));
                set(gca,'XScale','log');
                if HOLD hold on; end;
                
            else
                if ~SMOOTH_ONLY
                    if HOLD hold on; end;
                    h=semilogy(TT,Pow,TT-TShift,PowSmooth);
                    if HOLD hold off; end;
                else
                    if HOLD hold on; end;
                    h=semilogy(TT-TShift,PowSmooth);
                    if HOLD hold off; end;
                end
                xlim([0,8]);
                xlabel('Frequency [p]')
            end
            set(h,'LineWidth',3);
            
            if DB
                set(gca,'YScale','log');
            end
            ylabel([PP.PSD(iSignal).Signal,' Amplitude Spectrum']);
        end
        
        if USE_ATLAS
            set(gca,'YScale','log'); set(gca,'XScale','log');
        end
        
        %Save to Struct
        PP.PSD(iSignal).Spec.ff           = F;
        PP.PSD(iSignal).Spec.ww           = F * 2 * pi;
        PP.PSD(iSignal).Spec.Power        = PowSmooth;
        %         PP.PSD{n}.Spec.Amplitude    = Amp;
        
        
        %% Analysis
        % Peak
        % Hard code window for now
        fWindow = [.1,1.2];
        ww  = PP.PSD(iSignal).Spec.ww;
        
        fInd =  F > fWindow(1) & F < fWindow(2);
        ffInd = F(fInd);
        [maxPow,maxInd] = max(PowSmooth(fInd));
        
        PP.PSD(iSignal).SpecMax = maxPow;
        PP.PSD(iSignal).FreqMax = ffInd(maxInd);
        
        
    end
    
end




