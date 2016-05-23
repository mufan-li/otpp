
% function calcStrategyReturns3()
%	computes the return of all assets with moving average strategy
%	includes transaction cost
%
% inputs:
% 	- MA: matrix of moving average time series, 
%			each column is a series
%	- r_t: matrix of returns for each CDS series
%	- t_cost: double, transaction cost in basis points
%	- MA_tol: double, tolerance on moving average
%	- plot_volume: bool, whether or not to plot sparsity of volume matrix
%
%
% outputs:
%	- all_returns: matrix of dollar returns of trading strategy 
%			for each CDS series,
%			unit in millions of dollars
%
function all_returns = calcStrategyReturns3(MA, r_t, t_cost, MA_tol, plot_volume)
	[nrow_s, ncol_s] = size(MA);

	% determine the trading direction
	MA_sign = (MA > MA_tol) - (MA < -MA_tol);

	% fill zeros with previous value
	% 	here uses cumulative sum of non-zero indices (in binary) 
	% 	to find the previous index
	for i = 1:ncol_s
		idx = (MA_sign(:,i) ~= 0); % non-zero
		MA_sign_r = [0; MA_sign(idx,i)]; % non-zero, with leading zero
		%use cumsum to build index into MA_sign_r
		MA_sign(:,i) = MA_sign_r(cumsum(idx)+1); 
	end

	% shift by 1 row to match the trading dates
	trades = [zeros(1,ncol_s); MA_sign(1:(nrow_s-1),:)];

	% compute trading volume
	volume = [zeros(1,ncol_s); ...
				abs(trades(2:nrow_s,:) - trades(1:(nrow_s-1),:))];

	% compute returns
	all_returns = trades .* r_t - volume .* t_cost / 1e4;

	% plot volume
	if plot_volume
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

end