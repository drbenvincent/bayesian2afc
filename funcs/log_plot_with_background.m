function log_plot_with_background(IMAGE,...
	imXdata , imYdata,...
	pltXdata, pltYdata)


imagesc(imXdata,imYdata,IMAGE)
ax1 = gca;
axis xy
ax1_pos = get(ax1,'Position');
set(ax1,'Visible','off')
colormap(gray)
colormap(flipud(colormap))
axis square


%%
ax2 = axes('Position',ax1_pos,...
    'XAxisLocation','bottom',...
    'YAxisLocation','left',...
    'Color','none',...
	'XScale','log',...
	'XTick',[0.01 0.1 1, 10],...
	'YTick',[0:0.1:1]);
%ax2.TickDir='out'

% ax2.XTick=[0.01 0.1 1, 10, 100]
% ax2.YTick=[0:0.1:1]
axis square

%%
l=line(pltXdata,pltYdata,'Parent',ax2,'Color','k');
set(l,'Marker','o',...
	'MarkerFaceColor','w',...
	'MarkerSize',8,...
	'LineStyle','none')

% l.Marker='o';
% l.MarkerFaceColor='w';
% l.MarkerSize=10;
% l.LineStyle='none';

% ensure same y scale
set(ax1,'YLim',[0.3 1]);
set(ax2,'YLim',[0.3 1]);

set(ax1,'XLim',[0 10]);
set(ax2,'XLim',[0 10]);

xlabel('signal intensity, \Delta\mu')
ylabel('proportion correct, k/T')
return