options("getSymbols.warning4.0"=FALSE)
from ="2012-01-01"
to ="2012-12-31"
symbols = c("IBM","MSFT")
getSymbols(symbols, from=from, to=to, 
           adjust=TRUE)
initEq = 10^6


currency("USD")
strategy.st <- portfolio.st <- account.st <- "SMA"
rm.strat(strategy.st)

initPortf(portfolio.st, symbols)
initAcct(account.st, portfolios=portfolio.st, 
         initEq = initEq)
initOrders(portfolio.st)
strategy(strategy.st, store=TRUE)





add.indicator(
  strategy.st, name="SMA",
  arguments=list(x=quote(Cl(mktdata)), n=30),
  label="sma30")

add.indicator(
  strategy.st, name="SMA",
  arguments=list(x=quote(Cl(mktdata)), n=200),
  label="sma200")


# Bull market if SMA30>SMA200
add.signal(
  strategy.st, 
  name="sigComparison",
  arguments=list(columns=c("sma30","sma200"),
                 relationship="gt"),
  label="buy")

# Sell market if SMA30<SMA200
add.signal(
  strategy.st, 
  name="sigComparison",
  arguments=list(columns=c("sma30","sma200"), 
                 relationship="lt"), 
  label="sell")




# Buy Rule
add.rule(strategy.st, 
         name='ruleSignal', 
         arguments = list(sigcol="buy", 
                          sigval=TRUE,  
                          orderqty=1000, 
                          ordertype='market', 
                          orderside='long', 
                          pricemethod='market', 
                          replace=FALSE), 
         type='enter', 
         path.dep=TRUE)

# Sell Rule
add.rule(strategy.st, 
         name='ruleSignal', 
         arguments = list(sigcol="sell", 
                          sigval=TRUE,  
                          orderqty='all', 
                          ordertype='market', 
                          orderside='long', 
                          pricemethod='market', 
                          replace=FALSE), 
         type='exit', 
         path.dep=TRUE) 


out<-try(applyStrategy(strategy.st, 
                       portfolios=portfolio.st))

  