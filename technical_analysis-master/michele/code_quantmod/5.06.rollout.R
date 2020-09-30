ClosePrice <- as.numeric(Cl(AIR.PA[1,]))
UnitSize = as.numeric(trunc(equity/ClosePrice))

## entry order
for (p in 1:prices[2,]){
  ClosePrice <- as.numeric(prices[1,p])
  UnitSize = as.numeric(trunc(equity/ClosePrice))
  addTxn("portf.buyHold", Symbol = symbols[p], 
         TxnDate = CurrentDate, 
         TxnPrice = as.numeric(prices[1,p]),
         TxnQty = UnitSize, 
         TxnFees = 0) }
  
  
## exit order
for (p in 1:prices[2,]) {
  LastDate <- last(time(prices[1,]))
  LastPrice <- as.numeric(as.numeric(last(prices[,p])))
  addTxn("portf.buyHold", Symbol = sym, TxnDate = LastDate, TxnPrice = LastPrice,
         TxnQty = -UnitSize , TxnFees = 0)
}

#######===========

symbols = c("FP.PA","MC.PA","SAN.PA","AIR.PA","OR.PA" )
tmp= vector( length= 5)
i= 0
for (sym in symbols){
  
  tmp = as.numeric(first(Cl(sym[1,])))
  
  }


## ==============

# place an entry order
# CurrentDate <- time(getTxns(Portfolio = "portf.buyHold", Symbol = "AIR.PA"))#[2]
CurrentDate <- from
equity = getEndEq("acct.buyHold", CurrentDate)
firstPrice <- as.numeric(Cl(AIR.PA[CurrentDate,]))


UnitSize = as.numeric(trunc(equity/firstPrice))

## entry order
addTxn("portf.buyHold", Symbol = symbols[1], TxnDate = CurrentDate, TxnPrice = firstPrice,
       TxnQty = UnitSize, TxnFees = 0)



as.numeric(Cl(sym[LastDate,]))

as.numeric(last(AIR.PA$AIR.PA.Close))


## ============

prices= merge.xts(Cl(FP.PA),Cl(MC.PA),Cl(SAN.PA),Cl(AIR.PA),Cl(OR.PA))

