function [trialWBA,timeVec,extraChanData] = getDeltaWBA(obj,trialidx,preSec,postSec,extraChanIdx)

% For orientation grating experiments:
% |  bar tracking  | bar disappears, grating static | grating motion |
% |        5s      |                 5s             |        5s      |
% Just show 2s before grating motion : 2s after onset of motion
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


startSample = obj.TrialStartSample(trialidx) - floor(preSec*obj.AbfRate);
endSample = obj.TrialEndSample(trialidx) + floor(postSec*obj.AbfRate);

dataL = obj.Abf(startSample:endSample,obj.chanL);
dataR = obj.Abf(startSample:endSample,obj.chanR);
if nargin >= 5 && ~isempty(extraChanIdx)
    extraChanData = obj.Abf(startSample:endSample,extraChanIdx);
end
trialWBA = dataL - dataR;

timeVec = linspace(1/obj.AbfRate,length(trialWBA)/obj.AbfRate,length(trialWBA) );