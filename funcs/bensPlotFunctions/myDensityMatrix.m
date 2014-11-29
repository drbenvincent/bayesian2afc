function myDensityMatrix(x,y,z, varnames, truevals, support)
%
% my cheap-ass implementation of https://github.com/dfm/triangle.py

clf
colormap(gray)

bins = 40;
fs = 10;

% x=randn(1000,1)-3;
% y=randn(1000,1);
% z=randn(1000,1)+3;
% varnames={'x','y','z'};
% %varnames={'\sigma^2','\lambda','b'};
% truevals=[-3 0 3];

% Calculate consistent ranges
k=1.1;
xrange=[min(x) max(x)];
yrange=[min(y) max(y)];
zrange=[min(z) max(z)];



%% plot the marginal histrograms
h.x = subplot(3,3,1);
internal_histogram(x,xrange, support{1})
hline([],truevals(1))
set(gca,'XLim',xrange)

h.y = subplot(3,3,5);
internal_histogram(y,yrange, support{2})
hline([],truevals(2))
set(gca,'XLim',yrange)

h.z = subplot(3,3,9);
internal_histogram(z,zrange, support{3})
hline([],truevals(3))
set(gca,'XLim',zrange)

%%
% x,y
h.xy = subplot(3,3,4);
internal_twowayplot(x,y)
hline([],truevals(1))
hline(truevals(2))
set(gca,'XLim',xrange)
set(gca,'YLim',yrange)

% x,z
h.xz = subplot(3,3,7);
internal_twowayplot(x,z)
hline([],truevals(1))
hline(truevals(3))
set(gca,'XLim',xrange)
set(gca,'YLim',zrange)

% y,z
h.yz = subplot(3,3,8);
internal_twowayplot(y,z)
hline([],truevals(2))
hline(truevals(3))
set(gca,'XLim',yrange)
set(gca,'YLim',zrange)

%% set global axis properties
all_handles = get(gcf,'Children');
set(all_handles,'FontSize',fs,...
	'LineWidth',1)

%%
% add y-axis labels
subplot(3,3,4), ylabel(varnames(2), 'FontSize',fs)
subplot(3,3,7), ylabel(varnames(3), 'FontSize',fs)
% add x-axis labels
subplot(3,3,7), xlabel(varnames(1), 'FontSize',fs)
subplot(3,3,8), xlabel(varnames(2), 'FontSize',fs)
subplot(3,3,9), xlabel(varnames(3), 'FontSize',fs)

% remove x tick labels
subplot(3,3,1), set(gca,'XTickLabel',[])
subplot(3,3,4), set(gca,'XTickLabel',[])
subplot(3,3,5), set(gca,'XTickLabel',[])

% remove y tick labels
subplot(3,3,1), set(gca,'YTickLabel',[])
subplot(3,3,5), set(gca,'YTickLabel',[])
subplot(3,3,8), set(gca,'YTickLabel',[])
subplot(3,3,9), set(gca,'YTickLabel',[])

%% set positions
width=0.25;
height=0.25;
lb=0.15; % left border
bb=0.15; % bottom border
set(h.xz,'Position',[lb bb width height]);
set(h.yz,'Position',[lb+width bb width height]);
set(h.z,'Position',[lb+width+width bb width height]);

set(h.xy,'Position',[lb bb+height width height]);
set(h.x,'Position',[lb bb+height+height width height]);

set(h.y,'Position',[lb+width bb+height width height]);

%%
set(gcf,'Position',[0 0 360 360])
drawnow

%%
	function internal_twowayplot(a,b)
		%plot(a,b,'k.')
		
		my_2d_hist(a,b , bins, bins);
		colormap(flipud(colormap))
		set(gca,'TickDir','in')
		axis square
	end

	function internal_histogram(data, range, supp)
		[n,xi] = hist(data,linspace(min(range),max(range),bins));
		area(xi,n,...
			'FaceColor', [0.7 0.7 0.7], ...
			'LineStyle','none')
		% give a bit of headroom for the histogram
		axis tight; a=axis; ylim([0 a(4)*1.1])
		axis square
		set(gca,'TickDir','in')
		hold on
		%
		[MAP, xi, p, CI95] = sampleStats(data, supp);
		
		% plot 95% CI line
		a=axis; ypos=a(4)*0.05;
		plot(CI95,[ypos ypos],'k-')
		% Add summary info
		addDistributionSummaryText(MAP, CI95, 'TR', fs-2)
		

	end


end


