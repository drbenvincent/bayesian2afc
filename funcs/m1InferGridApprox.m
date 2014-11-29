function [posterior_var,vMode,HDI] = m1InferGridApprox(estOpts,params)

fprintf('Running parameter recovery via grid approximation...')
posterior_var=zeros(size(estOpts.V)); % preallocate
% GRID APPROX ---------------------------------------------------
parfor n=1:numel(estOpts.V) % Do the grid approximation
	posterior_var(n) = m1jointPosterior(estOpts.V(n),...
		params.sioriginal, params.koriginal, params.T);
end
% ---------------------------------------------------------------
fprintf(' done\n')
% normalise
posterior_var = posterior_var ./ sum(posterior_var);



% Calculate posterior mode, the MAP value
[~,index]=max(posterior_var);
vMode = estOpts.V(index);
% Calculate 95% HDI
[HDI] = HDIofGrid(estOpts.V,posterior_var, 0.95);

fprintf('Posterior over internal variance: mode=%2.3f (%2.3f - %2.3f)\n',...
	vMode, HDI.lower, HDI.upper)


return