function [trialwba,trialVec] = getDeltaWBA(obj,trialidx)

% For orientation grating experiments:
% |  bar tracking  | bar disappears, grating static | grating motion |
% |        5s      |                 5s             |        5s      |
% Just show 2s before grating motion : 2s after onset of motion
if isempty(obj.TrialCh2)
    getAxoParameters(obj)
end
if isempty(obj.Abf)
    getAbfData(obj)
end

startSample = obj.TrialStartSample(trialidx);% - floor(2*obj.AbfRate);
endSample = obj.TrialEndSample(trialidx);% + floor(2*obj.AbfRate);

dataL = obj.Abf(startSample:endSample,5);
dataR = obj.Abf(startSample:endSample,6);

trialwba = dataL - dataR;

timeVec = linspace(1/obj.AbfRate,length(trialwba)/obj.AbfRate,length(trialwba) );