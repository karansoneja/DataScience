## source file:///C:/Users/damic/Downloads/slides__Quantitative%20Finance%20Using%20R.pdf
## Faber, Mebane T., "A Quantitative Approach to Tactical Asset Allocation."
## GitHub https://github.com/R-Finance/quantstrat/blob/master/demo/faber.R


## packages used
# FinancialInstrument
# quantmod
# blotter
# quantstrat
# TTR
# xts

# run
# demo('faber')
# from inside R

# Buy when monthly price > 10-month SMA.
# Sell and move to cash when monthly price < 10-month SMA.
# 10 years of monthly data, S&P Sector ETFs.
# No shorting, 'sell' goes to cash
# Positions are fixed.

currency('USD')
symbols = c("XLF", "XLP", "XLE", "XLY", "XLV", "XLI", "XLB", "XLK",
            "XLU")
for(symbol in symbols){ stock(symbol, currency="USD",multiplier=1) }
getSymbols(symbols, src='yahoo', index.class=c("POSIXt","POSIXct"),
           from='1998-01-01')
for(symbol in symbols) {
  x<-get(symbol)
  x<-to.monthly(x,indexAt='lastof',drop.time=TRUE)
  colnames(x)<-gsub("x",symbol,colnames(x))
  assign(symbol,x)
}

## initialize
initPortf('faber', symbols=symbols, initDate='1997-12-31')
initAcct('faber', portfolios='faber', initDate='1997-12-31')
initOrders(portfolio='faber', initDate='1997-12-31')
strategy("faber", store=TRUE)

## indicators
add.indicator(strategy = 'faber', name = " SMA", 
              arguments = list(x = quote(Cl(mktdata)), n=10), label="SMA10")

## signals
add.signal(strategy='faber', name="sigCrossover", arguments = list
           (data=quote(mktdata), columns=c("Close","SMA"), relationship="gt"),
           label="Cl.gt.SMA")
add.signal(strategy='faber',name="sigCrossover", arguments = list
           (data=quote(mktdata), columns=c("Close","SMA"), relationship="lt"),
           label="Cl.lt.SMA")
## rules
add.rule(strategy='faber', name='ruleSignal', arguments = list
         (data=quote(mktdata), sigcol="Cl.gt.SMA", sigval=TRUE, orderqty=100,
           ordertype='market', orderside=NULL, threshold=NULL), type='enter')
add.rule(strategy='faber', name='ruleSignal', arguments = list
         (data=quote(mktdata), sigcol="Cl.lt.SMA", sigval=TRUE, orderqty='all',
           ordertype='market', orderside=NULL, threshold=NULL), type='exit')

## evaluate performance
out <- applyStrategy(strategy='faber' , portfolios='faber')
updatePortf(Portfolio='faber')