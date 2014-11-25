%% model2infer.m
% Use MCMC to infer the posterior distribution $P(L|parameters)$
%%

function [samples,stats, PC, PCI, R, k] = model2infer(params, mcmcparams)

%% Preliminaries
N=2; % DO NOT CHANGE

% create a structure of knowns by the observer
knowns = params;
%%
% Double check we have removed knowledge of the internal variance as this 
% is what we are trying to estimate
try
	knowns = rmfield(knowns,'L');
catch
	% the field was already removed
end 
%%
% Set initial values for latent variable in each chain
clear initial_param
for i=1:mcmcparams.infer.nchains
    initial_param(i).L = round( (rand(numel(knowns.si), knowns.T)*(N-1)) +1);
end


%% Invoke JAGS to generate samples
fprintf('Inferring signal locations\n')
fprintf('\nJAGS: running %d chains, each with %d MCMC samples...\n',...
	mcmcparams.infer.nchains, mcmcparams.infer.nsamples);
tic
[samples, stats] = matjags( ...
    knowns, ...                       
    fullfile(pwd, mcmcparams.JAGSmodel), ...    
    initial_param, ...                          
    'doparallel' , mcmcparams.doparallel, ...      
    'nchains', mcmcparams.infer.nchains,...             
    'nburnin', mcmcparams.infer.nburnin,...             
    'nsamples', mcmcparams.infer.nsamples, ...           
    'thin', 1, ...                      
    'monitorparams', {'L'}, ...  
    'savejagsoutput' , 1 , ... 
    'verbosity' , 1 , ... 
    'cleanup' , 0 ,...
    'rndseed', 1); 
min_sec(toc);




%% Decision rule
% The MCMC samples of L are the observer's posterior predictive
% distribution over the signal location. For each trial, we exact this
% distribution and calculate their response as the most likely location,
% which corresponds to the MAP decision rule.

R=zeros(params.T,numel(params.si)); % preallocate matrix
for t=1:params.T
    for s=1:numel(params.si)
        % extract all the samples from all the chains, for this trial (t)
        L_temp = vec(samples.L(:,:,s,t));
        % samples are {1,2} so we want to calculate the most likely
        % location of the signal, so we can use the mode function.
        R(t,s)		= mode( L_temp );
    end
end

%% 
% The matrix |R| now holds the response data. 

%% Evaluate the performance of the optimal observer
% On how many trials did the optimal observer make the correct inference
% (and response) about the correct location of the target. We know the
% correct location from our simulated dataset in step 1.
k=zeros(numel(params.si),1); % preallocate 
for s=1:numel(params.si)
    k(s) = sum( R(:,s)==params.L(:,s) );
end

%%
% Calculate the percent correct, and the 95% credibility intervals of the
% percent correct, given the number of trials we ran.
[PC, PCI] = binofit(k,params.T);

return