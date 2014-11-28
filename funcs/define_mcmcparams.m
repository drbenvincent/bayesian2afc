function mcmcparams = define_mcmcparams(model,varargin)
%
% mcmcparams = define_mcmcparams('model1')
% mcmcparams = define_mcmcparams('model3')
% mcmcparams = define_mcmcparams('model2',T)


% Parallel use of multiple CPU cores
mcmcparams.doparallel = 1;

 % How many cores do we have?
 numOfCores= feature('numcores');
 
% Set up access to use multiple CPU cores
try
	if isempty(gcp('nocreate'))==1
		% Enable use of multiple cores
		parpool
	end
catch
	% for whatever reason, we have failed at setting up use of multiple
	% cores, so revert to non-parallel
	mcmcparams.doparallel = 0;
	numOfCores=1; % just use one core.
end 


switch model
    case{'model1'}
        
		mcmcparams.JAGSmodel = 'jagsmodels/model1JAGS.txt';
		
        % 1) Dataset generation - only used if we are generating new
        % simulated behavioural data, not when we are loading pre-computed
        % data.
        mcmcparams.generate.nchains     = 1;
        mcmcparams.generate.nburnin     = 1000;
        mcmcparams.generate.nsamples    = mcmcparams.generate.nburnin + 1;
        
        % 2) Parameter recovery
        mcmcparams.infer.nchains    = numOfCores;
        mcmcparams.infer.nburnin    = 500;  % 500
        total_samples               = 10^6; % 10^7 in paper
        mcmcparams.infer.nsamples	= round(total_samples/mcmcparams.infer.nchains);
        
    case{'model3'}
        
        %T=varargin{1};
		
		% NUMBER OF TRIALS TO SIMULATE
		T = 100;                           % 2000 in paper ???
		
		mcmcparams.JAGSmodel = 'jagsmodels/model3JAGS.txt';
        
        % 1) Dataset generation - always used
        mcmcparams.generate.nchains = 2;    % 2
        mcmcparams.generate.nburnin = 500;  % 500
        mcmcparams.generate.nsamples = T;   % number of trials to simulate
        
        % 2) Parameter recovery
        mcmcparams.infer.nchains = numOfCores;       % 2
        mcmcparams.infer.nburnin = 500;    % 1000
        %mcmcparams.infer.nsamples = round(4000/mcmcparams.infer.nchains);
        total_samples = 10^3;               % 10^4
        mcmcparams.infer.nsamples = round(total_samples/mcmcparams.infer.nchains);
        
    case{'model2'}
        
        T=varargin{1};
		
		mcmcparams.JAGSmodel = 'jagsmodels/model2JAGS.txt';
        
        % 1) Dataset generation - only used if we are generating new
        % simulated behavioural data, not when we are loading pre-computed
        % data.
        mcmcparams.generate.nchains = 1;
        mcmcparams.generate.nburnin = 500;
        mcmcparams.generate.nsamples = T;
        
        % 2) Parameter recovery
        mcmcparams.infer.nchains = numOfCores;	% 4
        mcmcparams.infer.nburnin = 1000;        % 1000
		% TOTAL SAMPLES:
		% 10^6 takes ~4-5 hours ??
		% 10^5 takes ~25 mins on my quadcore iMac
        total_samples    = 10^4;                % 10^5 in paper
        mcmcparams.infer.nsamples = round(total_samples/mcmcparams.infer.nchains);        
end

return