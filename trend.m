% trend.m
% - implements back testing of a trend following strategy

data5y = csvread('data5Y.CSV');
data4y = csvread('data4Y.CSV');

h = helper(); % import helper functions

[nrow, ncol] = size(data5y);
d = data5y(:,1); % date vector
s5 = data5y(:,2:ncol);
s4 = data4y(:,2:ncol);

% compute interpolation and difference
[Sd, S_int5] = cdsDiff(d, s5, s4);

% compute CDS returns
r_t = calcCDSReturns(Sd, S_int5, d);

% compute moving average
MA = calcMA(r_t, 10);

% compute strategy returns
all_returns = calcStrategyReturns(MA, r_t);
[r_total,r_yr,r_sharpe,r_skew,r_kurt] = h.summary(all_returns);
[r_total,r_yr,r_sharpe,r_skew,r_kurt]
% negative skew -0.2167
% kurtosis 14.48, greater than t-dist(5)

% generate random samples
sample_sizes = [5,10,25,50,100,200,ncol-1];
sample_n = 50;
[R_total,R_yr,R_Sharpe,R_skew,R_kurt] = ...
				h.sample_summary(all_returns, sample_sizes, sample_n);

% compute strategy returns with transaction cost
all_returns2 = calcStrategyReturns2(MA, r_t, 5.41);
[r_total,r_yr,r_sharpe,r_skew,r_kurt] = h.summary(all_returns2);
[r_total,r_yr,r_sharpe,r_skew,r_kurt]

%%%%%%%%%%%%%%%%%%%%
% improve strategy %
%%%%%%%%%%%%%%%%%%%%

t_cost = 20;
MA_T_list = [3 5 7 10 15 20 30 50];

[max_tol_list,r_total_list,r_yr_list,r_sharpe_list,...
	r_skew_list,r_kurt_list] = improveStrategy(r_t, MA_T_list, t_cost);

