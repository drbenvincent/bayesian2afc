function plotChainAutocorrelationsModel2(samples)

nChains = size(samples.v,1);

cols = nChains;	% chains
rows = 3;	% variables
count= 1;

fig=4;

figure(fig), clf
plot_autocorr_for_all_chains(samples.v)
plot_autocorr_for_all_chains(samples.lr)
plot_autocorr_for_all_chains(samples.b)


figure(fig)

subplot(rows,cols, (nChains*0)+1), ylabel('\sigma^2','FontSize',16)
subplot(rows,cols, (nChains*1)+1), ylabel('\lambda','FontSize',16)
subplot(rows,cols, (nChains*2)+1), ylabel('b','FontSize',16)

for n=1:cols
	subplot(rows,cols,n)
	title(['Chain ' num2str(n)])
end



	function plot_autocorr_for_all_chains(samples)

		nchains = size(samples,1);
		lag = 200;
		
		for c=1:nchains
			subplot(rows,cols, count)
			
			acf( samples(c,:)', lag);
			
			% remove title etc
			title('')
			box off
			set(gca,'PlotBoxAspectRatio',[1.5 1 1])
			count=count+1;
		end
	end

end




