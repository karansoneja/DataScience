
## ##################################################### ##
## =============  4. SMA CROSSING RULE  =======================

## ~~ Blotter's functions build and manipulate objects that are stored in 
## an environment named ".blotter". Use 
ls(envir=.blotter) 
# to show them.



summary(getStrategy(strategy.1) )
summary(getPortfolio(portfolio.1))
summary(getAccount("Michele1"))
summary(getOrders("portfolio.1"))
summary(quantstrat::getOrderBook(portfolio.1))


## ref: https://github.com/R-Finance/quantstrat/blob/master/demo/macd.R
## correct for TZ issues if they crop up
# oldtz<-Sys.getenv('TZ')
# if(oldtz=='') {
#   Sys.setenv(TZ="GMT")
# }

library(quantmod)
library(blotter)
library(quantstrat)
# library(IKTrading)
library(magrittr)
# library(PerformanceAnalytics)

options("getSymbols.warning4.0"=FALSE)
from ="2012-12-28"
to ="2018-12-31"
symbols = c("MC.PA","AIR.PA")
prices <- 
  quantmod::getSymbols(symbols,
                       from=from, to=to, adjust=TRUE) %>%
  purrr::map( ~ (get(.)) ) %>%
  purrr::reduce(merge) 

# pricesCl=merge(Cl(AIR.PA),Cl(MC.PA))

## ==== 0. setup: portfolio, account, order, strategy========
currency("EUR")
stock(symbols, currency="EUR", multiplier=1)
print("Set capital to 100,000 Euros ")
initEq=10^5
initDate="1990-01-01" ## 	A date prior to the first close price given, used to contain initial account equity and initial position

strategy.1 <- portfolio.1 <- account.st <- "Michele1"
strategy.2 <- portfolio.2 <- account.st <- "Michele2"
# strategy.3 <- portfolio.st <- account.st <- "Michele1"
# strategy.4 <- portfolio.st <- account.st <- "Michele1"
rm.strat(strategy.1) # clean up any past residuals
rm.strat(strategy.2)
 

# rm.strat(strategy.3)
# rm.strat(strategy.4)
## initialize
print("initalize portfolio  ")
initPortf(portfolio.1, 
          symbols)
initPortf(portfolio.2, 
          symbols)
print("initalize account ")
initAcct(account.st, 
         portfolios=c(portfolio.1, portfolio.2), 
         initEq = initEq)
print("initalize order container ")
initOrders(portfolio.1)# order container by portfolio.
initOrders(portfolio.2)
strategy(strategy.1, store=TRUE)
strategy(strategy.2, store=TRUE)
# strategy(strategy.3, store=TRUE)
# strategy(strategy.4, store=TRUE)

## why not adding limits to the positions taken ?
# addPosLimit(portfolio = strategy.st, 
#             symbol = "SPY", 
#             timestamp = start_date, 
#             maxpos = 200, 
#             longlevels = 2)



## =========== 1. create filter indicator functions =============
## 1. 


quantstrat::add.indicator(
  strategy.1, name="SMA", ## name must correspond to an R function 
  arguments=list(x= quote(Cl(mktdata)), n=50), # prices
  label="sma50")
# out<-try( applyIndicators(strategy.st,
#                        portfolios=portfolio.st , mktdata = xts(apply(prices, MARGIN = 2, FUN = "SMA", n = 50), index(prices))))

## 2.
add.indicator(
  strategy.1, name="SMA",
  arguments=list(x=quote(Cl(mktdata)), n=200), # old mktdata
  label="sma200")

## ==
quantstrat::add.indicator(
  strategy.2, name="SMA", ## name must correspond to an R function 
  arguments=list(x= quote(Cl(mktdata)), n=50), # old mktdata
  label="sma50")
# out<-try( applyIndicators(strategy.st,
#                        portfolios=portfolio.st , mktdata = xts(apply(prices, MARGIN = 2, FUN = "SMA", n = 50), index(prices))))

## 2.
add.indicator(
  strategy.2, name="SMA",
  arguments=list(x=quote(Cl(mktdata)), n=200), # old mktdata
  label="sma200")

## == 
quantstrat::add.indicator(
  strategy.3, name="SMA", ## name must correspond to an R function 
  arguments=list(x= quote(Cl(mktdata)), n=50), # old mktdata
  label="sma50")
# out<-try( applyIndicators(strategy.st,
#                        portfolios=portfolio.st , mktdata = xts(apply(prices, MARGIN = 2, FUN = "SMA", n = 50), index(prices))))

## 2.
add.indicator(
  strategy.3, name="SMA",
  arguments=list(x=quote(Cl(mktdata)), n=200), # old mktdata
  label="sma200")

## == 

## 3.
# ref https://statsmaths.github.io/stat395-f17/assets/final_project/amarnani.html
add.indicator(strategy = strategy.2,
              name = 'RSI',
              arguments = list(price = quote(Cl(mktdata)), n=14), # old mktdata
              label = 'RSI_14')
out<-
  try( applyIndicators(
    strategy.st,portfolios=portfolio.st ))
                          
## ==
# ref https://statsmaths.github.io/stat395-f17/assets/final_project/amarnani.html
add.indicator(strategy = strategy.3,
              name = 'RSI',
              arguments = list(price = quote(Cl(mktdata)), n=14), # old mktdata
              label = 'RSI_14')
out<-
  try( applyIndicators(
    strategy.st,portfolios=portfolio.st ))

##==

## 4.
## add bollinger bands
# ref https://admiralmarkets.com/education/articles/forex-strategy/three-bollinger-bands-strategies-that-you-need-to-know

add.indicator(strategy = strategy.3,
              name= "BBands", # a TTR function 
              arguments = list(HLC = quote(HLC(mktdata)), n=20, maType= "SMA", sd=2), # old mktdata
              label = "BB_20.2")

## 5.
## MACD 
## ref https://github.com/R-Finance/quantstrat/blob/master/demo/macd.R
# parameters for MACD
fastMA = 12 
slowMA = 26 
signalMA = 9

# one indicator
add.indicator(strategy.4, name = "MACD", 
              arguments = list(x=quote(Cl(mktdata)), maType="SMA" ,nFast = 12, nSlow = 26, nSig = 9),
              label='macd' 
)

## =================== 2. trading signals ===========
## 1.
## Bull market if SMA50>SMA200
add.signal(strategy.1, name="sigComparison", ## "name" is proper of the function - not set by user
           arguments=list(columns=c("sma50","sma200"),relationship="gt"),
           label="smabuy")
## 2.
## Sell market if SMA50<SMA200
add.signal(strategy.1, name="sigComparison",
           arguments=list(columns=c("sma50","sma200"),relationship="lt"),
           label="smasell")

## 3.
## specifies all instance when RSI is below 20 (indication of asset being oversold)
add.signal(strategy.2, name = "sigThreshold",
           arguments = list(column = "RSI_14", threshold = 20,relationship = "lt", cross = FALSE),
           label = "rsi14buy") # old  "longthreshold"

## 4.
##  specifies the first instance whenrsi is above 80 (indication of asset being overbought)
add.signal(strategy.2, name = "sigThreshold", ## "name" is proper of the function - not set by user
           arguments = list(column = "RSI_14", threshold = 80,relationship = "gt", cross = TRUE),
           label = "rsi14sell") # old thresholdexit

## 5. makes uses of 1 and 3 above here
## sigFormula which indicates that both smabuy and rsi14buy must be true.
add.signal(strategy.3, name = "sigFormula",
           arguments = list(formula = "smabuy & rsi14buy",cross = TRUE),
           label = "entry1") # write entry1 old longentry

## 6. uses 2 and 4 above here
##  indicates that both smasell and rsi14sell are true 
add.signal(strategy.3, name = "sigFormula",
           arguments = list(formula = "smasell & rsi14sell",cross = TRUE),
           label = "exit1")  # write exit1 old longexit

## 7.
## ref https://github.com/timtrice/backtesting-strategies/blob/master/_bollinger.bands.Rmd
## Bollinger bands (MA 20, sd 2)
add.signal(strategy.3, 
           name="sigCrossover", 
           arguments = list(columns = c("Close", "up"), 
                            relationship = "gt"),
           label="Cl.gt.Upper.Band")
## 8.
quantstrat::add.signal(strategy.3, 
                       name = "sigCrossover",
                       arguments = list(columns = c("Close", "dn"), 
                                        relationship = "lt"),
                       label = "Cl.lt.Lower.Band")
## 9. 
add.signal(strategy.3, 
           name = "sigCrossover",
           arguments = list(columns = c("High", "Low", "mavg"), 
                            relationship = "op"),
           label = "Cross.Mid")

##  10. uses 8 and 3
## creando regole miste con Bbands e RSI
add.signal(strategy.3, name = "sigFormula",
           arguments = list(formula = "Cl.lt.Lower.Band & rsi14buy",cross = TRUE),
           label = "entry2")
## 11. uses 9 and 4
add.signal(strategy.3, name = "sigFormula",
           arguments = list(formula = "Cl.gt.Upper.Band & rsi14sell",cross = TRUE),
           label = "exit2")

## 12.
## MACD rules from the Demo file
#two signals
add.signal(strategy.4,name="sigThreshold",
           arguments = list(column="macd",
                            relationship="gt",
                            threshold=0,
                            cross=TRUE),
           label="macd.gt.zero"
)

## 13.
add.signal(strategy.4,name="sigThreshold",
           arguments = list(column="macd",
                            relationship="lt",
                            threshold=0,
                            cross=TRUE),
           label="macd.lt.zero"
)



## ========== 3. execution of the signals ==============


## ~~ SAME AS ABOVE 
# The first rule will be an exit rule. This exit rule will execute when the market
# environment is no longer conducive to a trade (i.e. when the SMA-50 falls below SMA-200)
add.rule(strategy.1, name = "ruleSignal",
         arguments = list(sigcol = "smasell", sigval = TRUE,
                          orderqty = "all", ordertype = "market",
                          orderside = "long", replace = FALSE,
                          prefer = "Open"),
         type = "exit")
add.rule(strategy.1, name = "ruleSignal",
         arguments = list(sigcol = "smabuy", sigval = TRUE,
                          orderqty = 1000, ordertype = "market",
                          orderside = "long", replace = FALSE,
                          prefer = "Open"),
         type = "enter")


## 1. uses signal 4
## The second rule, similar to the first, executes when the RSI has crossed above 80. 
add.rule(strategy.2, name = "ruleSignal",
         arguments = list(sigcol = "rsi14sell", sigval = TRUE,
                          orderqty = "all", ordertype = "market",
                          orderside = "long", replace = FALSE,
                          prefer = "Open"),
         type = "exit") # dont' need label- if NULL, '<name>.rule'

## The second rule, similar to the first, executes when the RSI has crossed above 80. 
add.rule(strategy.2, name = "ruleSignal",
         arguments = list(sigcol = "rsi14buy", sigval = TRUE,
                          orderqty = "all", ordertype = "market",
                          orderside = "long", replace = FALSE,
                          prefer = "Open"),
         type = "enter") # dont' need label- if NULL, '<name>.rule'

## 2. uses signals 5
## MIXED BUY rule 1
## Additionally, we also need an entry rule. 
## This rule executes "longentry" <<!-- replace with 'entry1' -->   
## That is when SMA-50 is above SMA-200 and the RSI is below 20.

tradesize <- 1000
add.rule(strategy.3, name = "ruleSignal",
         arguments = list(sigcol = "entry1", sigval = TRUE,
                          orderqty = 1000, ordertype = "market",
                          orderside = "long", replace = FALSE,
                          prefer = "Open", osFUN = IKTrading::osMaxDollar,
                          tradeSize = tradesize, maxSize = tradesize),
         type = "enter")  # dont' need label- if NULL, '<name>.rule'



## 3. uses signal 6
## MIXED EXIT rule 1
add.rule(strategy.3, name = "ruleSignal",
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
#                           threshold=NULL,osFUN=quantstrat::osMaxPos),
#          type='enter')
# add.rule(stratBBands,
#          name='ruleSignal', 
#          arguments = list(sigcol="Cl.lt.LowerBand",sigval=TRUE, 
#                           orderqty= 1000, ordertype='market', orderside=NULL, 
#                           threshold=NULL,osFUN=quantstrat::osMaxPos),
#          type='enter')
# add.rule(stratBBands, 
#          name='ruleSignal', 
#          arguments = list(sigcol="Cross.Mid",sigval=TRUE, 
#                           orderqty= 'all', ordertype='market', orderside=NULL, 
#                           threshold=NULL,osFUN=quantstrat::osMaxPos),
#          type='exit')

## 4. uses signals 11
## custom mix 1
add.rule(strategy = strategy.3, name= 'ruleSignal',
         arguments = list(sigcol = "exit2", sigval= TRUE,
                          orderqty = 1000, ordertype= 'market', orderside= NULL,
                          threshold=NULL,osFUN= quantstrat::osMaxPos ),
         type= "exit")

## 5. uses signals 10
## custom mix 2
add.rule(strategy = strategy.3, name= 'ruleSignal',
         arguments = list(sigcol = "entry2", sigval= TRUE,
                          orderqty = 1000, ordertype= 'market', orderside= NULL,
                          threshold=NULL,osFUN=quantstrat::osMaxPos ),
         type= "enter")
#### 

## 6. uses signals 12
## MACD
## entry alternatives for risk stops:
# simple stoplimit order, with threshold multiplier
add.rule(strategy.4, name='ruleSignal',
         arguments = list(sigcol="macd.gt.zero",sigval=TRUE, 
                          orderqty='all', ordertype='stoplimit', orderside='long', 
                          threshold=-.05,tmult=TRUE, orderset='exit2'),
         type='chain', parent='enter', 
         label='risk',storefun=FALSE)
# alternately, use a trailing order, also with a threshold multiplier
quantstrat::add.rule(strategy.4,name='ruleSignal', 
                     arguments = list(sigcol="macd.gt.zero",sigval=TRUE, 
                                      orderqty='all', ordertype='stoptrailing', orderside='long', 
                                      threshold=-1,tmult=FALSE, orderset='exit2'),	
                     type='chain', parent='enter')

## 7. uses signals 13
## exit
add.rule(strategy.4,name='ruleSignal', 
         arguments = list(sigcol="macd.lt.zero",
                          sigval=TRUE, 
                          orderqty='all', 
                          ordertype='market', 
                          orderside='long', 
                          threshold=NULL,
                          orderset='exit2'),
         type='exit')




## =========== 4.1 evaluation with PerformanceAnalytics pkg =============
out<-try( applyStrategy(strategy.1,
                       portfolios=portfolio.1 ))
                       ## parameters for MACD
                       #parameters=list(nFast=fastMA, nSlow=slowMA, nSig=signalMA),
                       #symbols = symbols ))




## update accounts  // before visualization ?
updatePortf(portfolio.1)
updateAcct(portfolio.1)
updateEndEq( "Michele1")

blotter::checkBlotterUpdate
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

## Per-trade statistics
##  ~~ need to edit first 
tStats <- tradeStats(Portfolios = portfolio_st, use="trades",
                     inclZeroDays = FALSE)
tStats[, 4:ncol(tStats)] <- round(tStats[, 4:ncol(tStats)], 2)
print(data.frame(t(tStats[, -c(1,2)])))

## plot performance of the trading rule
PerformanceAnalytics::charts.PerformanceSummary(rets, colorset = bluefocus)



## plots 
for(symbol in symbols) {
  blotter::chart.Posn(Portfolio=portfolio.st,
                      Symbol=symbol,log=TRUE)
}

