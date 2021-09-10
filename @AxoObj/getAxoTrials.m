function getAxoTrials(objarray)
for oidx = 1:length(objarray)
    
   
    if isempty(objarray(oidx).AbfFile)
        disp('No Abf file exists - try running ''getAbfFile(objarray(oidx))''')
        return
    end
   
     %{ 
    % No longer necessary with abf on-demand
    % abf data are required for trial detection:
    
    if isempty(objarray(oidx).Abf)
        getAbfData(objarray(oidx));
    end
    %} 
    
    % Get settings for detection.
    if ~isempty(objarray(oidx).TrialSettings)
        ts = objarray(oidx).TrialSettings;
    else
        ts = struct;
    end
    % The following fields can be assigned in objarray(oidx).TrialSettings:
    if ~isfield(ts,'chan')
        ts.chan = 2;
    end
    if ~isfield(ts,'setlimits')
        ts.setlimits = [1 size(objarray(oidx).Abf,1)];
    end
    if ~isfield(ts,'joined')
        ts.joined = 0;
    end
    if ~isfield(ts,'minpeak')
        ts.minpeak = 0.05;
    end
    if ~isfield(ts,'firstTrialError')
        ts.firstTrialError = 0;
    end
    if ~isfield(ts,'plotflag')
        ts.plotflag = 0;
    end
    
    % Main code:
    
    
    % Find trial times in Abf signal with settings specified:
    [trystarts, tryends] = detectAxoTrials(objarray(oidx),ts);
    
    
    %
    %    Opportunity to modify detected times here..
    %
    
    
    % Check trialtimes seem reasonable:
    if ( length(trystarts)==length(tryends) ) && ( all(trystarts<tryends) )
        trialstarts = trystarts;
        trialends = tryends;
    else
        %If not, plot the problematic trials:
        checkTrials(objarray(oidx), ts, trystarts, tryends);
        title('Check for errors: no trials saved to object')
        % And don't save anything to the object:
        trialstarts = [];
        trialends = [];
        ts = [];
        return
    end
    
    % When finished, push to obj :
    
    % Trial starts / ends
    %Saved as sample number:
    objarray(oidx).TrialStartSample = trialstarts;
    objarray(oidx).TrialEndSample = trialends;
    
    % The current parameters:
    objarray(oidx).TrialSettings = ts;
end
end
