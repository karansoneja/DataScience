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


##if you want to remove dates
AI_FINAL <- AI_FINALDATA [-1]
row.names(AI_FINAL) <- AI_FINALDATA$DATE
AI_FINAL



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
library(MASS)
set.seed(1234)
summary(AI_FINALDATA)

str(AI_FINALDATA)
# Load the party package. It will automatically load other
# required packages.
library(party)
library(randomForest)


#Lets create the train and test data set
library(caTools)

#target variable is adjusted price
indAI <- sample.split( Y= AI_FINALDATA$AI.PA.Adjusted , SplitRatio = 0.7)
trainDFAI <- AI_FINALDATA[indAI,]
testDFAI <- AI_FINALDATA[indAI,]

#high strength of tree =Low error rate of individual tree classifier

#random forest parameters
#mtry= number of variables selected at each split.


#lower m try means less correaltion between trees (good thing)

#fitting the model or creating the forest

output.forestAI <- randomForest(AI.PA.Adjusted ~  Interest.rates + ExchangeRate + PoliticalStability + Infaltion + AirLiquideDividend + REVENUE + NET.INCOME + Basic.earnings.per.share + Diluted.earnings.per.share + TOTAL.ASSETS  + INTANGIBLE.ASSETS + PPE + CASH  +  TOTAL.EQUITY + NON.CURRENT.LIABILITY + Cash.flows.from.operating.activities + Net.cash.flows.from.investing.activities + Net.cash.flows.from.financing.activities + Net.cash.and.cash.equivalents, AI_FINALDATA)

# View the forest results.
print(output.forestAI) 

VI_F=importance(output.forestAI)

VI_F
varImpPlot(output.forestAI,type=2)


#Predictions

PredictionsAdjusted <- predict(output.forestAI, testDFAI, type='response')
t <- table(predictions=PredictionsAdjusted, actual=testDFAI$AI.PA.Adjusted)
t

#Accuracy Metric
sum(diag(t))/sum(t)


#Plotting ROC curve and plotting AUC metric (giving errors)
PredictionsAdjusted <- predict(output.forestAI, testDFAI, type = 'response')
library(data.table)
install.packages("mltools")
library(mltools)

auc<-auc(testDFAI$AI.PA.Adjusted, PredictionsAdjusted[,])
plot(roc(testDFAI$AI.PA.Adjusted, PredictionsAdjusted[,])
     
#to find the best mtry

bestmtryAI <- tuneRF(trainDFAI,trainDFAI$AI.PA.Adjusted, ntreeTry = 100, stepFactor = 1.5, improve = 0.01, trace = T, plot= T)
bestmtryAI
     




##RANDOM FOREST FOR AIRBUS
library(MASS)
set.seed(1234)
summary(AIRBUS_FINALDATA)

str(AIRBUS_FINALDATA)
# Load the party package. It will automatically load other
# required packages.
library(party)
library(randomForest)


#Lets create the train and test data set
library(caTools)

#target variable is adjusted price
indAIRBUS <- sample.split( Y= AIRBUS_FINALDATA$AIR.PA.Adjusted , SplitRatio = 0.7)
trainDFAIR <- AIRBUS_FINALDATA[indAIRBUS,]
testDFAIR <- AIRBUS_FINALDATA[indAIRBUS,]

#high strength of tree =Low error rate of individual tree classifier

#random forest parameters
#mtry= number of variables selected at each split.


#lower m try means less correaltion between trees (good thing)

#fitting the model or creating the forest

output.forestAIR <- randomForest(AIR.PA.Adjusted ~  Interest.rates + ExchangeRate + PoliticalStability + Infaltion + AirbusDividend + REVENUE + NET.INCOME + Basic.earnings.per.share + Diluted.earnings.per.share + TOTAL.ASSETS  + INTANGIBLE.ASSETS + PPE + CASH  +  TOTAL.EQUITY + NON.CURRENT.LIABILITY + Cash.flows.from.operating.activities + Net.cash.flows.from.investing.activities + Net.cash.flows.from.financing.activities + Net.cash.and.cash.equivalents, AIRBUS_FINALDATA)

# View the forest results.
print(output.forestAIR) 

VI_F=importance(output.forestAIR)

VI_F
varImpPlot(output.forestAIR,type=2)


#Predictions

PredictionsAdjusted <- predict(output.forestAIR, testDFAIR, type='response')
t <- table(predictions=PredictionsAdjusted, actual=testDFAIR$AIR.PA.Adjusted)
t

#Accuracy Metric
sum(diag(t))/sum(t)


#Plotting ROC curve and plotting AUC metric (giving errors)
PredictionsAdjusted <- predict(output.forestAIR, testDFAIR, type = 'response')
library(data.table)
install.packages("mltools")
library(mltools)

auc<-auc(testDFAI$AI.PA.Adjusted, PredictionsAdjusted[,])
plot(roc(testDFAI$AI.PA.Adjusted, PredictionsAdjusted[,])
     
#to find the best mtry

bestmtryAIR <- tuneRF(trainDFAIR,trainDFAIR$AIR.PA.Adjusted, ntreeTry = 100, stepFactor = 1.5, improve = 0.01, trace = T, plot= T)
bestmtryAIR





##RANDOM FOREST FOR BNP
library(MASS)
set.seed(1234)
summary(BNP_FINALDATA)

str(BNP_FINALDATA)
# Load the party package. It will automatically load other
# required packages.
library(party)
library(randomForest)


#Lets create the train and test data set
library(caTools)

#target variable is adjusted price
indBNP <- sample.split( Y= BNP_FINALDATA$BNP.PA.Adjusted , SplitRatio = 0.7)
trainDFBNP <- BNP_FINALDATA[indBNP,]
testDFBNP <- BNP_FINALDATA[indBNP,]

#high strength of tree =Low error rate of individual tree classifier

#random forest parameters
#mtry= number of variables selected at each split.


#lower m try means less correaltion between trees (good thing)

#fitting the model or creating the forest

output.forestBNP <- randomForest(BNP.PA.Adjusted ~  Interest.rates + ExchangeRate + PoliticalStability + Infaltion + `BNP Dividends` + REVENUE + NET.INCOME + Basic.earnings.per.share + Diluted.earnings.per.share + TOTAL.ASSETS  + INTANGIBLE.ASSETS + PPE + CASH  +  TOTAL.EQUITY + NON.CURRENT.LIABILITY + Cash.flows.from.operating.activities + Net.cash.flows.from.investing.activities + Net.cash.flows.from.financing.activities + Net.cash.and.cash.equivalents, BNP_FINALDATA)

# View the forest results.
print(output.forestBNP) 

VI_F=importance(output.forestBNP)

VI_F
varImpPlot(output.forestBNP,type=2)


#Predictions

PredictionsAdjusted <- predict(output.forestBNP, testDFBNP, type='response')
t <- table(predictions=PredictionsAdjusted, actual=testDFBNP$BNP.PA.Adjusted)
t

#Accuracy Metric
sum(diag(t))/sum(t)


#Plotting ROC curve and plotting AUC metric (giving errors)
PredictionsAdjusted <- predict(output.forestBNP, testDFBNP, type = 'response')
library(data.table)
install.packages("mltools")
library(mltools)

auc<-auc(testDFBNP$BNP.PA.Adjusted, PredictionsAdjusted[,])
plot(roc(testDFBNP$BNP.PA.Adjusted, PredictionsAdjusted[,])
     
#to find the best mtry
bestmtryBNP <- tuneRF(trainDFBNP,trainBNPI$BNP.PA.Adjusted, ntreeTry = 100, stepFactor = 1.5, improve = 0.01, trace = T, plot= T)
bestmtryBNP
     
     
     
     
     
     

##RANDOM FOREST FOR DANONE
library(MASS)
set.seed(1234)
summary(DANONE_FINALDATA)

str(DANONE_FINALDATA)
# Load the party package. It will automatically load other
# required packages.
library(party)
library(randomForest)


#Lets create the train and test data set
library(caTools)

#target variable is adjusted price
indDANONE <- sample.split( Y= DANONE_FINALDATA$BN.PA.Adjusted , SplitRatio = 0.7)
trainDFDANONE <- DANONE_FINALDATA[indDANONE,]
testDFDANONE <- DANONE_FINALDATA[indDANONE,]

#high strength of tree =Low error rate of individual tree classifier

#random forest parameters
#mtry= number of variables selected at each split.


#lower m try means less correaltion between trees (good thing)

#fitting the model or creating the forest

output.forestDANONE <- randomForest(BN.PA.Adjusted ~  Interest.rates + ExchangeRate + PoliticalStability + Infaltion + DanoneDividends  + REVENUE + NET.INCOME + Basic.earnings.per.share + Diluted.earnings.per.share + TOTAL.ASSETS  + INTANGIBLE.ASSETS + PPE + CASH  +  TOTAL.EQUITY + NON.CURRENT.LIABILITY + Cash.flows.from.operating.activities + Net.cash.flows.from.investing.activities + Net.cash.flows.from.financing.activities + Net.cash.and.cash.equivalents, DANONE_FINALDATA)

# View the forest results.
print(output.forestDANONE) 

VI_F=importance(output.forestDANONE)

VI_F
varImpPlot(output.forestDANONE,type=2)


#Predictions

PredictionsAdjusted <- predict(output.forestDANONE, testDFDANONE, type='response')
t <- table(predictions=PredictionsAdjusted, actual=testDFDANONE$BN.PA.Adjusted)
t

#Accuracy Metric
sum(diag(t))/sum(t)


#Plotting ROC curve and plotting AUC metric (giving errors)
PredictionsAdjusted <- predict(output.forestDANONE, testDFDANONE, type = 'response')
library(data.table)
install.packages("mltools")
library(mltools)

auc<-auc(testDFBN$BN.PA.Adjusted, PredictionsAdjusted[,])
plot(roc(testDFBN$BN.PA.Adjusted, PredictionsAdjusted[,])
     
#to find the best mtry

bestmtryDANONE <- tuneRF(trainDFDANONE,trainDFDANONE$BN.PA.Adjusted, ntreeTry = 100, stepFactor = 1.5, improve = 0.01, trace = T, plot= T)
bestmtryDANONE
     
     
     

##RANDOM FOREST FOR VINCI
library(MASS)
set.seed(1234)
summary(VINCI_FINALDATA)

str(VINCI_FINALDATA)
# Load the party package. It will automatically load other
# required packages.
library(party)
library(randomForest)


#Lets create the train and test data set
library(caTools)

#target variable is adjusted price
indDG <- sample.split( Y= VINCI_FINALDATA$DG.PA.Adjusted , SplitRatio = 0.7)
trainDFDG <- VINCI_FINALDATA[indDG,]
testDFDG <- VINCI_FINALDATA[indDG,]

#high strength of tree =Low error rate of individual tree classifier

#random forest parameters
#mtry= number of variables selected at each split.


#lower m try means less correaltion between trees (good thing)

#fitting the model or creating the forest

output.forestDG <- randomForest(DG.PA.Adjusted ~  Interest.rates + ExchangeRate + PoliticalStability + Infaltion + VINCI_FINALDATA$`Vinci Dividend` + REVENUE + NET.INCOME + Basic.earnings.per.share + Diluted.earnings.per.share + TOTAL.ASSETS  + INTANGIBLE.ASSETS + PPE + CASH  +  TOTAL.EQUITY + NON.CURRENT.LIABILITY + Cash.flows.from.operating.activities + Net.cash.flows.from.investing.activities + Net.cash.flows.from.financing.activities + Net.cash.and.cash.equivalents, VINCI_FINALDATA)

# View the forest results.
print(output.forestDG) 

VI_F=importance(output.forestDG)

VI_F
varImpPlot(output.forestDG,type=2)


#Predictions

PredictionsAdjusted <- predict(output.forestDG, testDFDG, type='response')
t <- table(predictions=PredictionsAdjusted, actual=testDFDG$DG.PA.Adjusted)
t

#Accuracy Metric
sum(diag(t))/sum(t)


#Plotting ROC curve and plotting AUC metric (giving errors)
PredictionsAdjusted <- predict(output.forestAI, testDFDG, type = 'response')
library(data.table)
install.packages("mltools")
library(mltools)

auc<-auc(testDFDG$DG.PA.Adjusted, PredictionsAdjusted[,])
plot(roc(testDFDG$DG.PA.Adjusted, PredictionsAdjusted[,])
     
#to find the best mtry


bestmtryDG <- tuneRF(trainDFDG,trainDFDG$DG.PA.Adjusted, ntreeTry = 100, stepFactor = 1.5, improve = 0.01, trace = T, plot= T)
bestmtryDG
     
     
     
     
     
     
     
     
     

     
     
     
     
     
     
     
     
     
     

     
     