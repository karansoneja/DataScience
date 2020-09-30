symbols = c("MC.PA","AIR.PA")
quantmod::getSymbols(c("AIR.PA","MC.PA"),src = 'yahoo',
                     from = "2012-12-28",to = "2018-12-31",
                     auto.assign = TRUE, warnings = FALSE )

## ============ simple filter buy rule =====

price <- Cl(AIR.PA) # close price
r <- price/Lag(price) - 1 # % price change
delta <-0.005 #threshold
signal <-c(0) # first date has no signal

#Loop over all trading days (except the first)
for (i in 2: length(price)){
  if (r[i] > delta){
    signal[i]<- 1
  } else
    signal[i]<- 0
}

# Assign time to action variable using reclass;
signal<- 
  reclass(signal,price) %>%
  `colnames<-`("Signal")

## Charting

chartSeries(AIR.PA,
            type="line",
            name = "Line chart & Trading signals, closing, Air France",
            subset='2013',
            theme=chartTheme('white'))


addTA(signal, type= "S", col= "red") # here can add custom indicator

saveChart("png",width= 12,
          #path = "D:/2017-2018/data_analysis/technical_analysis/michele/output/linechart.png",
          # path can't be set. it goes to the working direcory
          width = 9, height = 6, units= "in", res= 300 )


## ========== Put everything together ================

trade <- Lag(signal,1) # trade based on yesterday signal

##
## To keep it simple, we evaluate using day trading:
## buy at open
## sell at close
## trading size: all in
##

ret<-dailyReturn(AIR.PA)*trade
names(ret)<-"filter"
PerformanceAnalytics::charts.PerformanceSummary(ret, main="Naive Buy Rule")
## save from R plots panel

## ====== buy and sell filter  rule ==============

# price <- Cl(AIR.PA)
# r <- price/Lag(price) - 1
# delta<-0.005
signal2 <-c(NA) # first signal is NA

for (i in 2: length(Cl(AIR.PA))){
  if (r[i] > delta){
    signal2[i]<- 1
  } else if (r[i]< -delta){
    signal2[i]<- -1
  } else
    signal2[i]<- 0
}

signal2<-reclass(signal2,Cl(AIR.PA))%>%
  `colnames<-`("Signal")

trade1 <- Lag(signal2)
ret1<-dailyReturn(AIR.PA)*trade1
names(ret1) <- 'Naive'
PerformanceAnalytics::charts.PerformanceSummary(ret1)

## ====================================

# price <- Cl(AIR.PA)
day <-14
signal3 <- c()                    #initialize vector
rsi <- RSI(price, day)     #rsi is the lag of RSI
signal3 [1:day+1] <- 0            #0 because no signal until day+1

for (i in (day+1): length(price)){
  if (rsi[i] < 30){             #buy if rsi < 30
    signal3[i] <- 1
  }else {                       #no trade all if rsi > 30
    signal3[i] <- 0
  }
}

## more efficient
# for (i in 1:length(price)){
#   signal3[i] <- 0
#   if (isTRUE(rsi[i] < 30)){             
#     signal3[i] <- 1
#   }
# }

signal3<-reclass(signal3,Cl(AIR.PA))%>%
  `colnames<-`("Signal")
trade2 <- Lag(signal3)

#construct a new variable ret1
ret1 <- dailyReturn(AIR.PA)*trade1
names(ret1) <- 'Naive'
# construct a new variable ret2
ret2 <- dailyReturn(AIR.PA)*trade2
names(ret2) <- 'RSI'

## compare the two
retall <- cbind(ret1, ret2)
PerformanceAnalytics::charts.PerformanceSummary(retall, 
                                                main="Naive v.s. RSI")
