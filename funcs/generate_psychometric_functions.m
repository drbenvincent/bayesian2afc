function generate_psychometric_functions

% Initial setting up
clear, close all; clc    
addpath([cd '/funcs'])
addpath([cd '/funcs/export_fig'])

%% Define anonymous functions
pc = @(muS,muN,variance) normcdf( muS ./ sqrt(2*variance) );
%Lk = @(k,T,pc) binopdf(k , T, pc);
%LkTotal = @(L) exp( sum( log(L) ) );


muN=0;
muS=logspace(-2,1,500);

v=[0.5, 1, 2]; % variance

for n=1:numel(v)
    performance(:,n) = pc(muS,muN,v(n))*100;
end

h = semilogx(muS,performance,'LineWidth',3);

% set line colour
set(h(1),'Color',[0.25 0.25 0.25])
set(h(2),'Color',[0.5 0.5 0.5])
set(h(3),'Color',[0.75 0.75 0.75])

% formatting
set(gca,'XScale','log',...
    'PlotBoxAspectRatio',[1 1 1],...
    'box', 'off',...
    'xlim', [0.009 10],...
    'ylim', [49 101],...
    'XTick',[0.01 0.1 1, 10],...
    'YTick',[0:10:100],...
    'PlotBoxAspectRatio',[2 1 1],...
    'TickDir','out')
xlabel('signal intensity')
ylabel('percent correct')

% Legend
legend(num2str(v'),...
    'Location', 'SouthEast')
legend boxoff

%% Export
figure(1)
% Automatic resizing to make figure appropriate for font size
latex_fig(12, 5, 3)

% Export in .fig and .pdf
cd('figs')
hgsave('psychometric_funcs')
export_fig psychometric_funcs -pdf -m1
cd('..')
return
