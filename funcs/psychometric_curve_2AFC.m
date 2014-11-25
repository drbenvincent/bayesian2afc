%% psychometric_curve_2AFC.m
%%
% Calculates proportion correct (pc) as a function of signal intensities
% ($\mu_S$) for a given noise variance (v).
%
% $pc = \Phi( \frac{d'}{\sqrt{2}})$

%%
% This function assumes the variance related to signal and noise items are 
% identical. Outputs of this function can be visualised by: |semilogx(muS, pc)|

function pc = psychometric_curve_2AFC(muS,muN,v)
dp  = (muS-muN) ./ real(sqrt(v));
pc  = normcdf( dp / sqrt(2));
return

