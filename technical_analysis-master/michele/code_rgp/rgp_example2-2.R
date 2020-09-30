library(rgp)
options(digits = 5)
stepsGenerations <- 100
initialPopulation <- 100
Steps <- c(10)
y <- china_train_effort   #
x <- china_train_size  # 

data2 <- data.frame(y, x)  # create a data frame with effort, size
# newFuncSet <- mathFunctionSet
# alternatives to mathFunctionSet
# newFuncSet <- expLogFunctionSet # sqrt", "exp", and "ln"
# newFuncSet <- trigonometricFunctionSet
# newFuncSet <- arithmeticFunctionSet
newFuncSet <- functionSet("+","-","*", "/","sqrt", "log", "exp") 

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