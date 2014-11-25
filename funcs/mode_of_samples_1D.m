%% mode_of_samples_1D.m
% This function calcalates the mode of a set of MCMC samples, and it does
% it by calcualing a kernel density function using the Matlab |ksdensity|
% function. 
%%

function [estimated_mode, XI, p, ci95] = mode_of_samples_1D(samples, support)
% convert samples into a vector, just in case it's not already
samples = samples(:);

% Compute the kernel density estimate
[F,XI]=ksdensity(samples,...
	'support', support,...
	'npoints',1000);

% now calculate the mode
[~,index]=max(F);
estimated_mode = XI(index);

% normalise
p=F./sum(F);


ci95 = prctile(samples,[5 95]);

%%
% We don't need to do this, but when exploring the code, you can use the
% following lines to visualise...

%   plot(XI,F)
%   hline([],estimated_mode)

return