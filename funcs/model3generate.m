%% model2generate.m
% This function generates a dataset of target locations (L) and internal 
% sensory observations (x) given the parameters provided, 
% $P(L,x|params)$
%%

function [params] = model2generate(params, mcmcparams)


%% Pleliminaries
N           = 2; % DO NOT CHANGE

% % If the external noise variance is set to zero, then we need to adjust
% % this to be a very small number. If it is exactly zero, then we get divide
% % by zero errors in JAGS.
% if params.varext==0
% 	params.varext=10^-20;
% end


%% Definine observed data

TRIALS_SIMULATED = params.T;
% simulate 1 trial, but generate many MCMC samples, see below. But due to
% some quirk of matjags(?) there are problems when evaluating just 1 trial,
% so we will simulate 2 and then discard this.
params.T = 2; 


%%
% Set initial values for latent variable in each chain
clear initial_param
for i=1:mcmcparams.generate.nchains
	for s=1:numel(params.si)
		for t=1:params.T
			initial_param(i).L(s,t) = round( ( rand*(N-1)) +1);
		end
	end
end

%% Do the MCMC sampling by invoking JAGS
fprintf('Generating dataset of x and L.\n')
fprintf('\nJAGS: running %d chains, each with %d MCMC samples...\n',...
	mcmcparams.generate.nchains, mcmcparams.generate.nsamples);
tic
[samples, stats, structArray] = matjags( ...
    params, ...                 
    fullfile(pwd, mcmcparams.JAGSmodel), ...   
    initial_param, ...                     
    'doparallel' , mcmcparams.doparallel, ...      
    'nchains', mcmcparams.generate.nchains,...              
    'nburnin', mcmcparams.generate.nburnin,...             
    'nsamples', mcmcparams.generate.nsamples, ...           
    'thin', 1, ...                      
    'monitorparams', {'L','x'}, ...    
    'savejagsoutput' , 1 , ...   
    'verbosity' , 1 , ...              
    'cleanup' , 0 ,...
    'rndseed', 1,...
    'dic',0);                    
min_sec(toc);

clear initial_param

%% Gather data we need in correct form
% We wanted to create our dataset by only simulating a single trial, but we
% gather our data over multiple trials from different MCMC samples. There
% seems to be a limitation in JAGS where you cannot evaluate only 1
% trial... seems to be due to size of the arrays etc. So we need to extract
% the information we are after now
params.L = squeeze(samples.L(1,:,:,1));
params.x = squeeze(samples.x(1,:,:,:,1));

params.T = TRIALS_SIMULATED;

% reshape dataset.x into form needed later
for t=1:params.T
    for s=1:numel(params.si)
        temp(s,1,t) = params.x(t,s,1) ;
        temp(s,2,t) = params.x(t,s,2) ;
    end
end
params.x = temp;

%%
% Now we have out simulated dataset, we can calculate the proportion of
% correct responses per signal level

return