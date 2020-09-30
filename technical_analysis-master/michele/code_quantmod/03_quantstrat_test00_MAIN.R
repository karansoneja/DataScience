

library(quantmod)
library(blotter)
library(quantstrat)
# library(IKTrading)
library(magrittr)


options("getSymbols.warning4.0"=FALSE)
from ="2012-12-28"
to ="2018-12-31"
symbols = c("MC.PA","AIR.PA")

prices <- 
  quantmod::getSymbols(symbols, index.class = "POSIXct",
                       from=from, to=to, adjust=TRUE) %>%
  purrr::map( ~ (get(.)) ) %>%
  purrr::reduce(merge) 

# pricesCl=merge(Cl(AIR.PA),Cl(MC.PA))

## ==== 0. setup: portfolio, account, order, strategy========
currency("EUR")
stock(symbols, currency="EUR", multiplier=1)
print("Set capital to 100,000 Euros ")
initEq=10^5
initDate="1990-01-01" ## 	

strategy.st <- "strat.macd" 
portfolio.st <- "portf.macd"
account.st <- "acct.macd"

 # clean up any past residuals
rm.strat(portfolio.st)
rm.strat(account.st)
rm.strat(strategy.st)
## initialize
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

## =============
fastMA = 12 
slowMA = 26 
signalMA = 9
# one indicator
add.indicator(strategy.st, name = "MACD", 
              arguments = list(x=quote(Cl(mktdata)), maType="SMA" ,nFast = fastMA, nSlow = slowMA, nSig = signalMA),
              label='macd' )

## =============

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
## ==============

add.rule(strategy.st, name='ruleSignal',
         arguments = list(sigcol="macd.gt.zero",sigval=TRUE, 
                          orderqty=1000, ordertype='market', orderside='long', #ordertype='stoplimit'
                          threshold=-.05,tmult=TRUE), #, orderset='exit2'
         type='enter', #parent='enter', # old : type = risk
         storefun=FALSE)
## 7. uses signals 13
## exit
add.rule(strategy.st,name='ruleSignal', 
         arguments = list(sigcol="macd.lt.zero",
                          sigval=TRUE, 
                          orderqty='all', 
                          ordertype='market', 
                           
                          threshold=NULL
                          ), #orderset='exit2'
         type='exit')


## =============
out<-try( applyStrategy(strategy.st,
                        portfolios=portfolio.st ))

out<-(applyStrategy(strategy.st,
                        portfolios=portfolio.st ))

table(mktdata$smabuy)
summary(mktdata$smasell)

table(mktdata$rsi14sell)
table(mktdata$rsi14buy)

updatePortf(portfolio.st)
updateAcct(account.st)
updateEndEq(account.st)

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

