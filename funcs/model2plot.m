function model2plot

display('Loading model 2 data...')
load('~/Dropbox/tempModelOutputs/tempModel2run.mat')


%% Plot MCMC chains
figure(1), clf
MCMCdiagnoticsPlot(samples,stats,{'v','lr','b'})

temp=cd;
try
    latex_fig(12, 6,4)
    cd('figs')
	hgsave('model2_infer_chains')
    export_fig model2_infer_chains -pdf -m1
    cd('..')
catch
    cd(temp)
end


%% Plot Autocorrelations
plotChainAutocorrelationsModel2(samples)

temp=cd;
try
	latex_fig(8, 6, 4)
	cd('figs')
	export_fig model2autocorrelations -pdf -m1
	hgsave('model2autocorrelations')
	cd('..')
catch
	cd(temp)
end



display('Plotting model 2 data...\n')

%% Plot in data space
figure(2), clf
% subplot(1,2,1)
% hold on
% h.data = semilogx(data.sioriginal',data.pc,'k.','MarkerSize',24);

predk = predictions.interp.predk';

subplot(1,2,1) 
% ===== TEST =====
clear IM
for n=1:size(predk,2) % loop over signal intensities
	[IM(:,n), ~] = hist( predk(:,n) ,[1:1:100] );
	% scale so the max numerical value = 1
	IM(:,n) =IM(:,n) / (max(IM(:,n))/100);
end
imXdata = data.sii;
imYdata = [0:1:100]/100;

pltXdata = data.sioriginal;
pltYdata = data.koriginal ./ data.T;

log_plot_with_background(IM,...
	imXdata , imYdata,...
	pltXdata, pltYdata)

% Plot the 95% CI for the model predictions give the data. These predictions
% are much more specific than the other models. The trial-to-trial basis of
% the model provides it with knowledge of the true target location on every
% trial
% for n=1:numel(si)
% 	plot([si(n) si(n)],...
% 		[predictions.knowingL.upper(n) predictions.knowingL.lower(n)],...
% 		'-','Color',([111 181 227]./255)./3)
% end
% % do that, but as a shaded region

% plot 95% CI posterior prediction given that we do have knowledge of the
% true signal locations in the actual experiment. In a real situation we
% would indeed know this.
my_errorbarsUL(data.sioriginal,...
	predictions.knowingL.upper,...
	predictions.knowingL.lower,...
	{'Color','r',...
	'LineWidth',4})

% my_shaded_errorbar_zone_UL...
% 	(data.sioriginal,...
%     predictions.knowingL.upper, predictions.knowingL.lower,...
% 	([111 181 227]./255).*0.6);


% xlim([0.009 10])
% ylim([0.3 1.01])
% set(gca,'XTick',[0.01 0.1 1, 10])
% set(gca,'XScale','log')
% 
% % PLOT POSTERIOR PREDICTIVE CHECK
% my_shaded_errorbar_zone_UL...
% 	(data.sii, ...
%     predictions.interp.upper, predictions.interp.lower,...
%     [111 181 227]./255);

%title('a.')
xlabel('signal intensity, \Delta\mu')
ylabel('proportion correct')
box off
set(gca,'PlotBoxAspectRatio',[1 1 1])















% %% NEW TYPE OF PLOT FOR POSTERIORS
% 
% fs=10; % font size for summary stats
% % ~~~~~~~~~~~~~~~~~~~~~~~
% subplot(3,2,2) % PLOT POSTERIOR DISTRIBUTION OVER VARIANCE
% % ~~~~~~~~~~~~~~~~~~~~~~~
% 
% % Covert MCMC samples into a kernel density estimate and extract summary
% % stats
% [MAP, xi, p, CI95] = mode_of_samples_1D(samples.v(:), 'positive');
% 
% % plot posterior distribution
% % plot(xi,p,'k-')
% area(xi,p,...
% 	'FaceColor', [0.7 0.7 0.7], ...
% 	'LineStyle','none')
% % format
% axis tight
% xlim([0 3])
% title('\sigma^2')
% hline([],data.v) % PLOT TRUE VALUE
% % remove y-axis
% box off
% set(gca,'YTick',[],...
% 	'XTick',[0:1:3],...
% 	'PlotBoxAspectRatio',[4,1,1])
% hold on
% 
% % Add summary info
% addDistributionSummaryText(MAP, CI95, 'TR', fs)
% % plot 95% CI line
% a=axis; ypos=a(4)*0.1;
% plot(CI95,[ypos ypos],'k-')
% 
% 
% % ~~~~~~~~~~~~~~~~~~~~~~~
% subplot(3,2,4)
% % ~~~~~~~~~~~~~~~~~~~~~~~
% % Covert MCMC samples into a kernel density estimate and extract summary
% % stats
% [MAP, xi, p, CI95] = mode_of_samples_1D(samples.lr(:), 'positive');
% 
% % plot posterior distribution
% % plot(xi,p,'k-')
% area(xi,p,...
% 	'FaceColor', [0.7 0.7 0.7], ...
% 	'LineStyle','none')
% % format
% axis tight
% xlim([0 0.1])
% title('\lambda')
% hline([],data.lr) % PLOT TRUE VALUE
% % remove y-axis
% box off
% set(gca,'YTick',[],...
% 	'XTick',[0:0.025:0.1],...
% 	'PlotBoxAspectRatio',[4,1,1])
% hold on
% 
% % Add summary info
% addDistributionSummaryText(MAP, CI95, 'TR', fs)
% % plot 95% CI line
% a=axis; ypos=a(4)*0.1;
% plot(CI95,[ypos ypos],'k-')
% 
% 
% 
% 
% % ~~~~~~~~~~~~~~~~~~~~~~~
% subplot(3,2,6) % PLOT POSTERIOR OVER BIAS (b)
% % ~~~~~~~~~~~~~~~~~~~~~~~
% % Covert MCMC samples into a kernel density estimate and extract summary
% % stats
% [MAP, xi, p, CI95] = mode_of_samples_1D(samples.b(:), [-100 100]);
% 
% % plot posterior distribution
% % plot(xi,p,'k-')
% area(xi,p,...
% 	'FaceColor', [0.7 0.7 0.7], ...
% 	'LineStyle','none')
% % format
% axis tight
% 
% title('b')
% hline([],data.b) % PLOT TRUE VALUE
% % remove y-axis
% box off
% set(gca,'YTick',[],...
% 	'XTick',[-0.5:0.5:0.5],...
% 	'XLim',[-0.5 0.5],...
% 	'PlotBoxAspectRatio',[4,1,1])
% hold on
% 
% % Add summary info
% addDistributionSummaryText(MAP, CI95, 'TR', fs)
% % plot 95% CI line
% a=axis; ypos=a(4)*0.1;
% plot(CI95,[ypos ypos],'k-')

% Export ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
figure(2), latex_fig(12, 5, 3)

% Export in .fig and .pdf
cd('figs')
figure(2), export_fig model2 -pdf -m1
figure(2), hgsave('model2')
cd('..')


%% PLOT PARAMETER SPACE
temp=cd;
try
	cd('figs')
	figure(5), clf
	myDensityMatrix(samples.v(:),samples.lr(:),samples.b(:),...
		{'\sigma^2','\lambda','b'},...
		[data.v, data.lr, data.b],...
		{'positive','positive',[-100 100]})
	
	figure(5), hgsave('model2paramMatrix')
	figure(5), export_fig model2paramMatrix -pdf -m1

	cd('..')
catch
	cd(temp)
end



