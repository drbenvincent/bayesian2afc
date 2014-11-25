%% model2runme.m
%
% Future updates or big fixes will appear at: 
% <http://www.inferenceLab.com www.inferenceLab.com>
% and/or
% <https://github.com/drbenvincent/bayesian2afc>
%%

% set things up
clear, clc, close all; drawnow
addpath([cd '/funcs'])
addpath([cd '/funcs/export_fig'])
addpath([cd '/funcs/acf']) % for autocorrelation function
addpath([cd '/funcs/ColorBand'])
plot_formatting_setup

DATAMODE = 'load'; % {'load'|'generate'}

%% Step 1: Either Load common dataset, or Generate simulated dataset
switch DATAMODE
	case{'load'}
		% Load file containing experiment parameters, and a pre-computed
		% dataset of locations (L) and responses (R).
		load('commondata_model2.mat')
		% Define MCMC parameters
		mcmcparams = define_mcmcparams('model2',params.T);
		
	case{'generate'}
		params = define_experiment_params('model2');
		% Define MCMC parameters
		mcmcparams = define_mcmcparams('model2',params.T);
		% Step 1: Generate simulated dataset
		[params] = model3generate(params, mcmcparams);
end


%% Step 2: Experimenters' inferences
timerStartOfModel2infer = tic;
[samples,stats] = model2infer(params, mcmcparams);
display('inferences done')
min_sec(toc(timerStartOfModel2infer));

 
%% POSTERIOR PREDICTION for interpolated si values
display('starting model predictions')
[predictions] = model2modelpredictions2(samples, mcmcparams, params);


%% SAVE
st=cd;
cd('~/Dropbox/tempModelOutputs')
save tempModel2run.mat -v7.3
cd(st)


%% RUN MODEL 2 FIGURE GENERATION AND EXPORTING CODE
%model2plot
% -------------------------------------------------
