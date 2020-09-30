## Miller's code (https://ntguardian.wordpress.com/2017/04/03/introduction-stock-market-data-r-2/)

# library(quantmod)
library(IKTrading)

## ===== get data ==========

start <- as.Date("2010-01-01")
end <- as.Date("2016-10-01")

# Let's get Apple stock data; Apple's ticker symbol is AAPL. We use the quantmod function getSymbols, and pass a string as a first argument to identify the desired ticker symbol, pass "yahoo" to src for Yahoo! Finance, and from and to specify date ranges

# The default behavior for getSymbols is to load data directly into the global environment, with the object being named after the loaded ticker symbol. This feature may become deprecated in the future, but we exploit it now.

getSymbols("AAPL", src="yahoo", from = start, to = end)

## ===== some charting with SMA's =========
candleChart(AAPL, up.col = "black", 
            dn.col = "red", theme = "white", 
            subset = "2016-01-04/")

AAPL_sma_20 <- SMA(
  Cl(AAPL),  # The closing price of AAPL, obtained by quantmod's Cl() function
  n = 20     # The number of days in the moving average window
)

AAPL_sma_50 <- SMA(
  Cl(AAPL),
  n = 50
)

AAPL_sma_200 <- SMA(
  Cl(AAPL),
  n = 200
)

zoomChart("2016")  # Zoom into the year 2016 in the chart
addTA(AAPL_sma_20, on = 1, col = "red")  # on = 1 plots the SMA with price
addTA(AAPL_sma_50, on = 1, col = "blue")
addTA(AAPL_sma_200, on = 1, col = "green")

## ======== 1. create indicators by comparing SMA crossing  ========
AAPL_trade <- AAPL
AAPL_trade$`20d` <- AAPL_sma_20
AAPL_trade$`50d` <- AAPL_sma_50

regime_val <- sigComparison("", data = AAPL_trade,
                            columns = c("20d", "50d"), relationship = "gt") -
  sigComparison("", data = AAPL_trade,
                columns = c("20d", "50d"), relationship = "lt")

plot(regime_val["2016"], main = "Regime", ylim = c(-2, 2))

plot(regime_val, main = "Regime", ylim = c(-2, 2))

## regime and main series in the same chart
candleChart(AAPL, up.col = "black", dn.col = "red", theme = "white", subset = "2016-01-04/")
addTA(regime_val, col = "blue", yrange = c(-2, 2))
addLines(h = 0, col = "black", on = 3)
addSMA(n = c(20, 50), on = 1, col = c("red", "blue"))
# zoomChart("2016")

## count how many bullish and how many bearish days there were  (i.e. buy vs sell)
table(as.vector(regime_val))


## generate signals out of the regimes -- actual triggering of mkt operations
sig <- diff(regime_val) / 2
plot(sig, main = "Signal", ylim = c(-2, 2))
table(sig)


## ====== computing profitability =====

# The Cl function from quantmod pulls the closing price from the object
# holding a stock's data
# Buy prices
Cl(AAPL)[which(sig == 1)]
# Sell prices
Cl(AAPL)[sig == -1]
# Since these are of the same dimension, computing profit is easy
as.vector(Cl(AAPL)[sig == 1])[-1] - Cl(AAPL)[sig == -1][-table(sig)[["1"]]]


candleChart(AAPL, up.col = "black", dn.col = "red", theme = "white")
addTA(regime_val, col = "blue", yrange = c(-2, 2))
addLines(h = 0, col = "black", on = 3)
addSMA(n = c(20, 50), on = 1, col = c("red", "blue"))
zoomChart("2014-05/2014-07")


## ########################################################## ##
## ============ 2. ADJUSTING ALL DATA ========================

getSymbols(Symbols = symbols, src = "yahoo", from = start, to = end)
## Quickly define adjusted versions of each of these
`%s%` <- function(x, y) {paste(x, y)}
`%s0%` <- function(x, y) {paste0(x, y)}
for (s in symbols) {
  eval(parse(text = s %s0% "_adj <- adjustOHLC(" %s0% s %s0% ")"))
}
symbols_adj <- paste(symbols, "adj", sep = "_")


## here uses quantstrat to manage portfolios

## =============== some trading rule indicators =============

## Indicators are used to construct signals
add.indicator(strategy = strategy_st, name = "SMA",     # SMA is a function
              arguments = list(x = quote(Cl(mktdata)),  # args of SMA
                               n = 20),
              label = "fastMA")

add.indicator(strategy = strategy_st, name = "SMA",
              arguments = list(x = quote(Cl(mktdata)),
                               n = 50),
              label = "slowMA")

## ============= Next comes trading signals =======
add.signal(strategy = strategy_st, name = "sigComparison",  # Remember me?
           arguments = list(columns = c("fastMA", "slowMA"),
                            relationship = "gt"),
           label = "bull")

add.signal(strategy = strategy_st, name = "sigComparison",
           arguments = list(columns = c("fastMA", "slowMA"),
                            relationship = "lt"),
           label = "bear")


## ============== rules that generate trades ============
## BUY
add.rule(strategy = strategy_st, name = "ruleSignal",  # Almost always this one
         arguments = list(sigcol = "bull",  # Signal (see above) that triggers
                          sigval = TRUE,
                          ordertype = "market",
                          orderside = "long",
                          replace = FALSE,
                          prefer = "Open",
                          osFUN = osMaxDollar,
                          # The next parameter, which is a parameter passed to
                          # osMaxDollar, will ensure that trades are about 10%
                          # of portfolio equity
                          maxSize = quote(floor(getEndEq(account_st,
                                                         Date = timestamp) * .1)),
                          tradeSize = quote(floor(getEndEq(account_st,
                                                           Date = timestamp) * .1))),
         type = "enter", path.dep = TRUE, label = "buy")

## SELL
add.rule(strategy = strategy_st, name = "ruleSignal",
         arguments = list(sigcol = "bear",
                          sigval = TRUE,
                          orderqty = "all",
                          ordertype = "market",
                          orderside = "long",
                          replace = FALSE,
                          prefer = "Open"),
         type = "exit", path.dep = TRUE, label = "sell")

## ======================= Execution =======

## Execution of the strategy 
applyStrategy(strategy_st, portfolios = portfolio_st)

## Update profile
updatePortf(portfolio_st)

dateRange <- time(getPortfolio(portfolio_st)$summary)[-1]
updateAcct(portfolio_st, dateRange)

updateEndEq(account_st)

## And some statistics
tStats <- tradeStats(Portfolios = portfolio_st, use="trades",
                     inclZeroDays = FALSE)
tStats[, 4:ncol(tStats)] <- round(tStats[, 4:ncol(tStats)], 2)
print(data.frame(t(tStats[, -c(1,2)])))

final_acct <- getAccount(account_st)
plot(final_acct$summary$End.Eq["2010/2016"], main = "Portfolio Equity")

## ======================================================== ## 
## ========= 3. ENLARGE PORTFOLIO ============================

start = "2018-01-01"
end = "2018-07-01"

# Get new symbols
symbols = c("AAPL", "MSFT", "GOOG", "FB", "TWTR", "NFLX", "AMZN", "YHOO",
            "SNY", "NTDOY", "IBM", "HPQ")
quantmod::getSymbols(Symbols = symbols, from = start, to = end)
# Quickly define adjusted versions of each of these
`%s%` <- function(x, y) {paste(x, y)}
`%s0%` <- function(x, y) {paste0(x, y)}
for (s in symbols) {
  eval(parse(text = s %s0% "_adj <- adjustOHLC(" %s0% s %s0% ")"))
}
initDate = "1990-01-01"
symbols_adj <- paste(symbols, "adj", sep = "_")
currency("USD")
stock(symbols_adj,currency= "USD" ,multiplier = 1)
init
strategy_st_2 <- portfolio_st_2 <- account_st_2 <- "SMAC-20-50_v2"
rm.strat(portfolio_st_2)
rm.strat(strategy_st_2)
initPortf(portfolio_st_2, symbols = symbols_adj,
          initDate = initDate, currency = "USD")
initAcct(account_st_2, portfolios = portfolio_st_2,
         initDate = initDate, currency = "USD",
         initEq = 1000000)
initOrders(portfolio_st_2, store = TRUE)

strategy(strategy_st_2, store = TRUE)

add.indicator(strategy = strategy_st_2, name = "SMA",
              arguments = list(x = quote(Cl(mktdata)),
                               n = 20),
              label = "fastMA")
add.indicator(strategy = strategy_st_2, name = "SMA",
              arguments = list(x = quote(Cl(mktdata)),
                               n = 50),
              label = "slowMA")

# Next comes trading signals
add.signal(strategy = strategy_st_2, name = "sigComparison",  # Remember me?
           arguments = list(columns = c("fastMA", "slowMA"),
                            relationship = "gt"),
           label = "bull")
add.signal(strategy = strategy_st_2, name = "sigComparison",
           arguments = list(columns = c("fastMA", "slowMA"),
                            relationship = "lt"),
           label = "bear")

# Finally, rules that generate trades
add.rule(strategy = strategy_st_2, name = "ruleSignal",
         arguments = list(sigcol = "bull",
                          sigval = TRUE,
                          ordertype = "market",
                          orderside = "long",
                          replace = FALSE,
                          prefer = "Open",
                          osFUN = osMaxDollar,
                          maxSize = quote(floor(getEndEq(account_st_2,
                                                         Date = timestamp) * .1)),
                          tradeSize = quote(floor(getEndEq(account_st_2,
                                                           Date = timestamp) * .1))),
         type = "enter", path.dep = TRUE, label = "buy")
add.rule(strategy = strategy_st_2, name = "ruleSignal",
         arguments = list(sigcol = "bear",
                          sigval = TRUE,
                          orderqty = "all",
                          ordertype = "market",
                          orderside = "long",
                          replace = FALSE,
                          prefer = "Open"),
         type = "exit", path.dep = TRUE, label = "sell")

applyStrategy(strategy_st_2, portfolios = portfolio_st_2)

# Now for analytics
updatePortf(portfolio_st_2)


## =====
dateRange <- time(getPortfolio(portfolio_st_2)$summary)[-1]
updateAcct(account_st_2, dateRange)

updateEndEq(account_st_2)


tStats2 <- tradeStats(Portfolios = portfolio_st_2, use="trades",
                      inclZeroDays = FALSE)
tStats2[, 4:ncol(tStats2)] <- round(tStats2[, 4:ncol(tStats2)], 2)
print(data.frame(t(tStats2[, -c(1,2)])))

final_acct2 <- getAccount(account_st_2)
plot(final_acct2$summary$End.Eq["2010/2016"], main = "Portfolio Equity")


## ============ 4. BENCHMARKING ===========

# one should always buy an index fund that merely reflects the composition of the market.
# SPY is an exchange-traded fund (a mutual fund that is traded on the market like a stock) 
# whose value effectively represents the value of the stocks in the S&P 500 stock index. 
# By buying and holding SPY, we are effectively trying to match our returns with the market 
# rather than beat it.
  

getSymbols("SPY", from = start, to = end)

# A crude estimate of end portfolio value from buying and holding SPY
1000000 * (SPY$SPY.Adjusted["2016-09-30"][[1]] / SPY$SPY.Adjusted[[1]])

plot(final_acct2$summary$End.Eq["2010/2016"] / 1000000,
     main = "Portfolio Equity", ylim = c(0.8, 2.5))
lines(SPY$SPY.Adjusted / SPY$SPY.Adjusted[[1]], col = "blue")
