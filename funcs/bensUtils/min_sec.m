function [m,s]=min_sec(t,varargin)
% This function simply prints the time between a tic and a toc command and
% does so in a more friendly way than the default.
% [m,s]=min_sec(toc, ['print','no_print'])
%
% written by: Benjamin T Vincent

switch nargin
	case{1}
		shall_I_print='print';
	case{2}
		shall_I_print=varargin{1};
end

% How many minuites?
m = fix(t/60);

% How many seconds?
s = t - (60*m);

switch shall_I_print
	case{'print'}
		if m>0
			fprintf('%2.0fmin %2.0fsec\n',m,s)
		else
			fprintf('%2.3f sec \n',s)
        end
end

return