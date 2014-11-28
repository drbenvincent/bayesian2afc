function model1runme(PARAM_RECOVERY_METHOD)
% model1runme('gridApprox')
% model1runme('mcmcCustom')
% model1runme('mcmcJAGS')

% Initial setting up
setup


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
		% 1. Define estimation options
		estOpts.V =linspace(10^-2, 3, 10^4)'; % range of variance values
		
		% 2. Conduct the inference
		[posterior_var,vMode,HDI] = m1GridApprox(estOpts,params);
		
	case{'mcmcCustom'}
		% 1. Define estimation options
		estOpts.initial_variance	= 0.1; % initial guess
		estOpts.n_samples			= 100000;
		estOpts.proposalstd			= 0.1;
		estOpts.pdf					= @model1jointPosterior;
		
		% 2. Conduct the inference
		[samples] = mhAlgorithm(estOpts,...
			params.sioriginal, params.koriginal, params.T);
		
		% Calc summary stats
		[MAP, xi, p, CI95] = sampleStats(samples, 'positive');
	
		
	case{'mcmcJAGS'}

		% 1. Define estimation options
		mcmcparams = define_mcmcparams('model1');
		starting_var = [0.1 1 10 100];
		mcmcparams.infer.nchains = numel(starting_var);
		
		[samples, stats] = model1inferMCMC(params, starting_var, mcmcparams);
		
		% Calc summary stats
		[MAP, xi, p, CI95] = sampleStats(samples.v(:), 'positive');
end



%% STEP 3: PREDICTIVE DISTRIBUTION
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


%% SAVE
switch PARAM_RECOVERY_METHOD
	case{'gridApprox'}
		save('output/m1MAPestimate.mat', 'vMode')
		save(['~/Dropbox/tempModelOutputs/tempModel1run_gridApprox.mat'], '-v7.3')

	case{'mcmcCustom'}
		save(['~/Dropbox/tempModelOutputs/tempModel1run_mcmcCustom.mat'], '-v7.3')
		
	case{'mcmcJAGS'}
		save(['~/Dropbox/tempModelOutputs/tempModel1run_mcmcJAGS.mat'], '-v7.3')
end


return




















