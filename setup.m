close all; clc
addpath([cd '/funcs'])
addpath([cd '/funcs/export_fig'])
addpath([cd '/funcs/acf'])
addpath([cd '/funcs/ColorBand'])
addpath([cd '/funcs/latex_fig'])
addpath([cd '/funcs/bensUtils'])
addpath([cd '/funcs/bensPlotFunctions'])

plot_formatting_setup

% test for a known issue
try
    sum(log( binopdf(1, 2, 0.5 )));
catch
    error(sprintf('ERROR: It is likely that you have another binopdf function on your path. Use \n\t >> which binopdf\n\nto find where this is then use \n\t >> pathtool \n\nand move it down the list'))
end
