function [deltaArray, sumArray, timeVector, ObjIdx] = findResponseArray(objarray, fields)

%FINDRESPARRAY Extract the aligned, interpolated response time-series for
%all trials which match the specified parameters, across an object array
% [responseArray, timeVector, F0Array, ObjIdx] = findRespArray(objarray, ROImaskidx, fields)
%
% See documentation for findTrials. This is an extension of that function
% which accepts a [1xN] array of objects and returns all the trials, resampled
% to a common time series, timeVector, with correct duration in seconds.
% All trials are accumulated, so no information on which animal or Tiff
% they came from is retained, but the number of SlidebookObjs is counted
% and returned as numExps. If there are multiple tiffs per animal this
% could cause a problem for calculating SEM
%
% See also findTrials.

if nargin < 2 || isempty(fields)
    disp('''fields'' is empty. All trials will be returned.')
    fields = struct;
end


% Now cycle through objects in objarray, and store matching trials in
% 'trials_returned' (after interpolating):
tcount = 0;
ObjIdx = []; % Store the object index from which each trial was taken
delta_trials_returned = [];
sum_trials_returned = [];
timevec_returned = [];
for oidx = 1:length(objarray)
    
    if isempty( objarray(oidx).TrialPatNum )
        getTrialParameters(objarray(oidx))
    end
    
    assert( ~isempty( objarray(oidx).TrialStartSample ) , [ 'No trial info stored. Run ''getTrialtimes(objarray(' num2str(oidx) ')) first'] );
    
    trialidx = findAxoTrials( objarray(oidx) , fields );
    
    for tidx = trialidx'
        
        % Get trial data
        tcount = tcount + 1;
        
        deltawba = getDeltaWBA(objarray(oidx), tidx);
        if length(deltawba) > size(delta_trials_returned,2)
            delta_trials_returned(:,end+1:length(deltawba)) = nan;
        end
        delta_trials_returned( tcount , 1:length(deltawba) ) = deltawba;
        
        [sumwba,timevec] = getSumWBA(objarray(oidx), tidx);
        if length(sumwba) > size(sum_trials_returned,2)
            sum_trials_returned(:,end+1:length(sumwba)) = nan;
        end
        sum_trials_returned( tcount , 1:length(sumwba) ) = sumwba;
        
        if length(timevec) > length(timevec_returned)
            timevec_returned = timevec;
        end
        
        % Store the index of the object for the trial
        ObjIdx(tcount) = oidx;
        
    end
    
    
    
end

deltaArray = delta_trials_returned;
sumArray = sum_trials_returned;
timeVector = timevec_returned;


