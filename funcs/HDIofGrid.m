%
% written by: Benjamin T Vincent
% Based on p.627 of Kruschke, Doing Bayesian Data Analysis

function [HDI] = HDIofGrid(x,y, credibiltyMass)

% expecting sum of probability density to sum to 1. In other words, we are
% expecting normalised probability distributions. 
% We could just see if sum(y)==1, but sometimes there are rounding errors
% and it's not quite. So we will compute if the difference between sum(y)
% and 1 is sufficiently low
if abs(1-sum(y))>10^-10
	error('Expecting probability density (y) to sum to 1')
end

sortedMass = sort(y,'descend');
HDIheightIdx = find(cumsum(sortedMass) >= credibiltyMass,1,'first');
HDIheight = sortedMass(HDIheightIdx);
HDImass = sum( (y(y>=HDIheight) ));

lowerIndex = find( y>=HDIheight ,1,'first');
upperIndex = find( y>=HDIheight ,1,'last');

HDI.lower = x(lowerIndex);
HDI.upper = x(upperIndex);

return
