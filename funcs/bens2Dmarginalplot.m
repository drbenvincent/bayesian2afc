

clf
% MAIN HISTOGRAM ==================================================
subplot(2,2,2)


xmin=0; xmax = max(xd(:));
ymin=0; ymax = max(yd(:));

xd = samples.varint(:);
yd = samples.lapserate(:);
n=40;
xi = linspace(0,xmax,n); % varint
yi = linspace(0,ymax,n); % lapse rate
xr = interp1(xi,1:numel(xi),xd,'nearest')';
yr = interp1(yi,1:numel(yi),yd,'nearest')';
z = accumarray([xr' yr'], 1, [n n]);
imagesc(xi,yi,z')



xlabel('inferred variance')
ylabel('inferred lapse rate')

%set(gca,'PlotBoxAspectRatio',[1 1 1])
hline([],truevarint)
hline(truelapserate)
axis xy
colormap(flipud(gray))
box off

h1 = gca; 


% Y- MARGINAL ==================================================
subplot(2,2,1); 
[n,yi] = hist(yd,31);
barh(yi,n,1,...
	'BarWidth',1,...
	'FaceColor',[146 205 233]/255,...
	'EdgeColor',[1 1 1])
box off
hold on
axis tight
ylim([ymin ymax])
h2 = gca; 
axis('off');
hline(truelapserate)
set(gca,'XDir','reverse')

% Plot 95% CI
a		=axis;
top		=a(2);
Y = prctile(yd,[5 95]);
k=0.05; % the y-location of the line in terms of percent of the y-range

% plot the 95% CI line
plot([top*k top*k],Y,'k-',...
 	'LineWidth',3)


% X-MARGINAL ==================================================
subplot(2,2,4); 

[n,xi] = hist(xd,31);
bar(xi,n,1,...
	'BarWidth',1,...
	'FaceColor',[146 205 233]/255,...
	'EdgeColor',[1 1 1])
box off
hold on
axis tight
xlim([xmin xmax])
h3 = gca; 
axis('off');
hline([],truevarint)

% Plot 95% CI
a		=axis;
top		=a(4);
Y = prctile(xd,[5 95]);
k=0.05; % the y-location of the line in terms of percent of the y-range
% plot the 95% CI line
plot(Y,[top*k top*k],'k-',...
 	'LineWidth',3)



% =============================================================

set(h1,'Position',[0.35 0.35 0.55 0.55]);
set(h3,'Position',[.35 .1 .55 .15]);
set(h2,'Position',[.1 .35 .15 .55]);