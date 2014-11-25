
function [knowns] = model2generate(knowns, mcmcparams)

%% Preliminaries

N           = 2; % DO NOT CHANGE THIS.

% If the external noise variance is set to zero, then we need to adjust
% this to be a very small number. If it is exactly zero, then we get divide
% by zero errors in JAGS.
if knowns.extvariance==0
    knowns.extvariance=10^-20;
end

% Set initial values for latent variable in each chain
clear initial_param
for i=1:mcmcparams.generate.nchains
    for s=1:numel(knowns.si)
        for t=1:knowns.T
            initial_param(i).L(s,t) = round( ( rand*(N-1)) +1);
            %initial_param(i).x(t,s) = randn*5;
        end
    end
end


%% Calling JAGS to sample
[samples, stats] = matjags( ...
    knowns, ...
    fullfile(pwd, mcmcparams.JAGSmodel), ...
    initial_param, ...
    'doparallel' , mcmcparams.doparallel, ...
    'nchains', mcmcparams.generate.nchains,...
    'nburnin', mcmcparams.generate.nburnin,...
    'nsamples', mcmcparams.generate.nsamples, ...
    'thin', 1, ...
    'monitorparams', {'L', 'R'}, ...
    'savejagsoutput' , 1 , ...
    'verbosity' , 1 , ...
    'cleanup' , 1 ,...
    'rndseed', 1);

%%
% We wanted to create our dataset by only simulating a single trial, but we
% gather our data over multiple trials from different MCMC samples. There
% seems to be a limitation in JAGS where you cannot evaluate only 1
% trial... seems to be due to size of the arrays etc. So we need to extract
% the information we are after now
knowns.L = squeeze(samples.L(1,:,:,1))';
knowns.R = squeeze(samples.R(1,:,:,1))';


% PROPORTION CORRECT - ACTUAL DATA
for n=1:numel(knowns.sioriginal)
    %knowns.k(n) = sum(knowns.L(:,n)==knowns.R(:,n));
    knowns.k(n) = sum(knowns.L(n,:)==knowns.R(n,:));
    knowns.pc(n) = knowns.k(n) / knowns.T;
end

% we now want to remove the responses generated for the additional si
% values. These would never have been obtained in an experiment. In fact,
% rather than literally delete the data, we replace with NaN's so that JAGS
% knows these are missing data point that we will make inferences about.
knowns.R([numel(knowns.sioriginal)+1:end],:) = NaN;

return