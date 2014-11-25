function [predictions] = model2modelpredictions2(samples, mcmcparams, params)
% Calcualte the model predictions for a much largner number of si values
% than we have data for. 


% ******* THIS IS IMPORTANT *******
% Choice of samples.R and samples.postpredR is important here




% *** could swap for postpredR and just do all in one go




totalSlevels =numel(params.si);

% collapse across chains
% Note we are taking samples from "R" that were supplied as missing values
% in the dataset.R. ie we are not looking at samples of postpredR
tempR = samples.postpredR(:,:,:,:);
predR = reshape( tempR ,...
	mcmcparams.infer.nchains*mcmcparams.infer.nsamples,...
	totalSlevels,...
	params.T);

% grab out the L and the R for the interpolated si values only
L = params.L(:,:)';




% Calculate model predicted performance  - METHOD 2 -----------------------
% This method uses the full predictive distribution, using all MCMC samples
% of predicted responses and compares them to the actual response.
mcmc_samples = mcmcparams.infer.nchains*mcmcparams.infer.nsamples;

% preallocate
model_predicted_correct = zeros(params.T, totalSlevels, mcmc_samples);
tic
for t=1:params.T
	for sl=1:totalSlevels
		model_predicted_correct(t,sl,:) = L(t,sl) == predR(:,sl,t) ;
	end
end
toc


% so the signal levels consist of this vector [si si sii]
% The precited correct for the first si is where we have knowledge of L
% and R on each trial... so very specific predictions
% The second is for model fitting later, for the actual si values used in
% the (simulated) experiment.
% The third chunch sii is a set of interpolated values that we want to
% know the model predictions for.



predk = squeeze( sum(model_predicted_correct(:,[1:numel(params.sioriginal)],:),1));
predpc = squeeze( sum(model_predicted_correct(:,[1:numel(params.sioriginal)],:),1)) ./ params.T;
predictions.knowingL.predk		= predk; 
predictions.knowingL.predpc		= predpc; 
predictions.knowingL.mean		= mean(predpc');
predictions.knowingL.lower		= prctile(predpc',5);
predictions.knowingL.upper		= prctile(predpc',95);
clear predpc

predk = squeeze( sum(model_predicted_correct(:,[numel(params.sioriginal)+1:numel(params.sioriginal)*2],:),1));
predpc = squeeze( sum(model_predicted_correct(:,[numel(params.sioriginal)+1:numel(params.sioriginal)*2],:),1)) ./ params.T;
predictions.notknowingL.predk	= predk; 
predictions.notknowingL.predpc	= predpc; 
predictions.notknowingL.mean	= mean(predpc');
predictions.notknowingL.lower	= prctile(predpc',5);
predictions.notknowingL.upper	= prctile(predpc',95);
clear predpc

predk = squeeze( sum(model_predicted_correct(:,[numel(params.sioriginal)*2+1:end],:),1));
predpc = squeeze( sum(model_predicted_correct(:,[numel(params.sioriginal)*2+1:end],:),1)) ./ params.T;
predictions.interp.predk		= predk;
predictions.interp.predpc		= predpc; 
predictions.interp.mean			= mean(predpc');
predictions.interp.lower		= prctile(predpc',5);
predictions.interp.upper		= prctile(predpc',95);
clear predpc

return