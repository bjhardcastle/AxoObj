function [trialwba,timeVec] = getSumWBA(obj,trialidx,preSec,postSec)

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

dataL = obj.Abf(startSample:endSample,obj.chanL);
dataR = obj.Abf(startSample:endSample,obj.chanR);

trialwba = dataL + dataR;

timeVec = linspace(1/obj.AbfRate,length(trialwba)/obj.AbfRate,length(trialwba) );