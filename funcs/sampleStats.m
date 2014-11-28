function [estimated_mode, XI, p, ci95] = sampleStats(samples, support)

% Compute the kernel density estimate based on MCMC samples
[F,XI]=ksdensity(samples(:),...
	'support', support,...
	'npoints',1000);

% now calculate the mode
[~,index]=max(F);
estimated_mode = XI(index);

% normalise
p=F./sum(F);

ci95 = prctile(samples,[5 95]);

fprintf('mode=%2.3f (%2.3f - %2.3f)\n',...
	estimated_mode, ci95(1), ci95(2))

return