function [trialwbf,timeVec] = getWBF(obj,trialidx,preSec,postSec)

% For orientation grating experiments:
% |  bar tracking  | bar disappears, grating static | grating motion |
% |        5s      |                 5s             |        5s      |
if isempty(obj.TrialCh2)
    getAxoParameters(obj)
end
% if isempty(obj.Abf)
%     getAbfData(obj)
% end
if nargin < 4 || isempty(postSec)
    postSec = 0;
end
if nargin < 3 || isempty(preSec)
    preSec = 0;
end

startSample = obj.TrialStartSample(trialidx) - floor(preSec*obj.AbfRate);% - floor(2*obj.AbfRate);
endSample = obj.TrialEndSample(trialidx) + floor(postSec*obj.AbfRate);% + floor(2*obj.AbfRate);

trialwbf = obj.Abf(startSample:endSample,obj.chanWingFreq);

% convert voltage to frequency (wing beats per sec)
% this is a complete guess for now:
trialwbf = trialwbf*500/5;

timeVec = linspace(1/obj.AbfRate,length(trialwbf)/obj.AbfRate,length(trialwbf) );