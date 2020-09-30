
quantmod::getSymbols(c("AIR.PA","MC.PA"),src = 'yahoo',
                     from = "2012-12-28",to = "2018-12-31",
                     auto.assign = TRUE, warnings = FALSE )

## ============ SIMPLE FILTER BUY RULE =====
library(quantmod)
library(magrittr)

# prices <- merge(Cl(AIR.PA), Cl(MC.PA)) # close price
pricesVolumes <- merge(Cl(AIR.PA),Vo(AIR.PA), Cl(MC.PA),Vo(MC.PA)) # closing prices
names= colnames(pricesVolumes)

# epsilon1 <- pricesVolumes[,1]/Lag(pricesVolumes[,1]) - 1 # % price change
# epsilon2 <- pricesVolumes[,3]/Lag(pricesVolumes[,3]) - 1 # % price change


epsilon = merge( pricesVolumes[,1]/Lag(pricesVolumes[,pricesVolumes]), # prices movements
                 pricesVolumes[,3]/Lag(pricesVolumes[,3]) - 1 ) %>%
  'colnames<-'(c(names[1],names[3]))

## not useful if the line above works
# colnames(epsilon) <- (c(names[1],names[3]))
  
delta <-0.005 #threshold
## for more than one stock, need to create a matrix fixing no. of rows and cols
signals <- matrix(NA ,nrow = length(pricesVolumes[,1]) ,ncol = length(epsilon[1]) )

# Loop over all trading days (except the first) for each stock
for (j in 1:length(epsilon[1])){
  for (i in 2: length(pricesVolumes[,1])) {
      if (epsilon[i,j] > delta){
      signals[i,j]<- 1
  } else
    signals[i,j]<- 0
}
}

# Assign time to action variable using reclass;
signals <- 
  reclass(signals,pricesVolumes) %>%
  `colnames<-` (c(names[1],names[3]))

##  ========================== Charting =======

chartSeries (AIR.PA ,
            type="line",
            name = "Line chart & Trading signals, closing, Air France",
            subset='2013',
            theme=chartTheme('white'))
addTA(Cl(MC.PA), col='red')

## ==== trying to overimposing charts ~~ not possible
# chart_Series(Cl(AIR.PA),
#              name = "Line chart & Trading signals, closing, Air France",
#              subset='2013' )
#              
# add_TA(Cl(MC.PA), col='green')
## ===== ## 

## only way to plot multiple price charts at once -- not possible with quantmod::chartSeries
## ~~ can also try using highcharter::highchart	for html file
PerformanceAnalytics::chart.TimeSeries(
  merge(pricesVolumes[,1],pricesVolumes[,3]), 
  main="Line chart & Trading signals, closing, Air France",
  legend.loc = "topleft" )
## save from R plots panel


## ========== Put everything together ================

# trades <- Lag(signals,1) # trade based on yesterday signal
trades <- merge(Lag(pricesVolumes[,1]),Lag(pricesVolumes[,3])) %>%
  'colnames<-' (c(names[1], names[3]))

##
## To keep it simple, we evaluate using day trading:
## buy at open
## sell at close
## trading size: all in
##

ret<-merge(dailyReturn(AIR.PA)*trades[,1], dailyReturn(MC.PA)*trades[,2]) ## what does this do?
names(ret)<- c("filter AIR.PA","filter MC.PA")
## ~~ can't plot two price charts at once
PerformanceAnalytics::charts.PerformanceSummary(ret[,1], main="Naive Buy Rule AIR.PA")
PerformanceAnalytics::charts.PerformanceSummary(ret[,2], main="Naive Buy Rule MC.PA")
## save from R plots panel


## =========================================== ##
## ====== BUY AND SELL FILTER RULE ==============

## 
## THIS PART NEEDED IF THE ONE ABOVE IS NOT RUN
## 

# pricesVolumes <- merge(Cl(AIR.PA),Vo(AIR.PA), Cl(MC.PA),Vo(MC.PA)) # close price
# names= colnames(pricesVolumes)
# 
# epsilon = merge( pricesVolumes[,1]/Lag(pricesVolumes[,pricesVolumes]), # prices movements
#                  pricesVolumes[,3]/Lag(pricesVolumes[,3]) - 1 ) %>%
#   'colnames<-'(c(names[1],names[3]))
# signals <- matrix(NA ,nrow = length(pricesVolumes[,1]) ,ncol = length(epsilon[1]) )
# 
# # Loop over all trading days (except the first) for each stock
# for (j in 1:length(epsilon[1])){
#   for (i in 2: length(pricesVolumes[,1])) {
#     if (epsilon[i,j] > delta){
#       signals[i,j]<- 1
#     } else
#       signals[i,j]<- 0
#   }
# }
# 
# signals <- 
#   reclass(signals,pricesVolumes) %>%
#   `colnames<-` (c(names[1],names[3]))
# 
# 
# trades <- merge(Lag(pricesVolumes[,1]),Lag(pricesVolumes[,3])) %>%
#   'colnames<-' (c(names[1], names[3]))
# ret <- merge(dailyReturn(AIR.PA)*trades[,1], dailyReturn(MC.PA)*trades[,2])
# 
# PerformanceAnalytics::charts.PerformanceSummary(ret[,1])

## ========== code for the RSI rule =====

day <-14
signals2 <- matrix(NA ,nrow = length(pricesVolumes[,1]) ,
                   ncol = length(epsilon[1]) ) #initialize vector

rsi <- merge(RSI(pricesVolumes[,1], day), 
             RSI(pricesVolumes[,3],day) )    #rsi is the lag of RSI

signals2 [1:(day+1)] <- 0            #0 because no signal until day+1
for (j in 1:length(epsilon[1])) {
  for (i in (day+1): length(pricesVolumes[,1])){
      if (rsi[i,j] < 30){             #buy if rsi < 30
        signals2[i,j] <- 1
      } else { #no trade all if rsi > 30
        signals2[i,j] <- 0
      }
  }
}

## more efficient
# for (i in 1:length(price)){
#   signals2[i] <- 0
#   if (isTRUE(rsi[i] < 30)){             
#     signals2[i] <- 1
#   }
# }

signals2<-reclass(signals2,Cl(AIR.PA)) #%>%
  `colnames<-`("Signal")

trades2 <- merge(Lag(signals2[,1]),Lag(signals2[,2]))

#construct a new variable ret1
ret1 <- dailyReturn(AIR.PA)*trades
names(ret1) <- 'Naive'
# construct a new variable ret2
ret2 <- dailyReturn(AIR.PA)*trades2
names(ret2) <- 'RSI'

## compare the two
retall <- cbind(ret1, ret2)
PerformanceAnalytics::charts.PerformanceSummary(retall, 
                                                main="Naive v.s. RSI")
