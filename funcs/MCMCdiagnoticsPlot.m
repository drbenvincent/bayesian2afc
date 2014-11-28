function MCMCdiagnoticsPlot(samples,stats,fields)
%
% MCMCdiagnoticsPlot(samples,stats,{'a','b','c'})
%
% MCMCdiagnoticsPlot(samples,stats,{'varint','lr','b'})
%
% This function plots chains and posterior distributions of MCMC samples.
% All the MCMC samples are assumed to be in a structure such as:
%	samples.a
%	samples.b
%	samples.c
%


nSamplesDisplayLimit=10^4;

figure(1), clf
%names = fieldnames(samples)

rows = numel(fields);
cols = 5; % chains, posterior

% plot MCMC chains
col=1;
for r=1:rows
	% select the right subplot
	%ind = sub2ind([cols rows],[1:5],r);
	subplot(rows,cols,[(cols*r)-cols+1 : (cols*r)-1])
	
	% plot MCMC chains, but only do so if there are fewer than 10^6 chains
	% as matlab can stall when plotting large numbers of data points.
	mcmcsamples = getfield(samples, fields{r});
	
	% if there are more than 100,000 samples (per chain), then just plot the first
	% 100,000 because the plot just looks insane otherwise
	samplesPerChain = size(mcmcsamples,2);
	if samplesPerChain>nSamplesDisplayLimit
		mcmcsamples=mcmcsamples(:,[1:nSamplesDisplayLimit]);
	end
	samplesPerChainDisplayed = size(mcmcsamples,2);
	
	% pick colours for each line
	
	% CREATE COLOURS
	
	nchains = size(mcmcsamples,1);
	ColorSet = ColorBand(nchains);
	hold all
	set(gca, 'ColorOrder', ColorSet);
	
	plot(mcmcsamples',...
		'LineWidth',0.2)
	
	% ylabel
	ylabel(fields(r))
	set(gca,'XTick',[0:1000:samplesPerChainDisplayed])
	
	%%
	% print Rhat statistic
	add_text_to_figure('T',...
		['$\hat{R}$ = ' num2str(getfield(stats.Rhat, fields{r}))],...
		20, 'latex')
	
	box off

	annotation('textbox', [0 0.9 1 0.1], ...
		'String', 'up to the first 10,000 MCMC samples', ...
		'EdgeColor', 'none', ...
		'HorizontalAlignment', 'center')
	
	if r==rows
		xlabel('MCMC sample')
	end
		
end


%%
% plot distributions
col=2;
for r=1:rows
	% select the right subplot
	subplot(rows,cols,(cols*r))
	
	% plot MCMC chains
	mcmcsamples = getfield(samples, fields{r});
	plotPost(mcmcsamples(:));
	
	xlabel(fields(r))
end

drawnow

return
