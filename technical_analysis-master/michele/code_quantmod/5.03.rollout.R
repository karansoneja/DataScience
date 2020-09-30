## ====================== 5. BENCHMARKING ===========

# one should always buy an index fund that merely reflects the composition of the market.
# SPY is an exchange-traded fund (a mutual fund that is traded on the market like a stock) 
# whose value effectively represents the value of the stocks in the S&P 500 stock index. 
# By buying and holding SPY, we are effectively trying to match our returns with the market 
# rather than beat it.



## ref https://www.morningstar.co.uk/uk/etf/snapshot/snapshot.aspx?id=0P000018SQ
## ref https://www.investopedia.com/articles/investing/021715/france-etfs-explained-cac-40.asp
### https://www.easy.bnpparibas.fr/professional-professional/fundsheet/equity/bnp-paribas-easy-cac-40-ucits-etf-classique-d-fr0010150458/
## ref https://www.boursorama.com/bourse/trackers/cours/1rTE40/
getSymbols("E40.PA", from = from, to = to) ## too many NAs

# A crude estimate of end portfolio value from buying and holding 
initEq * (E40.PA$E40.PA.Adjusted["2018-12-28"][[1]] / E40.PA$E40.PA.Adjusted[[1]])
final.acct <- getAccount(account.st)
plot(final.acct$summary$End.Eq["2012/2018"] / 1000000,
     main = "CAC40 Tracking: E40.PA ETF", ylim = c(0.8, 2.5))
lines(E40.PA$E40.PA.Adjusted / E40.PA$E40.PA.Adjusted[[1]], col = "blue")

## 
# https://www.amundietf.fr/particuliers/product/view/LU1681046931
getSymbols("C40.MI", from = from, to = to) 
# A crude estimate of end portfolio value from buying and holding 
initEq * (C40.MI$C40.MI.Adjusted["2018-12-28"][[1]] / C40.MI$C40.MI.Adjusted[[1]])
final.acct <- getAccount(account.st)
plot(final.acct$summary$End.Eq["2012/2018"] / 1000000,
     main = "CAC40 Tracking: C40.MI ETF", ylim = c(0.8, 2.5))
lines(C40.MI$C40.MI.Adjusted / C40.MI$C40.MI.Adjusted[[1]], col = "blue")
