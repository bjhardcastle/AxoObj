function varargout = plotWBF(objarray, fields, errorbar, plotcolor, tfig,preSec,postSec )
%PLOTTRIALS Find all trials with certain fields, and plot their aligned, averaged time-series.
% [figHandle,axHandle] = plotTrials(objarray, ROIindex, fields, errorbar, plotcolor, figHandle)
%
% Get a processed, nicely plot time-series easily. This function works in a
% similar way to 'findTrials' - see its documentation for help on
% specifying the 'fields' input argument.
% Matching trials are found in each object in the array, the specified ROI
% is scanned for each trial and interpolated to a common time vector, for
% all objects, regardless of the original framerate of the Tiff recording.
% The mean of all the returned trials is found and plot along with the
% individual trials by default, or a shaded error bar can be drawn, which
% looks cleaner when adding multiple data lines. If Fly numbers have been
% specified for each object, the SEM will be drawn, otherwise STD will be
% drawn. The color of the line can also be specified. To re-draw on the
% same figure (as you would with 'hold on') you must feed in the figure
% handle as an input argument.
%
%   objarray                          - [1xN] array of SlidebookObj objects
%
%   ROImaskidx                        - a single numerical value to specify
%                                       which ROI to use::
%                                       ' obj.ROI(ROImaskidx).mask '
%                                       will be scanned.
%
%   fields                            - structure of parameters for
%                                       specifying a set of trials to be
%                                       plot
%
%   errorbar                          - In addition to a mean line:
%                                       0: plot indivdiual trials (default)
%                                       1: plot errorbar with SEM or STD
%
%   plotcolor                         - specify the color of the lines
%                                       drawn. Can be an RGB array ([1 0
%                                       0]) or string ('r').
%                                       By default, the ROI's color is
%                                       used, as saved in obj.ROI.color
%
%   tfig                              - handle to figure to plot in
%
% See also findTrials, findRespArray
import 'AxoObjfuncs.*'

if nargin < 7 || isempty(postSec)
   postSec = 0; 
end
if nargin < 6 || isempty(preSec)
   preSec = 0; 
end
if nargin < 4 || isempty(plotcolor)
    plotcolor = []; % No color is specified for the trace - will be chosen automatically
end
if nargin < 3 || isempty(errorbar)
    errorbar = 0; % Default is to plot individual traces
end
if nargin < 2 || isempty(fields)
    fields = [];
end


% Setup the figure for plotting traces:
if nargin >= 5 && ~isempty(tfig) && ishghandle(tfig)
    set(tfig, 'color', [1 1 1] )
    if isempty( tfig.CurrentAxes )
        taxes = axes(tfig);
    else
        taxes = tfig.CurrentAxes;
    end
else
    % If tfig doesn't exist, is invalid or has been deleted, make a new one,
    tfig = figure('color',[1 1 1]);
    taxes = axes(tfig);
end
hold(taxes, 'on');

% Add buttons for easy figure export
addExportFigToolbar(tfig)

% Get line color:
if length(plotcolor) == 3
    % color specified as [r g b]
    linecolor = plotcolor;
    brightcolor = linecolor + 0.5*(1 - linecolor);
    
elseif isstring(plotcolor) && length(plotcolor) == 1
    % color specified as 'b'
    switch(plotcolor)
        case 'k', out=[0 0 0];
        case 'w', out=[1 1 1];
        case 'r', out=[1 0 0];
        case 'g', out=[0 1 0];
        case 'b', out=[0 0 1];
        case 'y', out=[1 1 0];
        case 'm', out=[1 0 1];
        case 'c', out=[0 1 1];
    end
    linecolor = out;
    
else
    % ROI index not specified   OR   plotcolor == 'auto'
    % Use the standard Matlab plot colors for each new dataset added to
    % figure
    disp('Color not properly defined. Using axes defaults')
    linecolor = taxes.ColorOrder(taxes.ColorOrderIndex,:);
end


% Get the intensity time-series for the requested trials
[deltaArray, sumArray, timeVector, respIdx,wbfArray] = findResponseArray(objarray, fields, preSec, postSec);


if ~isempty(timeVector) % Only start plotting if some trials and their F0 values were returned
    
     
    % Get the mean trial timeseries:
    meanTrials = nanmean(wbfArray , 1);
    
    switch errorbar
        
        
        case 1 % Plot mean and errorbar
            
            % Work out whether to plot +/-SEM or +/-SEM errorbar (requires
            % information on which SlidebookObj belongs to which Fly.
            % Cannot assume strictly 1 Tiff per Fly)
            flies = [objarray.Fly];
            if isempty(flies)
                disp('No Fly numbers assigned: errorbar will be +/- STD of all trials')
                varTrials = nanstd(wbfArray , [] , 1) ;
            else % Some additional processing for SEM 
			
				% Convert repIdx for each trial from 'obj number' to 'fly number' 
				TrialFlyNum = [objarray( respIdx ).Fly];
				
				% Get number of flies across all returned trials
				included_flies = unique(TrialFlyNum);                
				populationSize = length(included_flies);			
				
				% Get individual fly mean-traces
				fly_mean_traces = nan(populationSize,size(wbfArray,2));
				for ifidx = 1:populationSize
					fly_mean_traces(ifidx,:) = nanmean( wbfArray( (TrialFlyNum == included_flies(ifidx)), : ) , 1);
				end
				
				% Work on these mean-traces to get STD (then SEM) and the mean trace again
                varTrials = nanstd(fly_mean_traces , [] , 1) ./ sqrt(populationSize);
				meanTrials = nanmean(fly_mean_traces,1);
            end
            
            lineprops.col = {linecolor,0.8};
            lineprops.edgestyle = ':';
            
            % Plot
            mseb(timeVector , meanTrials , varTrials ,lineprops, 1);
            
            
            
        case 0 % plot individual traces and their mean
            
            % For narrower traces, choose a lighter color:
            brightcolor = linecolor+(1-linecolor)*0.55;
            
            brightcolor(4) = 0.3; % alpha 
            linecolor(4) = 0.3; % alpha 
            meanwidth = 2;
            tracewidth = 0.5*meanwidth;
            
            % Plot individual traces:
            plot(taxes, timeVector, wbfArray, 'color', brightcolor, 'LineWidth', tracewidth);
            % Plot their mean:
            plot(taxes, timeVector, meanTrials, 'color', linecolor, 'LineWidth', meanwidth)
            
            
    end
    
    % Whichever was plot, set axis labels
    taxes.YLabel.String = ('Hz');
    taxes.XLabel.String = ('Time [s]');
    
    % Store axes limits
    % ylimits = taxes.YLim;
    % xlimits = taxes.XLim;
    
    taxes.FontSize = 14;
    taxes.LineWidth = 1;
    
    % Restore axes limits
    % taxes.YLim = ylimits;
    % taxes.XLim = xlimits;
    
    axis tight
    % Offset origin for fancy modern plot style
%     offsetAxes(taxes)
    taxes.YAxis.TickLength = 1.25*taxes.YAxis.TickLength;
    taxes.XAxis.TickLength = 1.25*taxes.XAxis.TickLength;
    
else % If no F0data exists then there's nothing to plot..
    
end
if nargout >= 1
    varargout{1} = tfig;
end
if nargout >= 2
    varargout{2} = taxes;
end