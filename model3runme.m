function model3runme

% set things up
clear, clc, %close all; drawnow
addpath([cd '/funcs'])
addpath([cd '/funcs/export_fig'])
addpath([cd '/funcs/acf']) % for autocorrelation function
addpath([cd '/funcs/ColorBand'])
plot_formatting_setup

%% set some simulation parameters
% Parameters for grid approximation (parameter estimation)
nGridValues = 50;
varianceGridVals = linspace(0.25, 2, nGridValues)'; 

% the larger this number, the more accurately we are assessing the
% performance of the optimal observer in the limit of many many trials.
paramest.nSimulatedTrials = 10^6; % 10^6 minimum for reliable results

% Because we are drawing many samples, we run the model each time, so this
% takes a long time to compute! So we will drop down the number of
% simulated trials when evaluating the predictive distribution.
predictive.nSimulatedTrials = 10^5; % 10^5
% Number of samples from the predictive distribtion to draw, each of which
% will result in a predicted psychometric function
predictive.nSamples = 10^3; %10^3

%%
% open up multiple cores for use
%parpool

DATAMODE = 'load'; % {'load'|'generate'}

switch DATAMODE
	case{'load'}
		% Load file containing experiment parameters, and a pre-computed
		% dataset of locations (L) and responses (R).
		load('data/commondata_model3.mat')

end

display('data loaded')

%% Define anonymous functions
Lk = @(k,T,pc) binopdf(k , T, pc);
LkTotal = @(L) exp( sum( log(L) ) );
% % use the SDT equation below to check the accuracy of the Monte Carlo
% % calculations
% pcfunc = @(si,variance) normcdf( si ./ sqrt(2*variance) );


%% Grid approximation: loop over many variance values
dPrior = [0.5 0.5]; % assume an unbiased observer
likelihood=zeros(size(varianceGridVals)); % preallocate
figure(1), clf
for n=1:numel(varianceGridVals)
    fprintf('%d of %d',n,numel(varianceGridVals))
    
    % Calculate PC over different si values, for this variance parameter
    % value
    % --------------------------------------------------
    pc = model3nonMCMC(varianceGridVals(n), params.sioriginal,...
		paramest.nSimulatedTrials, dPrior);
    % --------------------------------------------------
    
    % plotting
    figure(2)
    semilogx(params.sioriginal,pc','k-')
    hold on
    semilogx(params.sioriginal,...
        pcfunc( params.sioriginal, varianceGridVals(n) ),...
        'r:')
    
    legend('monte carlo','sdt')
    
    xlabel('signal intensity')
    ylabel('k/T')
    hold on
    % plot data
    plot(params.sioriginal, params.koriginal./params.T, 'ko')
    hold off
    drawnow
    

    
    % Calculate likelihood
	L = Lk(params.koriginal, params.T, pc' );
    %L =L(L~=0)  %<------ this was causing problems. Kill it.
    likelihood(n) = LkTotal( L );
    
    
    figure(1), hold off
    %plot(varianceGridVals,likelihood)
    area(varianceGridVals,likelihood,...
	'FaceColor', [0.7 0.7 0.7], ...
	'LineStyle','none')
    xlabel('\sigma^2')
    ylabel('likelihood')
    drawnow
    
    
    fprintf(' done\n')
end

%%
% Calculate the posterior. We will use a uniform prior distribution over
% the range of variance values examined. This could be evaluated as
% follows:
%%
%
%   prior = ones(numel(varianceGridVals),1)./numel(varianceGridVals);
%   posterior_var = likelihood.*prior; 
%   posterior_var = posterior_var ./sum(posterior_var); 
% 
% But it's simpler to simply normalise the likelihood...

prior_over_k = 1/params.T;  % discreet uniform prior over k.
prior_over_sigma2 = 1/1000; % continuous uniform prior (range 0-1000) over sigma2
posterior_var = likelihood .* prior_over_k .* prior_over_sigma2;

% normalise it
posterior_var = posterior_var ./sum(posterior_var);

% Calculate mode, the MAP value 
[~,index]=max(posterior_var);
vMode = varianceGridVals(index);
% Calculate 95% HDI
[HDI] = HDIofGrid(varianceGridVals,posterior_var, 0.95);

fprintf('Posterior over internal variance: mode=%2.3f (%2.3f - %2.3f)\n',...
	vMode, HDI.lower, HDI.upper)

% save the MAP estimate in a file so that model2MCMCse.m can use it
cd('output')
save('m3MAPestimate.mat', 'vMode')
cd('..')




%% MODEL PREDICTIONS in data space
% Generate a set of predictions for many signal intensity levels, beyond
% that which we have data for (sii). Useful for visualising the model's
% predictions.

% Sample from the posterior. * REQUIRES STATISTICS TOOLBOX * 
fprintf('Drawing %d samples from the posterior distribution of internal variance...',...
    predictive.nSamples)
var_samples = randsample(varianceGridVals,predictive.nSamples,true,posterior_var);
fprintf('done\n')
fprintf('Calculating model predictions in data space for sii...')
% predictive distribution
predk=zeros(predictive.nSamples,numel(params.sii)); % preallocate
for i=1:predictive.nSamples
	fprintf('%d of %d',i,predictive.nSamples)
    % --------------------------------------------------
    pc = model3nonMCMC(var_samples(i), params.sii, predictive.nSimulatedTrials, dPrior);
    % --------------------------------------------------
    predk(i,:) = binornd(params.T, pc );
end
fprintf('done\n')
% Calculate 95% CI's for each signal level
CI = prctile(predk,[5 95]) ./ params.T;
%clear predk




%% EXPORT
save(['~/Dropbox/tempModelOutputs/tempModel3run.mat'], '-v7.3')
