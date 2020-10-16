function getTrialParameters(obj)
%GETPARAMETERS Extract additional trial parameters from saved DAQ data
% getParameters(obj)
%
% For each saved .tiff file, a single .mat file is usually saved by Matlab
% with time-series data from the DAQ that contains control signals to the
% LED panels, frame-time markers, user-defined trial markers, pattern-
% number and sequence-number markers, plus signals from auxillary
% equipment, such as temperature probes or wingbeat analysers.
%
% Functions 'getFrametimes' and 'getTrialtimes' extract the minimum data
% required for a basic analysis.
% This function extracts any additional data.
%
% Subfunctions do the basic detection of peaks etc. on signals. These
% should generally be left alone - just modify the input arguments to
% tweak. This parent function assigns parameters to the object and is the
% one that should be customized if needed.
%
% Currently, the function saves to the object:
%
% Different values per trial:   all [1 x numTrials] arrays:
%       obj.TrialPatNum         Voltage level on DAQ(:,2) multiplied by 5
%       obj.TrialSeqNum         Voltage level on DAQ(:,3) multiplied by 5
%       obj.TrialXGain          Panels X gain from DAQ(:,5)
%       obj.TrialYGain          Panels Y gain from DAQ(:,4)
%       obj.TrialCh6            Voltage level on DAQ(:,6) if it exists
%       obj.TrialCh7            Voltage level on DAQ(:,7) if it exists
%
% Note:
% The default behaviour is panels X data on ch5 | Y data on ch4
% This can be reversed by assigning the following parameter value:
%          obj.SwitchXYDaqChans = 1
% 
% Similarly, default is Pattern Number on ch2 | Sequence Numbero n ch3
% This can be reversed by assigning the following parameter value:
%          obj.SwitchPatSeqDaqChans = 1
%
% Same values for entire object:
%       obj.ExpXGains           Array of X gains used in experiment
%       obj.ExpYGains           Array of Y gains used in experiment
%       obj.ExpXOnTime          Median stimulus onset/offset, in seconds
%       obj.ExpXOffTime         (relative to trial onset: used to indicate
%       obj.ExpYOnTime          stimulus region in 'plotTrials')
%       obj.ExpYOffTime
%
% To be added, if required:
%                               Stimulus position (static)
%                               Timing of changes in static stim position
%
% See also getTrialtimes, getDaqData, getFrametimes.
import 'AxoObjfuncs.*'

%{
if isempty(obj.Abf)
    getAbfData(obj)
end
%}
if isempty(obj.TrialStartSample)
    getAxoTrials(obj);
end

wstim = obj.Abf;
% For each trial find some parameters from the Abf file:
% for each trial,
% for each channel (except Abf(:,1))
% get voltage level or slope
ch6 = [];
ch7 = [];
for tidx = 1:length(obj.TrialStartSample)
    
    % Get ch2 mean voltage within trials 
    ch2(tidx) = mean( wstim( obj.TrialStartSample(tidx) : obj.TrialEndSample(tidx) ,2) );
    
    % Get ch3 mean voltage within trials 
    ch3(tidx) = mean(wstim( obj.TrialStartSample(tidx) : obj.TrialEndSample(tidx) ,3) );
    
     % Get ch7 mean voltage within trials 
    ch7(tidx) = mean(wstim( obj.TrialStartSample(tidx) : obj.TrialEndSample(tidx) ,7) );
   
%     
%     % If they exist, get mean voltages within trials on channels 6 and 7
%     if size(wstim,2) >= 6
%         % voltage amplitude wstim(:,6)
%         ch6(tidx) = mean(wstim( obj.TrialStartSample(tidx) : obj.TrialEndSample(tidx) ,6) );
%     end
%     
%     if size(wstim,2) >= 7
%         % voltage amplitude wstim(:,7)
%         ch7(tidx) = mean(wstim( obj.TrialStartSample(tidx): obj.TrialEndSample(tidx) ,7) );
%     end
%     
end

% Get Panels x- and y-gain values (not assigned at this point):
panels_refresh_rate = 50; % Approximate value is sufficient - used as a threshold
ch4gain = detectAxoTrialGains(obj, 4, panels_refresh_rate);
% ch5gain = detectAxoTrialGains(obj, 5, panels_refresh_rate);

% % Push to object:

% X and Y Gains
% Default behaviour is x on ch5, y on ch4
% These can be reversed by adding a property to the object and setting it
% to 1:
if isprop(obj,'SwitchXYAbfChans') && ~isempty(obj.SwitchXYAbfChans) && obj.SwitchXYAbfChans == 1
    obj.TrialXGain = ch4gain;
%     obj.TrialYGain = ch5gain;
obj.ExpXGains = unique(obj.TrialXGain);

else
%     obj.TrialXGain = ch5gain;
    obj.TrialYGain = ch4gain;
    
    obj.ExpYGains = unique(obj.TrialYGain);

end

% Ch2 and Ch3 data
% Default behaviour is patternNum on ch2, sequenceNum on ch3 
% These can also be reversed by adding a property to the object and setting it
% to 1:
 % wstim(:,2) voltage x 5
% wstim(:,7) voltage x 5
if isprop(obj,'SwitchPatSeqAbfChans') && ~isempty( obj.SwitchPatSeqAbfChans ) && obj.SwitchPatSeqAbfChans == 1
    obj.TrialPatNum = round(ch7);
    obj.TrialSeqNum =  (ch2*5);
else
    obj.TrialPatNum = round(ch2*5);
    obj.TrialSeqNum =  (ch7);
end

% Ch6 and Ch7 data
obj.TrialCh2 = (ch2);
obj.TrialCh7 = (ch7);


% Display results
disp(['ExpXGains found: [' regexprep(num2str(obj.ExpXGains),'\s{1,}',' ') ']']);
disp(['ExpYGains found: [' regexprep(num2str(obj.ExpYGains),'\s{1,}',' ') ']']);


% Now get stimulus onset/offsets from ch4 and ch5 ( relies on obj.TrialXGain
% and obj.TrialYgain that we just found, so this must be run after previous
% info has already been found)

disp('Detecting stimulus on/off times..')

% 
% [obj.ExpXOnTime, obj.ExpXOffTime, obj.TrialXOnFrame, obj.TrialXOffFrame] = ...
%     detectPanelsMovement(obj,'x');
% [obj.ExpYOnTime, obj.ExpYOffTime, obj.TrialYOnFrame, obj.TrialYOffFrame] = ...
%     detectPanelsMovement(obj,'y');


disp('Done.')
end