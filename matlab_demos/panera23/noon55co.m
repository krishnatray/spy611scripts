% /a/ks/b/matlab/panera23/noon55co.m

% I use this script to issue close-to-open predictions of SPY at 12:55.

% Get some data:

startDate = datenum( [ 1993 1 1 ] );
endDate = now;
symbl = 'SPY';
freq = 'd';

% cp is closing-price:
[ydate, cp, openp, lowp, highp, volume, closeadj] = StockQuoteQuery(symbl, startDate, endDate, freq);

dateprice = table();
dateprice.ydatestr = datestr(ydate,'yyyy-mm-dd');
dateprice.ydate    = ydate;
dateprice.openp    = openp;
dateprice.cp       = cp;

writetable(dateprice, 'data/dateprice.csv');

dateprice = readtable('data/dateprice.csv');

new_lastrow = table();
noon55price;
% Add estimated closing price I expect to see in 5 minutes:
new_lastrow.ydatestr = noon55_datestr;
new_lastrow.ydate    = noon55_date;
new_lastrow.openp    = noon55_openp;
new_lastrow.cp       = noon55_price;

new_dateprice = vertcat(dateprice, new_lastrow);

% Create vectors from dates and prices:
spyv = cr_spyv(new_dateprice);

% Now work towards collecting initial predictions
% where each prediction comes from 20 years of training observations:

myfeatures = {...
'cpma'
,'ocg'
,'n1dg1'
,'n1dg2'
,'n1dg3'
,'n1wlagd'
,'n2wlagd'
,'n1mlagd'
,'n2mlagd'
}' ;

ip20yr = table();
for yr = (2013:2014)
  ip20yr = vertcat(ip20yr, co_ip4yr(yr,spyv, myfeatures));
end

% Report on initial-prediction effectiveness:
myiprpt = rpt_ip(ip20yr);

% Make copy of spyv and cut it into 3 pieces:
% boundry3 ... piece3 ... boundry2 ... piece2 ... boundry1 ... piece1 ... end
boundry1 = rowcount(spyv) - 100;
boundry2 = round(boundry1/2);
boundry3 = 1;

piece1 = spyv(boundry1:end,      :);
piece2 = spyv(boundry2:boundry1, :);
piece3 = spyv(boundry3:boundry2, :);

% Use piece3 to predict both piece2 and piece1.
prdct2 = prdct(piece3, piece2, myfeatures);
prdct1 = prdct(piece3, piece1, myfeatures);

% Add 2 new features to copies of piece2 and piece1
isdata2  = prdct2;
oosdata1 = prdct1;

% upprob will get overwritten soon:
isdata2.upprob1  = isdata2.upprob;
oosdata1.upprob1 = oosdata1.upprob;

% Calculate corrp feature for both
corrp_rowcount = 9;
% corrp_rowcount tells cr_corrp() number of rows to look backwards during calls to corr():
isdata2.corrp  = cr_corrp(isdata2.upprob , isdata2.pctg , corrp_rowcount);
oosdata1.corrp = cr_corrp(oosdata1.upprob, oosdata1.pctg, corrp_rowcount);

myfeatures2 = [myfeatures, {'upprob1', 'corrp'}];

% Use isdata2 to predict oosdata1:
lr2lr_predictions         = prdct(isdata2, oosdata1, myfeatures2);
lr2lr_predictions.upprob2 = lr2lr_predictions.upprob;

% Report on lr2lr-prediction effectiveness:
my_lr2lr_rpt = rpt_lr2lr(lr2lr_predictions);

% done
