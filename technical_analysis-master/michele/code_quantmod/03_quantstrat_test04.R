
## ##################################################### ##
## =============  FINAL =======================

## ======== upload packages ==========

if(!require(quantmod)) install.packages("quantmod")
if(!require(FinancialInstrument)) install.packages("FinancialInstrument")
if(!require(PerformanceAnalytics)) install.packages("PerformanceAnalytics")
if(!require(foreach)) install.packages("foreach")
if(!require(devtools)) install.packages("devtools")
if(!require(blotter)) devtools::install_github("braverock/blotter")
if(!require(quantstrat)) install_github("braverock/quanstrat")



## ref: https://github.com/R-Finance/quantstrat/blob/master/demo/macd.R
## correct for TZ issues if they crop up
# oldtz<-Sys.getenv('TZ')
# if(oldtz=='') {
#   Sys.setenv(TZ="GMT")
# }

library(quantmod)
library(blotter)
library(quantstrat)
library(magrittr)
# library(PerformanceAnalytics)
# library(IKTrading)


## ============ get data ========

options("getSymbols.warning4.0"=FALSE)
from ="2012-12-28"
to ="2018-12-31"
symbols = c("MC.PA","AIR.PA")
prices <- 
  quantmod::getSymbols(symbols,index.class = "POSIXct",
                       from=from, to=to, adjust=TRUE) %>%
  purrr::map( ~ (get(.)) ) %>%
  purrr::reduce(merge) 


## ==== 0. setup: portfolio, account, order, strategy========
currency("EUR")
stock(symbols, currency="EUR", multiplier=1)
print("Set capital to 100,000 Euros ")
initEq=10^5
initDate="1990-01-01" ## 	A date prior to the first close price given, used to contain initial account equity and initial position

strategy.st <- "strat.mix1" 
portfolio.st <- "portf.mix1"
account.st <- "acct.mix1"

rm.strat(strategy.st) # clean up any past residuals
rm.strat(portfolio.st)


## initialize portfolio, account, order container, strategy 
print("initalize portfolio  ")
initPortf(portfolio.st, 
          symbols)
print("initalize account ")
initAcct(account.st, 
         portfolios=portfolio.st, 
         initEq = initEq)
print("initalize order container ")
initOrders(portfolio.st)# order container by portfolio.
strategy(strategy.st, store=TRUE)

## why not adding limits to the positions taken ?
# addPosLimit(portfolio = strategy.st, 
#             symbol = "SPY", 
#             timestamp = start_date, 
#             maxpos = 200, 
#             longlevels = 2)



## =========== 1. create filter indicator functions =============


## 1. 
quantstrat::add.indicator(
  strategy.st, name="SMA", ## name must correspond to an R function 
  arguments=list(x= quote(Cl(mktdata)), n=50), # prices
  label="sma50") ## mktdata column name
# out<-try( applyIndicators(strategy.st,
#                        portfolios=portfolio.st , mktdata = xts(apply(prices, MARGIN = 2, FUN = "SMA", n = 50), index(prices))))

## 2.
add.indicator(
  strategy.st, name="SMA",
  arguments=list(x=quote(Cl(mktdata)), n=200), # old mktdata
  label="sma200")



## 3.
# ref https://statsmaths.github.io/stat395-f17/assets/final_project/amarnani.html
add.indicator(strategy = strategy.st,
              name = 'RSI',
              arguments = list(price = quote(Cl(mktdata)), n=14), # old mktdata
              label = 'rsi.14')


# out<-  try( applyIndicators(
#     strategy.st,portfolios=portfolio.st ))


## 4.
## add bollinger bands
# ref https://admiralmarkets.com/education/articles/forex-strategy/three-bollinger-bands-strategies-that-you-need-to-know

add.indicator(strategy = strategy.st,
              name= "BBands", # a TTR function 
              arguments = list(HLC = quote(HLC(mktdata)), n=20, maType= "SMA", sd=2), # old mktdata
              label = "bb.20.2")

## 5. NOT WORKING
## MACD 
## ref https://github.com/R-Finance/quantstrat/blob/master/demo/macd.R
# parameters for MACD
# fastMA = 12 
# slowMA = 26 
# signalMA = 9
# 
# # one indicator
# add.indicator(strategy.st, name = "MACD", 
#               arguments = list(x=quote(Cl(mktdata)), maType="SMA" ,nFast = fastMA, nSlow = slowMA, nSig = signalMA),
#               label='macd' 
# )

## =================== 2. trading signals ===========
## 1.
## Bull market if SMA50>SMA200
add.signal(strategy.st, name="sigCrossover", ## "name" is proper of the function - not set by user
           arguments=list(columns=c("sma50","sma200"),relationship="gt"), # here columns refers to indicators above
           label="smabuy") 
## 2.
## Sell market if SMA50<SMA200
add.signal(strategy.st, name="sigCrossover", # rather than sigComparison
           arguments=list(columns=c("sma50","sma200"),relationship="lt"),
           label="smasell")

## 3.
## specifies all instance when RSI is below 20 (indication of asset being oversold)
add.signal(strategy.st, name = "sigThreshold",
           arguments = list(column = "rsi.14", threshold = 30,relationship = "lt", cross = TRUE),
           label = "rsi14buy") # old  "longthreshold"

## 4.
##  specifies the first instance whenrsi is above 80 (indication of asset being overbought)
add.signal(strategy.st, name = "sigThreshold", ## "name" is proper of the function - not set by user
           arguments = list(column = "rsi.14", threshold = 70,relationship = "gt", cross = TRUE),
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
           arguments = list(columns = c("Close", "up"), # up is created by the BBands
                            relationship = "gt"),
           label="Cl.gt.UpperBand")
## 8.
quantstrat::add.signal(strategy.st, 
                       name = "sigCrossover",
                       arguments = list(columns = c("Close", "dn"), 
                                        relationship = "lt"),
                       label = "Cl.lt.LowerBand")
## 9. 
add.signal(strategy.st, 
           name = "sigCrossover",
           arguments = list(columns = c("High", "Low", "mavg"), 
                            relationship = "op"),
           label = "CrossMid")

##  10. uses 8 and 3
## creando regole miste con Bbands e RSI
add.signal(strategy.st, name = "sigFormula",
           arguments = list(formula = "Cl.lt.LowerBand & rsi14buy",cross = TRUE),
           label = "entry2")
## 11. uses 9 and 4
add.signal(strategy.st, name = "sigFormula",
           arguments = list(formula = "Cl.gt.UpperBand & rsi14sell",cross = TRUE),
           label = "exit2")

# ## 12.
# ## MACD rules from the Demo file
# #two signals
# add.signal(strategy.4,name="sigThreshold",
#            arguments = list(column="macd",
#                             relationship="gt",
#                             threshold=0,
#                             cross=TRUE),
#            label="macd.gt.zero"
# )
# 
# ## 13.
# add.signal(strategy.4,name="sigThreshold",
#            arguments = list(column="macd",
#                             relationship="lt",
#                             threshold=0,
#                             cross=TRUE),
#            label="macd.lt.zero"
# )



## ========== 3. execution of the signals ==============


## 0. 
# The first rule will be an exit rule. This exit rule will execute when the market
# environment is no longer conducive to a trade (i.e. when the SMA-50 falls below SMA-200)
# add.rule(strategy.st, name = "ruleSignal",
#          arguments = list(sigcol = "smasell", sigval = TRUE,
#                           orderqty = "all", ordertype = "market",
#                           orderside = "long", replace = FALSE,
#                           prefer = "Open"),
#          type = "exit")
# add.rule(strategy.st, name = "ruleSignal",
#          arguments = list(sigcol = "smabuy", sigval = TRUE,
#                           orderqty = 1000, ordertype = "market",
#                           orderside = "long", replace = FALSE,
#                           prefer = "Open"),
#          type = "enter")


## 1. uses signal 4
## The second rule, similar to the first, executes when the RSI has crossed above 80. 
# add.rule(strategy.st, name = "ruleSignal",
#          arguments = list(sigcol = "rsi14sell", sigval = TRUE,
#                           orderqty = "all", ordertype = "market",
#                           orderside = "long", replace = FALSE,
#                           prefer = "Open"),
#          type = "exit") # dont' need label- if NULL, '<name>.rule'
# 
# ## The second rule, similar to the first, executes when the RSI has crossed above 80. 
# add.rule(strategy.st, name = "ruleSignal",
#          arguments = list(sigcol = "rsi14buy", sigval = TRUE,
#                           orderqty = 1000,  ordertype = "market",
#                           orderside = "long", replace = FALSE,
#                           prefer = "Open"),
#          type = "enter") # dont' need label- if NULL, '<name>.rule'

## 2. uses signals 5
## MIXED BUY rule 1
## Additionally, we also need an entry rule. 
## This rule executes "longentry" <<!-- replace with 'entry1' -->   
## That is when SMA-50 is above SMA-200 and the RSI is below 20.

tradesize <- 1000
add.rule(strategy.st, name = "ruleSignal",
         arguments = list(sigcol = "entry1", sigval = TRUE,
                          orderqty = 1000, ordertype = "market",
                          orderside = "long", replace = FALSE,
                          prefer = "Open", 
                          tradeSize = tradesize, maxSize = tradesize),
         type = "enter")  # dont' need label- if NULL, '<name>.rule' #osFUN = IKTrading::osMaxDollar,



## 3. uses signal 6
## MIXED EXIT rule 1
add.rule(strategy.st, name = "ruleSignal",
         arguments = list(sigcol = "exit1", sigval = TRUE,
                          orderqty = 'all', ordertype = "market",
                          orderside = "long", replace = FALSE,
                          prefer = "Open", #osFUN = IKTrading::osMaxDollar,
                          tradeSize = tradesize, maxSize = tradesize),
         type = "exit") 


## BOLLINGER BANDS
# add.rule(strategy.st,
#          name='ruleSignal',
#          arguments = list(sigcol="Cl.gt.UpperBand",sigval=TRUE,
#                           orderqty=-1000, ordertype='market', orderside="long",
#                           threshold=NULL), #quantstrat::osMaxPos
#          type='enter')
# add.rule(strategy.st,
#          name='ruleSignal',
#          arguments = list(sigcol="Cl.lt.LowerBand",sigval=TRUE,
#                           orderqty= 1000, ordertype='market', orderside="long",
#                           threshold=NULL),
#          type='enter')
# add.rule(strategy.st,
#          name='ruleSignal',
#          arguments = list(sigcol="Cross.Mid",sigval=TRUE,
#                           orderqty= 'all', ordertype='market', orderside="long",
#                           threshold=NULL),
#          type='exit')

## 4. uses signals 11
## custom mix 1
add.rule(strategy = strategy.st, name= 'ruleSignal',
         arguments = list(sigcol = "exit2", sigval= TRUE,
                          orderqty = "all", ordertype= 'market', orderside= NULL,
                          threshold=NULL ),  #osFUN= quantstrat::osMaxPos
         type= "exit")

## 5. uses signals 10
## custom mix 2
add.rule(strategy = strategy.st, name= 'ruleSignal',
         arguments = list(sigcol = "entry2", sigval= TRUE,
                          orderqty = 1000, ordertype= 'market', orderside= NULL,
                          threshold=NULL ), #osFUN=quantstrat::osMaxPos
         type= "enter")
#### 

## 6. uses signals 12
## MACD
## entry alternatives for risk stops:
# simple stoplimit order, with threshold multiplier
# add.rule(strategy.4, name='ruleSignal',
#          arguments = list(sigcol="macd.gt.zero",sigval=TRUE, 
#                           orderqty='all', ordertype='stoplimit', orderside='long', 
#                           threshold=-.05,tmult=TRUE), #, orderset='exit2'
#          type='chain', parent='enter', 
#          label='risk',storefun=FALSE)
# # alternately, use a trailing order, also with a threshold multiplier
# quantstrat::add.rule(strategy.4,name='ruleSignal', 
#                      arguments = list(sigcol="macd.gt.zero",sigval=TRUE, 
#                                       orderqty='all', ordertype='stoptrailing', orderside='long', 
#                                       threshold=-1,tmult=FALSE),	#, orderset='exit2'
#                      type='chain', parent='enter')
# 
# ## 7. uses signals 13
# ## exit
# add.rule(strategy.4,name='ruleSignal', 
#          arguments = list(sigcol="macd.lt.zero",
#                           sigval=TRUE, 
#                           orderqty='all', 
#                           ordertype='market', 
#                           orderside='long', 
#                           threshold=NULL
#                           ), #orderset='exit2'
#          type='exit')




## =========== 4. evaluation with PerformanceAnalytics pkg =============
out<-try( applyStrategy(strategy.st,
                        portfolios=portfolio.st ))

## update accounts before visualization
updatePortf(portfolio.st)
updateAcct(account.st)
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

## Per-trade statistics
##  ~~ need to edit first 
tStats <- tradeStats(Portfolios = portfolio.st, use="trades",
                     inclZeroDays = FALSE)

tStats[, 4:ncol(tStats)] <- round(tStats[, 4:ncol(tStats)], 2)
print(data.frame(t(tStats[, -c(1,2)])))


## stats for RSI 
# table(mktdata$rsi14sell)
# table(mktdata$rsi14buy)

## plot performance of the trading rule
PerformanceAnalytics::charts.PerformanceSummary(
  rets, main= "Performance Summary",colorset = bluefocus)

## plots 
for(symbol in symbols) {
  blotter::chart.Posn(Portfolio=portfolio.st,
                      Symbol=symbol,log=TRUE)
}

## ====== Summaries ============

## ~~ Blotter's functions build and manipulate objects that are stored in 
## an environment named ".blotter". Use 
ls(envir=.blotter) 
# to show them.

summary(getStrategy(strategy.st) )
summary(getPortfolio(portfolio.st))
## summary(getAccount("strat.rsi"))
summary(getOrders(portfolio.st))
summary(quantstrat::getOrderBook(portfolio.st))



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
