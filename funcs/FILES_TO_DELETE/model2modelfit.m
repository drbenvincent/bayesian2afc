function [predictions] = model2modelfit(predictions, params)


%% Compute the likelihood 
% % p(data|model,parameters) = L(parameters)
% predk = reshape( samples.predk ,...
% 	mcmcparams.infer.nchains*mcmcparams.infer.nsamples,...
% 	numel(sii));
% 
% % Here, we only want the values corresponding to the actual data seen
% predk=predk(:,[1:numel(si)]);


predpc = predictions.data.predpc;


for s=1:numel(params.sioriginal) % loop over signal level
	% we have a distribution of predicted number of correct responses. One 
	% value for each MCMC sample, which reflects uncertainty in the
	% parameters. We can visualise this distribution with...
	% hist( predk(:,s), [1:T])
	% calculate a probability distribution for predicted number of correct
	% responses
	f = hist( predpc(:,s),linspace(0,1,params.T));
	p = f./sum(f); % normalise into a probability distribution
	
	actual_correct_responses = params.k(s);
	% look up the probability of getting that number correct, according to
	% the model posterior prediction. This is the likelihood of the actual
	% data, given the model predictions
	data_likelihoodS(s) = p(actual_correct_responses);
end
% remove zeros
data_likelihoodS=data_likelihoodS(data_likelihoodS~=0);

probOfDataGivenParameters = prod(data_likelihoodS);
% Calculate AIC
num_of_parameters = 1;
predictions.data.AIC = 2*num_of_parameters - 2*log( probOfDataGivenParameters );

% %% EXAMINE ERROR BETWEEN DATA AND MODEL PREDICTION
% % I also calcualted the error between the actual number correct k) and
% % model predicted number correct (predk) in JAGS. We will similarly reshape
% % this matrix to collapse across MCMC chains
% residual = reshape( samples.residual ,...
% 	mcmcparams.infer.nchains*mcmcparams.infer.nsamples,...
% 	numel(dataset.si));
% 
% % residual is in terms of NUMBER of correct trials. Convert it to a
% % proportion
% residual = residual./T;
% % COMPUTE ROOT MEAN SQUARED ERROR
% MSE = mean( residual(:).^2 ); % over ALL MCMC samples
% predictions.data.RMSE = sqrt(MSE);

% %% compute sum of r2 values 
% % see p.140-141 of Lunn, D. J., Jackson, C., Best, N., Thomas, A., & 
% % Spiegelhalter, D. (2013). The BUGS Book: A practical introduction to 
% % Bayesian analysis. CRC Press.
% 
% r = mean(residual) ./ sqrt(var(residual));
% % remove NaN's that could occur for perfect model fit
% r = r(~isnan(r));
% r2=sum(r.^2)
% fit.r2 = r2;

% %% plot
% figure(10), clf, boxplot(residual,[1:numel(si)]) %semilogx(si,residual')
% xlabel('\mu_S condition'), ylabel('proportion correct, residual')
% hline(0)
% set(gca,'PlotBoxAspectRatio',[1.5 1 1])
% title(sprintf('RMSE=%3.8f',fit.MSE))
% drawnow
% export_fig model1errors -pdf -m1

return