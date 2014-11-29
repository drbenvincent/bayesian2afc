function model1plot(filename)
% This function plots the results (parameter recovery and posterior prediction) that was conducted by model1runme.
%
% model1plot('tempModel1run_gridApprox')
% model1plot('tempModel1run_mcmcCustom')
% model1plot('tempModel1run_mcmcJAGS')

% load the parameter estimation results calculated by model1runme.m
load(['~/Dropbox/tempModelOutputs/' filename])

switch PARAM_RECOVERY_METHOD
    case{'mcmcJAGS'}
        
        % plot MCMC chains
        % Visually inspect chains and examine the $\hat{R}$ statistic.
        MCMCdiagnoticsPlot(samples,stats,{'v'})
        temp=cd;
        try
            latex_fig(12,6,3)
            cd('figs')
            hgsave('model1_mcmcJAGS_infer_chains')
            export_fig model1_mcmcJAGS_infer_chains -pdf -m1
            cd('..')
        catch
            cd(temp)
        end
end



%% Plot the inferences in parameter space
% Plot the posterior distribution over $\sigma^2$
figure(1), clf, latex_fig(12, 5, 3)
subplot(1,2,2)
% plot posterior distribtion
switch PARAM_RECOVERY_METHOD
	case{'gridApprox'}
		area(estOpts.V,posterior_var,...
			'FaceColor', [0.7 0.7 0.7], ...
			'LineStyle','none')
		hold on, a=axis; top =a(4); z=0.03;
		% plot 95% CHI interval as horizontal line
		plot([HDI.lower HDI.upper],[top*z top*z],'k-');
		% Add summary info
		addDistributionSummaryText(vMode, [HDI.lower HDI.upper], 'TR', 12)
		
	case{'mcmcCustom','mcmcJAGS'}
		area(xi,p,...
			'FaceColor', [0.7 0.7 0.7], ...
			'LineStyle','none')
		% Add summary info
		addDistributionSummaryText(MAP, CI95, 'TR', 12)
		
end

axis tight
hline([],params.v)

% format graph
xlabel('inferred \sigma^2')
ylabel('posterior density')
set(gca, 'PlotBoxAspectRatio',[1 1 1],...
	'box', 'off',...
	'yticklabel',{},...
	'YTick',[],...
	'xlim', [0 3])
%title('b.')



%% Plot results in data space
% Plot the simulated behaviour data alongside model predictions

subplot(1,2,1)
% ===== TEST =====
for n=1:size(predk,2)
	IM(:,n) = hist( predk(:,n) ,[1:1:100] );
	% scale so the max numerical value = 100
	IM(:,n) =IM(:,n) / (max(IM(:,n))/100);
end
imXdata = params.sii;
imYdata = [0:1:100]/100;

pltXdata = params.sioriginal;
pltYdata = params.koriginal ./ params.T;

log_plot_with_background(IM,...
	imXdata , imYdata,...
	pltXdata, pltYdata)


%% Export
figure(1)
%latex_fig(12, 5, 3)

% Export in .fig and .pdf
cd('figs')

switch PARAM_RECOVERY_METHOD
	case{'gridApprox'}
		hgsave('model1')
		export_fig model1 -pdf -m1
		
	case{'mcmcCustom'}
		hgsave('model1mcmcCustom')
		export_fig model1mcmcCustom -pdf -m1
		
	case{'mcmcJAGS'}
		hgsave('model1mcmcJAGS')
		export_fig model1mcmcJAGS -pdf -m1
end

cd('..')

