%% analytic2AFC.m
% This function calculates:
% $L(pc|k,n) = P(k,n|pc)$
% over a range of different internal noise values,
% using equations from signal detection thoery.
%%
% Use the following code to demonstrate the use of this function:
%	[variance_vec,likelihood] = analytic2AFC(1, 0, [49, 54, 56, 50, 56, 56, 80, 95, 100, 100], 100);
%	plot(variance_vec,likelihood)
%%


function [variance_vec,likelihood] = analytic2AFC(muS, muN, k, TRIALS)
% define a range of values of observation variance we will examine
variance_vec=linspace(10^-3, 5, 1000);

% loop over these values
for n=1:numel(variance_vec)
    % Calculate the likelihood, defined in the local function "mypdf"
    likelihood(n) = mypdf(variance_vec(n));
end

%%
% We don't need to do this, but use the code below to visualise the output...

% plot(variance_vec,L)
% xlabel('variance'), ylabel('likelihood')



%% An internal function to compute the likelihood
% Compute the overall likelihood, which is the product of
% likelihoods for each signal intensity condition. This could be
% done by the product of the likelihoods, but it is safer (more
% numerically stable) and standard practice to compute it as the
% sum of log likelihoods. The exp, then returns it to a likelihood.
%
% Note that dp, pc, and Ltemp will be vectors because it is calculating them
% for a number of signal intensity conditions

    function L = mypdf(variance)
        dp          = (muS-muN)/sqrt(variance);
        pc          = normcdf(dp ./ sqrt(2));
        Ltemp       = binopdf( k , TRIALS, pc );    % Likelihood
        log_likelihood = sum( log(Ltemp) );         % sum log likelihoods
        L = exp( log_likelihood );                  % Likelihood
    end

end




