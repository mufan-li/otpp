
% function calcStrategyReturns()
%	computes the return of all assets with moving average strategy
%
% inputs:
% 	- MA: matrix of moving average time series, 
%			each column is a series
%	- r_t: matrix of returns for each CDS series
%
% outputs:
%	- all_returns: matrix of dollar returns of trading strategy 
%			for each CDS series,
%			unit in millions of dollars
%
function all_returns = calcStrategyReturns(MA, r_t)
	[nrow_s, ncol_s] = size(MA);

	% determine the trading direction
	MA_sign = (MA>0) - (MA<0);

	% shift by 1 row to match the trading dates
	trades = [zeros(1,ncol_s); MA_sign(1:(nrow_s-1),:)];

	% compute returns
	all_returns = trades .* r_t;
end