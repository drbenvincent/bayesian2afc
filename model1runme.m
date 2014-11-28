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

		starting_var = [0.1 1 10 100];
		mcmcparams.infer.nchains = numel(starting_var);
		
		% Define MCMC parameters
		mcmcparams = define_mcmcparams('model1');
		
		[samples, stats] = model1inferMCMC(params, starting_var, mcmcparams);
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

return




















