function predictions = model2extractpredictions(samples, mcmcparams, params)


si = params.sioriginal;
sii = params.sii;
T = params.T;

%% POSTERIOR PREDICTION - for extrapolated si values
% JAGS is providing samples of predicted number of correct trials out of T.
% Concatenate all the samples from different MCMC chains into one long list
% of MCMC samples
predk = reshape( samples.predk ,...
	mcmcparams.infer.nchains*mcmcparams.infer.nsamples,...
	numel([si sii]));


% convert NUMBER of predicted correct responses into PROPORTION
predpc = predk(:,1:numel(si))./T;

predictions.data.predpc = predpc;
predictions.data.mean	= mean(predpc);
predictions.data.median  = median(predpc);
predictions.data.lower	= prctile(predpc,5);
predictions.data.upper	= prctile(predpc,95);


% Predictions for interpolated values
predpc = predk(:,numel(si)+1:end)./T;

predictions.interp.predpc = predpc;
predictions.interp.mean	= mean(predpc);
predictions.interp.median  = median(predpc);
predictions.interp.lower	= prctile(predpc,5);
predictions.interp.upper	= prctile(predpc,95);


return
