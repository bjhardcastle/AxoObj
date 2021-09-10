classdef AxoObj < handle_light
    
    properties (Dependent, Hidden)        
       % Abf % Data extracted from .abf file on-demand (hidden to avoid fetching any time obj is examined in command window)
    end
    properties (Dependent)
        Link
    end
    
    properties
        
        Fly
        File % filename (no extension)
        Folder % folder path
        AbfFile % filename plus extension
        
        Abf
        
        AbfRate  % sampling rate of axoscope data
        AbfInfo % structure 'h' returned from 'abfload.m'
        
        pSet % from parameter file
        
        Unattended = 0
        
        TrialSettings
        
        TrialStartSample
        TrialEndSample
        
        TrialXGain
        TrialYGain
        ExpXGains
        ExpYGains
        
        TrialPatNum
        TrialSeqNum
        TrialCh2
        TrialCh7
        
        TrialXpos  % obj.Abf(:,3)
        TrialYpos  % obj.Abf(:,4)
        
        SwitchPatSeqAbfChans

        chanL = 4;
        chanR = 5;
        chanWingFreq = 6;
       

        
    end
    
    properties (Transient)
        % Abf % Data extracted from .abf file (not saved to disk with
        % object) [defunct - replaced with dependent prop]
    end
    
    methods  % Constructor - runs on object creation
        
        function obj = AxoObj(pathIN)
            
            % If no path is specified:
            if nargin == 0 || isempty(pathIN)
                try
                    [FileName,PathName] = uigetfile('*.abf*');
                    obj = getAbfPath(obj, fullfile(PathName,FileName) );
                catch
                end
            end
            
            % If path is specified:
            if nargin >0 && ~isempty(pathIN)
                if isa(pathIN,'char')
                    obj = getAbfPath(obj,pathIN);
                else
                    error('Please input path to abf file as a string, or leave empty')
                end
            end
                        
            % Some defaults for what each channel corresponds to 
            % (to modify these, assign different values in a subclass constructor)
        end
      
    end
    
    methods % Dependent variables) 
        
        function Link = get.Link(obj)
            Link = ['<a href="matlab:winopen(''' obj.Folder ''')">open folder</a>'];
        end
        
%         function Abf = get.Abf(obj)
%             Abf =  getAbfData(obj);
%         end
        
    end
    
    methods % Regular functions with their own .m file               
       
        obj = getAbfPath(obj,pathIN) % runs with constructor upon object creation
        [Abf,AbfRate,AbfInfo] = getAbfData(obj); % Read abf file    
        getParameterFile(obj)
        getAxoTrials(objarray)
        [trystarts, tryends] = detectAxoTrials(obj,trialsettings)
        varargout = checkTrials(obj , trialsettings, trialstarts, trialends)
        getTrialParameters(obj)
        chanGains = detectAxoTrialGains(obj, chanIdx, panels_refresh_rate)
        trialIdx = findAxoTrials(obj,fields)
        [deltaArray, sumArray, timeVector, ObjIdx,wbfArray] = findResponseArray(objarray, fields,preSec,postSec)
        [trialwba,timeVec,extraChanData] = getDeltaWBA(obj,trialidx,preSec,postSec,extraChanIdx)
        [trialwba,timeVec] = getSumWBA(obj,trialidx, preSec,postSec)
        [trialwbf,timeVec] = getWBF(obj,trialidx,preSec,postSec)
        varargout = plotDeltaWBA(objarray, fields, errorbar, plotcolor, tfig, preSec,postSec)
        varargout = plotSumWBA(objarray, fields, errorbar, plotcolor, tfig,preSec,postSec)
        varargout = plotWBF(objarray, fields, errorbar, plotcolor, tfig, preSec,postSec)

    end
    
    
end