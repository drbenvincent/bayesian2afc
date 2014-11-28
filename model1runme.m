function model1runme(PARAM_RECOVERY_METHOD)
% model1runme('gridApprox')
% model1runme('mcmcCustom')
% model1runme('mcmcJAGS')

% Initial setting up
close all; clc    
addpath([cd '/funcs'])
addpath([cd '/funcs/export_fig'])
addpath([cd '/funcs/ColorBand'])
plot_formatting_setup

figure(1),clf

DATASET_MODE='load'  % {'load','generate'}
PARAM_RECOVERY_METHOD
%PARAM_RECOVERY_METHOD = 'mcmcCustom' %{'gridApprox', 'mcmcJAGS', 'mcmcCustom'}

%% STEP 1: SIMULATE DATASET. Either load or create a new dataset
switch DATASET_MODE
    case{'load'}
        load('data/commondata_model1.mat')
        
    case{'generate'}
        % define known variables
        params = define_experiment_params('model1');
        
        % GENERATE SIMULATED DATA
		% Sample from the distribution P(k|T,si,variance)
        params.k = model1posteriorPrediction(params.T, params.sioriginal,...
            params.v);
end

%% STEP 2: Parameter Recovery via GRID APPROXIMATION
% Evaluate likelihood over range of variance values. Then obtain posterior
% by combining with a uniform prior.
switch PARAM_RECOVERY_METHOD
	case{'gridApprox'}
		V=linspace(10^-2, 3, 10^4)'; % range of variance values
		likelihood=zeros(size(V)); % preallocate
		fprintf('Running parameter recovery via grid approximation...')
		for n=1:numel(V) % Do the grid approximation
			posterior_var(n) = model1jointPosterior(V(n), params.sioriginal, params.koriginal, params.T);
		end
		fprintf(' done\n')
		% normalise
		posterior_var = posterior_var ./ sum(posterior_var);
		
	case{'mcmcCustom'}
		initial_variance	= 0.1; % initial guess
		n_samples			= 100000;
		proposalstd			= 0.1;
		pdf					= @model1jointPosterior;
		
		[samples] = mhAlgorithm(initial_variance,n_samples,proposalstd,...
			pdf,...
			params.sioriginal, params.koriginal, params.T);
		
	case{'mcmcJAGS'}
		
		
		load('commondata_model1.mat')
		
		
		starting_var = [0.1 1 10 100];
		mcmcparams.infer.nchains = numel(starting_var);
		
		% Define MCMC parameters
		mcmcparams = define_mcmcparams('model1');
		
		[samples, stats] = model1inferMCMC(params, starting_var, mcmcparams);
		
% 		% plot MCMC chains
% 		% Visually inspect chains and examine the $\hat{R}$ statistic.
% 		MCMCdiagnoticsPlot(samples,stats,{'v'})
% 		temp=cd;
% 		try
% 			latex_fig(12,6,3)
% 			cd('figs')
% 			hgsave('model1_mcmcJAGS_infer_chains')
% 			export_fig model1_mcmcJAGS_infer_chains -pdf -m1
% 			cd('..')
% 		catch
% 			cd(temp)
% 		end
end

% Calculate summary stats
switch PARAM_RECOVERY_METHOD
	case{'gridApprox'}
		% Calculate posterior mode, the MAP value
		[~,index]=max(posterior_var);
		vMode = V(index);
		% Calculate 95% HDI
		[HDI] = HDIofGrid(V,posterior_var, 0.95);
		
		fprintf('Posterior over internal variance: mode=%2.3f (%2.3f - %2.3f)\n',...
			vMode, HDI.lower, HDI.upper)
		
		% save the MAP estimate in a file so that model2MCMCse.m can use it
		cd('output')
		save('m1MAPestimate.mat', 'vMode')
		cd('..')
		
	case{'mcmcCustom'}
		[MAP, xi, p, CI95] = mode_of_samples_1D(samples, 'positive');
		Y = prctile(samples,[5 95]); % Calcaulte 95% CI
		fprintf('paramater estimation of sigma^2 (VARIANCE): mode=%2.3f (%2.3f - %2.3f)\n',...
			MAP, Y(1), Y(2))
		
	case{'mcmcJAGS'}
		[MAP, xi, p, CI95] = mode_of_samples_1D(samples.v(:), 'positive');
		Y = prctile(samples.v(:),[5 95]); % Calcaulte 95% CI
		fprintf('paramater estimation of sigma^2 (VARIANCE): mode=%2.3f (%2.3f - %2.3f)\n',...
			MAP, Y(1), Y(2))

end





%% SAVE
st=cd;
cd('~/Dropbox/tempModelOutputs')
switch PARAM_RECOVERY_METHOD
	case{'gridApprox'}
		save tempModel1run_gridApprox.mat -v7.3
		
	case{'mcmcCustom'}
		save tempModel1run_mcmcCustom.mat -v7.3
		
	case{'mcmcJAGS'}
		save tempModel1run_mcmcJAGS.mat -v7.3
end
cd(st)



% %% Plot the inferences in parameter space
% % Plot the posterior distribution over $\sigma^2$
% figure(1), clf
% subplot(1,2,2)
% % plot posterior distribtion
% switch PARAM_RECOVERY_METHOD
% 	case{'gridApprox'}
% 		area(V,posterior_var,...
% 			'FaceColor', [0.7 0.7 0.7], ...
% 			'LineStyle','none')
% 		hold on, a=axis; top =a(4); z=0.03;
% 		% plot 95% CHI interval as horizontal line
% 		plot([HDI.lower HDI.upper],[top*z top*z],'k-');
% 		% Add summary info
% 		addDistributionSummaryText(vMode, [HDI.lower HDI.upper], 'TR', 12)
% 
% 	case{'mcmcCustom','mcmcJAGS'}
% 		area(xi,p,...
% 			'FaceColor', [0.7 0.7 0.7], ...
% 			'LineStyle','none')
% 		% Add summary info
% 		addDistributionSummaryText(MAP, CI95, 'TR', 12)
% 		
% end
% 
% axis tight
% hline([],params.v)
% 
% % format graph
% xlabel('inferred \sigma^2')
% ylabel('posterior density')
% set(gca, 'PlotBoxAspectRatio',[1 1 1],...
%     'box', 'off',...
%     'yticklabel',{},...
% 	'YTick',[],...
%     'xlim', [0 3])
% title('b.')











% %% STEP 3: MODEL PREDICTIONS in data space
% % Generate a set of predictions for many signal intensity levels, beyond
% % that which we have data for (sii). Useful for visualising the model's
% % predictions.
% 
% 
% switch PARAM_RECOVERY_METHOD
% 	case{'gridApprox'}
% 		% Sample from the posterior. * REQUIRES STATISTICS TOOLBOX *
% 		nsamples=10^5;
% 		fprintf('\nDrawing %d samples from the posterior distribution of internal variance...',...
% 			nsamples)
% 		var_samples = randsample(V, nsamples, true, posterior_var);
% 		fprintf('done\n')
% 		fprintf('Calculating model predictions in data space for sii...')
% 		% predictive distribution
% 		predk=zeros(nsamples,numel(params.sii)); % preallocate
% 		for n=1:nsamples
% 			predk(n,:) = model1posteriorPrediction(params.T, params.sii, var_samples(n));
% 		end
% 		fprintf('done\n')
% 		% Calculate 95% CI's for each signal level
% 		CI = prctile(predk,[5 95]) ./ params.T;
% 		%clear predk
% 		
% 	case{'mcmcCustom'}
% 		predk=zeros(n_samples,numel(params.sii)); % preallocate
% 		for n=1:numel(samples)
% 			predk(n,:) = model1posteriorPrediction(params.T, params.sii, samples(n));
% 		end
% 		
% 	case{'mcmcJAGS'}
% 		
% 		% Generation of the predictive posterior values of K was already
% 		% done in Step 2.
% 		
% 		si = params.sioriginal;
% 		sii = params.sii;
% 		T = params.T;
% 		
% 		% JAGS is providing samples of predicted number of correct trials out of T.
% 		% Concatenate all the samples from different MCMC chains into one long list
% 		% of MCMC samples
% 		predk = reshape( samples.predk ,...
% 			mcmcparams.infer.nchains*mcmcparams.infer.nsamples,...
% 			numel([si sii]));
% 		
% 		predk = predk(:,numel(si)+1:end);
% 
% end


% 
% %% Plot results in data space
% % Plot the simulated behaviour data alongside model predictions
% 
% subplot(1,2,1) 
% % ===== TEST =====
% for n=1:size(predk,2)
% 	IM(:,n) = hist( predk(:,n) ,[1:1:100] );
% 	% scale so the max numerical value = 100
% 	IM(:,n) =IM(:,n) / (max(IM(:,n))/100);
% end
% imXdata = params.sii;
% imYdata = [0:1:100]/100;
% 
% pltXdata = params.sioriginal;
% pltYdata = params.koriginal ./ params.T;
% 
% log_plot_with_background(IM,...
% 	imXdata , imYdata,...
% 	pltXdata, pltYdata)
% 
% 
% %% Export
% figure(1)
% %set(gcf,'color','w');
% % Automatic resizing to make figure appropriate for font size
% latex_fig(12, 5, 3)
% 
% % Export in .fig and .pdf
% cd('figs')
% 
% switch PARAM_RECOVERY_METHOD
% 	case{'gridApprox'}
% 		hgsave('model1')
% 		export_fig model1 -pdf -m1
% 		
% 	case{'mcmcCustom'}
% 		hgsave('model1mcmcCustom')
% 		export_fig model1mcmcCustom -pdf -m1
% 		
% 	case{'mcmcJAGS'}
% 		hgsave('model1mcmcJAGS')
% 		export_fig model1mcmcJAGS -pdf -m1
% end
% 
% cd('..')

% % save everything to my dropbox folder. These files can be too large to go
% % on GitHub.
% st=cd;
% cd('/Users/benvincent/Dropbox/RESEARCH/PAPERSinprogress/MCMCtutorial/localSavedJobs')
% save tempModel1run.mat -v7.3
% cd(st)

return























% function [predictions] = model1MCMCmodelfit(predictions, params)
% 
% 
% %% Compute the likelihood 
% % % p(data|model,parameters) = L(parameters)
% % predk = reshape( samples.predk ,...
% % 	mcmcparams.infer.nchains*mcmcparams.infer.nsamples,...
% % 	numel(sii));
% % 
% % % Here, we only want the values corresponding to the actual data seen
% % predk=predk(:,[1:numel(si)]);
% 
% 
% predpc = predictions.data.predpc;
% 
% 
% for s=1:numel(params.sioriginal) % loop over signal level
% 	% we have a distribution of predicted number of correct responses. One 
% 	% value for each MCMC sample, which reflects uncertainty in the
% 	% parameters. We can visualise this distribution with...
% 	% hist( predk(:,s), [1:T])
% 	% calculate a probability distribution for predicted number of correct
% 	% responses
% 	f = hist( predpc(:,s),linspace(0,1,params.T));
% 	p = f./sum(f); % normalise into a probability distribution
% 	
% 	actual_correct_responses = params.k(s);
% 	% look up the probability of getting that number correct, according to
% 	% the model posterior prediction. This is the likelihood of the actual
% 	% data, given the model predictions
% 	data_likelihoodS(s) = p(actual_correct_responses);
% end
% % remove zeros
% data_likelihoodS=data_likelihoodS(data_likelihoodS~=0);
% 
% probOfDataGivenParameters = prod(data_likelihoodS);
% % Calculate AIC
% num_of_parameters = 1;
% predictions.data.AIC = 2*num_of_parameters - 2*log( probOfDataGivenParameters );
% 
% % %% EXAMINE ERROR BETWEEN DATA AND MODEL PREDICTION
% % % I also calcualted the error between the actual number correct k) and
% % % model predicted number correct (predk) in JAGS. We will similarly reshape
% % % this matrix to collapse across MCMC chains
% % residual = reshape( samples.residual ,...
% % 	mcmcparams.infer.nchains*mcmcparams.infer.nsamples,...
% % 	numel(dataset.si));
% % 
% % % residual is in terms of NUMBER of correct trials. Convert it to a
% % % proportion
% % residual = residual./T;
% % % COMPUTE ROOT MEAN SQUARED ERROR
% % MSE = mean( residual(:).^2 ); % over ALL MCMC samples
% % predictions.data.RMSE = sqrt(MSE);
% 
% % %% compute sum of r2 values 
% % % see p.140-141 of Lunn, D. J., Jackson, C., Best, N., Thomas, A., & 
% % % Spiegelhalter, D. (2013). The BUGS Book: A practical introduction to 
% % % Bayesian analysis. CRC Press.
% % 
% % r = mean(residual) ./ sqrt(var(residual));
% % % remove NaN's that could occur for perfect model fit
% % r = r(~isnan(r));
% % r2=sum(r.^2)
% % fit.r2 = r2;
% 
% % %% plot
% % figure(10), clf, boxplot(residual,[1:numel(si)]) %semilogx(si,residual')
% % xlabel('\mu_S condition'), ylabel('proportion correct, residual')
% % hline(0)
% % set(gca,'PlotBoxAspectRatio',[1.5 1 1])
% % title(sprintf('RMSE=%3.8f',fit.MSE))
% % drawnow
% % export_fig model1errors -pdf -m1
% 
% return





% function predictions = model1MCMCextractpredictions(samples, mcmcparams, params)
% 
% 
% si = params.sioriginal;
% sii = params.sii;
% T = params.T;
% 
% %% POSTERIOR PREDICTION - for extrapolated si values
% % JAGS is providing samples of predicted number of correct trials out of T.
% % Concatenate all the samples from different MCMC chains into one long list
% % of MCMC samples
% predk = reshape( samples.predk ,...
% 	mcmcparams.infer.nchains*mcmcparams.infer.nsamples,...
% 	numel([si sii]));
% 
% 
% % convert NUMBER of predicted correct responses into PROPORTION
% predpc = predk(:,1:numel(si))./T;
% 
% predictions.data.predpc = predpc;
% predictions.data.mean	= mean(predpc);
% predictions.data.median  = median(predpc);
% predictions.data.lower	= prctile(predpc,5);
% predictions.data.upper	= prctile(predpc,95);
% 
% 
% % Predictions for interpolated values
% predpc = predk(:,numel(si)+1:end)./T;
% 
% predictions.interp.predpc = predpc;
% predictions.interp.mean	= mean(predpc);
% predictions.interp.median  = median(predpc);
% predictions.interp.lower	= prctile(predpc,5);
% predictions.interp.upper	= prctile(predpc,95);
% 
% 
% return


