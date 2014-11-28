function model3plot
plot_formatting_setup

load('~/Dropbox/tempModelOutputs/tempModel3run.mat')
% temp=cd;
% try
% 	cd('~/Dropbox/tempModelOutputs')
% 	load tempModel3run.mat
% 	cd(temp)
% catch
% 	
% end




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
