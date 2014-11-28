function model1plot(filename)
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
figure(1), clf
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
title('b.')




%% STEP 3: MODEL PREDICTIONS in data space
% Generate a set of predictions for many signal intensity levels, beyond
% that which we have data for (sii). Useful for visualising the model's
% predictions.


switch PARAM_RECOVERY_METHOD
	case{'gridApprox'}
		% Sample from the posterior. * REQUIRES STATISTICS TOOLBOX *
		nsamples=10^5;
		fprintf('\nDrawing %d samples from the posterior distribution of internal variance...',...
			nsamples)
		var_samples = randsample(estOpts.V, nsamples, true, posterior_var);
		fprintf('done\n')
		fprintf('Calculating model predictions in data space for sii...')
		% predictive distribution
		predk=zeros(nsamples,numel(params.sii)); % preallocate
		for n=1:nsamples
			predk(n,:) = model1posteriorPrediction(params.T, params.sii, var_samples(n));
		end
		fprintf('done\n')
		% Calculate 95% CI's for each signal level
		CI = prctile(predk,[5 95]) ./ params.T;
		%clear predk
		
	case{'mcmcCustom'}
		predk=zeros(estOpts.n_samples,numel(params.sii)); % preallocate
		for n=1:numel(samples)
			predk(n,:) = model1posteriorPrediction(params.T, params.sii, samples(n));
		end
		
	case{'mcmcJAGS'}
		
		% Generation of the predictive posterior values of K was already
		% done in Step 2.
		
		si = params.sioriginal;
		sii = params.sii;
		T = params.T;
		
		% JAGS is providing samples of predicted number of correct trials out of T.
		% Concatenate all the samples from different MCMC chains into one long list
		% of MCMC samples
		predk = reshape( samples.predk ,...
			mcmcparams.infer.nchains*mcmcparams.infer.nsamples,...
			numel([si sii]));
		
		predk = predk(:,numel(si)+1:end);
		
end



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
%set(gcf,'color','w');
% Automatic resizing to make figure appropriate for font size
latex_fig(12, 5, 3)

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

