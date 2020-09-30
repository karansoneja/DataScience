## ====================== 5. BENCHMARKING ===========

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
