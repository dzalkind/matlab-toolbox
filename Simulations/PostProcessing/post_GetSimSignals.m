%% A4_GetSimSignals

if exist('sigsOut','var') && ~isempty(sigsOut)
    %% Get Element Names
    Signals = struct();
    Names = sigsOut.getElementNames;
    
    
    for iSig = 1:length(Names)
        if ~isempty(Names{iSig})
            DS = sigsOut.getElement(Names{iSig});
            if strcmp(class(DS),'Simulink.SimulationData.Signal')
                Signals.(Names{iSig}) = DS.Values.Data;
                
                if ndims(Signals.(Names{iSig})) > 2
                    Signals.(Names{iSig}) = squeeze(Signals.(Names{iSig}));
                end
            end
        end
    end
    
    Signals.Time = DS.Values.Time;
else
    disp('no sigsOut')
end
