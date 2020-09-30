
## ~~ Blotter's functions build and manipulate objects that are stored in 
## an environment named ".blotter". Use ls(envir=.blotter) to show them.

## ======= upload packages ====

# install.packages("devtools")
# library(devtools)
# # Install from github directly
# devtools::install_github("braverock/blotter")
# devtools::install_github("braverock/quantstrat")
library(blotter)
library(quantstrat)

## ============= set up working space ===



# quantmod::getSymbols(c("AIR.PA","MC.PA"),src = 'yahoo',
#                     from = "2012-12-28",to = "2018-12-31",
#                     auto.assign = TRUE, warnings = FALSE )


symbols = c("AIR.PA", "MC.PA")
options("getSymbols.warning4.0"=FALSE)

from = "2012-12-28"
to = "2018-12-31"
# from ="2008-01-01"
# to ="2012-12-31"

currency("EUR")
getSymbols(symbols, from=from, to=to, 
           adjust=TRUE)
stock(symbols, currency="EUR", multiplier=1) # is a function!
initEq=10^6 ### 1 Million

## ===== init account and portfolio ===

# first clean env
rm("account.buyHold",pos=.blotter)
rm("portfolio.buyHold",pos=.blotter)

## create portfolio and account
## both not shown in environmement
# print('Creating portfolio \"buyHold\"...')
initPortf("buyHold", symbol=symbols)
# print('Creating account \"buyHold\"...')
initAcct("buyHold", portfolios = "buyHold",
         initEq = initEq) # name account, specify linked portfolio and capital to invest

## ======== 1. NAIVE BUY AND HOLD STRATEGY ======
## ========= get prices and timing data =====

AirFrance.Buy.Date <- first(time(AIR.PA))
AirFrance.Buy.Price <- as.numeric(Cl(AIR.PA[AirFrance.Buy.Date,]))
AirFrance.Sell.Date <- last(time(AIR.PA))
AirFrance.Sell.Price <- as.numeric(Cl(AIR.PA[AirFrance.Sell.Date,]))
AirFrance.Qty <- trunc(initEq/(2*AirFrance.Buy.Price)) # half the money in AirFrance

MC.PA.Buy.Date <- first(time(MC.PA))
MC.PA.Buy.Price <- as.numeric(Cl(MC.PA[MC.PA.Buy.Date,]))
MC.PA.Sell.Date <- last(time(MC.PA))
MC.PA.Sell.Price <- as.numeric(Cl(MC.PA[MC.PA.Sell.Date,]))
MC.PA.Qty <- trunc(initEq/(2*MC.PA.Buy.Price)) # Half the money in LVMH


## ======== add  BUY transaction to the portfolio records ====

addTxn(Portfolio = "buyHold", 
       Symbol = "AIR.PA", 
       TxnDate = AirFrance.Buy.Date, 
       TxnQty = AirFrance.Qty,
       TxnPrice = AirFrance.Buy.Price,
       TxnFees = 0)

addTxn(Portfolio = "buyHold", 
       Symbol = "MC.PA", 
       TxnDate = MC.PA.Buy.Date, 
       TxnQty = MC.PA.Qty,
       TxnPrice = MC.PA.Buy.Price,
       TxnFees = 0)

## =========== add SELL transactions =====

addTxn(Portfolio = "buyHold", 
       Symbol = "AIR.PA", 
       TxnDate = AirFrance.Sell.Date, 
       TxnQty = -AirFrance.Qty,
       TxnPrice = AirFrance.Sell.Price,
       TxnFees = 0)

addTxn(Portfolio = "buyHold", 
       Symbol = "MC.PA", 
       TxnDate = MC.PA.Sell.Date, 
       TxnQty = -MC.PA.Qty,
       TxnPrice = MC.PA.Sell.Price,
       TxnFees = 0)


## ======= update account =========
updatePortf(Portfolio = "buyHold")
updateAcct(name = "buyHold")
updateEndEq(Account = "buyHold")

## ======= chart positions and trade stats ==============

blotter::chart.Posn("buyHold", Symbol = "AIR.PA")
out <- blotter::perTradeStats("buyHold", "AIR.PA")
t(out)

chart.Posn("buyHold", Symbol = "MC.PA")
out <- perTradeStats("buyHold", "MC.PA")
t(out)


## #################################################### ##
## ================= 2. FILTER RULE =============================== 

options("getSymbols.warning4.0"=FALSE)
from ="2003-01-01"
to ="2012-12-31"
symbols = c("AIR.PA", "MC.PA")
getSymbols(symbols, from=from, to=to, 
           adjust=TRUE)

currency("EUR")
stock(symbols, currency="EUR", multiplier=1)

##  make some things to remove
strategy.st <- "filter"
portfolio.st <- "filter"
account.st <- "filter"
## Now remove them before next session
rm.strat("filter")


## ========= initialization of new account, and portfolio ======
initEq=100000
initDate="1990-01-01" ## 	A date prior to the first close price given, used to contain initial account equity and initial position

print('Creating portfolio \"filter\" ')
initPortf(name=portfolio.st, 
          symbols=symbols, 
          initDate=initDate, 
          currency='EUR')
print('Creating account \"filter\" ' )
initAcct(name=account.st, 
         portfolios=portfolio.st,    
         initDate=initDate, 
         currency='EUR', 
         initEq=initEq)
print('Order container for portfolio \"filter\" ')
initOrders(portfolio=portfolio.st, 
           symbols=symbols,
           initDate=initDate)
print('Creating strategy object ')
strategy(strategy.st, store=TRUE)

## ========= create filter indicator function =====
filter <- function(price) {
  lagprice <- lag(price,1)
  temp<-price/lagprice - 1
  colnames(temp) <- "filter"
  return(temp)
} 

## add to the strategy object 
add.indicator(
  strategy=strategy.st,
  name = "filter", 
  arguments = base::list(price = base::quote(Cl(mktdata))), 
  label= "filter") #  is variable assigned to this indicator, which implies it must be unique.

## function sanity check 
test <-base::try(applyIndicators(strategy.st, 
                           mktdata=OHLC(AIR.PA)))
head(test, n=4)

## ========== trading strategy signals =====

## BUY: enter when filter > 1+delta
add.signal(strategy.st, 
           name="sigThreshold",
           arguments = list(threshold=0.05,   
                            column="filter",
                            relationship="gt", # greater than
                            cross=TRUE),
           label="filter.buy")

## SELL: exit when filter < 1-delta
add.signal(strategy.st, 
           name="sigThreshold",
           arguments = list(threshold=-0.05, 
                            column="filter",
                            relationship="lt", # less than
                            cross=TRUE),
           label="filter.sell") 

## ======== trading rules i.e. Execution of  signals through rules =====

## BUY
add.rule(strategy.st, 
         name='ruleSignal', 
         # here are the signals from above
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

## visualize the trading position, profit and loss, and drawdown
for(symbol in symbols) {
  chart.Posn(Portfolio=portfolio.st,
             Symbol=symbol,
             log=TRUE)
}

## trading stats
tstats <- tradeStats(portfolio.st)
t(tstats) #transpose tstats

## ============ evaluation /2 with PerformanceAnalytics pkg =============

rets <- PortfReturns(Account = account.st) # calls in glob.env the account timeseries
rownames(rets) <- NULL
tab <- table.Arbitrary(rets, # function creating a table of statistics
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

## plot performance of the trading rule
charts.PerformanceSummary(rets, colorset = bluefocus)


## #################################################### ##
## =========== 3. buyAndHold vs Active management ===============================

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
## ============= 4. SMA CROSSING RULE =======================

options("getSymbols.warning4.0"=FALSE)
from ="2012-01-01"
to ="2012-12-31"
symbols = c("MC.PA","AIR.PA")
getSymbols(symbols, from=from, to=to, 
           adjust=TRUE)

## ==== setup ========
currency("EUR")
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

## ========== execution of the signals ==============
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




## ############################################################## ##
## ============= 5. SMA rule and volatility filter ==============


# Buy every day when
# SMA30 SMA200 and
# 52 period standard deviation of close prices is less than its median over the last N periods.
# Sell everything when
# SMA30 SMA200

## download data 

## ============= setup  ======
strategy.st <- portfolio.st <- account.st <- "SMAv"
rm.strat("SMAv")

initPortf(portfolio.st, symbols=symbols,
          initDate=initDate, currency='USD')
initAcct(account.st, portfolios=portfolio.st, 
         initDate=initDate, currency='USD',
         initEq=initEq)
initOrders(portfolio.st, initDate=initDate)
strategy(strategy.st, store=TRUE)

## ========== add indicators =========

## create  function apt to the trading signaling
RB <- function(x,n){
  x <- x
  sd <- runSD(x, n, sample= FALSE)
  med <- runMedian(sd,n)
  mavg <- SMA(x,n)
  signal <- ifelse(sd < med & x > mavg,1,0)
  colnames(signal) <- "RB"
  reclass(signal,x)
}


## add indicators to the strategy // notice only last one is totally new
add.indicator(
  strategy.st, name="SMA",
  arguments=list(x=quote(Cl(mktdata)), n=30),
  label="sma30")

add.indicator(
  strategy.st, name="SMA",
  arguments=list(x=quote(Cl(mktdata)), n=200),
  label="sma200")

add.indicator(
  strategy.st, name="RB",
  arguments=list(x=quote(Cl(mktdata)), n=200),
  label="RB")


## ============= generate signals out of indicators =====

# Bull market if RB>=1
add.signal(strategy.st, 
           name="sigThreshold", 
           arguments = list(threshold=1, column="RB",
                            relationship="gte",
                            cross=TRUE),
           label="buy")

# Sell market if SMA30<SMA200
add.signal(strategy.st, 
           name="sigComparison",
           arguments=list(columns=c("sma30","sma200"), 
                          relationship="lt"), 
           label="sell")


## ================ exploit signals to operate on the markets =======

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

## ========= evaluation ========

out<-try(applyStrategy(strategy.st,
                       portfolios=portfolio.st))

## update the accounts
updatePortf(portfolio.st)
updateAcct(portfolio.st)
updateEndEq(account.st)

## plot the position(s)
chart.Posn(Portfolio=portfolio.st,
           Symbol="IBM",
           log=TRUE)

## can make further evaluations as above