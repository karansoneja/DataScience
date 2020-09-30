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

# getSymbols("E40.PA", from = from, to = to) ## too many NAs
# 
# # A crude estimate of end portfolio value from buying and holding 
# initEq * (E40.PA$E40.PA.Adjusted["2018-12-28"][[1]] / E40.PA$E40.PA.Adjusted[[1]])
# final.acct <- getAccount(account.st)
# plot(final.acct$summary$End.Eq["2012/2018"] / 1000000,
#      main = "CAC40 Tracking: E40.PA ETF", ylim = c(0.8, 2.5))
# lines(E40.PA$E40.PA.Adjusted / E40.PA$E40.PA.Adjusted[[1]], col = "blue")
# 
# ## 
# # https://www.amundietf.fr/particuliers/product/view/LU1681046931
# getSymbols("C40.MI", from = from, to = to) 
# # A crude estimate of end portfolio value from buying and holding 
# initEq * (C40.MI$C40.MI.Adjusted["2018-12-28"][[1]] / C40.MI$C40.MI.Adjusted[[1]])
# final.acct <- getAccount(account.st)
# plot(final.acct$summary$End.Eq["2012/2018"] / 1000000,
#      main = "CAC40 Tracking: C40.MI ETF", ylim = c(0.8, 2.5))
# lines(C40.MI$C40.MI.Adjusted / C40.MI$C40.MI.Adjusted[[1]], col = "blue")


# ## ===== no need to rerun? ====
# symbols = c("FP.PA","MC.PA","SAN.PA","AIR.PA","OR.PA" )
# # symbols = ("AIR.PA")
# 
# oldtz<-Sys.getenv('TZ')
# if(oldtz=='') {
#   Sys.setenv(TZ="GMT")
# }
# 
# library(quantmod)
# library(blotter)
# library(quantstrat)
# library(magrittr)
# library(purrr)
# 
# from ="2012-12-28"
# to ="2018-12-31"
# 
# 
# FP.PA = 
#   readr::read_csv("D:/2017-2018/data_analysis/technical_analysis/data/raw/FP.PA_total.csv", 
#                   col_types =  readr::cols(date = readr::col_date(format ="%d/%m/%Y" ))) %>% 
#   timetk::tk_xts(date_var = date)
# 
# MC.PA =
#   readr::read_csv("D:/2017-2018/data_analysis/technical_analysis/data/raw/MC.PA_LVMH.csv", 
#                   col_types =  readr::cols(date = readr::col_date(format ="%d/%m/%Y" ))) %>% 
#   timetk::tk_xts(date_var = date)
# 
# SAN.PA = 
#   readr::read_csv("D:/2017-2018/data_analysis/technical_analysis/data/raw/SAN.PA_sanofi.csv", 
#                   col_types =  readr::cols(date = readr::col_date(format ="%d/%m/%Y" ))) %>% 
#   timetk::tk_xts(date_var = date)
# 
# AIR.PA= 
#   readr::read_csv("D:/2017-2018/data_analysis/technical_analysis/data/raw/AIR.PA_airbus.csv", 
#                   col_types =  readr::cols(date = readr::col_date(format ="%d/%m/%Y" ))) %>% 
#   timetk::tk_xts(date_var = date)
# 
# OR.PA = 
#   readr::read_csv("D:/2017-2018/data_analysis/technical_analysis/data/raw/OR.PA_oreal.csv", 
#                   col_types =  readr::cols(date = readr::col_date(format ="%d/%m/%Y" ))) %>% 
#   timetk::tk_xts(date_var = date)
## ##


## ==== 0. setup: portfolio, account, order, strategy========
currency("EUR")
stock(symbols, currency="EUR", multiplier=1)
print("Set capital to 100,000 Euros ")
initEq=10^5
initDate="2012-12-25"


strategy.st <- "strat.buyHold" 
portfolio.st <- "portf.buyHold"
account.st <- "acct.buyHold"

rm.strat(strategy.st) # clean up any past residuals
rm.strat(portfolio.st)
rm.strat(account.st)

# initialize portfolio and account
initPortf("portf.buyHold", symbols, initDate = initDate)
initAcct("acct.buyHold", portfolios = "portf.buyHold",
         initDate = initDate, initEq = initEq)

## ======== old ===========
# place an entry order
# CurrentDate <- time(getTxns(Portfolio = "portf.buyHold", Symbol = "AIR.PA"))#[2]

# # ClosePrice <- as.numeric(Cl(AIR.PA[CurrentDate,]))
# 
# ClosePrice <- as.numeric(Cl(AIR.PA[1,]))
# UnitSize = as.numeric(trunc(equity/ClosePrice))
# 
# # # addTxn("portf.buyHold", Symbol = symbols, TxnDate = CurrentDate, TxnPrice = ClosePrice,
# # #       TxnQty = UnitSize, TxnFees = 0)
# 
# for (sym in symbols){
#   addTxn("portf.buyHold", Symbol = sym, TxnDate = CurrentDate, TxnPrice = as.numeric(Cl(sym[1,])),
#          TxnQty = as.numeric(Cl(sym[1,])), TxnFees = 0)}

## ================

# ## place an exit order
# 
# # LastDate <- last(time(AIR.PA))
# # LastPrice <- as.numeric(Cl(AIR.PA[LastDate,]))
# # addTxn("portf.buyHold", Symbol = symbols, TxnDate = LastDate, TxnPrice = LastPrice,
# #        TxnQty = -UnitSize , TxnFees = 0)
# 
# ## exit order

# for (sym in symbols) {
#   LastDate <- last(time(sym))
#   LastPrice <- as.numeric(Cl(sym[LastDate,]))
#   addTxn("portf.buyHold", Symbol = sym, TxnDate = LastDate, TxnPrice = LastPrice,
#          TxnQty = -UnitSize , TxnFees = 0)
# }


# CurrentDate <- from
FirstDate <- first(time(prices[,]))
equity = getEndEq("acct.buyHold", FirstDate)/5
## =============  new ==================
## entry order
# FirstDate <- first(time(prices[,]))
for (p in 1:5){
  ClosePrice <- as.numeric(first(prices[,p]))
  UnitSize = as.numeric(trunc(equity/ClosePrice))
  
  addTxn("portf.buyHold", Symbol = symbols[p], 
         TxnDate = FirstDate, 
         TxnPrice = as.numeric(prices[1,p]),
         TxnQty = UnitSize, 
         TxnFees = 0) }


## exit order
LastDate <- last(time(prices[,]))
for (p in 1:5) {
 
  ClosePrice <- as.numeric(first(prices[,p]))
  UnitSize = as.numeric(trunc(equity/ClosePrice))
  
  LastPrice <- as.numeric(last(prices[,p]))
   addTxn("portf.buyHold", Symbol = symbols[p], 
         TxnDate = LastDate, 
         TxnPrice = LastPrice,
         TxnQty = -UnitSize , 
         TxnFees = 0)
}


# update portfolio and account
updatePortf(Portfolio = "portf.buyHold")
updateAcct(name = "acct.buyHold")
updateEndEq(Account = "acct.buyHold")
# chart.Posn("portf.buyHold", Symbol = "AIR.PA")


# rets.bh <- PortfReturns(Account = "acct.buyHold")
# strat.bh <- charts.PerformanceSummary(rets.bh, colorset = bluefocus,
#                           main = "B&H Strategy Performance")



# ## ========== strategy vs market
# 
#  rets <- PortfReturns(Account = "acct.full")
#  rets.bh <- PortfReturns(Account = "acct.buyHold")
#  returns <- cbind(rets, rets.bh)
#  charts.PerformanceSummary(returns, geometric = FALSE, wealth.index = TRUE,
#                            main = "Strategy vs. Market")

bhrets <- blotter::PortfReturns(Account = "acct.buyHold") # calls in glob.env the account timeseries
rownames(bhrets) <- NULL
bh.rets <- 
  PerformanceAnalytics::table.Arbitrary(
    bhrets, # function creating a table of statistics
    metrics=c("Return.cumulative","Return.annualized",
              "SharpeRatio.annualized"),
    metricsNames=c("Cumulative Return", "Annualized Return",
                   "Annualized Sharpe Ratio"))



# write.csv(as.data.frame(bh.rets),
#           file="D:/2017-2018/data_analysis/technical_analysis/data/raw/bh.rets.csv",
#           quote= FALSE)


## done only once
# acc2 <- getAccount("acct.buyHold")
# # Retrieves the most recent value of the capital account
# equity2 <- acc2$summary$End.Eq[-1,] 
# png('D:/2017-2018/data_analysis/technical_analysis/report/equity_BH.png',
#      width = 1800, height = 900)
# plot(equity2, main = "Equity Curve B&H portfolio")
# dev.off()
