
% class helper
%	write helper functions as helper class methods
%
% use:
%	h = helper() % initialize class
%	h.method_name(...) % to use a helper function
%
classdef helper < handle
	properties
	end

	methods
		% initialize
		function h = helper()
		end

		% function [d_std5, d_std4] = find_std_maturity(d)
		%	finds the 5Y and 4Y standard maturity dates
		%
		% note: while the function uses for loops,
		%		run time is only ~0.06 seconds and O(n)
		%
		% inputs:
		%	- d: vector of datenum
		%
		% outputs:
		% 	- d_std5: vector of datenum, 5Y standard maturity dates
		% 	- d_std4: vector of datenum, 4Y standard maturity dates
		%	- d5: vector of datenum, 5Y exact maturity dates
		%
		function [d_std5, d_std4, d5] = find_std_maturity(h,d)

			d_str = datestr(d, 'yyyymmdd');
			d_year = str2num(d_str(:,1:4));
			d_mmdd = str2num(d_str(:,5:8));

			d_round = zeros(length(d),3);
			d_std_maturity = zeros(length(d),1);
			row_before = sum(d <= datenum(2015,9,20));

			% first round up the dates to the nearest 
			% standard maturity date
			for i = 1:row_before
				if d_mmdd(i) >= 1220
					d_round(i,:) = [d_year(i)+1,3,20];
				elseif d_mmdd(i) >= 920
					d_round(i,:) = [d_year(i),12,20];
				elseif d_mmdd(i) >= 620
					d_round(i,:) = [d_year(i),9,20];
				elseif d_mmdd(i) >= 320
					d_round(i,:) = [d_year(i),6,20];
				else
					d_round(i,:) = [d_year(i),3,20];
				end
			end

			for i = (row_before+1):length(d)
				if d_mmdd(i) >= 1220
					d_round(i,:) = [d_year(i)+1,6,20];
				elseif d_mmdd(i) >= 620
					d_round(i,:) = [d_year(i),12,20];
				else
					d_round(i,:) = [d_year(i),6,20];
				end
			end

			% move forward 4 and 5 years
			d_std5 = datenum(d_round(:,1)+5,d_round(:,2),d_round(:,3));
			d_std4 = datenum(d_round(:,1)+4,d_round(:,2),d_round(:,3));

			% also return the exact date 5 years from now
			d5 = datenum(d_year + 5, ...
						str2num(d_str(:,5:6)), ...
						str2num(d_str(:,7:8)) );
			
		end % end function

		% function c = cv01(s)
		% 	helper function to compute returns
		%
		% inputs:
		% 	- S: matrix of CDS spread
		%
		% outputs:
		%	- cv: intermediate value in return computation
		%
		function cv = cv01(h, S_int5)
			xv = [0 75 250 1000 5000];
			yv = [-0.00061 -0.00053 -0.00043 -0.00023 -0.0001];
			cv = interp1(xv, yv, S_int5,'linear','extrap');
		end % end function

		% function
		%	compute summary statistics
		%
		% inputs:
		% 	- all_returns: matrix of portfolio returns on 
		%				each CDS series (column)
		%
		% outputs:
		%	- r_total: total return in the entire period
		%	- r_yr: annualized return
		%	- r_sharpe: sharpe ratio, annualized
		%	- r_skew: skewness of daily returns
		%	- r_kurt: kurtosis of daily returns
		%
		function [r_total,r_yr,r_sharpe,r_skew,r_kurt] = summary(h, all_returns)

			portfolio_return = mean(all_returns,2);

			r_total = sum(portfolio_return);
			r_yr = mean(portfolio_return) * 252;
			r_sharpe = mean(portfolio_return) / ...
							std(portfolio_return) * sqrt(252);

			r_skew = skewness(portfolio_return); 
			r_kurt = kurtosis(portfolio_return); 

		end % end function

		% function
		%	compute summary statistics for random samples of 
		%	CDS series instead of whole portfolio
		%
		%	also plots the boxplots of sharpe ratio and 
		%	returns for the samples
		%
		% inputs:
		% 	- all_returns: matrix of portfolio returns on 
		%				each CDS series (column)
		%
		% outputs:
		%	all matrix, each row for one sample size
		%	- R_total: total return in the entire period
		%	- R_yr: annualized return
		%	- R_Sharpe: sharpe ratio, annualized
		%	- R_skew: skewness of daily returns
		%	- R_kurt: kurtosis of daily returns
		%
		function [R_total,R_yr,R_Sharpe,R_skew,R_kurt] = ...
				sample_summary(h, all_returns, sample_sizes, sample_n)

				[nrow_s, ncol_s] = size(all_returns);

				m = length(sample_sizes);
				R_total = zeros(m, sample_n);
				R_yr = zeros(m, sample_n);
				R_Sharpe = zeros(m, sample_n);
				R_skew = zeros(m, sample_n);
				R_kurt = zeros(m, sample_n);

				for i = 1:m
					for j = 1:sample_n
						sample_cds = randsample(1:ncol_s,sample_sizes(i));
						[R_total(i,j),R_yr(i,j),R_Sharpe(i,j),...
							R_skew(i,j),R_kurt(i,j)] = ...
							h.summary(all_returns(:,sample_cds));
					end
				end

				figure;
				boxplot(R_Sharpe', sample_sizes);
				sz = 22;
				hax = gca;
				set(hax, 'FontSize', sz-2, 'TickLength', [0.02 0.05]);
				hlx = xlabel('Sample Size');
				set(hlx, 'FontSize',sz);
				hly = ylabel('Sharpe Ratio');
				set(hly, 'FontSize',sz);
				ht = title(...
					'Sharpe Ratio for Samples of CDS Series');
				set(ht, 'FontSize', sz);

				figure;
				boxplot(R_yr', sample_sizes);
				sz = 22;
				hax = gca;
				set(hax, 'FontSize', sz-2, 'TickLength', [0.02 0.05]);
				hlx = xlabel('Sample Size');
				set(hlx, 'FontSize',sz);
				hly = ylabel('Annualized Return');
				set(hly, 'FontSize',sz);
				ht = title(...
					'Annualized Return for Samples of CDS Series');
				set(ht, 'FontSize', sz);

		end % end function

		function obj_val = objective(h, r_t, t_cost, MA_T, MA_tol)
			MA3 = calcMA(r_t, round(MA_T));

			% compute strategy returns
			all_returns3 = calcStrategyReturns3(MA3, r_t, t_cost, MA_tol, 0);
			[r_total,r_yr,r_sharpe,r_skew,r_kurt] = h.summary(all_returns3);

			obj_val = r_yr*100 + r_sharpe;
		end

	end % end methods
end % end class











