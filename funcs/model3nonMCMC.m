function [PC, k] = model3nonMCMC(variance, muS, T, dPrior)

%Provided as input arguments
%T=50000; % Trials per signal level
%sigma   = 0.8;
%muS		= logspace(-2,1,40);
% prior over signal location
% dPrior = [0.5 0.5];

% convert variance parameter to std (sigma)
sigma = sqrt(variance);

C = numel(muS);
N = 2; % 2AFC
true_spatial_prior = [0.5 0.5];
% initialse number of correct trials
k = zeros(C,1);

% deterministic p(xmu|L), to be modified later for each signal intensity
% condition. muN is assumed to equal zero.
xMu = eye(N);

%fprintf('Evaluating model 3... ')
tic
parfor t=1:T % loop over trials (using multiple cores)
	
	%% STEP 1: GENERATIVE
	% Sample signal locations (for all signal intensity conditions). This
	% will be a Cx10 size binary matrix indicating signal location on each
	% trial.

	l = mnrnd(1,true_spatial_prior,C);
	% Calculate means of observations: mean signal is equal to the muS for
	% that signal intensity condition, mean noise is zero.
	mu = bsxfun(@times,l,muS');
	% generate noisy observations
	x = normrnd( mu, sigma);
	
	
	%% STEP 2: INFERENCE
	Post=zeros(C,N);
	
	mu_if_signal_in_location_1 = [muS', zeros(size(muS'))];
	n=1;
	Post(:,n) = prod( normpdf(x, mu_if_signal_in_location_1 , sigma) ,2);
	Post(:,n) = Post(:,n) .* dPrior(n);
	
	mu_if_signal_in_location_2 = [zeros(size(muS')), muS'];
	n=2;
	Post(:,n) = prod( normpdf(x, mu_if_signal_in_location_2 , sigma) ,2);
	Post(:,n) = Post(:,n) .* dPrior(n);
	
	%% STEP 3: RESPONSE
	% for each location, response will be either 1 or 2 (indexing the
	% inferred signal location)
	response=zeros(1,C);
	response( Post(:,1) > Post(:,2) ) = 1;
	response( Post(:,1) < Post(:,2) ) = 2;
	
	% see if the response location is correct
	[~,true_location] = max(l,[],2);
	iscorrect = true_location==response';
	
    % update vector of correct responses over easch muS value
	k= k+iscorrect;
	
    
    %% Below is my initially coded, non-vectorised, thus slow code.
	% 	for c=1:C % loop over muS conditions
	%
	% 		%         %% STEP 1: GENERATIVE
	% 		%         % sample signal location from prior
	% 		%         l = mnrnd(1,dPrior);
	%
	% 		% sample noisy observation, with observation mean dependent upon
	% 		% the signal location
	% 		%x = normrnd( l(c,:)*muS(c), sigma);
	%
	% 		%% step 2: INFERENCE, now we know x
	% 		% This portion of the code model's the observer's inferences about
	% 		% the signal being in each of the two locations. The joint
	% 		% posterior of this unknown parameter value is evaluated for each
	% 		% location, so it is a simple grid approximation, with just 2
	% 		% values of the location parameter.
	% 		for n=1:N % loop over spatial locations
	% 			% log likelihood of each value of L (each location)
	% 			LLd(n) = sum( log( normpdf(x(c,:), xMu(n,:)*muS(c) , sigma) ));
	% 		end
	% 		logPosteriorD = LLd + log(dPrior);	% posterior
	%
	% 		%% STEP 3: DECISION
	% 		response = argmax(logPosteriorD);
	% 		if response == argmax(l)
	% 			k(c) = k(c) + 1;
	% 		end
	
end

fprintf(' %2.1f simulations per second\n',T/toc)
%fprintf('%f u sec per iteration\n',(toc/T)*1000)
min_sec(toc);
fprintf('.\n')

PC = k./T;

return