function [samples,acceptance_rate] = mhAlgorithm(estOpts,...
	si, k, T)

accepted = 0;

% preallocate vector of param values
samples = zeros(estOpts.n_samples,1);
samples(1) = estOpts.initial_variance;

for n=2:estOpts.n_samples
	
	old_sample = samples(n-1);
	old_posterior = estOpts.pdf(old_sample, si, k, T);
	
	% suggest a new sample, but variance can't be less than or equal to zero
	new_sample=-inf;
	while le(new_sample,0)
		new_sample = normrnd(old_sample,estOpts.proposalstd);
	end
	new_posterior = estOpts.pdf(new_sample, si, k, T);
	
	% maybe accept new sample
	if new_posterior > old_posterior
		samples(n) = new_sample;
		accepted = accepted + 1;
	else
		u = rand;
		if u < new_posterior/old_posterior
			samples(n) = new_sample;
			accepted = accepted + 1;
		else
			samples(n) = old_sample;
		end
	end

	if rem(n,5000)==0
		fprintf('%3.1f%%\n',(n/estOpts.n_samples)*100)
	end
end

acceptance_rate = accepted / estOpts.n_samples;
fprintf('Acceptance rate: %2.1f %%\n',acceptance_rate*100)
	
	
return