function [samples,acceptance_rate] = mhAlgorithm(param,n_samples,proposalstd,...
	pdf,...
	si, k, T)

accepted = 0;

% preallocate vector of param values
samples = zeros(n_samples,1);
samples(1) = param;

for n=2:n_samples
	
	old_sample = samples(n-1);
	old_posterior = pdf(old_sample, si, k, T);
	
	% suggest a new sample, but variance can't be less than or equal to
	% zero
	new_sample=-inf;
	while le(new_sample,0)
		new_sample = normrnd(old_sample,proposalstd);
	end
	new_posterior = pdf(new_sample, si, k, T);
	
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
end

acceptance_rate = accepted / n_samples;
fprintf('Acceptance rate: %2.1f %%\n',acceptance_rate*100)
	
	
	