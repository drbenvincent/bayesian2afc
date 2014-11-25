function [h]=plotPost(x)
% Plots the distribution in a style very similar to that in the Kruschke
% textbook.
%
% Basically it's a histogram plot, but because the data (x) are samples
% from a posterior distribtion, the data represent samples from a posterior
% distribution. Therefore the y-axis is probability density so there is no
% real need for a y-axis.
%
% |support| should equal 'positive' or 'unbounded'


% % PLOT AS A FILLED HISTOGRAM -----------------
% [f,xi]=hist(x,64);
% 
% h.bar = bar(xi,f,32,...
% 	'BarWidth',1,...
% 	'FaceColor',[0.8 0.8 0.8],...
% 	'EdgeColor','none');
% % --------------------------------------------

% PLOT AS AN OUTLINED HISTOGRAM --------------
[f,xx] = hist(x, 50);
% normalise it to a probability mass function
f=f./sum(f);
% plot
h = stairs(xx, f, 'k-');
% --------------------------------------------

% zoom in on both axes
axis tight
% scale the y-axis
ylim([0 max(f)])

% format axes
box off

% remove YTicks, and make the axis white (i.e. invisible)
% set(gca,'YTick',[],...
% 	'YColor',[1 1 1])
% keep y axis, but remove labels
set(gca,'yticklabel',{},...
	'YTick',[])

a		=axis;
top		=a(4);

% % Add text describing the mean ~~~~~~~~~~~~~
% mx		=mean(x);
% mytext = sprintf('mean = %2.2f',mx);
% text(mx,top, mytext,...
% 	'HorizontalAlignment','center',...
% 	'VerticalAlignment','top')
% % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% % % Add text describing the mode ~~~~~~~~~~~~~
% [estimated_mode] = mode_of_samples_1D(x,support);
% mytext = sprintf('mode = %2.2f',estimated_mode);
% text(estimated_mode,top, mytext,...
% 	'HorizontalAlignment','center',...
% 	'VerticalAlignment','top')
% % % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~




hold on
% Plot 95% CI
Y = prctile(x,[5 95]);
k=0.03; % the y-location of the line in terms of percent of the y-range

% plot the 95% CI line
plot(Y,[top*k top*k],'k-',...
 	'LineWidth',3);
% % add the "95% CI" label
% text(mean(Y),top*k , '95% CI',...
% 	'HorizontalAlignment','center',...
% 	'VerticalAlignment','bottom')

% Add text labels (lower and uppper values) onto the 95% CI bar
% lower = sprintf('%.2f',Y(1));
% upper = sprintf('%.2f',Y(2));
% text(Y(1),top*k , lower,...
% 	'HorizontalAlignment','center',...
% 	'VerticalAlignment','bottom',...
% 	'FontSize',10)
% text(Y(2),top*k , upper,...
% 	'HorizontalAlignment','center',...
% 	'VerticalAlignment','bottom',...
% 	'FontSize',10)

% ensure the axis is in front of the bars
set(gca,'Layer','top')
hold off