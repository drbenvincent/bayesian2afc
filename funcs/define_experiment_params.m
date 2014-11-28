function exptparams = define_experiment_params(model)
%
% exptparams = define_experiment_params('model1')
% exptparams = define_experiment_params('model2')
% exptparams = define_experiment_params('model3')

% common parameters
exptparams.T            = 100;
exptparams.sioriginal	= logspace(-2,2,10);
exptparams.muN          = 0;
exptparams.v			= 1;

% in order to conduct model prediction on si values that we do not have
% response data for, we will actually generate simulated data for all these
% additional si values now. But the data we generate will be used in step
% 2 where we only provide the model with response data for the actual si
% values run in an experiment. In other words, we are just using this step
% now to generate simulated 2AFC trial data (L) for these additional si
% values we wish to examine.
ni                      = 41;
exptparams.sii			= logspace(-2,2,ni);


switch model
	
	case{'model1'}
        exptparams.si		= [exptparams.sioriginal exptparams.sii];
		
	case{'model2'}
		exptparams.lr		= 0.01; 	% true lapse rate
		exptparams.b		= 0;		% true bias
		exptparams.pdist	= [0.5 0.5];% trie spatial prior
		exptparams.si		= [exptparams.sioriginal exptparams.sioriginal exptparams.sii];
		
	case{'model3'}
		exptparams.si		= [exptparams.sioriginal exptparams.sii];
		
end

return