function model1MCMCse(TASK)
% model1MCMCse('calculate')
% model1MCMCse('plot')

close all; clc    % First, tidy thigs up
addpath([cd '/funcs'])
addpath([cd '/funcs/export_fig'])
plot_formatting_setup

rows=2;
cols=1;


switch TASK
	case{'calculate'}
		N_SIMULATIONS = 30; % 30 in paper
		
		% nsamples	=[  10^2	10^3	10^4	10^5	10^6];
		% n			=[  20		20		20		20		20];
		nsamples	=logspace(2,6,5); %logspace(2,6,5) in paper
		n			=N_SIMULATIONS.*ones(size(nsamples));
		
		%% load the MAP estimate made by Model 1, which we will use in a plot
		cd('output')
		load('m1MAPestimate.mat') % variable stored as 'vMode'
		cd('..')
		
		%%
		counter = 1;
		for k=1:numel(nsamples)
			for rep=1:n(k)
				fprintf('job %d of %d. %d samples \n', counter, sum(n) , nsamples(k))
				Emode(counter)= internal_function_paramrecovery( nsamples(k) );
				Ensamples(counter) = nsamples(k) ;
				
				figure(3), clf
				subplot(rows,cols,1)
				semilogx(Ensamples,Emode,'k+')
				xlabel('total MCMC samples')
				ylabel('MAP value of \sigma^2')
				drawnow
				
				counter = counter+1;
			end
			% Calculate the standard error of the estimate
			temp_estimates = Emode( Ensamples==nsamples(k) );
			se(k) = std(temp_estimates) / sqrt( n(k) );
		end
		
		
		%% SAVE
		save(['~/Dropbox/tempModelOutputs/' 'tempModel_MCMCse'], '-v7.3')

	case{'plot'}
		% load data
		try
			load(['~/Dropbox/tempModelOutputs/' 'tempModel_MCMCse.mat'])
		catch
			
		end
		
		figure(3), clf
		subplot(rows,cols,1)
		semilogx(Ensamples,Emode,'k+')
		xlabel('total MCMC samples')
		ylabel('MAP value of \sigma^2')
		drawnow
				

		axis tight
		figure(3)
		subplot(rows,cols,1)
		set(gca, 'PlotBoxAspectRatio',[2 1 1],...
			'box', 'off',...
			'xlim', [min(nsamples)-10 max(nsamples)+10],...
			'XTick',nsamples,...
			'YTick',[0.6:0.1:1.2])
		
		% plot line at the estimated mode by Model 1
		hline(vMode)
		
		subplot(rows,cols,2)
		%bar(se)
		semilogx(nsamples,se,'ko-',...
			'MarkerFaceColor','w')
		xlabel('total MCMC samples')
		ylabel('standard error')
		axis tight
		a=axis;
		set(gca, 'PlotBoxAspectRatio',[2 1 1],...
			'box', 'off',...
			'xlim', [min(nsamples)-10 max(nsamples)+10],...
			'ylim', [0 a(4)*1.1],...
			'XTick',nsamples)
		
		
		%% Export
		latex_fig(12, 3,3.5)
		
		cd('figs')
		hgsave('model1MCMCse')
		export_fig model1MCMCse -pdf -m1
		cd('..')
		
end

end








function [mcmc_estimated_mode]=internal_function_paramrecovery(nsamples)

%% define MCMC params
% Define MCMC parameters
mcmcparams = define_mcmcparams('model1');
% overwrite default params
mcmcparams.infer.nsamples = round(nsamples / mcmcparams.infer.nchains);


load('commondata_model1.mat')


% First define a range of initial parameter estimates for the variance,
% each will be the starting point for an individual MCMC chain
starting_var = [0.1 1 10 100];
mcmcparams.infer.nchains = numel(starting_var);

%%
% Now do inference on all the generated data. The function |model2infer.m|
% gathers the data and sends it to JAGS via _MATJAGS_.

[samples, stats] = model1inferMCMC(params, starting_var, mcmcparams);

%%
% Calculate mode (the MAP estimate) by kernel density estimation
mcmc_estimated_mode = mode_of_samples_1D(samples.v(:), 'positive');

end
