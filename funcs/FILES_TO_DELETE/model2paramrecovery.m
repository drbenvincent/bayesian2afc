function model2paramrecovery

% The aim here is to calculate how variable the *inferences* are based upon
% a fixed dataset of observations. Therefore, we simulate a dataset for
% each sized dataset and true variance value, and then repeatedly conduct 
% inference about the internal noise variance. The variability of the MAP
% estimates (and how often the 95% CI's overlap with true variance value)
% tells us how reliable the inference is.


%% Define initial parameters
clear, close all; clc   % First, tidy thigs up
T               = [50 200];  % trials per stimulus level
true_variance   = [1 2 3];
% number of times to repeat the procedure for each level of variance and T
repetitions = 5; 

% Define experiment parameters
params = define_experiment_params('model1');
% Define MCMC parameters
mcmcparams = define_mcmcparams('model1');
% overwrite some params because this takes a LONG time to compute
total_samples    = 10^5;
mcmcparams.infer.nsamples = round(total_samples/mcmcparams.infer.nchains);

%% Loops, doing parameter recovery many times
% preallocation
mcmc_estimated_mode = zeros(numel(T),numel(true_variance), repetitions); 
true_in_interval = zeros(numel(T),numel(true_variance), repetitions); 

nJobs = repetitions * numel(T) * numel(true_variance);
count = 1;
for t=1:numel(T)
    for v=1:numel(true_variance)
        
        % overwrite appropriate parameters
        params.T = T(t);
        params.intvariance = true_variance(v);
        
        % Generate a dataset here, that we will then repeatedly conduct
        % infrence upon.
        [experimenters_knowledge] = model1generate(params, mcmcparams);
        
        
        
		for r=1:repetitions

			fprintf('Running job %d of %d...\n',count,nJobs)

			% run parameter recovery --------------------------------------
            [samples, ~] = model1infer(experimenters_knowledge,...
                [0.5 1 5 10], mcmcparams);
            % -------------------------------------------------------------
			%[samples] = model1paramrecoveryjob(params, mcmcparams);
			% store vector of samples
			%mcmcsamples(v,:) = samples.variance(:);
			
			% calculate mode
			mcmc_estimated_mode(t,v,r) = mode_of_samples_1D(samples.intvariance(:), 'positive');
% 			% what is the 95% credibility interval and is the true value
% 			% within this interval?
 			CI = prctile(samples.intvariance(:),[5 95]);
			true_in_interval(t,v,r) = true_variance(v)>CI(1) & true_variance(v)<CI(2);
            
            drawnow
			count=count+1;
		end
	end
end


%% Calculate proportion of 95% CI's which include the true variance value
times_in_interval   = sum(true_in_interval,3);
prop_in_interval    = (times_in_interval./repetitions);

%% Plot
figure(2), clf, colormap(gray)
for t=1:numel(T)
	subplot(2,numel(T),t)
	
	plot([0 max(true_variance)+0.5],[0 max(true_variance)+0.5],'k-')
	hold on
	for v=1:numel(true_variance)
		xjitter = true_variance(v)+randn(repetitions,1)*0.05;
		plot(xjitter, squeeze(mcmc_estimated_mode(t,v,:)),'r+')
		% plot the median of the MAP estimates
		plot(true_variance(v), median(mcmc_estimated_mode(t,v,:)),'bo')
	end

	% format axis
	    set(gca,'XTick',true_variance,...
            'YTick',true_variance)
	%axis square
	axis equal
	axis([0 max(true_variance)+0.5 0 max(true_variance)*1.5])
	
	box off
	% label axes
	xlabel('true \sigma^2')
	ylabel('inferred \sigma^2')
	%title([num2str(T(t)) ' trials per stimulus level'])
	 title(sprintf('%d trials per\nstimulus level',T(t)))
end

pbar = get(gca,'PlotBoxAspectRatio');
% plot proportion of runs where the 95% credibility intervals overlapped
% with the true value
for t=1:numel(T)
	subplot(2,numel(T),numel(T)+t)
	
    bar(true_variance,prop_in_interval(t,:))
	
    set(gca,'PlotBoxAspectRatio',pbar,...
        'XTick',true_variance,...
        'YTick',[0:0.2:1])
    axis square
	%axis equal
	axis([min(true_variance)-0.5 max(true_variance)+0.5 0 1])
    
    box off
    % label axes
	xlabel('true \sigma^2')
	ylabel(sprintf('proportion 95%% CI\nincludes true value'))
end




%% Export

% Automatic resizing to make figure appropriate for font size
% Download from here http://www.mathworks.com/matlabcentral/fileexchange/36439-resizing-matlab-plots-for-publication-purposes-latex
latex_fig(10, 3, 3)

% Save as a Matlab format .fig file
hgsave('model2paramrecoveryeval')

%%
% If you download <http://www.mathworks.co.uk/matlabcentral/fileexchange/23629-exportfig export_fig.m>
% from Mathworks File Exchange, then the following command can be used for
% publication quality figure export: |export_fig model1 -pdf -m1|

export_fig model2paramrecoveryeval -pdf -m1

return