function [samples,stats] = model2infer(knowns, mcmcparams)

try
    % remove fields for which we want to make inferences
	knowns = rmfield(knowns,'v');
    knowns = rmfield(knowns,'lr');
    knowns = rmfield(knowns,'b');
catch
	% the field was already removed
end

% Set initial values for latent variable in each chain
clear initial_param
for i=1:mcmcparams.infer.nchains
    initial_param(i).v= 0.01+rand*10;
    %if inferlapserateFLAG==1
        initial_param(i).lr		= rand;
    %end
    %if inferbFLAG==1
        initial_param(i).b		= (rand-0.5)*8;
    %end
end

%% Call JAGS
fprintf( 'Running JAGS...\n' );
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
    'monitorparams', {'v','lr', 'b', 'postpredR','bprior'}, ...  
    'savejagsoutput' , 1 , ... 
    'verbosity' , 1 , ... 
    'cleanup' , 1 ,...
    'rndseed', 1); 
min_sec(toc);

 % note: we are monitoring R because we have supplied missing data
 % corresponding to additional muS values that we want to predict the
 % performance for
 



return