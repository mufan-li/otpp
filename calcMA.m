
% function MA = calcMA(M, T)
%	calculates a simple moving average
%
% inputs:
%	- M: matrix of time series values, 
%			each column representing a series
%	- T: integer, size of the slide window for computing
%			the simple moving average
%
% outputs:
%	- MA: matrix of moving average values
%
function MA = calcMA(M, T)
	T = round(T);
	[nrow_M, ncol_M] = size(M);
	MA = zeros(nrow_M, ncol_M);
	
	for i = T:nrow_M
		MA(i,:) = mean(M((i-T+1):i,:), 1);
	end
end