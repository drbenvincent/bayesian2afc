function sanityCheck2AFC(sigma)
%
% sanityCheck2AFC(0.75)
%

% Double, triple checking SDT equations are correct by comparing analytical
% and monte carlo



figure(1)
clf

set(0,'DefaultTextInterpreter', 'latex')

c1=[1 0 0]
c2=[0 0 1]

K = 5; % axis lim
fs=12;

muS=logspace(-2,2,50);
muN=0;
 % sigma = std, sigma^2 = variance



C = 0; % unbiased criterion


%% Analytically

pc = @(mus,sigma) normcdf( mus ./ sqrt(2*(sigma^2)) );

pcA = pc( muS(:), sigma );

% for n=1:numel(muS)
% 	%pcA(n) = pc( dp(muS(n),muN,sigma) );
% 	pcA(n) = pc( muS(n), sigma );
% end

subplot(1,2,1)
semilogx(muS,pcA)
hold on


%% Monte Carlo

TRIALS=100000;


for n=1:numel(muS)
	XS = normrnd(muS(n),sigma,[TRIALS 1]);
	XN = normrnd(muN,sigma,[TRIALS 1]);
	D = XS-XN;
	
	varD(n) = var(D);
	
	pcB(n) = sum(D>0)/TRIALS;
end
plot(muS,pcB,'ro')

subplot(1,2,2)
hist(varD)
2*(sigma^2)

hline([], 2*(sigma^2))
title('variance of D=XS-XN')



