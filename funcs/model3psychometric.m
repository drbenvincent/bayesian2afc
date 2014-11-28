function model3psychometric(TASK)
% model3psychometric('calculate')
% model3psychometric('plot')

%% model3psychometric.m
%
% Future updates or big fixes will appeclear, close all; clc           % First, tidy thigs up
addpath([cd '/funcs'])
addpath([cd '/funcs/export_fig'])


switch TASK
	case{'calculate'}
		
		params.si		= logspace(-2,1,10);    % define the signal intensities
		params.varint	= 1;                    % internal noise variance
		params.pdist	= [0.5 0.5];
		
		% Define MCMC parameters
		mcmcparams		= define_mcmcparams('model3');
		params.T		= mcmcparams.generate.nsamples; % TRIALS TO SIMULATE
		%%
		% WARNING: This is a relatively complex model, and simulating more than
		% about 1000 trials per stimulus level will result in quite long
		% computation time.
		
		
		%% Generate simulated dataset
		% Generate samples of L and x. These samples are generated with a uniform
		% probability of signals occuring in each of N=2 locations.
		
		[params] = model3generate(params, mcmcparams);
		% <http://www.inferenceLab.com www.inferenceLab.com>
		% and/or
		% <https://github.com/drbenvincent/bayesian2afc>
		%%
		
		%% Define initial parameters
		% Feel free to experiment with altering the following parameters. For the
		% paper I used a relatively high number of trials per stimulus level (|T=2000|),
		% but this does start to take quite a long time to compute. So for learning
		% or testing purposes I set it lower, e.g. |T=100|.
		
		
		
		
		%% Inferences, for unbiased observer
		% Inferences are made from the dataset generated above. This observer
		% is unbiased in that it expects signals to occur in each location with
		% equal probability.
		tic
		params.pdist=[0.5 0.5];
		[samples,stats, PCunbiased, PCIm1, R, k] = model3infer(params, mcmcparams);
		toc
		
		%% Inferences, for biased observer
		% Inferences are again made from the dataset generated above. This observer
		% is biased, and assumes there is a 75% change of signals occuring in
		% location 1.
		
		params.pdist=[0.75 0.25];
		[samples,stats, PCbiased, PCIm2, R, k] = model3infer(params, mcmcparams);
		
		
		
		%% Calculate psychometric functions for model 3, but for MANY simulated trials
		% MCMC approach is not workable for more than a few thousand simulated
		% trials, so I'll calculate it using non-MCMC methods
		nSimulatedTrials = 10^6;
		
		si = logspace(-2,1,100);
		% unbiased observer
		dPrior=[0.5 0.5];
		pc_unbiased = model3nonMCMC(params.varint, si,...
			nSimulatedTrials, dPrior);
		% biased observer
		dPrior=[0.75 0.25];
		pc_biased = model3nonMCMC(params.varint, si,...
			nSimulatedTrials, dPrior);
		
		%% SAVE
		save(['~/Dropbox/tempModelOutputs/' 'tempModel3psychometric'], '-v7.3')

		
	case{'plot'}
		
		% load data
		try
			load(['~/Dropbox/tempModelOutputs/' 'tempModel3psychometric.mat'])
		catch
			
		end
		
		%%
		% Plot the MCMC-derived performances
		figure(1), clf
		
				% plot psychometric functions
		semilogx(si,pc_unbiased,'k-')
		hold on
		semilogx(si,pc_biased,'k--')
		
		
		% [h.m1ci]=my_shaded_errorbar_zone_UL...
		%     (params.si,PCIm1(:,2)',PCIm1(:,1)',[0.9 0.9 1]);
		% hold on
		% [h.m2ci]=my_shaded_errorbar_zone_UL...
		%     (params.si,PCIm2(:,2)',PCIm2(:,1)',[1 0.9 0.9]);
		
		[h.m1]=semilogx(params.si',PCunbiased,'ko','MarkerSize',8,...
			'MarkerFaceColor','k');
		hold on
		[h.m2]=semilogx(params.si',PCbiased,'ks','MarkerSize',8,...
			'MarkerFaceColor','w');
		xlabel('signal intensity, \Delta\mu')
		ylabel('proportion correct')
		
		% Formatting of the figure
		box off
		set(gca,'XScale','log',...
			'PlotBoxAspectRatio',[1.5 1 1])
		
		

		

		
		
		
		
		%% Export
		latex_fig(12, 3, 3)
		
		% Export in .fig and .pdf
		cd('figs')
		hgsave('model3psychometric')
		export_fig model3psychometric -pdf -m1
		cd('..')
		
% 		% save everything to my dropbox folder. These files can be too large to go
% 		% on GitHub.
% 		st=cd;
% 		cd('/Users/benvincent/Dropbox/RESEARCH/PAPERSinprogress/MCMCtutorial/localSavedJobs')
% 		save tempModel3run.mat -v7.3
% 		cd(st)
end

end
