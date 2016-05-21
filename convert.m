% convertible bond test

StartDates = 'May-20-2016';
EndDates = 'May-20-2021';
Sigma = 0.3;
Price = 20;
Rf = 0.0125;

RateSpec = intenvset('ValuationDate',StartDates,'StartDates',StartDates, ...
					'EndDates',EndDates,'Rates',Rf,'Compounding',-1, ...
					'Basis',1);
StockSpec = stockspec(Sigma,Price);

Settle = 'May-20-2016';
Maturity = 'May-20-2021';
NumSteps = 100;
TimeSpec = crrtimespec(Settle,Maturity,NumSteps);

CRRT = crrtree(StockSpec,RateSpec,TimeSpec);

CouponRate = 0.03;
Period = 2;
ConvRatio = 3.7;

[CbMatrix, UndMatrix, DebtMatrix, EqtyMatrix] = ...
	cbprice(Rf, 0, Sigma, Price, ConvRatio, ...
		NumSteps, StartDates, Settle, Maturity, CouponRate, ...
		'Basis', 1);
CbMatrix(1,1)

% [Price, PriceTree, EqtTree, DbtTree] = ...
% 	cbondbycrr(CRRT, CouponRate, Settle, Maturity, ConvRatio, ...
% 				'Period',Period)