function generateGridVsMCMCschematic

%% true distribution
% k heads out of T coin tosses
k=3;T=10;

thetai = linspace(0,1,1000);
postTrue = betapdf(thetai,1+k,1+(T-k));
postTrue = postTrue./max(postTrue);



%% GRID APPROXIMATION
theta_vec=linspace(0,1,21);
for n=1:numel(theta_vec)
	
	% calculate joint
	logp=0;
	logp=logp+log(betapdf(theta_vec(n),1,1));
	logp=logp+log(binopdf(k,T,theta_vec(n)));
	p(n) = exp(logp);
end


p = p./max(p);

figure(1), clf
subplot(1,2,1), plot(thetai,postTrue,'r-'), hold on


subplot(1,2,1)
stem(theta_vec,p,'filled')
box off
xlabel('parameter value')
ylabel('posterior')
axis tight
set(gca,'YTick',[],...
	'XTick',[0:0.1:1],...
	'PlotBoxAspectRatio',[1.5 1 1])
title('Grid approximation','FontWeight','Bold')


%% samples
% This is just a schematic diagram, so the code below does not atually
% conduct MCMC sampling. We just draw samples from a known posterior.
nsamples = 200;
R = betarnd(1+k,1+(T-k), nsamples,1)';

subplot(1,2,2), hold on




postTrue = postTrue./sum(postTrue);
subplot(1,2,2), plot(thetai,postTrue,'r-')

% kernel density estimate
dens = ksdensity(R,thetai,'support',[0 1]);
dens=  dens./sum(dens);
plot(thetai,dens)

ymax = max(get(gca,'YLim'));

% rug plot
plot([R;R], [zeros(size(R));ones(size(R)).*0.05*ymax],...
	'k',...
	'LineWidth',1)
hold on

box off
xlabel('parameter value')
ylabel('posterior')
axis tight
set(gca,'YTick',[],...
	'XTick',[0:0.1:1],...
	'PlotBoxAspectRatio',[1.5 1 1])
title('MCMC sampling','FontWeight','Bold')


%% Export
latex_fig(12, 7, 3)

% Export in .fig and .pdf
cd('figs')
figure(1), export_fig param_estimation -pdf -m1
figure(1), hgsave('param_estimation')
cd('..')
end