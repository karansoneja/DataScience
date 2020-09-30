
## ======= upload packages ====

# install.packages("devtools")
# library(devtools)
# # Install from github directly
# devtools::install_github("braverock/blotter")
# devtools::install_github("braverock/quantstrat")
library(blotter)
library(quantstrat)

## ============= set up working space ===

options("getSymbols.warning4.0"=FALSE)
from ="2008-01-01"
to ="2012-12-31"
symbols = c("AAPL", "IBM")
currency("USD")
getSymbols(symbols, from=from, to=to, 
           adjust=TRUE)
stock(symbols, currency="USD", multiplier=1) # is a function!
initEq=10^6

## ===== init account and portfolio ===

# first clean env
rm("account.buyHold",pos=.blotter)
rm("portfolio.buyHold",pos=.blotter)

# create portfolios
initPortf("buyHold", symbol=symbols)
initAcct("buyHold", portfolios = "buyHold",
         initEq = initEq)

## ========= get prices and timing data =====

Apple.Buy.Date <- first(time(AAPL))
Apple.Buy.Price <- as.numeric(Cl(AAPL[Apple.Buy.Date,]))
Apple.Sell.Date <- last(time(AAPL))
Apple.Sell.Price <- as.numeric(Cl(AAPL[Apple.Sell.Date,]))
Apple.Qty <- trunc(initEq/(2*Apple.Buy.Price))

IBM.Buy.Date <- first(time(IBM))
IBM.Buy.Price <- as.numeric(Cl(IBM[IBM.Buy.Date,]))
IBM.Sell.Date <- last(time(IBM))
IBM.Sell.Price <- as.numeric(Cl(IBM[IBM.Sell.Date,]))
IBM.Qty <- trunc(initEq/(2*IBM.Buy.Price))


## ======== add  BUY transaction ====

addTxn(Portfolio = "buyHold", 
       Symbol = "AAPL", 
       TxnDate = Apple.Buy.Date, 
       TxnQty = Apple.Qty,
       TxnPrice = Apple.Buy.Price,
       TxnFees = 0)

addTxn(Portfolio = "buyHold", 
       Symbol = "IBM", 
       TxnDate = IBM.Buy.Date, 
       TxnQty = IBM.Qty,
       TxnPrice = IBM.Buy.Price,
       TxnFees = 0)

## =========== add SELL transactions =====

addTxn(Portfolio = "buyHold", 
       Symbol = "AAPL", 
       TxnDate = Apple.Sell.Date, 
       TxnQty = -Apple.Qty,
       TxnPrice = Apple.Sell.Price,
       TxnFees = 0)

addTxn(Portfolio = "buyHold", 
       Symbol = "IBM", 
       TxnDate = IBM.Sell.Date, 
       TxnQty = -IBM.Qty,
       TxnPrice = IBM.Sell.Price,
       TxnFees = 0)


## ======= update account =========
updatePortf(Portfolio = "buyHold")
updateAcct(name = "buyHold")
updateEndEq(Account = "buyHold")

## ======= chart positions and trade stats ==============

chart.Posn("buyHold", Symbol = "AAPL")
out <- perTradeStats("buyHold", "AAPL")
t(out)

chart.Posn("buyHold", Symbol = "IBM")
out <- perTradeStats("buyHold", "IBM")
t(out)


## #################################################### ##
## ================= FILTER RULE =============================== 

options("getSymbols.warning4.0"=FALSE)
from ="2003-01-01"
to ="2012-12-31"
symbols = c("MSFT", "IBM")
getSymbols(symbols, from=from, to=to, 
           adjust=TRUE)

currency("USD")
stock(symbols, currency="USD", multiplier=1)

## define the following
strategy.st <- "filter"
portfolio.st <- "filter"
account.st <- "filter"

## clean portfolios
rm.strat("filter")


## ========= initialization ======
initEq=100000
initDate="1990-01-01"

initPortf(name=portfolio.st, 
          symbols=symbols, 
          initDate=initDate, 
          currency='USD')
initAcct(name=account.st, 
         portfolios=portfolio.st,    
         initDate=initDate, 
         currency='USD', 
         initEq=initEq)
initOrders(portfolio=portfolio.st, 
           symbols=symbols,
           initDate=initDate)

strategy(strategy.st, store=TRUE)

## ========= create filter indicator function =====
filter <- function(price) {
  lagprice <- lag(price,1)
  temp<-price/lagprice - 1
  colnames(temp) <- "filter"
  return(temp)
} 

add.indicator(
  strategy=strategy.st,
  name = "filter", 
  arguments = list(price = quote(Cl(mktdata))), 
  label= "filter")

## function sanity check 
test <-try(applyIndicators(strategy.st, 
                           mktdata=OHLC(AAPL)))
head(test, n=4)

## ========== trading signals =====

## BUY: enter when filter > 1+\delta
add.signal(strategy.st, 
           name="sigThreshold",
           arguments = list(threshold=0.05,   
                            column="filter",
                            relationship="gt",   
                            cross=TRUE),
           label="filter.buy")

## SELL: exit when filter < 1-delta
add.signal(strategy.st, 
           name="sigThreshold",
           arguments = list(threshold=-0.05, 
                            column="filter",
                            relationship="lt",
                            cross=TRUE),
           label="filter.sell") 

## ======== trading rules i.e. Order Execution  =====

## BUY
add.rule(strategy.st, 
         name='ruleSignal', 
         arguments = list(sigcol="filter.buy", 
                          sigval=TRUE,  
                          orderqty=1000,
                          ordertype='market', 
                          orderside='long',
                          pricemethod='market',
                          replace=FALSE), 
         type='enter', 
         path.dep=TRUE)

## SELL
add.rule(strategy.st, 
         name='ruleSignal', 
         arguments = list(sigcol="filter.sell",
                          sigval=TRUE, 
                          orderqty=-1000,  
                          ordertype='market',  
                          orderside='long', 
                          pricemethod='market',  
                          replace=FALSE), 
         type='enter', 
         path.dep=TRUE) 


## =========== evaluation /1 ==========
out<-try(applyStrategy(strategy=strategy.st,
                       portfolios=portfolio.st))

## update positions,and account 
updatePortf(portfolio.st)
updateAcct(portfolio.st)
updateEndEq(account.st)

## plot
for(symbol in symbols) {
  chart.Posn(Portfolio=portfolio.st,
             Symbol=symbol,
             log=TRUE)
}

## trading stats
tstats <- tradeStats(portfolio.st)
t(tstats) #transpose tstats

## ============ evaluation /2 =============
rets <- PortfReturns(Account = account.st)
rownames(rets) <- NULL
tab <- table.Arbitrary(rets,
                       metrics=c(
                         "Return.cumulative",
                         "Return.annualized",
                         "SharpeRatio.annualized",
                         "CalmarRatio"),
                       metricsNames=c(
                         "Cumulative Return",
                         "Annualized Return",
                         "Annualized Sharpe Ratio",
                         "Calmar Ratio"))
tab

## plot performance
charts.PerformanceSummary(rets, colorset = bluefocus)


## #################################################### ##
## =========== BUY AND HOLD ===============================

## 
getSymbols("SPY", from=from, to=to, adjust=TRUE)

## ======== initializie ======


initEq=100000
initDate="1990-01-01"
rm.strat("buyHold") # clean env vars

#Initial Setup
initPortf("buyHold", "SPY", initDate = initDate)
initAcct("buyHold", portfolios = "buyHold",
         initDate = initDate, initEq = initEq)

## BUY at t=0
FirstDate <- first(time(SPY))
# Enter order on the first date
BuyDate <- FirstDate
equity = getEndEq("buyHold", FirstDate)
FirstPrice <- as.numeric(Cl(SPY[BuyDate,]))
UnitSize = as.numeric(trunc(equity/FirstPrice))
addTxn("buyHold", Symbol = "SPY", 
       TxnDate = BuyDate, TxnPrice = FirstPrice,
       TxnQty = UnitSize, TxnFees = 0)

## SELL at t=T
LastDate <- last(time(SPY))
# Exit order on the Last Date
LastPrice <- as.numeric(Cl(SPY[LastDate,]))
addTxn("buyHold", Symbol = "SPY", 
       TxnDate = LastDate, TxnPrice = LastPrice,
       TxnQty = -UnitSize , TxnFees = 0)


## ======= evaluation ==========

updatePortf(Portfolio = "buyHold")
updateAcct(name = "buyHold")
updateEndEq(Account = "buyHold")
chart.Posn("buyHold", Symbol = "SPY")

## compare BH vs active trading
# Compare strategy and market
rets <- PortfReturns(Account = account.st)
rets.bh <- PortfReturns(Account = "buyHold")
returns <- cbind(rets, rets.bh)
charts.PerformanceSummary(
  returns, geometric = FALSE,
  wealth.index = TRUE, 
  main = "Strategy vs. Market")



## ##################################################### ##
## ============= SMA CROSSING RULE =======================

options("getSymbols.warning4.0"=FALSE)
from ="2012-01-01"
to ="2012-12-31"
symbols = c("IBM","MSFT")
getSymbols(symbols, from=from, to=to, 
           adjust=TRUE)

## ==== setup ========
currency("USD")
strategy.st <- portfolio.st <- account.st <- "SMA"
rm.strat(strategy.st)

initPortf(portfolio.st, symbols)
initAcct(account.st, portfolios=portfolio.st, 
         initEq = initEq)
initOrders(portfolio.st)
strategy(strategy.st, store=TRUE)

## =========== create filter indicator functions =============
add.indicator(
  strategy.st, name="SMA",
  arguments=list(x=quote(Cl(mktdata)), n=30),
  label="sma30")

add.indicator(
  strategy.st, name="SMA",
  arguments=list(x=quote(Cl(mktdata)), n=200),
  label="sma200")

## =================== trading signals ===========
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

## ========== execution ==============
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




## =========== evaluation ==========
out<-try(applyStrategy(strategy.st, 
                       portfolios=portfolio.st))


## update accounts
updatePortf(portfolio.st)
updateAcct(portfolio.st)
updateEndEq(account.st)

## plots 
for(symbol in symbols) {
  chart.Posn(Portfolio=portfolio.st,
             Symbol=symbol,log=TRUE)
}