%% model2runme.m



DATAMODE = 'load'; % {'load'|'generate'}

%% Step 1: Either Load common dataset, or Generate simulated dataset
switch DATAMODE
	case{'load'}
		% Load file containing experiment parameters, and a pre-computed
		% dataset of locations (L) and responses (R).
		load('data/commondata_model2.mat')
		% Define MCMC parameters
		mcmcparams = define_mcmcparams('model2',data.T);
		
	case{'generate'}
		data = define_experiment_params('model2');
		% Define MCMC parameters
		mcmcparams = define_mcmcparams('model2',data.T);
		% Step 1: Generate simulated dataset
		[data] = model2generate(data, mcmcparams);
end


%% Step 2: Experimenters' inferences
timerStartOfModel2infer = tic;
[samples,stats] = model2infer(data, mcmcparams);
display('inferences done')
min_sec(toc(timerStartOfModel2infer));

 
%% POSTERIOR PREDICTION for interpolated si values
display('starting model predictions')
[predictions] = model2modelpredictions2(samples, mcmcparams, data);


%% SAVE
save(['~/Dropbox/tempModelOutputs/tempModel2run.mat'], '-v7.3')


%% RUN MODEL 2 FIGURE GENERATION AND EXPORTING CODE
%model2plot
% -------------------------------------------------
