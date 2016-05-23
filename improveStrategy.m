
% function [max_tol_list,r_total_list,r_yr_list,...
%			r_sharpe_list,r_skew_list,r_kurt_list] = ...
%			improveStrategy(r_t, MA_T_list, t_cost)
%
%	optimize the trend following strategy based on 
%	both moving average length and tolerance
%	with transaction cost using in-sample data,
%	and returns the summary for out-of-sample tests.
%
%	also plots the sparsity of volume matrices for 
%	the first two values of moving average lengths.
%
% inputs:
%	- r_t: matrix of returns for each CDS series
%	- MA_T_list: list of integers, moving average lengths
%	- t_cost: double, transaction cost in basis points
%
%
% outputs:
%	- max_tol_list: list of optimal tolerance 
%	- r_total_list: list of total portfolio return 
%	- r_yr_list: list of annualized portfolio return
%	- r_sharpe_list: list of Sharpe ratios, annualized
%	- r_skew_list: list of portfolio daily return skewness
%	- r_kurt_list: list of portfolio daily return kurtosis
%
function [max_tol_list,r_total_list,r_yr_list,...
			r_sharpe_list,r_skew_list,r_kurt_list] = ...
			improveStrategy(r_t, MA_T_list, t_cost)

	% import helper functions
	h = helper();
	[nrow_s, ncol_s] = size(r_t);
	% set in-sample size
	nrow_t = round(nrow_s/2);
	ncol_t = round(ncol_s/2);

	m = length(MA_T_list);
	max_tol_list = zeros(m,1);
	r_total_list = zeros(m,1);
	r_yr_list = zeros(m,1);
	r_sharpe_list = zeros(m,1);
	r_skew_list = zeros(m,1);
	r_kurt_list = zeros(m,1);
	for i = 1:m
		MA_T = MA_T_list(i);
		f = @(MA_tol) h.objective(r_t(1:nrow_t,1:ncol_t), t_cost, MA_T, MA_tol);
		[max_tol, f_max] = fminbnd(@(MA_tol) -f(MA_tol), 0, 0.01);
		max_tol_list(i) = max_tol;

		% compute strategy returns
		MA3 = calcMA(r_t, MA_T);
		all_returns3 = calcStrategyReturns3(...
					MA3((nrow_t+1):nrow_s, (ncol_t+1):ncol_s), ...
					r_t((nrow_t+1):nrow_s, (ncol_t+1):ncol_s), ...
					t_cost, max_tol, i<=2);
		[r_total_list(i),r_yr_list(i),r_sharpe_list(i),...
			r_skew_list(i),r_kurt_list(i)] = h.summary(all_returns3);
	end

end