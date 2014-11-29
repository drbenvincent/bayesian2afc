function data = define_experiment_params(model)
%
% data = define_experiment_params('model1')
% data = define_experiment_params('model2')
% data = define_experiment_params('model3')

% common parameters
data.T            = 100;
data.sioriginal	= logspace(-2,2,10);
data.muN          = 0;
data.v			= 1;

% in order to conduct model prediction on si values that we do not have
% response data for, we will actually generate simulated data for all these
% additional si values now. But the data we generate will be used in step
% 2 where we only provide the model with response data for the actual si
% values run in an experiment. In other words, we are just using this step
% now to generate simulated 2AFC trial data (L) for these additional si
% values we wish to examine.
ni                      = 41;
data.sii			= logspace(-2,2,ni);


switch model
	
	case{'model1'}
        data.si		= [data.sioriginal data.sii];
		
	case{'model2'}
		data.lr		= 0.01; 	% true lapse rate
		data.b		= 0;		% true bias
		data.pdist	= [0.5 0.5];% trie spatial prior
		data.si		= [data.sioriginal data.sioriginal data.sii];
		
	case{'model3'}
		data.si		= [data.sioriginal data.sii];
		
end

return