function pc = pcfunc(si,variance)
% This function calculates the percent correct given a value (or a vector
% of values) of signal intesities (si) and a variance.

pc =  normcdf( (si) ./ sqrt(2*variance) );

return