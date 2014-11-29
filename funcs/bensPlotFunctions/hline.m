function out=hline(h,v)
%HLINE  Adds a horizontal/vertical line to current figure
%  hline(h) adds horizontal line at h
%  hline([],v) adds vertical line at v

% Marko Laine <marko.laine@fmi.fi>
% $Revision: 1.4 $  $Date: 2012/09/27 11:47:36 $

ax=get(gcf,'CurrentAxes');
ylim=get(ax,'YLim');
xlim=get(ax,'Xlim');

if isempty(h)
   hl=line([v v], ylim);
else
   hl=line(xlim, [h h]);
end
set(hl,'Color',[0 0 0]);
set(hl,'LineStyle',':');
set(hl,'LineWidth',1);

if nargout>0
   out=hl;
end
