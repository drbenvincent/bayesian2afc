%% model2infer.m
% This function passes invokes JAGS
%%

function [samples, stats] = model1inferMCMC(knowns, starting_var, mcmcparams)

% Double check we have removed knowledge of the internal variance as this
% is what we are trying to estimate
try
	knowns = rmfield(knowns,'v');
catch
	% the field was already removed
end
%%
% Set initial values for each chain
clear initial_param
for n=1:mcmcparams.infer.nchains 
	initial_param(n).v = starting_var(n);
end

%% Invoke JAGS via the |matjags.m| function
% invoke JAGS to return samples from the posterior distribution of
% 'variance' given the parameters defined in the structure 'dataset'

fprintf( 'Running JAGS...\n' );
[samples, stats] = matjags( ...
    knowns, ...                       
    fullfile(pwd, mcmcparams.JAGSmodel), ...    
    initial_param, ...                          
    'doparallel' , mcmcparams.doparallel, ...      
    'nchains', mcmcparams.infer.nchains,...             
    'nburnin', mcmcparams.infer.nburnin,...       
    'nsamples', mcmcparams.infer.nsamples, ...           
    'thin', 1, ...                      
    'monitorparams', {'v','predk','k'}, ...  
    'savejagsoutput' , 1 , ... 
    'verbosity' , 1 , ... 
    'cleanup' , 1 ,...
    'rndseed',1); 

fprintf('done\n')
% %% plot MCMC chains
% % Visually inspect chains and examine the $\hat{R}$ statistic.
% MCMCdiagnoticsPlot(samples,stats,{'v'})
% 
% temp=cd;
% try 
%     latex_fig(12, 6,4)
%     cd('figs')
%     export_fig model2_infer_chains -pdf -m1
%     cd('..')
% catch
%     cd(temp)
% end

return