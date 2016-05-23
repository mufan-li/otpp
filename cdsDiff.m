
% function Sd = cdsDiff(d, s5, s4)
% 	calculates the spread change of that contract
%	from d_{i-1} to d_i
%
% inputs:
%	- d: vector of datenum, corresponding to the CDS spreads
%	- s5: matrix of standard 5Y spreads, 
%			each column representing a series
%	- s4: matrix of standard 4Y spreads
%
% outputs:
%	- Sd: matrix of change in the 5Y spread from d_{i-1} to d_i
%			for CDS series j, each column representing a series
%	- S_int5: matrix of CDS spreads for 5Y exact maturity
%
function [Sd, S_int5] = cdsDiff(d, s5, s4)

	% include helper functions
	h = helper();
	[nrow_s, ncol_s] = size(s5);

	% find the standard and exact maturity dates in datenum
	% 	used for interpolation
	[d_std5, d_std4, d5] = h.find_std_maturity(d);

	% compute the constants used for linear interpolation
	w5 = (d5 - d_std4) ./ (d_std5 - d_std4); % weight for standard 5Y
	w5 = repmat(w5, 1, ncol_s);
	w4 = (d_std5 - d5) ./ (d_std5 - d_std4);
	w4 = repmat(w4, 1, ncol_s);

	% checked using interp1
	S_int5 = w4 .* s4 + w5 .* s5;

	% compute the difference
	% 	set first row to zero as required by convention
	% 	zero row allows the dates to match
	Sd = [zeros(1,ncol_s); S_int5(2:nrow_s,:) - S_int5(1:(nrow_s-1),:)];

end
