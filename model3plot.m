function model3plot


temp=cd;
try
	cd('~/Dropbox/tempModelOutputs')
	load tempModel3run.mat
	cd(temp)
catch
	
end




% %% MODEL PREDICTIONS in data space
% % Generate a set of predictions for many signal intensity levels, beyond
% % that which we have data for (sii). Useful for visualising the model's
% % predictions.
% 
% % Sample from the posterior. * REQUIRES STATISTICS TOOLBOX * 
% fprintf('Drawing %d samples from the posterior distribution of internal variance...',...
%     predictive.nSamples)
% var_samples = randsample(varianceGridVals,predictive.nSamples,true,posterior_var);
% fprintf('done\n')
% fprintf('Calculating model predictions in data space for sii...')
% % predictive distribution
% predk=zeros(predictive.nSamples,numel(params.sii)); % preallocate
% for i=1:predictive.nSamples
% 	fprintf('%d of %d',i,predictive.nSamples)
%     % --------------------------------------------------
%     pc = model3nonMCMC(var_samples(i), params.sii, predictive.nSimulatedTrials, dPrior);
%     % --------------------------------------------------
%     predk(i,:) = binornd(params.T, pc );
% end
% fprintf('done\n')
% % Calculate 95% CI's for each signal level
% CI = prctile(predk,[5 95]) ./ params.T;
% clear predk



%% Plot results in data space
% Plot the simulated behaviour data alongside model predictions

figure(1),clf
subplot(1,2,1) 
% % plot simulated data
% semilogx(params.sioriginal, params.koriginal ./ params.T,'k.','MarkerSize',24);
% hold on
% 
% % plot model predictions
% my_shaded_errorbar_zone_UL...
% 	(params.sii,CI(2,:),CI(1,:),[111 181 227]./255);
% set(gca,'XScale','log')

% ===== TEST =====
for n=1:size(predk,2)
	IM(:,n) = hist( predk(:,n) ,[1:1:100] );
	% scale so the max numerical value = 100
	IM(:,n) =IM(:,n) / (max(IM(:,n))/100);
end
imXdata = params.sii;
imYdata = [0:1:100]/100;

pltXdata = params.sioriginal;
pltYdata = params.koriginal ./ params.T;

log_plot_with_background(IM,...
	imXdata , imYdata,...
	pltXdata, pltYdata)


% formatting
set(gca,'XScale','log',...
    'PlotBoxAspectRatio',[1 1 1],...
    'box', 'off',...
    'xlim', [0.009 10],...
    'ylim', [0.3 1.01],...
    'XTick',[0.01 0.1 1, 10],...
    'YTick',[0:0.1:1])
xlabel('signal level \mu_S')
ylabel('proportion correct')
title('a.')


%% Plot the inferences in parameter space
% Plot the posterior distribution over $\sigma^2$

subplot(1,2,2) 
% plot posterior distribtion 
%plot(varianceGridVals,posterior_var,'k-')
area(varianceGridVals,posterior_var,...
	'FaceColor', [0.7 0.7 0.7], ...
	'LineStyle','none')
axis tight
hline([],params.v)
% plot 95% HDI
hold on, a=axis; top =a(4); z=0.03;
plot([HDI.lower HDI.upper],[top*z top*z],'k-');
% format graph
xlabel('inferred \sigma^2')
ylabel('posterior density')
set(gca, 'PlotBoxAspectRatio',[1 1 1],...
    'box', 'off',...
    'yticklabel',{},...
	'YTick',[],...
    'xlim', [0 3])
title('b.')
% Add summary info
addDistributionSummaryText(vMode, [HDI.lower HDI.upper], 'TR', 12)


%% Export
figure(1)
% Automatic resizing to make figure appropriate for font size
latex_fig(12, 5, 3)

% Export in .fig and .pdf
cd('figs')
hgsave('model3')
export_fig model3 -pdf -m1
cd('..')

% % save everything to my dropbox folder. These files can be too large to go
% % on GitHub.
% st=cd;
% cd('/Users/benvincent/Dropbox/RESEARCH/PAPERSinprogress/MCMCtutorial/localSavedJobs')
% save tempModel3run.mat -v7.3
% cd(st)
