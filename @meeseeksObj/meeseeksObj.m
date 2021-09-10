classdef meeseeksObj < AxoObj
    
    properties (Dependent, Hidden)        
        %Abf % Data extracted from .abf file on-demand (hidden to avoid fetching any time obj is examined in command window)
    end
    properties (Dependent)
        %         Link
        TrialSetNum
    end
    
    properties
        
%         
%         Fly
%         File % filename (no extension)
%         Folder % folder path
%         AbfFile % filename plus extension
%         
%         AbfRate  % sampling rate of axoscope data
%         AbfInfo % structure 'h' returned from 'abfload.m'
%         
%         Unattended = 0
%         
%         TrialSettings
%         
%         TrialStartSample
%         TrialEndSample
%         
%         TrialXGain
%         TrialYGain
%         ExpXGains
%         ExpYGains
%         
%         TrialPatNum
%         TrialSeqNum
%         TrialCh2
%         TrialCh7
%         
%         TrialXpos  % obj.Abf(:,3)
%         TrialYpos  % obj.Abf(:,4)
%         
%         SwitchPatSeqAbfChans
polAng
TrialPolAng
    end
    
    properties (Transient)
        % Abf % Data extracted from .abf file (not saved to disk with
        % object) [defunct - replaced with dependent prop]
    end
    
    methods  % Constructor - runs on object creation
        
        function obj = meeseeksObj(pathIN)
            
            % If no path is specified:
             if nargin == 0 || isempty(pathIN)
                try
                    [FileName,PathName] = uigetfile('*.abf;*.daq');
                    pathIN = fullfile(PathName,FileName);
                catch
                end
            end
            
            
            % Call superclass constructor:
            obj@AxoObj(pathIN);
                           
            obj.AbfRate = 1000;  % sampling rate of axoscope data
            obj.TrialSettings.chan = 1;
            obj.chanL = 4;
            obj.chanR = 5;
            obj.chanWingFreq = 6;
            try
                getParameterFile(obj)
            catch
                disp('no parameter file loaded')
            end
            % Some defaults for what each channel corresponds to 
            % (to modify these, assign different values in a subclass constructor)
        end
      
    end
    
    methods % Dependent variables) 
        
        %         function Link = get.Link(obj)
        %             Link = ['<a href="matlab:winopen(''' obj.Folder ''')">open folder</a>'];
        %         end
        %
        %         function Abf = get.Abf(obj)
        %             Abf =  getAbfData(obj);
        %         end
        
        function value = get.TrialSetNum(obj)
            if isempty(obj.TrialPolAng)
                obj.getTrialParameters
            end                
            trialIdx = 1:length(obj.TrialPolAng);
            angsPerSet = length(obj.pSet(1).polShiftAngleArray);
            value =  ceil(trialIdx/angsPerSet);
        end
        
    end
    
    methods % Regular functions with their own .m file               
      abfData = getAbfData(obj)

      %         obj = getAbfPath(obj,pathIN) % runs with constructor upon object creation
%         [Abf,AbfRate,AbfInfo] = getAbfData(obj); % Read abf file    
%         getAxoTrials(objarray)
%         [trystarts, tryends] = detectAxoTrials(obj,trialsettings)
%         varargout = checkTrials(obj , trialsettings, trialstarts, trialends)
        getTrialParameters(obj)
%         chanGains = detectAxoTrialGains(obj, chanIdx, panels_refresh_rate)
%         trialIdx = findAxoTrials(obj,fields)
%         [deltaArray, sumArray, timeVector, ObjIdx] = findResponseArray(objarray, fields)
%         [trialwba,timeVec] = getDeltaWBA(obj,trialidx)
%         [trialwba,timeVec] = getSumWBA(obj,trialidx)
%         varargout = plotDeltaWBA(objarray, fields, errorbar, plotcolor, tfig)
%         varargout = plotSumWBA(objarray, fields, errorbar, plotcolor, tfig)
[] = tempAssignTrials(obj)
    end
    
    
end