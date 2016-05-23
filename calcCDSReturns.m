
% function r_t = calcCDSReturns(Sd, S_int5)
% 	computes the return of CDS spreads
%
% inputs:
%	- Sd: matrix of 5Y exact CDS spread differences,
%			computed by interpolating the 5Y and 4Y standards,
%			each column represents a series
%	- S_int5: matrix of 5Y exact CDS spreads,
%			computed also by interpolating the standards
%	- d: vector date nums, corresponding to the CDS spreads
%
% outputs:
%	- r_t: matrix of 5Y exact CDS spread returns,
%			approximated by formula in part 3
%
function r_t = calcCDSReturns(Sd, S_int5, d)

	% include helper functions
	h = helper();

	[nrow_s, ncol_s] = size(Sd);

	% compute cv01 by interpolation
	cv = h.cv01( S_int5(1:(nrow_s-1),:) );
	date_dif = d(2:nrow_s) - d(1:(nrow_s-1));
	date_dif_mat = repmat(date_dif, 1, ncol_s);

	% add zero row by convention
	r_t = [zeros(1,ncol_s);
			cv .* Sd(2:nrow_s,:) + ...
			S_int5(1:(nrow_s-1),:) .* date_dif_mat / (1e4 * 365)];

end