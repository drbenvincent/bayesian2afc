function [predictions] = model4modelpredictions(samples, mcmcparams, dataset, T, muS, muSi, muSivals, ni)
% Calcualte the model predictions for a much largner number of muS values
% than we have data for. 


% ******* THIS IS IMPORTANT *******
% Choice of samples.R and samples.postpredR is important here

% collapse across chains
% Note we are taking samples from "R" that were supplied as missing values
% in the dataset.R. ie we are not looking at samples of postpredR
tempR = samples.R(:,:,[numel(muSi)-ni+1:numel(muSi)],:);
predR = reshape( tempR ,...
	mcmcparams.infer.nchains*mcmcparams.infer.nsamples,...
	ni,...
	T);

% grab out the L and the R for the interpolated muS values only
L = dataset.L(:,[end-ni+1:end]);




% Calculate model predicted performance  - METHOD 2 -----------------------
% This method uses the full predictive distribution, using all MCMC samples
% of predicted responses and compares them to the actual response.
mcmc_samples = mcmcparams.infer.nchains*mcmcparams.infer.nsamples;

% SLOW VERSION -----
% % preallocate
% model_predicted_correct = zeros(T,numel(muS),mcmc_samples);
% tic
% for m = 1:mcmc_samples
% 	for t=1:T
% 		for sl=1:numel(muS)
% 			model_predicted_correct(t,sl,m) = dataset.L(t,sl) == postpredR(m,sl,t) ;
% 		end
% 	end
% end
% toc

% FAST VERSION -----
model_predicted_correct = zeros(T,numel(muS),mcmc_samples);
tic
for t=1:T
	for sl=1:numel(muSivals)
		model_predicted_correct(t,sl,:) = L(t,sl) == predR(:,sl,t) ;
	end
end
toc

predpc = squeeze( sum(model_predicted_correct,1)) ./ T;
predictions.mean	= mean(predpc');
predictions.lower	= prctile(predpc',5);
predictions.upper	= prctile(predpc',95);

return