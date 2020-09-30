## =========== 4. evaluation with PerformanceAnalytics pkg =============

# out<- base::try( quantstrat::applyStrategy(strategy.st,
# portfolios=portfolio.st ))

## ===== try and export the results in a .Rdata object. It fails because of a bug with timestamps ====

# cwd <- getwd() 
# setwd("output")
# mktdata= make.index.unique(mktdata)
# results_file <- paste("results", strategy.st, "RData", sep = ".") # create a .Rdata file to be filled 
# if( file.exists(results_file) ) {
#   load(results_file)
# } else {
#   results <- applyStrategy(strategy.st, portfolios = portfolio.st)
#   if(checkBlotterUpdate(portfolio.st, account.st, verbose = TRUE)) {
#     save(list = "results", file = results_file)
#     save.strategy(strategy.st)
#   }
# }
# setwd(cwd)

## ========= update accounts &  visualization ##### ========
updatePortf(portfolio.st)
updateAcct(account.st)
updateEndEq(account.st)


## visualize some overall statistics 

rets <- blotter::PortfReturns(Account = account.st) # calls in glob.env the account timeseries
rownames(rets) <- NULL
act.rets <- 
  PerformanceAnalytics::table.Arbitrary(
    rets, # function creating a table of statistics
    metrics=c("Return.cumulative","Return.annualized",
              "SharpeRatio.annualized",
              "StdDev.annualized"), # "CalmarRatio"
    metricsNames=c("Cumulative Return", "Annualized Return",
                   "Annualized Sharpe Ratio",
                   "Annualized StdDev")) # "Calmar Ratio"
  
write.csv(as.data.frame(act.rets),
          file="D:/2017-2018/data_analysis/technical_analysis/data/raw/act.rets.csv",
          quote= FALSE)


# act.risk <- table.Arbitrary(rets,
#                             metrics=c(
#                               
#                               "VaR",
#                               "ES"),
#                             metricsNames=c(
#                               ,
#                               "Value-at-Risk",
#                               "Conditional VaR"))
# 
# write.csv(as.data.frame(act.risk),
#           file="D:/2017-2018/data_analysis/technical_analysis/data/raw/act.risk.csv",
#           quote= FALSE)

## ================================
  
## Per-trade statistics
tStats <- tradeStats(Portfolios = portfolio.st, use="trades",
                     inclZeroDays = FALSE)

tStats[, 4:ncol(tStats)] <- round(tStats[, 4:ncol(tStats)], 2)

act.stats= (data.frame(t(tStats[, -c(1,2)])))
write.csv(as.data.frame(act.stats),
          file="D:/2017-2018/data_analysis/technical_analysis/data/raw/act.stats.csv",
          quote= FALSE)

## =======================

## ref on weird trading stats results & limits to trading 
## https://stackoverflow.com/questions/49945081/quantstrat-trade-statistics-yielding-100-cumulative-returns

## stats for RSI 
# table(mktdata$rsi14sell)
# table(mktdata$rsi14buy)

## ===========

## BLOCCA
## how our portfolio does through time. We plot this below as well as 
## the cumulative return plots 
# 
# final.acct <- getAccount(account.st)
# end.eq <- final.acct$summary$End.Eq
# returns <- 
#   PerformanceAnalytics::Return.calculate(end.eq, 
#                                          method="discrete") # method="log"
# 
# # 
# charts.PerformanceSummary(returns, colorset = bluefocus,
#                           main = "Strategy Performance")




# ## plot performance of the trading rule
# PerformanceAnalytics::charts.PerformanceSummary(
#   rets, main= "Performance Summary",colorset = bluefocus)
# 
# ## plots
# par(mfrow=c(3,2))
# for(symbol in symbols) {
#   blotter::chart.Posn(Portfolio=portfolio.st,
#                       Symbol=symbol,log=TRUE)
# }


## ====== Summaries ============

## ~~ Blotter's functions build and manipulate objects that are stored in 
## an environment named ".blotter". To show them, Use 
# ls(envir=.blotter) 


## some other stats

# summary(getStrategy(strategy.st) )
# summary(getPortfolio(portfolio.st))
# ## summary(getAccount("strat.rsi"))
# summary(getOrders(portfolio.st, symbol= symbols))
# summary(quantstrat::getOrderBook(portfolio.st), symbol= symbols)
# head(.blotter$account.acct.full$summary)
# tail(.blotter$account.acct.full$summary)


## export done only once
# acc1 <- getAccount("acct.full")
# # Retrieves the most recent value of the capital account
# equity <- acc1$summary$End.Eq[-1,] 
# png('D:/2017-2018/data_analysis/technical_analysis/report/equity_active.png',
#      width = 1800, height = 900)
# plot(equity, main = "Equity Curve Active portfolio")
# dev.off()

## TENIAMO OFF
# rets <- PortfReturns(Account = "acct.full")
# PerformanceAnalytics::chart.CumReturns(
#   rets, colorset = rich10equal, 
#   legend.loc = "topleft", 
#   main="SPDR Cumulative Returns")