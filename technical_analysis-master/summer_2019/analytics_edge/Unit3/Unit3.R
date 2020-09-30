quality <- read.csv("D:/Scuola/Uni/2018-2019/Programming/R/TheAnalyticsEdge/Unit3/quality.csv")

summary(quality)
table(quality$PoorCare)

#install.packages("caTools")
library(caTools)

# split randomly data set into training set and testing set
set.seed(88)
split= sample.split(quality$PoorCare,SplitRatio = 0.75)
qualityTrain= subset(quality, split==TRUE)
qualityTest= subset(quality, split== FALSE)

# If you wanted to instead split a data frame data,
# where the dependent variable is a continuous outcome
# (this was the case for all the datasets we used last week),
# you could instead use the sample() function. Here is how to
# select 70% of observations for the training set (called "train")
# and 30% of observations for the testing set (called "test"):
# 
#   spl = sample(1:nrow(data), size=0.7 * nrow(data))
# train = data[spl,]
# test = data[-spl,]


# logistic regression with glm() function
QualityLog= glm(PoorCare~ OfficeVisits + Narcotics, data= qualityTrain, family = binomial)
summary(QualityLog)

# out of sample data
# type= "response" che ci vengono mostrate probabilità
predictTrain= predict(QualityLog, type= "response")
summary(predictTrain)
str(predictTrain)

# average prediction for true outcome
tapply(predictTrain, qualityTrain$PoorCare, mean)

###############################################################
# "family=binomial" definisce la logit
Model2 = glm(PoorCare ~ StartedOnCombination + ProviderCount, data= qualityTrain,family=binomial)
summary(Model2)

# confusion matrix
table(qualityTrain$PoorCare, predictTrain> 0.5)
# sensitivity( i.e. TRUE POSITIVE)
10 / (15+10)
# specificity
70 +(70+4)

table(qualityTrain$PoorCare, predictTrain> 0.7)
# sensitivity( i.e. TRUE POSITIVE)
17/(17+8)
# specificity
73/74

#### ROC (Receiver Operator Characteristic) curve:
# plots with (x=)false positive rate and (y=)true positive rate

# install.packages("ROCR")
library(ROCR)
ROCRpred= prediction(predictTrain, qualityTrain$PoorCare)
ROCRperf= performance(ROCRpred, "tpr","fpr")
plot(ROCRperf, colorize=T, print.cutoffs.at= seq(0,1,0.1),text.adj= c(-0.2,1.7))

#################### AUC: area under the curve

# compute the test set predictions 
predictTest = predict(QualityLog, type="response", newdata=qualityTest)
# You can compute the test set AUC by running the following two commands
ROCRpredTest = prediction(predictTest, qualityTest$PoorCare)
auc = as.numeric(performance(ROCRpredTest, "auc")@y.values)
# given a random patient from the dataset who actually received poor care, 
# and a random patient from the dataset who actually received good care, 
# the AUC is the perecentage of time that our model will classify which
# is which correctly. 

###########################################################################
framingham <- read.csv("D:/Scuola/Uni/2018-2019/Programming/R/TheAnalyticsEdge/Unit3/framingham.csv")
library(caTools)
set.seed(1000)
split= sample.split(framingham$TenYearCHD, SplitRatio = 0.65)
train = subset(framingham, split== T)
test = subset(framingham, split== F)

framinghamLog= glm(TenYearCHD ~.,data=train, family = binomial)
summary(framinghamLog)
predictTest= predict(framinghamLog, type= "response", newdata= test)
table( test$TenYearCHD, predictTest >0.5)
# accuracy
(1069+11)/(1069+6+187+11)
# baseline method : actual negative / obs
(1069+6)/(1069+6+187+11)

# out-of-sample AUC(area under the curve) ie on the testing set
library(ROCR)
ROOCpred= prediction(predictTest, test$TenYearCHD)
as.numeric(performance(ROOCpred, "auc")@y.values)

# sensutivity 
11/(187+11)
# specificity
 1069/1075
 
################################################################################
 polling <- read.csv("D:/Scuola/Uni/2018-2019/Programming/R/TheAnalyticsEdge/Unit3/PollingData.csv")
 str(polling)
 # table(polling)
 # install.packages("mice")
 library(mice)
 
 # crea subset di polling 
 simple= polling[c("Rasmussen","SurveyUSA","PropR","DiffCount")]
 summary(simple)
 table(simple)
 set.seed(144)
 
 # imputation , ie "fill in" missing data
 imputed= complete(mice(simple))
 # so now "simple" has no more NA's
 
 # plug these new values into the original data frame
 polling$Rasmussen = imputed$Rasmussen
 polling$SurveyUSA = imputed$SurveyUSA
 summary(polling)
 
 #########################################
 train= subset(polling, Year==2004| Year == 2008)
 test= subset(polling, Year==2012 )
 # baseline model 
 table(train$Republican)
 
 # smart baseline model
 table(sign(train$Rasmussen))
 
 # 'normal' baseline (ie observed data) vs smart baseline
 table( train$Republican,sign(train$Rasmussen))
 
 ################
 # check for multicollinearity
 cor(train)
 # this command won't work beacuse there are categorical variables in the dataframe
 
 str(train)
 cor(train[c("Rasmussen","SurveyUSA","DiffCount","PropR","Republican")])
 
 # create a model
 mod1= glm(Republican ~PropR, data= train, family = binomial)
 summary(mod1)
 # prediction on the training set with the first model
 pred1= predict(mod1, type="response")
 table(train$Republican, pred1>= 0.5)
 
 mod2= glm(Republican ~SurveyUSA + DiffCount, data= train, family = binomial)
 summary(mod2)
 # let's do a training set predicition with the second model 
 pred2= predict(mod2, type="response")
 table(train$Republican, pred2>= 0.5)
 
 ################ 
 # out of sample testing: start with baseline
 table(test$Republican,sign(test$Rasmussen))
 
 testPrediction= predict(mod2, newdata= test, type= "response")
 table(test$Republican, testPrediction>= 0.5)
 # the ouptup shows only one error. let's go and see to which obs it corresponds to 
 
 subset(test, testPrediction>= 0.5 & Republican== 0)
 