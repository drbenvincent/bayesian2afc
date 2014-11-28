function [predictions] = model2modelfit(predictions, T, pc, k, free_params)

% % ******* THIS IS IMPORTANT *******
% % Choice of samples.R and samples.postpredR is important here
% 
% % These are model predictions given knowledge of the exact signal locations
% % L and the response locations R that the simulated participant made. Given
% % this knowledge, the model predictions can be much more precise (if it's a
% % good model).
% 
% % collapse across chains
% % We are sampling from the posterior predictive distribution
% % not the supplied actual data! ie samples.R
% tempR = samples.postpredR(:,:,[1:numel(muS)],:);
% predR = reshape( tempR ,...
% 	mcmcparams.infer.nchains*mcmcparams.infer.nsamples,...
% 	numel(muS),...
% 	T);
% 
% % grab out the L and the R for the interpolated muS values only
% L = dataset.L(:,[1:numel(muS)]);
% 
% 
% % Calculate model predicted performance  - METHOD 2 -----------------------
% % This method uses the full predictive distribution, using all MCMC samples
% % of predicted responses and compares them to the actual response.
% mcmc_samples = mcmcparams.infer.nchains*mcmcparams.infer.nsamples;
% 
% % SLOW VERSION -----
% % % preallocate
% % model_predicted_correct = zeros(T,numel(muS),mcmc_samples);
% % tic
% % for m = 1:mcmc_samples
% % 	for t=1:T
% % 		for sl=1:numel(muS)
% % 			model_predicted_correct(t,sl,m) = ...
% %               dataset.L(t,sl) == postpredR(m,sl,t) ;
% % 		end
% % 	end
% % end
% % toc
% 
% % FAST VERSION -----
% model_predicted_correct = zeros(T,numel(muS),mcmc_samples);
% %tic
% for t=1:T
% 	for sl=1:numel(muS)
% 		model_predicted_correct(t,sl,:) = L(t,sl) == predR(:,sl,t) ;
% 	end
% end
% %toc
% 
% predpc = squeeze( sum(model_predicted_correct,1)) ./ T;
% 
% % Calculate the 95% CI in the model predictions for the actual data. The
% % model will give much more specific predictions because the model had
% % access to the trial-to-trial set of actual locations
% fit.CI = prctile(predpc',[5 95]);



% Calcualte errors for knowingL
error = bsxfun(@minus, pc', predictions.knowingL.predpc)' ;
MSE = mean( error(:).^2 ); % summed error over ALL MCMC samples
predictions.knowingL.RMSE = sqrt(MSE);

% Calcualte errors for notknowingL
error = bsxfun(@minus, pc', predictions.notknowingL.predpc)' ;
MSE = mean( error(:).^2 ); % summed error over ALL MCMC samples
predictions.notknowingL.RMSE = sqrt(MSE);






nsl = size(predictions.knowingL.predpc,1);

% % Calcualte errors
% error = bsxfun(@minus, pc', predpc)' ;
% fit.MSE = mean( error(:).^2 ); % summed error over ALL MCMC samples
% fit.RMSE = sqrt(fit.MSE);

%% Compute Likelihood FOR KNOWING L
% p(data|model,parameters) = L(parameters)



for s=1:nsl % loop over signal level
	f = hist( predictions.knowingL.predpc(s,:), linspace(0,1,T));
	p = f./sum(f);
	actual_correct_responses = k(s);
	data_likelihoodS(s) = p(actual_correct_responses);
end
data_likelihoodS;
probOfDataGivenParameters = prod(data_likelihoodS);
% Calculate AIC
predictions.knowingL.likelihood = probOfDataGivenParameters;
predictions.knowingL.AIC = 2*free_params - 2*log( probOfDataGivenParameters );

clear f p actual_correct_responses data_likelihoodS probOfDataGivenParameters

%% Compute for NOT KNOWING L

for s=1:nsl % loop over signal level
	f = hist( predictions.notknowingL.predpc(s,:), linspace(0,1,T));
	p = f./sum(f);
	actual_correct_responses = k(s);
	data_likelihoodS(s) = p(actual_correct_responses);
end
data_likelihoodS;
probOfDataGivenParameters = prod(data_likelihoodS);
% Calculate AIC
predictions.notknowingL.likelihood = probOfDataGivenParameters;
predictions.notknowingL.AIC = 2*free_params - 2*log( probOfDataGivenParameters );





return