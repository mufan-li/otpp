
% function calcStrategyReturns2()
%	computes the return of all assets with moving average strategy
%	includes transaction cost
%
% inputs:
% 	- MA: matrix of moving average time series, 
%			each column is a series
%	- r_t: matrix of returns for each CDS series
%	- t_cost: double, transaction cost in basis points
%
% outputs:
%	- all_returns: matrix of dollar returns of trading strategy 
%			for each CDS series,
%			unit in millions of dollars
%
function all_returns = calcStrategyReturns2(MA, r_t, t_cost)
	[nrow_s, ncol_s] = size(MA);

	% determine the trading direction
	MA_sign = (MA>0) - (MA<0);

	% shift by 1 row to match the trading dates
	trades = [zeros(1,ncol_s); MA_sign(1:(nrow_s-1),:)];
	volume = [zeros(1,ncol_s); ...
				abs(trades(2:nrow_s,:) - trades(1:(nrow_s-1),:))];

	% compute returns
	all_returns = trades .* r_t - volume .* t_cost / 1e4;

	% plot volume
	figure;
	spy(volume(100:150,1:50));
	sz = 22;
	hax = gca;
	set(hax, 'FontSize', sz-2, 'TickLength', [0.02 0.05]);
	hlx = xlabel('CDS Series');
	set(hlx, 'FontSize',sz);
	hly = ylabel('Date');
	set(hly, 'FontSize',sz);
	ht = title(...
		'Sparsity of Volume Matrix');
	set(ht, 'FontSize', sz);
	
end