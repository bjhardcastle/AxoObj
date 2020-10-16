function [P] = plotmeanDeltaWBA(deltaArray_norm, visstimArray_norm, Fs, wholefield)

% Plot all indiv trials, then calc mean and plot mean with shaded error
% bars and bar position

% Define colors for mean and shaded standard deviation - blue here
color1 = [0/255 128/255 255/255];
color11 = [0/255, 0/255, 200/255];

figure(110)
hold on
set(0,'DefaultFigureWindowStyle','docked')

if wholefield == 0
    %% For indiv small field trials
    
    for n = 1:length(deltaArray_norm(:,1))
        
        frames = length(deltaArray_norm(n,:));
        x = linspace(0,frames/Fs,frames);
        y = deltaArray_norm(n,1:frames);
        
        figure(110)
        subplot(2,2,1)
        hold on
        
        plot(x,y,'Color', color1, 'Linewidth', 1)
        
        ylim([-1 1])
        xlabel('Time(s)')
        ylabel('Delta WBA')
        
        
    end
    
    M = nanmean(deltaArray_norm,1);
    bar = (visstimArray_norm(1,:)/60)+0.5;

else
    
    % For whole field stimuli
    
    P = randperm(42,15);
    
    for n = 1:length(P)
        
        frames = length(deltaArray_norm(n,:));
        x = linspace(0,frames/Fs,frames);
        y = deltaArray_norm(P(n),1:frames);
        
        rand_WF_array(n,:) = y;
        
        figure(110)
        subplot(2,2,2)
        hold on
        
        plot(x,y,'Color', color1, 'Linewidth', 1)
        
        ylim([-1 1])
        xlabel('Time(s)')
        ylabel('Delta WBA')
        
        
    end
    
    M = nanmean(rand_WF_array,1);
    bar = (visstimArray_norm(1,:)/60)+0.5;
end

%% Plot mean
figure(110)
subplot(2,2,2)
title('Whole field')
hold on
plot(x,M,'Color', color11, 'Linewidth', 1.5)
hold on
plot(x,bar,'k', 'Linewidth', 1.5)

%% Plot mean with shadedErr
figure(110)
subplot(2,2,4)
shadedErrorBarMR(x,deltaArray_norm,{@nanmean,@nanstd},'lineprops',{'color',color1})
% shadedErrorBarMR(x,rand_WF_array,{@nanmean,@nanstd},'lineprops',{'color',color1})
ylim([-1 1])
xlabel('Time(s)')
ylabel('Delta WBA')
hold on
plot(x,bar,'k', 'Linewidth', 1.5)

cd('Z:\Martha\RigidExperiments_Analysis\Figures\bandpassed data_new')
saveas(gcf,'wholefieldshadederr_bandpassed.fig')
end