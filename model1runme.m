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




















