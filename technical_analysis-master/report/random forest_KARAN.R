library(quantmod)
library(rpart)
library(rpart.plot)
library(ROCR)
library(caret)
library(randomForest)
library(plotly)
library(ggplot2)
library (cowplot)
library(randomForest)
require(caTools)

#importing data dor all the stocks with their respective variables


##AIR LIQUIDE

AI_FINALDATA

dim(AI_FINALDATA)
summary(AI_FINALDATA)
sapply(AI_FINALDATA, class)
str(AI_FINALDATA)

##AIRBUS 
AIRBUS_FINALDATA

dim(AIRBUS_FINALDATA)
summary(AIRBUS_FINALDATA)
sapply(AIRBUS_FINALDATA, class)
str(AIRBUS_FINALDATA)

##BNP
BNP_FINALDATA
dim(BNP_FINALDATA)
summary(BNP_FINALDATA)
sapply(BNP_FINALDATA, class)
str(BNP_FINALDATA)

##DANONE
DANONE_FINALDATA
dim(DANONE_FINALDATA)
summary(DANONE_FINALDATA)
sapply(DANONE_FINALDATA, class)
str(DANONE_FINALDATA)

##VINCI
VINCI_FINALDATA
dim(VINCI_FINALDATA)
summary(VINCI_FINALDATA)
sapply(VINCI_FINALDATA, class)
str(VINCI_FINALDATA)

##AIR LIQUIDE
##regression of the Air Liquide adjusted price with respect to other varaibles

fitAI <- lm(AI_FINALDATA$AI.PA.Close ~  Interest.rates + ExchangeRate + PoliticalStability + Infaltion + AirLiquideDividend + REVENUE + NET.INCOME + Basic.earnings.per.share + Diluted.earnings.per.share + TOTAL.ASSETS  + INTANGIBLE.ASSETS + PPE + CASH  +  TOTAL.EQUITY + NON.CURRENT.LIABILITY + Cash.flows.from.operating.activities + Net.cash.flows.from.investing.activities + Net.cash.flows.from.financing.activities + Net.cash.and.cash.equivalents, AI_FINALDATA)
summary(fitAI) # show results

# Other useful functions
tmp1 = coefficients(fitAI) # model coefficients
confint(fitAI, level=0.95) # CIs for model parameters
fitted(fitAI) # predicted values
residuals(fitAI) # residuals
anova(fitAI) # anova table
vcov(fitAI) # covariance matrix for model parameters
influence(fitAI) # regression diagnostics

write.csv(tmp1 , "fitAI.csv")

##AIRBUS
##regression of the Air Liquide adjusted price with respect to other varaibles

fitAIRBUS <- lm(AIRBUS_FINALDATA$AIR.PA.Close ~  Interest.rates + ExchangeRate + PoliticalStability + Infaltion + AirbusDividend + REVENUE + NET.INCOME + Basic.earnings.per.share + Diluted.earnings.per.share + TOTAL.ASSETS  + INTANGIBLE.ASSETS + PPE + CASH  +  TOTAL.EQUITY + NON.CURRENT.LIABILITY + Cash.flows.from.operating.activities + Net.cash.flows.from.investing.activities + Net.cash.flows.from.financing.activities + Net.cash.and.cash.equivalents, AIRBUS_FINALDATA)
summary(fitAIRBUS) # show results

# Other useful functions
coefficients(fitAIRBUS) # model coefficients
confint(fitAIRBUS, level=0.95) # CIs for model parameters
fitted(fitAIRBUS) # predicted values
residuals(fitAIRBUS) # residuals
anova(fitAIRBUS) # anova table
vcov(fitAIRBUS) # covariance matrix for model parameters
influence(fitAIRBUS) # regression diagnostics

##BNP
BNP_FINALDATA
##regression of the Air Liquide adjusted price with respect to other varaibles

fitBNP <- lm(BNP.PA.Close ~  Interest.rates + ExchangeRate + PoliticalStability + Infaltion + `BNP Dividends` + REVENUE + NET.INCOME + Basic.earnings.per.share + Diluted.earnings.per.share + TOTAL.ASSETS  + INTANGIBLE.ASSETS + PPE + CASH  +  TOTAL.EQUITY + NON.CURRENT.LIABILITY + Cash.flows.from.operating.activities + Net.cash.flows.from.investing.activities + Net.cash.flows.from.financing.activities + Net.cash.and.cash.equivalents, BNP_FINALDATA)
summary(fitBNP) # show results

# Other useful functions
coefficients(fitBNP) # model coefficients
confint(fitBNP, level=0.95) # CIs for model parameters
fitted(fitBNP) # predicted values
residuals(fitBNP) # residuals
anova(fitBNP) # anova table
vcov(fitBNP) # covariance matrix for model parameters
influence(fitBNP) # regression diagnostics

##DANONE
DANONE_FINALDATA
##regression of the Air Liquide adjusted price with respect to other varaibles

fitDANONE <- lm(DANONE_FINALDATA$BN.PA.Close ~  Interest.rates + ExchangeRate + PoliticalStability + Infaltion + DanoneDividends + REVENUE + NET.INCOME + Basic.earnings.per.share + Diluted.earnings.per.share + TOTAL.ASSETS  + INTANGIBLE.ASSETS + PPE + CASH  +  TOTAL.EQUITY + NON.CURRENT.LIABILITY + Cash.flows.from.operating.activities + Net.cash.flows.from.investing.activities + Net.cash.flows.from.financing.activities + Net.cash.and.cash.equivalents, DANONE_FINALDATA)
summary(fitDANONE) # show results

# Other useful functions
coefficients(fitDANONE) # model coefficients
confint(fitDANONE, level=0.95) # CIs for model parameters
fitted(fitDANONE) # predicted values
residuals(fitDANONE) # residuals
anova(fitDANONE) # anova table
vcov(fitDANONE) # covariance matrix for model parameters
influence(fitDANONE) # regression diagnostics

##VINCI
VINCI_FINALDATA
##regression of the Air Liquide adjusted price with respect to other varaibles

fitVINCI <- lm(VINCI_FINALDATA$DG.PA.Close ~  Interest.rates + ExchangeRate + PoliticalStability + Infaltion + `Vinci Dividend` + REVENUE + NET.INCOME + Basic.earnings.per.share + Diluted.earnings.per.share + TOTAL.ASSETS  + INTANGIBLE.ASSETS + PPE + CASH  +  TOTAL.EQUITY + NON.CURRENT.LIABILITY + Cash.flows.from.operating.activities + Net.cash.flows.from.investing.activities + Net.cash.flows.from.financing.activities + Net.cash.and.cash.equivalents, VINCI_FINALDATA)
summary(fitVINCI) # show results

# Other useful functions
coefficients(fitVINCI) # model coefficients
confint(fitVINCI, level=0.95) # CIs for model parameters
fitted(fitVINCI) # predicted values
residuals(fitVINCI) # residuals
anova(fitVINCI) # anova table
vcov(fitVINCI) # covariance matrix for model parameters
influence(fitVINCI) # regression diagnostics

##RANDOM FOREST FOR AI
summary(AI_FINALDATA)
str(AI_FINALDATA)
# Load the party package. It will automatically load other
# required packages.
library(party)
library(randomForest)

#install caret package
install.packages('caret')
#load package
set.seed(123)
library(caret)
trainAI = createDataPartition(AI_FINALDATA$AI.PA.Close,
                                 p=0.7, list=FALSE,times=1)

train_1 = AI_FINALDATA[1:1075,]
test_1 = AI_FINALDATA[1076:1533,]


#random forest parameters
#mtry= number of variables selected at each split.
#lower m try means less correaltion between trees (good thing)
#fitting the model or creating the forest
library(randomForest)
output.forestAI <- randomForest(AI.PA.Close ~  Interest.rates + ExchangeRate + PoliticalStability + Infaltion + AirLiquideDividend + REVENUE + NET.INCOME + Basic.earnings.per.share + Diluted.earnings.per.share + TOTAL.ASSETS  + INTANGIBLE.ASSETS + PPE + CASH  +  TOTAL.EQUITY + NON.CURRENT.LIABILITY + Cash.flows.from.operating.activities + Net.cash.flows.from.investing.activities + Net.cash.flows.from.financing.activities + Net.cash.and.cash.equivalents, train_1)
# View the forest results.

print(output.forestAI) 
summary(output.forestAI)

VI_F=importance(output.forestAI)

VI_F
write.csv(VI_F , "VI_FAI.csv")

varImpPlot(output.forestAI,type=2)


#Predictions

PredictionsAdjusted <- predict(output.forestAI, test_1, type='response')
t <- table(predictions=PredictionsAdjusted, actual=test_1$AI.PA.Close)
t
write.csv(t , "ConfusionMatrix_AI.csv")

#Accuracy Metric
sum(diag(t))/sum(t)

 #high strength of tree =Low error rate of individual tree classifier

PredictionWithProbs <- predict(output.forestAI, test_1, type = 'response')
PredictionWithProbs
write.csv(PredictionWithProbs , "PredictionsPrices_AI.csv")


 #to find the best mtry

bestmtryAI <- tuneRF(train_1,train_1$AI.PA.Close, mtry=3,  ntreeTry = 500, stepFactor = 1.5, improve = 0.01, trace = T, plot= T)
bestmtryAI
     
write.csv(bestmtryAI , "OOB_AI.csv")

 
##RANDOM FOREST FOR AIRBUS
summary(AIRBUS_FINALDATA)
str(AIRBUS_FINALDATA)
# Load the party package. It will automatically load other
# required packages.
library(party)
library(randomForest)

#install caret package
install.packages('caret')
#load package
set.seed(123)
library(caret)
trainAIRBUS = createDataPartition(AIRBUS_FINALDATA$AIR.PA.Close,
                              p=0.7, list=FALSE,times=1)

train_2 = AIRBUS_FINALDATA[1:1075,]
test_2 = AIRBUS_FINALDATA[1076:1533,]


#random forest parameters
#mtry= number of variables selected at each split.
#lower m try means less correaltion between trees (good thing)
#fitting the model or creating the forest
library(randomForest)
output.forestAIRBUS <- randomForest(AIR.PA.Close ~  Interest.rates + ExchangeRate + PoliticalStability + Infaltion + AirbusDividend + REVENUE + NET.INCOME + Basic.earnings.per.share + Diluted.earnings.per.share + TOTAL.ASSETS  + INTANGIBLE.ASSETS + PPE + CASH  +  TOTAL.EQUITY + NON.CURRENT.LIABILITY + Cash.flows.from.operating.activities + Net.cash.flows.from.investing.activities + Net.cash.flows.from.financing.activities + Net.cash.and.cash.equivalents, train_2)

# View the forest results.
print(output.forestAIRBUS) 

VI_F=importance(output.forestAIRBUS)

VI_F
write.csv(VI_F , "VI_FAIRBUS.csv")
varImpPlot(output.forestAIRBUS,type=2)


#Predictions

PredictionsAdjusted_2 <- predict(output.forestAIRBUS, test_2, type='response')
t_2 <- table(predictions=PredictionsAdjusted_2, actual=test_2$AIR.PA.Close)
t_2

write.csv(t_2 , "ConfusionMatrix_AIR.csv")

#Accuracy Metric
sum(diag(t_2))/sum(t_2)

#high strength of tree =Low error rate of individual tree classifier

PredictionWithProbs_2 <- predict(output.forestAIRBUS, test_2, type = 'response')
PredictionWithProbs_2

write.csv(PredictionWithProbs_2 , "PredictionsPrices_AIR.csv")


#to find the best mtry

bestmtryAIRBUS <- tuneRF(train_2,train_2$AIR.PA.Close, ntreeTry = 200, stepFactor = 1.5, improve = 0.01, trace = T, plot= T)
bestmtryAIRBUS
write.csv(bestmtryAI , "OOB_AIRBUS.csv")



##RANDOM FOREST FOR BNP
summary(BNP_FINALDATA)
str(BNP_FINALDATA)
# Load the party package. It will automatically load other
# required packages.
library(party)
library(randomForest)

#install caret package
install.packages('caret')
#load package
set.seed(123)
library(caret)
trainBNP = createDataPartition(BNP_FINALDATA$BNP.PA.Close,
                                  p=0.7, list=FALSE,times=1)

train_3 = BNP_FINALDATA[1:1075,]
test_3 = BNP_FINALDATA[1076:1533,]
test_3


#random forest parameters
#mtry= number of variables selected at each split.
#lower m try means less correaltion between trees (good thing)
#fitting the model or creating the forest

library(randomForest)
BNP_FINALDATA
output.forestBNP <- randomForest(BNP.PA.Close ~  Interest.rates + ExchangeRate + PoliticalStability + Infaltion + BNPDividends + REVENUE + NET.INCOME + Basic.earnings.per.share + Diluted.earnings.per.share + TOTAL.ASSETS  + INTANGIBLE.ASSETS + PPE + CASH  +  TOTAL.EQUITY + NON.CURRENT.LIABILITY + Cash.flows.from.operating.activities + Net.cash.flows.from.investing.activities + Net.cash.flows.from.financing.activities + Net.cash.and.cash.equivalents, train_3)
# View the forest results.
print(output.forestBNP) 

VI_F=importance(output.forestBNP)

VI_F
write.csv(VI_F , "VI_FBNP.csv")
varImpPlot(output.forestBNP,type=2)


#Predictions

PredictionsAdjusted_3 <- predict(output.forestBNP, test_3, type='response')
t_3 <- table(predictions=PredictionsAdjusted_3, actual=test_3$BNP.PA.Close)
t_3

write.csv(t_3 , "ConfusionMatrix_BNP.csv")

#Accuracy Metric
sum(diag(t_3))/sum(t_3)

#high strength of tree =Low error rate of individual tree classifier

PredictionWithProbs_3 <- predict(output.forestBNP, test_3, type = 'response')
PredictionWithProbs_3

write.csv(PredictionWithProbs_3 , "PredictionsPrices_BNP.csv")

#to find the best mtry

bestmtryBNP <- tuneRF(train_3,train_3$BNP.PA.Close, ntreeTry = 200, stepFactor = 1.5, improve = 0.01, trace = T, plot= T)
bestmtryBNP

write.csv(bestmtryAI , "OOB_BNP.csv")

##RANDOM FOREST FOR DANONE


str(DANONE_FINALDATA)
# Load the party package. It will automatically load other
# required packages.
library(party)
library(randomForest)

#install caret package
install.packages('caret')
#load package
set.seed(123)
library(caret)
trainDANONE = createDataPartition(DANONE_FINALDATA$BN.PA.Close,
                              p=0.7, list=FALSE,times=1)

train_4 = DANONE_FINALDATA[1:1075,]
test_4 = DANONE_FINALDATA[1076:1533,]


#random forest parameters
#mtry= number of variables selected at each split.
#lower m try means less correaltion between trees (good thing)
#fitting the model or creating the forest

library(randomForest)
output.forestDANONE <- randomForest(BN.PA.Close ~  Interest.rates + ExchangeRate + PoliticalStability + Infaltion + DanoneDividends + REVENUE + NET.INCOME + Basic.earnings.per.share + Diluted.earnings.per.share + TOTAL.ASSETS  + INTANGIBLE.ASSETS + PPE + CASH  +  TOTAL.EQUITY + NON.CURRENT.LIABILITY + Cash.flows.from.operating.activities + Net.cash.flows.from.investing.activities + Net.cash.flows.from.financing.activities + Net.cash.and.cash.equivalents, train_4)

# View the forest results.
print(output.forestDANONE) 

VI_F=importance(output.forestDANONE)

VI_F
write.csv(VI_F , "VI_FDANONE.csv")
varImpPlot(output.forestDANONE,type=2)


#Predictions

PredictionsAdjusted_4 <- predict(output.forestDANONE, test_4, type='response')
t_4 <- table(predictions=PredictionsAdjusted_4, actual=test_4$BN.PA.Close)
t_4

write.csv(t_4 , "ConfusionMatrix_DANONE.csv")

#Accuracy Metric
sum(diag(t_4))/sum(t_4)

#high strength of tree =Low error rate of individual tree classifier

PredictionWithProbs_4 <- predict(output.forestDANONE, test_4, type = 'response')
PredictionWithProbs_4

write.csv(PredictionWithProbs_4 , "PredictionsPrices_DANONE.csv")

#to find the best mtry

bestmtryDANONE <- tuneRF(train_4,train_4$BN.PA.Close, ntreeTry = 200, stepFactor = 1.5, improve = 0.01, trace = T, plot= T)
bestmtryDANONE

write.csv(bestmtryAI , "OOB_DANONE.csv")
     

##RANDOM FOREST FOR VINCI
str(VINCI_FINALDATA)
# Load the party package. It will automatically load other
# required packages.

library(party)
library(randomForest)

#install caret package
install.packages('caret')
#load package
set.seed(123)
library(caret)
trainVINCI = createDataPartition(VINCI_FINALDATA$DG.PA.Close,
                                  p=0.7, list=FALSE,times=1)

train_5 = VINCI_FINALDATA[1:1075,]
test_5 = VINCI_FINALDATA[1076:1533,]
test_5

#random forest parameters
#mtry= number of variables selected at each split.
#lower m try means less correaltion between trees (good thing)
#fitting the model or creating the forest

library(randomForest)
output.forestVINCI <- randomForest(DG.PA.Close ~  Interest.rates + ExchangeRate + PoliticalStability + Infaltion + VinciDividends + REVENUE + NET.INCOME + Basic.earnings.per.share + Diluted.earnings.per.share + TOTAL.ASSETS  + INTANGIBLE.ASSETS + PPE + CASH  +  TOTAL.EQUITY + NON.CURRENT.LIABILITY + Cash.flows.from.operating.activities + Net.cash.flows.from.investing.activities + Net.cash.flows.from.financing.activities + Net.cash.and.cash.equivalents, train_5)

# View the forest results.
print(output.forestVINCI) 

VI_F=importance(output.forestVINCI)

VI_F
write.csv(VI_F , "VI_FVINCI.csv")
varImpPlot(output.forestVINCI,type=2)


#Predictions

PredictionsAdjusted_5 <- predict(output.forestVINCI, test_5, type='response')
t_5 <- table(predictions=PredictionsAdjusted_5, actual=test_5$DG.PA.Close)
t_5

write.csv(t_5 , "ConfusionMatrix_VINCI.csv")

#Accuracy Metric
sum(diag(t_5))/sum(t_5)

#high strength of tree =Low error rate of individual tree classifier

PredictionWithProbs_5 <- predict(output.forestVINCI, test_5, type = 'response')
PredictionWithProbs_5

write.csv(PredictionWithProbs_5 , "PredictionsPrices_VINCI.csv")

#to find the best mtry

bestmtryVINCI <- tuneRF(train_5,train_5$DG.PA.Close, ntreeTry = 200, stepFactor = 1.5, improve = 0.01, trace = T, plot= T)
bestmtryVINCI

write.csv(bestmtryAI , "OOB_VINCI.csv")     


##graphs
attach(mtcars)

par(mfrow=c(2,2))

varImpPlot(output.forestAIR,type=2)
plot(bestmtryAIRBUS)

varImpPlot(output.forestBNP,type=2)
plot(bestmtryBNP)

varImpPlot(output.forestDANONE,type=2)
plot(bestmtryDANONE)
    
varImpPlot(output.forestVINCI,type=2)
plot(bestmtryVINCI)      


PA
DAT

RETU <- (PA-DAT)/DAT
View(RETU)
I <- c()
for (n in 1:458){
    if (max(RETU[n,]) == RETU[n,1]){
        I[n] = 1
    } else if (max(RETU[n,]) == RETU[n,2]){
        I[n] = 2
    } else if (max(RETU[n,]) == RETU[n,3]){
        I[n] = 3
    } else if (max(RETU[n,]) == RETU[n,4]){
        I[n] = 4
    } else if (max(RETU[n,]) == RETU[n,5]){
        I[n] = 5
    }
}
X = 10000
for (n in 1:456){
    if (I[n] == 1){
        Y = 1
    } else if (I[n] == 2){
        Y = 2
    } else if (I[n] == 3){
        Y = 3
    } else if (I[n] == 4){
        Y = 4
    } else if (I[n] == 5){
        Y = 5
    }
    X = X*(DAT[n+2,Y]/DAT[n+1,Y])
}
View(X)
write.csv(X , "FINALPREDICTION.csv")     


     
     

     
     
     
     
     
     
     
     
     
     

     
     