library(quantmod)
library(rpart)
library(rpart.plot)
library(ROCR)
library(caret)
library(randomForest)
library(plotly)
library(ggplot2)
library()
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


##if you want to remove dates
AI_FINAL <- AI_FINALDATA [-1]
row.names(AI_FINAL) <- AI_FINALDATA$DATE
AI_FINAL


AI_FINALDATA
colnames(AI_FINALDATA)
colnames(result)

##AIR LIQUIDE
##regression of the Air Liquide adjusted price with respect to other varaibles

fitAI <- lm(AI.PA.Adjusted ~  Interest.rates + ExchangeRate + PoliticalStability + Infaltion + AirLiquideDividend + REVENUE + NET.INCOME + Basic.earnings.per.share + Diluted.earnings.per.share + TOTAL.ASSETS  + INTANGIBLE.ASSETS + PPE + CASH  +  TOTAL.EQUITY + NON.CURRENT.LIABILITY + Cash.flows.from.operating.activities + Net.cash.flows.from.investing.activities + Net.cash.flows.from.financing.activities + Net.cash.and.cash.equivalents, AI_FINALDATA)
summary(fitAI) # show results


# Other useful functions
coefficients(fitAI) # model coefficients
confint(fitAI, level=0.95) # CIs for model parameters
fitted(fitAI) # predicted values
residuals(fitAI) # residuals
anova(fitAI) # anova table
vcov(fitAI) # covariance matrix for model parameters
influence(fitAI) # regression diagnostics

##AIRBUS
##regression of the Air Liquide adjusted price with respect to other varaibles

fitAIRBUS <- lm(AIR.PA.Adjusted ~  Interest.rates + ExchangeRate + PoliticalStability + Infaltion + AirbusDividend + REVENUE + NET.INCOME + Basic.earnings.per.share + Diluted.earnings.per.share + TOTAL.ASSETS  + INTANGIBLE.ASSETS + PPE + CASH  +  TOTAL.EQUITY + NON.CURRENT.LIABILITY + Cash.flows.from.operating.activities + Net.cash.flows.from.investing.activities + Net.cash.flows.from.financing.activities + Net.cash.and.cash.equivalents, AIRBUS_FINALDATA)
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

fitBNP <- lm(BNP.PA.Adjusted ~  Interest.rates + ExchangeRate + PoliticalStability + Infaltion + `BNP Dividends` + REVENUE + NET.INCOME + Basic.earnings.per.share + Diluted.earnings.per.share + TOTAL.ASSETS  + INTANGIBLE.ASSETS + PPE + CASH  +  TOTAL.EQUITY + NON.CURRENT.LIABILITY + Cash.flows.from.operating.activities + Net.cash.flows.from.investing.activities + Net.cash.flows.from.financing.activities + Net.cash.and.cash.equivalents, BNP_FINALDATA)
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

fitDANONE <- lm(BN.PA.Adjusted ~  Interest.rates + ExchangeRate + PoliticalStability + Infaltion + DanoneDividends + REVENUE + NET.INCOME + Basic.earnings.per.share + Diluted.earnings.per.share + TOTAL.ASSETS  + INTANGIBLE.ASSETS + PPE + CASH  +  TOTAL.EQUITY + NON.CURRENT.LIABILITY + Cash.flows.from.operating.activities + Net.cash.flows.from.investing.activities + Net.cash.flows.from.financing.activities + Net.cash.and.cash.equivalents, DANONE_FINALDATA)
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

fitVINCI <- lm(DG.PA.Adjusted ~  Interest.rates + ExchangeRate + PoliticalStability + Infaltion + `Vinci Dividend` + REVENUE + NET.INCOME + Basic.earnings.per.share + Diluted.earnings.per.share + TOTAL.ASSETS  + INTANGIBLE.ASSETS + PPE + CASH  +  TOTAL.EQUITY + NON.CURRENT.LIABILITY + Cash.flows.from.operating.activities + Net.cash.flows.from.investing.activities + Net.cash.flows.from.financing.activities + Net.cash.and.cash.equivalents, VINCI_FINALDATA)
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
library(randomForest)
library(MASS)
set.seed(1234)
library(ggplot2)
library(cowplot)
library(randomForest)

model <- randomForest(AI.PA.Adjusted ~  Interest.rates + ExchangeRate + PoliticalStability + Infaltion + AirLiquideDividend + REVENUE + NET.INCOME + Basic.earnings.per.share + Diluted.earnings.per.share + TOTAL.ASSETS  + INTANGIBLE.ASSETS + PPE + CASH  +  TOTAL.EQUITY + NON.CURRENT.LIABILITY + Cash.flows.from.operating.activities + Net.cash.flows.from.investing.activities + Net.cash.flows.from.financing.activities + Net.cash.and.cash.equivalents, AI_FINALDATA, proximity=TRUE)
model


library(caTools)
ind <- sample.split(Y= AI_FINALDATA$AI.PA.Adjusted, SplitRatio = 0.7)
trainDFAI <- AI_FINALDATA[ind,]
testDFAI <- AI_FINALDATA[!ind,]

#fittiing the model
modelRandom <- randomForest(AI.PA.Adjusted ~  Interest.rates + ExchangeRate + PoliticalStability + Infaltion + AirLiquideDividend + REVENUE + NET.INCOME + Basic.earnings.per.share + Diluted.earnings.per.share + TOTAL.ASSETS  + INTANGIBLE.ASSETS + PPE + CASH  +  TOTAL.EQUITY + NON.CURRENT.LIABILITY + Cash.flows.from.operating.activities + Net.cash.flows.from.investing.activities + Net.cash.flows.from.financing.activities + Net.cash.and.cash.equivalents, trainDFAI, mtry=3)
modelRandom
importance(modelRandom)
varImpPlot(modelRandom)

#predictions
PredictionsWithClass <- predict(modelRandom, testDFAI , type = 'class')
t <- table(predictions= PredictionsWithClass , actual=testDFAI$AI.PA.Adjusted)
t


##accuracy metric
sum(diag(t))/sum(t)


##plotting ROC curve and calculating AUC metric
library(pROC)
PredictionWithProbs <- predict(modelRandom , testDFAI)
auc <- auc(testDFAI$AI.PA.Adjusted, PredictionWithProbs[,2])
plot(roc(testDFAI$AI.PA.Adjusted, PredictionWithProbs[,2]))


#to find the best mtry

bestmtry <- tuneRF(trainDFAI,trainDFAI$AI.PA.Adjusted, ntreeTry = 20, stepFactor = 1.5, improve = 0.01, trace = T, plot=T)

bestmtry




###RANDOM FOREST FOR AIRBUS
library(randomForest)
library(MASS)
set.seed(1234)
library(ggplot2)
library(cowplot)
library(randomForest)

modelAIR <- randomForest(AIR.PA.Adjusted ~  Interest.rates + ExchangeRate + PoliticalStability + Infaltion + AirbusDividend + REVENUE + NET.INCOME + Basic.earnings.per.share + Diluted.earnings.per.share + TOTAL.ASSETS  + INTANGIBLE.ASSETS + PPE + CASH  +  TOTAL.EQUITY + NON.CURRENT.LIABILITY + Cash.flows.from.operating.activities + Net.cash.flows.from.investing.activities + Net.cash.flows.from.financing.activities + Net.cash.and.cash.equivalents, AIRBUS_FINALDATA , proximity=TRUE)
modelAIR


library(caTools)
indAIR <- sample.split(Y= AIR_FINALDATA$AIR.PA.Adjusted, SplitRatio = 0.7)
trainDFAIR <- AIRBUS_FINALDATA[indAIR,]
testDFAIR <- AIRBUS_FINALDATA[!indAIR,]

#fittiing the model
modelRandomAIR <- randomForest(AIR.PA.Adjusted ~  Interest.rates + ExchangeRate + PoliticalStability + Infaltion + AirbusDividend + REVENUE + NET.INCOME + Basic.earnings.per.share + Diluted.earnings.per.share + TOTAL.ASSETS  + INTANGIBLE.ASSETS + PPE + CASH  +  TOTAL.EQUITY + NON.CURRENT.LIABILITY + Cash.flows.from.operating.activities + Net.cash.flows.from.investing.activities + Net.cash.flows.from.financing.activities + Net.cash.and.cash.equivalents, trainDFAIR, mtry=3)
modelRandomAIR
importance(modelRandomAIR)
varImpPlot(modelRandomAIR)

#predictions
PredictionsWithClass <- predict(modelRandom, testDFAIR , type = 'class')
t <- table(predictions= PredictionsWithClass , actual=testDFAIR$AIR.PA.Adjusted)
t


##accuracy metric
sum(diag(t))/sum(t)


##plotting ROC curve and calculating AUC metric
library(pROC)
PredictionWithProbs <- predict(modelRandom , testDFAIR)
auc <- auc(testDFAIR$AIR.PA.Adjusted, PredictionWithProbs[,2])
plot(roc(testDFAIR$AIR.PA.Adjusted, PredictionWithProbs[,2]))


#to find the best mtry

bestmtry <- tuneRF(trainDFAIR,trainDFAIR$AIR.PA.Adjusted, ntreeTry = 20, stepFactor = 1.5, improve = 0.01, trace = T, plot=T)

bestmtry




##RANDOM FOREST FOR BNP
library(randomForest)
library(MASS)
set.seed(1234)
library(ggplot2)
library(cowplot)
library(randomForest)

modelBNP <- randomForest(BNP.PA.Adjusted ~  Interest.rates + ExchangeRate + PoliticalStability + Infaltion + BNPDividend + REVENUE + NET.INCOME + Basic.earnings.per.share + Diluted.earnings.per.share + TOTAL.ASSETS  + INTANGIBLE.ASSETS + PPE + CASH  +  TOTAL.EQUITY + NON.CURRENT.LIABILITY + Cash.flows.from.operating.activities + Net.cash.flows.from.investing.activities + Net.cash.flows.from.financing.activities + Net.cash.and.cash.equivalents, BNP_FINALDATA, proximity=TRUE)
modelBNP


library(caTools)
ind <- sample.split(Y= BNP_FINALDATA$AI.PA.Adjusted, SplitRatio = 0.7)
trainDFBNP <- BNP_FINALDATA[ind,]
testDFBNP <- BNP_FINALDATA[!ind,]

#fittiing the model
modelRandomBNP <- randomForest(BNP.PA.Adjusted ~  Interest.rates + ExchangeRate + PoliticalStability + Infaltion + BNPDividend + REVENUE + NET.INCOME + Basic.earnings.per.share + Diluted.earnings.per.share + TOTAL.ASSETS  + INTANGIBLE.ASSETS + PPE + CASH  +  TOTAL.EQUITY + NON.CURRENT.LIABILITY + Cash.flows.from.operating.activities + Net.cash.flows.from.investing.activities + Net.cash.flows.from.financing.activities + Net.cash.and.cash.equivalents, trainDFAI, mtry=3)
modelRandomBNP
importance(modelRandomBNP)
varImpPlot(modelRandomBNP)

#predictions
PredictionsWithClass <- predict(modelRandomBNP, testDFBNP , type = 'class')
t <- table(predictions= PredictionsWithClass , actual=testDFBNP$BNP.PA.Adjusted)
t


##accuracy metric
sum(diag(t))/sum(t)


##plotting ROC curve and calculating AUC metric
library(pROC)
PredictionWithProbs <- predict(modelRandom , testDFBNP)
auc <- auc(testDFBNP$BNP.PA.Adjusted, PredictionWithProbs[,2])
plot(roc(testDFBNP$BNP.PA.Adjusted, PredictionWithProbs[,2]))


#to find the best mtry

bestmtry <- tuneRF(trainDFBNP,trainDFBNP$BNP.PA.Adjusted, ntreeTry = 20, stepFactor = 1.5, improve = 0.01, trace = T, plot=T)

bestmtry







##RANDOM FOREST FOR DANONE
library(randomForest)
library(MASS)
set.seed(1234)
library(ggplot2)
library(cowplot)
library(randomForest)

modelDANONE <- randomForest(BN.PA.Adjusted ~  Interest.rates + ExchangeRate + PoliticalStability + Infaltion + DanoneDividend + REVENUE + NET.INCOME + Basic.earnings.per.share + Diluted.earnings.per.share + TOTAL.ASSETS  + INTANGIBLE.ASSETS + PPE + CASH  +  TOTAL.EQUITY + NON.CURRENT.LIABILITY + Cash.flows.from.operating.activities + Net.cash.flows.from.investing.activities + Net.cash.flows.from.financing.activities + Net.cash.and.cash.equivalents, DANONE_FINALDATA, proximity=TRUE)
modelDANONE


library(caTools)
ind <- sample.split(Y= DANONE_FINALDATA$BN.PA.Adjusted, SplitRatio = 0.7)
trainDFDANONE <- DANONE_FINALDATA[ind,]
testDFDANONE <- DANONE_FINALDATA[!ind,]

#fittiing the model
modelRandomDANONE <- randomForest(BN.PA.Adjusted ~  Interest.rates + ExchangeRate + PoliticalStability + Infaltion + DanoneDividend + REVENUE + NET.INCOME + Basic.earnings.per.share + Diluted.earnings.per.share + TOTAL.ASSETS  + INTANGIBLE.ASSETS + PPE + CASH  +  TOTAL.EQUITY + NON.CURRENT.LIABILITY + Cash.flows.from.operating.activities + Net.cash.flows.from.investing.activities + Net.cash.flows.from.financing.activities + Net.cash.and.cash.equivalents, trainDFAI, mtry=3)
modelRandomDANONE
importance(modelRandomDANONE)
varImpPlot(modelRandomDANONE)

#predictions
PredictionsWithClass <- predict(modelRandomDANONE, testDFDANONE , type = 'class')
t <- table(predictions= PredictionsWithClass , actual=testDFDANONE$BN.PA.Adjusted)
t


##accuracy metric
sum(diag(t))/sum(t)


##plotting ROC curve and calculating AUC metric
library(pROC)
PredictionWithProbs <- predict(modelRandomDANONE , testDFDANONE)
auc <- auc(testDFDANONE$BN.PA.Adjusted, PredictionWithProbs[,2])
plot(roc(testDFDANONE$BN.PA.Adjusted, PredictionWithProbs[,2]))


#to find the best mtry

bestmtry <- tuneRF(trainDFDANONE,trainDFDANONE$BN.PA.Adjusted, ntreeTry = 20, stepFactor = 1.5, improve = 0.01, trace = T, plot=T)

bestmtry




##RANDOM FOREST FOR VINCI
library(randomForest)
library(MASS)
set.seed(1234)
library(ggplot2)
library(cowplot)
library(randomForest)

modelVINCI <- randomForest(DG.PA.Adjusted ~  Interest.rates + ExchangeRate + PoliticalStability + Infaltion + VinciDividend + REVENUE + NET.INCOME + Basic.earnings.per.share + Diluted.earnings.per.share + TOTAL.ASSETS  + INTANGIBLE.ASSETS + PPE + CASH  +  TOTAL.EQUITY + NON.CURRENT.LIABILITY + Cash.flows.from.operating.activities + Net.cash.flows.from.investing.activities + Net.cash.flows.from.financing.activities + Net.cash.and.cash.equivalents, VINCI_FINALDATA, proximity=TRUE)
modelVINCI


library(caTools)
ind <- sample.split(Y= VINCI_FINALDATA$DG.PA.Adjusted, SplitRatio = 0.7)
trainDFVINCI <- VINCI_FINALDATA[ind,]
testDFVINCI <- VINCI_FINALDATA[!ind,]

#fittiing the model
modelRandomVINCI <- randomForest(DG.PA.Adjusted ~  Interest.rates + ExchangeRate + PoliticalStability + Infaltion + VinciDividend + REVENUE + NET.INCOME + Basic.earnings.per.share + Diluted.earnings.per.share + TOTAL.ASSETS  + INTANGIBLE.ASSETS + PPE + CASH  +  TOTAL.EQUITY + NON.CURRENT.LIABILITY + Cash.flows.from.operating.activities + Net.cash.flows.from.investing.activities + Net.cash.flows.from.financing.activities + Net.cash.and.cash.equivalents, trainDFAI, mtry=3)
modelRandomVINCI
importance(modelRandomVINCI)
varImpPlot(modelRandomVINCI)

#predictions
PredictionsWithClass <- predict(modelRandomVINCI, testDFVINCI , type = 'class')
t <- table(predictions= PredictionsWithClass , actual=testDFVINCI$DG.PA.Adjusted)
t


##accuracy metric
sum(diag(t))/sum(t)


##plotting ROC curve and calculating AUC metric
library(pROC)
PredictionWithProbs <- predict(modelRandomVINCI , testDFVINCI)
auc <- auc(testDFVINCI$DG.PA.Adjusted, PredictionWithProbs[,2])
plot(roc(testDFVINCI$BN.PA.Adjusted, PredictionWithProbs[,2]))


#to find the best mtry

bestmtry <- tuneRF(trainDFVINCI,trainDFVINCI$DG.PA.Adjusted, ntreeTry = 20, stepFactor = 1.5, improve = 0.01, trace = T, plot=T)

bestmtry
