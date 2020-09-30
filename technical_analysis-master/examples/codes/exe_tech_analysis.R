data= read.csv("data/raw/spy_historical_data.txt")
# library (TTR)
head(data)
colnames(data)

# simple MA(20)
sma20 = TTR:: SMA(data [c ('CLOSE')],n=20)
head(sma20, n=50)

# bollinger bands
bb20 = TTR::BBands(data[c("CLOSE")], sd= 2.0)
head(bb20, n=30)

# create new dataframe with our prev data + BB indicator
dataPlusBB = data.frame(data,bb20)

# plot BB indicator and MA 
plot(dataPlusBB$DATE_TIME, data$CLOSE)
lines(dataPlusBB$CLOSE, col = "red")
lines(dataPlusBB$up, col = "purple")
lines(dataPlusBB$dn, col = "brown")
lines(dataPlusBB$mavg, col = "blue")

## bbEMA exponential MA with Bollinger bands
bbEMA = TTR::BBands(data$CLOSE, sd=2.0, n=14, maType=TTR::EMA)

# RSI relative strength index
rsi14 = TTR::RSI(data$CLOSE, n=14)

# MACD moving average convergence divergence
macd = TTR::MACD(data$CLOSE, nFast=12, nSlow=26, nSig=9, maType=TTR::SMA)

# join all indicators in one table
allData = data.frame(data,sma20,bb20,rsi14,macd)

# export data in a .csv file
write.table(allData, file="spy_with_indicators.csv", na="", sep=",", row.names = FALSE)
