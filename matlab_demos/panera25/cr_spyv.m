% /a/ks/b/matlab/panera25/cr_spyv.m

% I use this script to create a table full of vectors full of features
% from a table full of dates, open-prices, and close-prices.

% Demo:
% % cp is closing-price:
% [ydate, cp, openp, lowp, highp, volume, closeadj]=StockQuoteQuery(symbl, startDate, endDate, freq);
% 
% dateprice = table();
% dateprice.ydatestr = datestr(ydate,'yyyy-mm-dd');
% dateprice.ydate    = ydate;
% dateprice.openp    = openp;
% dateprice.cp       = cp;
% 
% writetable(dateprice, 'data/dateprice.csv');

% spyv = cr_spyv(dateprice);

function spyv = cr_spyv(dateprice)

spyv = dateprice;

spyv.pctg  = 100.0*(spyv.cp - spyv.openp)./spyv.openp;
is_spyv = spyv( ( spyv.ydate < datenum( [2013 1 1] )),:);
median_pctg = median(is_spyv.pctg);
% spyv.yval  = 1+(spyv.pctg >= median_pctg);
spyv.yval  = 1+(spyv.pctg >= 0.0);

% Get the last pctg:
spyv.pctg1 = lagn(1,spyv.pctg);

% Get mvgavg of last 10 pctg1:
wndw                 = 10;
bval10               = ones(1,wndw)/wndw;
spyv.pctg1ma10       = filter(bval10, 1, spyv.pctg1);
spyv.pctg1ma10(1:10) = spyv.pctg1(1:10);

% Get mvgavg of last 100 pctg1:
wndw                   = 100;
bval100                = ones(1,wndw)/wndw;
spyv.pctg1ma100        = filter(bval100, 1, spyv.pctg1);
spyv.pctg1ma100(1:100) = spyv.pctg1(1:100);

spyv.cplag  = lagn(1, spyv.cp);
spyv.cplag2 = lagn(2, spyv.cp);

spyv.n1dg1 = (spyv.cplag - spyv.cplag2) ./ spyv.cplag2 ;
spyv.n1dg2 = lagn(1, spyv.n1dg1);
spyv.n1dg3 = lagn(1, spyv.n1dg2);

lag = 5;
wlag1 = lagn(lag, spyv.cplag);
spyv.n1wlagd = (spyv.cplag - wlag1) ./ wlag1;
spyv.n2wlagd = lagn(lag, spyv.n1wlagd);

lag = 20;
mlag1 = lagn(lag, spyv.cplag);
spyv.n1mlagd = (spyv.cplag - mlag1) ./ mlag1;
spyv.n2mlagd = lagn(lag, spyv.n1mlagd);

% cpma is my next feature, borrow params from last mvavg calculation:
mvgavg100        = filter(bval100, 1, spyv.cplag);
mvgavg100(1:100) = spyv.cplag(1:100);
spyv.cpma = spyv.cplag ./ mvgavg100;

% cplag2open is my next feature:
spyv.cplag2open = (spyv.openp - spyv.cplag) ./ spyv.cplag;

% Features calculated now.
