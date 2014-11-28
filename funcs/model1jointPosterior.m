function [posterior, predk] = model1jointPosterior(variance, si, k, T)
% This function will return the posterior of the joint distribution
% P(variance, si, k, T).
% It will do this by summing log probabilities

logp = 0;

%% prior
logp = logp + log(1/1000); % uniform prior on range 0-1000
% calculate value of deterministic node PC
PC = pcfunc(si, variance);

%% data likelihood
klogp = sum(log( binopdf(k, T, PC )));
logp = logp + klogp;

%% convert from log posterior to posterior
posterior = exp(logp);

% %% Posterior prediction
% 
% % sample some values of k, given the params {variance, si, T}
% predk = binornd(T, PC );

return