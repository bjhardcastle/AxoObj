function [] = tempAssignTrials(obj)
obj.getAxoTrials;
w = obj.Abf(:,2);
z = w<1;
z(1:100) = 0;
dz = diff(z);
[~,locs]=findpeaks(double(dz>0));
ts = locs-1;
[~,locs]=findpeaks(double(dz<0));
te = locs-1;
% figure,plot(w), hold on, plot(te,zeros(size(te)),'ro'),plot(ts,zeros(size(ts)),'go')
obj.TrialStartSample = ts;
obj.TrialEndSample = te;