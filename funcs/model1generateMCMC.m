%% model2generate.m
% Generate a dataset of number of times correct, out of T trials (per
% condition) for the stimulus levels (defined in vector muS) with the noise
% level muN and the specified noise variance.
%%


function [params] = model1generateMCMC(params, mcmcparams)


%%
% Set initial values for each chain
for n=1:mcmcparams.generate.nchains
	initial_param(n).k = round( (rand(numel(params.si),1)*10) +1 );
end

%% Invoke JAGS via the |matjags| function
% invoke JAGS to return samples from the posterior distribution of
% 'variance' given the parameters defined in the structure 'dataset'

[samples, stats] = matjags( ...
    params, ...                       
    fullfile(pwd, mcmcparams.JAGSmodel), ...    
    initial_param, ...                          
    'doparallel' , mcmcparams.doparallel, ...      
    'nchains', mcmcparams.generate.nchains,...             
    'nburnin', mcmcparams.generate.nburnin,...       
    'nsamples', mcmcparams.generate.nsamples, ...           
    'thin', 1, ...                      
    'monitorparams', {'k'}, ...  
    'savejagsoutput' , 1 , ... 
    'verbosity' , 1 , ... 
    'cleanup' , 1 ,...
    'rndseed', 1,...
	'dic',0); 

% keep data from chain 1, for one sample
params.k = squeeze( samples.k(1,end,:) )';

% we want to overwrite the generated k values corresponding to the signal
% intensity levels we are examining for prediction
params.k(:,[numel(params.sioriginal)+1:end]) = NaN;

%params.k=knowns.k([1:numel(params.muS)]);
params.koriginal=params.k([1:numel(params.sioriginal)]);

return