function addDistributionSummaryText(map, CI, position, fontsize)
% Adds MAP and 95% CI info to a figure
%
% eg.
% addDistributionSummaryText(0.9, [0.85 0.93], 'TR', 12)

text_to_write=sprintf('%2.3f (%2.3f-%2.3f)',...
	map, CI(1), CI(2));

add_text_to_figure(position,text_to_write, fontsize)

return