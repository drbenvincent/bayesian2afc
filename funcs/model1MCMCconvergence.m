% Initial set up
clear, close all; clc   
addpath([cd '/funcs'])
addpath([cd '/funcs/export_fig'])
addpath([cd '/funcs/ColorBand'])
DATAMODE='generate'  % {'load','generate'}

% Define MCMC parameters 
mcmcparams = define_mcmcparams('model1');


%% Step 1: Either Load common dataset, or generate simulated dataset
switch DATAMODE
	case{'load'}
		load('commondata_model1.mat')
	
	case{'generate'}
		% Define experiment parameters
		params = define_experiment_params('model1');
		
		% Generate simulated number of correct trials for a rang of signal
		% levels.
		params = model1generateMCMC(params, mcmcparams);
		
end

%% Step 2: Infer the internal noise using the graphical model and the simulated data
% Now we have a dataset consisting of the number of trials the simulated
% observer correctly localised the target across a range of signal levels.
%
% First define a range of initial parameter estimates for the variance,
% each will be the starting point for an individual MCMC chain
starting_var = logspace(-5,5,11);
mcmcparams.infer.nchains = numel(starting_var); 
%%
% We want to observer chain values, so we are removing the burn in period
mcmcparams.infer.nburnin=0;
%%
% we only need to calculate a low number of samples, just to demonstrate
% initial convervence
mcmcparams.infer.nsamples=1000;
%%
% Now do inference on all the generated data. The function |model2infer.m|
% gathers the data and sends it to JAGS via _MATJAGS_.

[samples, stats] = model1inferMCMC(params, starting_var, mcmcparams);

%% JAGS seems to cut off the initial parameters
% So to demonstrate the point, we'll add them back on
chains = samples.v(:,[1:200])';
chains =[starting_var ; chains];

%% plot MCMC chains
figure(1), clf, hold all

ColorSet=ColorBand( numel(starting_var) );
set(gca, 'ColorOrder', ColorSet);

% Visually inspect chains and examine the $\hat{R}$ statistic.

plot(chains)
axis tight
%legend(num2str(starting_var'))
xlabel('mcmc sample')
ylabel('\sigma^2')
box off
set(gca,'XScale','log',...
	'YScale','log',...
	'YTick',starting_var)




%% Export
temp=cd;
try 
    latex_fig(12, 6, 4)
    cd('figs')
	hgsave('model1mcmcConvergence')
    export_fig model1mcmcConvergence -pdf -m1
    cd('..')
catch
    cd(temp)
end