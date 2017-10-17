function model1runme(PARAM_RECOVERY_METHOD)
% This code implements Model 1 in 3 differnet ways. 
%
% model1runme('gridApprox')
% model1runme('mcmcCustom')
% model1runme('mcmcJAGS')
%
% For each method, the same basic steps are undertaken:
% Step 1: load dataset, OR generate new data
% Step 2: Conduct parameter recovery
% Step 3: Calculate the model's predictions. What is the models predictive
% distribution over the data, given the parmeter distributions inferred
% given the data in step 1.
%
% Grid Approximation, and the custom MCMC implementation both use the
% function m1jointPosterior.m for the parameter estimation, to evaluate
% the joint probability.
% They also both use m1posteriorPrediction.m in order to calculate the
% posterior distribution

setup

DATASET_MODE='load'  % {'load','generate'}
PARAM_RECOVERY_METHOD

%% STEP 1: SIMULATE DATASET. Either load or create a new dataset
switch DATASET_MODE
    case{'load'}
        load('data/commondata_model1.mat')
        
        % The fields of data, for commondata_model1.mat are:
        % - sioriginal = stimulus intensities (there are 10)
        % - koriginal = counts, 1, 2, 3, ? T (there are 10, corresponding to the responses for each stimulus intensity)
        % - T = trials = 100
        % - the other variables (sii, si, k) also correspond to counts and stimulus intensities, but now we are interpolating more values in between the actual 10
        
    case{'generate'}
        % define known variables
        data = define_experiment_params('model1');
        
        % GENERATE SIMULATED DATA: sample from P(k|T,si,variance)
        data.k = m1posteriorPrediction(data.T, data.sioriginal,...
            data.v);
end



%% STEP 2: Parameter Recovery
% Evaluate likelihood over range of variance values. Then obtain posterior
% by combining with a uniform prior.
switch PARAM_RECOVERY_METHOD
	case{'gridApprox'}
		% 1. Define estimation options
		estOpts.V = linspace(10^-2, 3, 10^4)'; % range of variance values
		
		% 2. Conduct the inference
		[posterior_var,vMode,HDI] = m1InferGridApprox(estOpts,data);
		
	case{'mcmcCustom'}
		% 1. Define estimation options
		estOpts.initial_variance	= 0.1; % initial guess
		estOpts.n_samples			= 100000;
		estOpts.proposalstd			= 0.1;
		estOpts.pdf					= @m1jointPosterior;
		
		% 2. Conduct the inference
		[samples] = mhAlgorithm(estOpts,...
			data.sioriginal, data.koriginal, data.T);
		
		% Calc summary stats
		[MAP, xi, p, CI95] = sampleStats(samples, 'positive');
	
	case{'mcmcJAGS'}

		% 1. Define estimation options
		mcmcparams = define_mcmcparams('model1');
		starting_var = [0.1 1 10 100];
		mcmcparams.infer.nchains = numel(starting_var);
		
		[samples, stats] = m1inferJAGS(data, starting_var, mcmcparams);
		
		% Calc summary stats
		[MAP, xi, p, CI95] = sampleStats(samples.v(:), 'positive');
end



%% STEP 3: PREDICTIVE DISTRIBUTION
% Generate a set of predictions for many signal intensity levels, beyond
% that which we have data for (sii). Useful for visualising the model's
% predictions.

switch PARAM_RECOVERY_METHOD
	case{'gridApprox'}
		% Drawing MANY samples from the posterior distribution of internal
		% variance * REQUIRES STATISTICS TOOLBOX *
		nsamples=10^5;
		var_samples = randsample(estOpts.V, nsamples, true, posterior_var);
		
		% predictive distribution
		predk=zeros(nsamples,numel(data.sii)); % preallocate
		for n=1:nsamples
			predk(n,:) = m1posteriorPrediction(data.T, data.sii, var_samples(n));
		end

		% Calculate 95% CI's for each signal level
		CI = prctile(predk,[5 95]) ./ data.T;
		
	case{'mcmcCustom'}
		predk=zeros(estOpts.n_samples,numel(data.sii)); % preallocate
		for n=1:numel(samples)
			predk(n,:) = m1posteriorPrediction(data.T, data.sii, samples(n));
		end
		
	case{'mcmcJAGS'}
		
		% Generation of the predictive posterior values of K was already
		% done in Step 2.
		%
		% JAGS is providing samples of predicted number of correct trials out of T.
		% Concatenate all the samples from different MCMC chains into one long list
		% of MCMC samples
		predk = reshape( samples.predk ,...
			mcmcparams.infer.nchains*mcmcparams.infer.nsamples,...
			numel([data.sioriginal data.sii]));
		
		predk = predk(:,numel(data.sioriginal)+1:end);

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