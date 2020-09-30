##
## only one rule, that considers three signals
## rather than two rules, each considering two signals
##
##
##
##

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
oldtz<-Sys.getenv('TZ')
if(oldtz=='') {
  Sys.setenv(TZ="GMT")
}

library(quantmod)
library(blotter)
library(quantstrat)
library(magrittr)
library(purrr)
# library(PerformanceAnalytics)
# library(IKTrading)


## ============ get data ========

# options("getSymbols.warning4.0"=FALSE)
from ="2012-12-28"
to ="2018-12-31"
symbols = c("FP.PA","MC.PA","SAN.PA","AIR.PA","OR.PA" )
# 
# # prices <- 
# quantmod::getSymbols(symbols,index.class = "POSIXct",
#                      from=from, to=to, adjust=TRUE) #%>%
#   purrr::map( ~ (get(.)) ) %>%
#   purrr::reduce(merge) 


## or can upload from local dir 
FP.PA = 
  readr::read_csv("D:/2017-2018/data_analysis/technical_analysis/data/raw/FP.PA_total.csv", 
                  col_types =  readr::cols(date = readr::col_date(format ="%d/%m/%Y" ))) %>% 
  timetk::tk_xts(date_var = date)

MC.PA =
  readr::read_csv("D:/2017-2018/data_analysis/technical_analysis/data/raw/MC.PA_LVMH.csv", 
                  col_types =  readr::cols(date = readr::col_date(format ="%d/%m/%Y" ))) %>% 
  timetk::tk_xts(date_var = date)

SAN.PA = 
  readr::read_csv("D:/2017-2018/data_analysis/technical_analysis/data/raw/SAN.PA_sanofi.csv", 
                  col_types =  readr::cols(date = readr::col_date(format ="%d/%m/%Y" ))) %>% 
  timetk::tk_xts(date_var = date)

AIR.PA= 
  readr::read_csv("D:/2017-2018/data_analysis/technical_analysis/data/raw/AIR.PA_airbus.csv", 
                  col_types =  readr::cols(date = readr::col_date(format ="%d/%m/%Y" ))) %>% 
  timetk::tk_xts(date_var = date)

OR.PA = 
  readr::read_csv("D:/2017-2018/data_analysis/technical_analysis/data/raw/OR.PA_oreal.csv", 
                  col_types =  readr::cols(date = readr::col_date(format ="%d/%m/%Y" ))) %>% 
  timetk::tk_xts(date_var = date)




## ==== 0. setup: portfolio, account, order, strategy========
currency("EUR")
stock(symbols, currency="EUR", multiplier=1)
print("Set capital to 100,000 Euros ")
initEq=10^5
initDate="1990-01-01" ## 	A date prior to the first close price given, 
# used to contain initial account equity and initial position

strategy.st <- "strat.full.limit" 
portfolio.st <- "portf.full.limit"
account.st <- "acct.full.limit"

rm.strat(strategy.st) # clean up any past residuals
rm.strat(portfolio.st)
# rm.strat(account.st)
# rm(portfolio.st, strategy.st,account.st )


## initialize portfolio, account, order container, strategy 
cat("initalize portfolio:", portfolio.st)
initPortf(portfolio.st, 
          symbols)

cat("initalize account:",account.st )
initAcct(account.st, 
         portfolios=portfolio.st, 
         initEq = initEq)

# print("initalize order container ")
initOrders(portfolio.st)# order container by portfolio.

cat("initializie strategy:", strategy.st)

strategy(strategy.st, store=TRUE)

## why not adding limits to the positions taken ?
# addPosLimit(portfolio = strategy.st, 
#             symbol = "SPY", 
#             timestamp = start_date, 
#             maxpos = 200, 
#             longlevels = 2)



## =========== 1. create filter indicator functions =============
tradesize <- 1000
for (sym in symbols) {
  addPosLimit(portfolio.st, sym, start(get(sym)), maxpos = 300, longlevels = 2)
}

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
## specifies all instance when RSI is below 30 (indication of asset being oversold)
add.signal(strategy.st, name = "sigThreshold",
           arguments = list(column = "rsi.14", threshold = 30,relationship = "lt", cross = TRUE),
           label = "rsi14buy") # old  "longthreshold"

## 4.
##  specifies the first instance when rsi is above 70 (indication of asset being overbought)
add.signal(strategy.st, name = "sigThreshold", ## "name" is proper of the function - not set by user
           arguments = list(column = "rsi.14", threshold = 70,relationship = "gt", cross = TRUE),
           label = "rsi14sell") # old thresholdexit


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

## 5. makes uses of 1 and 3 above here
## sigFormula which indicates that both smabuy and rsi14buy must be true.
add.signal(strategy.st, name = "sigFormula",
           arguments = list(formula = "(smabuy== 1) & (rsi14buy==1) & (Cl.lt.LowerBand==1) ",cross = TRUE),
           label = "entry1") # write entry1 old longentry

## 6. uses 2 and 4 above here
##  indicates that both smasell and rsi14sell are true 
add.signal(strategy.st, name = "sigFormula",
           arguments = list(formula = "(smasell ==1) & (rsi14sell ==1) & (Cl.gt.UpperBand==1)",cross = TRUE),
           label = "exit1")  # write exit1 old longexit


##  10. uses 8 and 3
## creando regole miste con Bbands e RSI
add.signal(strategy.st, name = "sigFormula",
           arguments = list(formula = "Cl.lt.LowerBand & rsi14buy  ",cross = TRUE),
           label = "entry2")

## 11. uses 9 and 4
add.signal(strategy.st, name = "sigFormula",
           arguments = list(formula = "Cl.gt.UpperBand & rsi14sell  ",cross = TRUE),
           label = "exit2")

# ## 12. MACD


## ========== 3. execution of the signals ==============

## ref https://rpubs.com/Mohammed/Trading_Basics


## 0. 
# The first rule will be an exit rule. This exit rule will execute when the market
# environment is no longer conducive to a trade (i.e. when the SMA-50 falls below SMA-200)


## 1. uses signal 4: xecutes when the RSI has crossed above 80. 


## 2. uses signals 5
## This rule executes "longentry" <<!-- replace with 'entry1' -->   
## That is when SMA-50 is above SMA-200 and the RSI is below 20.
add.rule(strategy.st, name = "ruleSignal",
         arguments = list(sigcol = "entry1", sigval = TRUE,
                          orderqty = 100, ordertype = "market",
                          orderside = "long", replace = FALSE,
                          prefer = "Open", 
                          osFUN = osMaxPos,
                          tradeSize = tradesize, maxSize = tradesize),
         type = "enter")  # dont' need label- if NULL, '<name>.rule' #osFUN = IKTrading::osMaxDollar,



## 3. uses signal 6
## MIXED EXIT rule 1
add.rule(strategy.st, name = "ruleSignal",
         arguments = list(sigcol = "exit1", sigval = TRUE,
                          orderqty = -100 , ordertype = "market",
                          orderside = "long", replace = FALSE,
                          prefer = "Open", 
                          osFUN = osMaxPos,
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
#                           orderqty= -1000 , ordertype='market', orderside="long",
#                           threshold=NULL),
#          type='exit')

## =============
# 
# ## 4. uses signals 11
# ## custom mix 1
# add.rule(strategy = strategy.st, name= 'ruleSignal',
#          arguments = list(sigcol = "exit2", sigval= TRUE,
#                           orderqty = -100, ordertype= 'market', orderside= NULL,
#                           threshold=NULL ),  
#          type= "exit")
# 
# ## 5. uses signals 10
# ## custom mix 2
# add.rule(strategy = strategy.st, name= 'ruleSignal',
#          arguments = list(sigcol = "entry2", sigval= TRUE,
#                           orderqty = 100, ordertype= 'market', orderside= NULL,
#                           osFUN = osMaxPos,
#                           threshold=NULL ), 
#          type= "enter")

## ==================

## 6. uses signals 12
## MACD


## ## 7. uses signals 13




## =========== 4. evaluation with PerformanceAnalytics pkg =============

testing_strat <- base::try( quantstrat::applyStrategy(
  strategy.st, portfolios=portfolio.st ))

#  write.csv(as.data.frame(base::try( quantstrat::applyStrategy(
# strategy.st, portfolios=portfolio.st ))),file="D:/2017-2018/data_analysis/technical_analysis/data/raw/strat_output.csv",quote= FALSE)