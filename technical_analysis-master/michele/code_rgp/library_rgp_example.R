# install.packages("rgp")
library(rgp)
Fset <- functionSet("+", "*", "-")
Var <- inputVariableSet("x")
cFset <- constantFactorySet(function()rnorm(1))


int <- seq(from = -1, to = 1, by = 0.01)

y <- int*sin(int)
plot(y)
fF <- function(f) rgp::rmse(f(int), y) # rmse(actual, predicted)

set.seed(1)
res <- geneticProgramming(  functionSet = Fset,
                            inputVariables = Var,
                            constantSet = cFset,
                            fitnessFunction = fF,
                            stopCondition = makeTimeStopCondition(100))


best_res <- res$population[[which.min(res$fitnessValues)]]
best_res

plot(y = best_res(int), x = int, type = "l",lty = 1, xlab = "x", ylab = "y")
lines(y, x = int, lty = 2)
