library(rgp)
library(caTools)

# install.packages("rgpui")
# library(rgpui)
# symbolicRegressionUi()

# =========== create training and testing dataframes ===========
airbus = read.csv("D:/2017-2018/data_analysis/technical_analysis/michele/data/processed/AIR.PA_airbus.csv", header = TRUE )
# require(caTools)
set.seed(101) 
sample.airbus = caTools::sample.split(airbus$AIR.PA.Close, SplitRatio = .75)
train.airbus = subset(airbus, sample.airbus == TRUE)
test.airbus  = subset(airbus, sample.airbus == FALSE)

closing.train= train.airbus$AIR.PA.Close
closing.testing = test.airbus$AIR.PA.Close
# ================== create functions =========================

## lag function
lagpad <- function(x= closing.train, k=NULL) {
  if (!is.vector(x)) 
    stop('x must be a vector')
  if (!is.numeric(x)) 
    stop('x must be numeric')
  if (!is.numeric(k))
    stop('k must be numeric')
  if (1 != length(k))
    stop('k must be a single number')
  lag= c(rep(NA, k), x)[1 : length(x)] 
  return(lag)
} #ok

## max (min) of a ts (not an MA!) over past n days

maxTs = function(x= closing.train, k=NULL) {
  if (!is.vector(x)) 
    stop('x must be a vector')
  if (!is.numeric(x)) 
    stop('x must be numeric')
  if (!is.numeric(k))
    stop('k must be numeric')
  if (1 != length(k))
    stop('k must be a single number')
  tmp= c(rep(NA, k), x)[1 : length(x)] 
  return (tmp[which.max(tmp)] )# so that you can have the entire lagged series
} # ok


## min(lag) function
minTs = function(x= closing.train, k=NULL) {
  if (!is.vector(x)) 
    stop('x must be a vector')
  if (!is.numeric(x)) 
    stop('x must be numeric')
  if (!is.numeric(k))
    stop('k must be numeric')
  if (1 != length(k))
    stop('k must be a single number')
  tmp= c(rep(NA, k), x)[1 : length(x)] 
  return(tmp[which.min(tmp)])
}

## volatility of the ts
volatility= function(x= closing.train, k=NULL){
  z= forecast::ma(x, order= k ) 
  z_sd = stats::sd(z, na.rm = TRUE)
  # return(z_sd)
} # OK

## price

## constant
# constant= function(x=rnorm(10), i= sample(1:10,1)){
#   if (!is.vector(x)) 
#     stop('x must be a vector')
#   if (!is.numeric(x)) 
#     stop('x must be numeric')
#   if (!is.numeric(i))
#     stop('i must be numeric')
#   if (1 != length(i))
#     stop('i must be a single number')
#   if (i <1 | i> length(x) ) 
#     stop('i must be between 1 and legnth(x)')
#   return(x[i])
# }

## moving average 
ma <- function(x= closing.train, k=NULL) {
  if (!is.vector(x)) 
    stop('x must be a vector')
  if (!is.numeric(x)) 
    stop('x must be numeric')
  if (!is.numeric(k))
    stop('k must be numeric')
  if (1 != length(k))
    stop('k must be a single number')
  movAv = rep("", times=length(x)-k)
  j = 0
  lag = c(rep(NA, k), x)[1 : length(x)]
  # z = lag[!is.na(lag)]
  for (i in (k+1:length(lag)-k)) {
    j = j +1
    m= (sum(lag[i : i+k]))/k
    movAv[j]= m }
  
  return(movAv)
}
# ========= geneticProgramming function arguments =====================
  
funcSetMic <<- rgp::functionSet("+","-","*", "/","<",">","|","&","!=")
vars <<- rgp::inputVariableSet("closing.train") ## input variables

## cfr Potvin et al 2004
cFset = rgp::constantFactorySet(c(ma(), maxTs(), minTs(), lagpad(), volatility()) )

## returns from buy-and-hold strategy

# pZero = airbus$AIR.PA.Close[1]
# pFinal = airbus$AIR.PA.Close[length(airbus$AIR.PA.Close)]
# 
# buyHReturn = exp(log(pFinal) - log(pZero))-1 # relative return of buy & hold

buyHReturn = function(x=rnorm(10)) {
  if (!is.vector(x)) 
    stop('x must be a vector')
  if (!is.numeric(x)) 
    stop('x must be numeric')
  pZero= x[1]; pFinal= x[(length(x))]
  r= exp(log(pFinal)- log(pZero))-1
  return(r)
}

## returns from active strategy
activeReturn = function(x=rnorm(10)) {
  if (!is.vector(x)) 
    stop('x must be a vector')
  if (!is.numeric(x)) 
    stop('x must be numeric')
  returns= rep("", length(x))
  j=0
  for (i in (1:length(x)-1)){
    r= log(x[i])-log(x[i+1])
    j= j+1
    returns[j]= r  }
  actRet= sum(returns[i]: returns[length(returns)]) -1
  return(actRet)
}

# ============ fitness Function ===============================================================
fF = function(x=rnorm(10)) {
  spread= activeReturn(x)- buyHReturn(x)
  return(spread)
  
}

## approfondisci guardando la vignette
# mutationFn=function(func) {# set the mutation Funation function: added from book
#   mutateSubtree(func,funcset=funcset,inset=input, conset= rnorm(1), ## questo conset puo' dare problemi
#   mutatesubtreeprob=0.1,maxsubtreedepth=4) 
#   
# }

# ===================== execute GP search ===============================================================

results = rgp::geneticProgramming( functionSet = funcSet,
                            inputVariables = vars,
                            constantSet = cFset,
                            fitnessFunction = fF,
                            stopCondition = makeTimeStopCondition(30),
                            # three lines below are from book:
                            populationSize=50,
                            #mutationFunction=mut,
                            verbose=TRUE) 
## this stop condition is in seconds


bestRes = results$population[[which.min(results$fitnessValues)]]
bestRes

## =================================================
## =============== symbolic regression =============
## =================================================
## has nothing to do with our GP

## ref https://danrodgar.github.io/DASE/advanced-models.html#genetic-programming-for-symbolic-regression


# library("rgp")
options(digits = 5)
stepsGenerations <- 100
# initialPopulation <- 100
Steps <- c(10)
# y <- china_train_effort   #
# x <- china_train_size  # 

# data2 <- data.frame(y, x)  # create a data frame with effort, size
# newFuncSet <- mathFunctionSet
# alternatives to mathFunctionSet
# newFuncSet <- expLogFunctionSet # sqrt", "exp", and "ln"
# newFuncSet <- trigonometricFunctionSet
# newFuncSet <- arithmeticFunctionSet
newFuncSet <- functionSet("+","-","*", "/","sqrt", "log", "exp") # ,, )

gpresult <- symbolicRegression(y ~ x, 
                               data=data2, functionSet=newFuncSet,
                               populationSize=initialPopulation,
                               stopCondition=makeStepsStopCondition(stepsGenerations))

bf <- gpresult$population[[which.min(sapply(gpresult$population, gpresult$fitnessFunction))]]
wf <- gpresult$population[[which.max(sapply(gpresult$population, gpresult$fitnessFunction))]]

bf1 <- gpresult$population[[which.min((gpresult$fitnessValues))]]
plot(x,y)
lines(x, bf(x), type = "l", col="blue", lwd=3)
lines(x,wf(x), type = "l", col="red", lwd=2)