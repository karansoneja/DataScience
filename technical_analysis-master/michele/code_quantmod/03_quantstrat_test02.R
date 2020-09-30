
## ~~ Blotter's functions build and manipulate objects that are stored in 
## an environment named ".blotter". Use ls(envir=.blotter) to show them.

## --> aggiungi trading rules 
## --> crea charts con performanceAnalytics per avere tutti i ritorni insieme // 
## consider using highchart as well

## ======= upload packages ====

library(blotter)
library(quantstrat)
library(IKTrading)

## ============= 0. set up working space =========

symbols = c("AIR.PA", "MC.PA")
options("getSymbols.warning4.0"=FALSE)

from = "2012-12-28"
to = "2018-12-31"

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
print('Creating portfolio \"buyHold\"...')
initPortf("buyHold", symbol=symbols)
print('Creating account \"buyHold\"...')
initAcct("buyHold", portfolios = "buyHold",
         initEq = initEq) # name account, specify linked portfolio and capital to invest

## ======== 1. NAIVE BUY AND HOLD STRATEGY ======
## ========= get prices and timing data =====



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


## ========= 0. initialization of new account,  portfolio, and order container ======
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

## ========= 1. create filter indicator function =====
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

## ========== 2. trading strategy signals =====

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

## ======== 3. trading rules i.e. Execution of  signals through rules =====

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



## ============ 4. evaluation /2 with PerformanceAnalytics pkg =============

rets <- blotter::PortfReturns(Account = account.st) # calls in glob.env the account timeseries
rownames(rets) <- NULL
tab <- PerformanceAnalytics::table.Arbitrary(rets, # function creating a table of statistics
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
PerformanceAnalytics::charts.PerformanceSummary(rets, colorset = bluefocus)






## ##################################################### ##
## =============  4. SMA CROSSING RULE =======================


## ref: https://github.com/R-Finance/quantstrat/blob/master/demo/macd.R
## correct for TZ issues if they crop up
# oldtz<-Sys.getenv('TZ')
# if(oldtz=='') {
#   Sys.setenv(TZ="GMT")
# }


options("getSymbols.warning4.0"=FALSE)
from ="2012-12-28"
to ="2018-12-31"
symbols = c("MC.PA","AIR.PA")
getSymbols(symbols, from=from, to=to, 
           adjust=TRUE)

## ==== 0. setup: portfolio, account, order, strategy========
currency("EUR")
print("Set capital to 100,000 Euros ")
initEq=10^5
initDate="1990-01-01" ## 	A date prior to the first close price given, used to contain initial account equity and initial position

strategy.st <- portfolio.st <- account.st <- "Michele1"
rm.strat(strategy.st) # clean up any past residuals

## initialize
print("initalize portfolio ")
initPortf(portfolio.st, 
          symbols)
print("initalize account  ")
initAcct(account.st, 
         portfolios=portfolio.st, 
         initEq = initEq)
print("initalize order container  ")
initOrders(portfolio.st)


## why not adding limits to the positions taken ?
# addPosLimit(portfolio = strategy.st, 
#             symbol = "SPY", 
#             timestamp = start_date, 
#             maxpos = 200, 
#             longlevels = 2)
strategy(strategy.st, store=TRUE)

## =========== 1. create filter indicator functions =============
## 1. 
quantstrat::add.indicator(
  strategy.st, name="SMA", ## name must correspond to an R function 
  arguments=list(x=quote(Cl(mktdata)), n=50),
  label="sma50")

## 2.
add.indicator(
  strategy.st, name="SMA",
  arguments=list(x=quote(Cl(mktdata)), n=200),
  label="sma200")

## 3.
# ref https://statsmaths.github.io/stat395-f17/assets/final_project/amarnani.html
add.indicator(strategy = strategy.st,
              name = 'RSI',
              arguments = list(price = quote(Cl(mktdata)), n=14),
              label = 'RSI_14')

## 4.
## add bollinger bands
# ref https://admiralmarkets.com/education/articles/forex-strategy/three-bollinger-bands-strategies-that-you-need-to-know

add.indicator(strategy = strategy.st,
              name= "BBands", # a TTR function 
              arguments = list(HLC = quote(HLC(mktdata), n=20, maType= "SMA", sd=2)),
              label = "BB_20.2")

## 5.
## MACD 
## ref https://github.com/R-Finance/quantstrat/blob/master/demo/macd.R
# parameters for MACD
fastMA = 12 
slowMA = 26 
signalMA = 9

# one indicator
add.indicator(strategy.st, name = "MACD", 
              arguments = list(x=quote(Cl(mktdata)), maType="SMA"),
              label='macd' 
)

## =================== 2. trading signals ===========
## 1.
## Bull market if SMA50>SMA200
add.signal(strategy.st, name="sigComparison", ## "name" is proper of the function - not set by user
           arguments=list(columns=c("sma50","sma200"),relationship="gt"),
           label="smabuy")
## 2.
## Sell market if SMA50<SMA200
add.signal(strategy.st, name="sigComparison",
           arguments=list(columns=c("sma50","sma200"),relationship="lt"),
           label="smasell")

## 3.
## specifies all instance when RSI is below 20 (indication of asset being oversold)
add.signal(strategy.st, name = "sigThreshold",
           arguments = list(column = "RSI_14", threshold = 20,relationship = "lt", cross = FALSE),
           label = "rsi14buy") # old  "longthreshold"

## 4.
##  specifies the first instance whenrsi is above 80 (indication of asset being overbought)
add.signal(strategy.st, name = "sigThreshold", ## "name" is proper of the function - not set by user
           arguments = list(column = "RSI_14", threshold = 80,relationship = "gt", cross = TRUE),
           label = "rsi14sell") # old thresholdexit

## 5. makes uses of 1 and 3 above here
## sigFormula which indicates that both smabuy and rsi14buy must be true.
add.signal(strategy.st, name = "sigFormula",
           arguments = list(formula = "smabuy & rsi14buy",cross = TRUE),
           label = "entry1") # write entry1 old longentry

## 6. uses 2 and 4 above here
##  indicates that both smasell and rsi14sell are true 
add.signal(strategy.st, name = "sigFormula",
           arguments = list(formula = "smasell & rsi14sell",cross = TRUE),
           label = "exit1")  # write exit1 old longexit

## 7.
## ref https://github.com/timtrice/backtesting-strategies/blob/master/_bollinger.bands.Rmd
## Bollinger bands (MA 20, sd 2)
add.signal(strategy.st, 
           name="sigCrossover", 
           arguments = list(columns = c("Close", "up"), 
                            relationship = "gt"),
           label="Cl.gt.Upper.Band")
## 8.
quantstrat::add.signal(strategy.st, 
           name = "sigCrossover",
           arguments = list(columns = c("Close", "dn"), 
                            relationship = "lt"),
           label = "Cl.lt.Lower.Band")
## 9. 
add.signal(strategy.st, 
           name = "sigCrossover",
           arguments = list(columns = c("High", "Low", "mavg"), 
                            relationship = "op"),
           label = "Cross.Mid")

##  10. uses 8 and 3
## creando regole miste con Bbands e RSI
add.signal(strategy.st, name = "sigFormula",
           arguments = list(formula = "Cl.lt.Lower.Band & rsi14buy",cross = TRUE),
           label = "entry2")
## 11. uses 9 and 4
add.signal(strategy.st, name = "sigFormula",
           arguments = list(formula = "Cl.gt.Upper.Band & rsi14sell",cross = TRUE),
           label = "exit2")

## 12.
## MACD rules from the Demo file
#two signals
add.signal(strategy.st,name="sigThreshold",
           arguments = list(column="macd",
                            relationship="gt",
                            threshold=0,
                            cross=TRUE),
           label="macd.gt.zero"
)

## 13.
add.signal(strategy.st,name="sigThreshold",
           arguments = list(column="macd",
                            relationship="lt",
                            threshold=0,
                            cross=TRUE),
           label="macd.lt.zero"
)



## ========== 3. execution of the signals ==============


## ~~ SAME AS ABOVE 
## The first rule will be an exit rule. This exit rule will execute when the market 
## environment is no longer conducive to a trade (i.e. when the SMA-50 falls below SMA-200)
# add.rule(strategy.st, name = "ruleSignal",
#          arguments = list(sigcol = "smasell", sigval = TRUE,
#                           orderqty = "all", ordertype = "market",
#                           orderside = "long", replace = FALSE,
#                           prefer = "Open"),
#          type = "exit")

## 1. uses signal 4
## The second rule, similar to the first, executes when the RSI has crossed above 80. 
add.rule(strategy.st, name = "ruleSignal",
         arguments = list(sigcol = "rsi14sell", sigval = TRUE,
                          orderqty = "all", ordertype = "market",
                          orderside = "long", replace = FALSE,
                          prefer = "Open"),
         type = "exit") # dont' need label- if NULL, '<name>.rule'

## 2. uses signals 5
## MIXED BUY rule 1
## Additionally, we also need an entry rule. 
## This rule executes "longentry" <<!-- replace with 'entry1' -->   
## That is when SMA-50 is above SMA-200 and the RSI is below 20.
add.rule(strategy.st, name = "ruleSignal",
         arguments = list(sigcol = "entry1", sigval = TRUE,
                          orderqty = 1000, ordertype = "market",
                          orderside = "long", replace = FALSE,
                          prefer = "Open", osFUN = IKTrading::osMaxDollar,
                          tradeSize = tradesize, maxSize = tradesize),
         type = "enter")  # dont' need label- if NULL, '<name>.rule'



## 3. uses signal 6
## MIXED EXIT rule 1
add.rule(strategy.st, name = "ruleSignal",
         arguments = list(sigcol = "exit1", sigval = TRUE,
                          orderqty = 'all', ordertype = "market",
                          orderside = "long", replace = FALSE,
                          prefer = "Open", osFUN = IKTrading::osMaxDollar,
                          tradeSize = tradesize, maxSize = tradesize),
         type = "exit")


## Bollinger bands
# add.rule(stratBBands,
#          name='ruleSignal', 
#          arguments = list(sigcol="Cl.gt.UpperBand",sigval=TRUE, 
#                           orderqty=-1000, ordertype='market', orderside=NULL, 
#                           threshold=NULL,osFUN=IKTrading::osMaxPos),
#          type='enter')
# add.rule(stratBBands,
#          name='ruleSignal', 
#          arguments = list(sigcol="Cl.lt.LowerBand",sigval=TRUE, 
#                           orderqty= 1000, ordertype='market', orderside=NULL, 
#                           threshold=NULL,osFUN=IKTrading::osMaxPos),
#          type='enter')
# add.rule(stratBBands, 
#          name='ruleSignal', 
#          arguments = list(sigcol="Cross.Mid",sigval=TRUE, 
#                           orderqty= 'all', ordertype='market', orderside=NULL, 
#                           threshold=NULL,osFUN=IKTrading::osMaxPos),
#          type='exit')

## 4. uses signals 11
## custom mix 1
add.rule(strategy = strategy.st, name= 'rulesignal',
         arguments = list(sigcol = "exit2", sigval= TRUE,
                          orderqty = 1000, ordertype= 'market', orderside= NULL,
                          threshold=NULL,osFUN=IKTrading::osMaxPos ),
         type= "exit")

## 5. uses signals 10
## custom mix 2
add.rule(strategy = strategy.st, name= 'rulesignal',
         arguments = list(sigcol = "entry2", sigval= TRUE,
                          orderqty = 1000, ordertype= 'market', orderside= NULL,
                          threshold=NULL,osFUN=IKTrading::osMaxPos ),
         type= "entry")
#### 

## 6. uses signals 12
## MACD
## entry alternatives for risk stops:
# simple stoplimit order, with threshold multiplier
add.rule(strategy.st, name='ruleSignal', 
         arguments = list(sigcol="macd.gt.zero",sigval=TRUE, 
                          orderqty='all', ordertype='stoplimit', orderside='long', 
                          threshold=-.05,tmult=TRUE, orderset='exit2'),
         type='chain', parent='enter', 
         label='risk',storefun=FALSE)
# alternately, use a trailing order, also with a threshold multiplier
quantstrat::add.rule(strategy.st,name='ruleSignal', 
         arguments = list(sigcol="macd.gt.zero",sigval=TRUE, 
                          orderqty='all', ordertype='stoptrailing', orderside='long', 
                          threshold=-1,tmult=FALSE, orderset='exit2'),	
         type='chain', parent='enter')

## 7. uses signals 13
## exit
add.rule(strategy.st,name='ruleSignal', 
         arguments = list(sigcol="macd.lt.zero",
                          sigval=TRUE, 
                          orderqty='all', 
                          ordertype='market', 
                          orderside='long', 
                          threshold=NULL,
                          orderset='exit2'),
         type='exit')




## =========== 4.1 evaluation with PerformanceAnalytics pkg =============
out<-try(applyStrategy(strategy.st,
                       portfolios=portfolio.st,
                       ## parameters for MACD
                       parameters=list(nFast=fastMA, nSlow=slowMA, nSig=signalMA,maType=maType)))



## update accounts  // before visualization ?
updatePortf(portfolio.st)
updateAcct(portfolio.st)
updateEndEq(account.st)

## visualize
rets <- blotter::PortfReturns(Account = account.st) # calls in glob.env the account timeseries
rownames(rets) <- NULL
tab <- 
  PerformanceAnalytics::table.Arbitrary(
    rets, # function creating a table of statistics
    metrics=c("Return.cumulative","Return.annualized",
              "SharpeRatio.annualized","CalmarRatio"),
    metricsNames=c("Cumulative Return", "Annualized Return",
                   "Annualized Sharpe Ratio","Calmar Ratio"))

tab

## plot performance of the trading rule
PerformanceAnalytics::charts.PerformanceSummary(rets, colorset = bluefocus)



## plots 
for(symbol in symbols) {
  blotter::chart.Posn(Portfolio=portfolio.st,
             Symbol=symbol,log=TRUE)
}




## ############################################################## ##
## ============= 5. SMA RULE WITH VOLATILITY FILTER ==============


# Buy every day when
# SMA30 SMA200 and
# 52 period standard deviation of close prices is less than its median over the last N periods.
# Sell everything when
# SMA30 SMA200

## download data 
