climate_change <- read.csv("D:/Scuola/Uni/2018-2019/Programming/R/TheAnalyticsEdge/Unit2/climate_change.csv")

# A training set refers to the data that will be used to build the model
climate_train = subset(climate_change, Year<= 2006)
# a testing set refers to the data we will use to test our predictive ability
climate_test= subset(climate_change, Year > 2006)

regr1= lm(Temp ~ MEI+ CO2+ CH4+ N2O+ CFC.11+ CFC.12+ TSI +  Aerosols, data= climate_train)
summary(regr1)

#cor(climate_train$MEI, climate_train$CO2, climate_train$CH4, climate_train$N2O, climate_train$CFC.11, climate_train$CFC.12, climate_train$TSI,climate_train$Aerosols)
cor(climate_train)

regr2= lm(Temp ~ MEI+ N2O+  TSI +  Aerosols, data= climate_train)
summary(regr2)

# use function step() to select model according to AIC criterion
regr_step= step(regr1)
summary(regr_step)

############## part 2:using test data

temp_prediction= predict(regr_step, newdata= climate_test)

SSE= sum((temp_prediction - climate_test$Temp)^2)
SST = sum((mean(climate_train$Temp)-climate_test$Temp)^2)
R_sq= 1- SSE/SST


#####################################################################################
pisa_train <- read.csv("D:/Scuola/Uni/2018-2019/Programming/R/TheAnalyticsEdge/Unit2/pisa2009train.csv")
pisa_test <- read.csv("D:/Scuola/Uni/2018-2019/Programming/R/TheAnalyticsEdge/Unit2/pisa2009test.csv")

# Q: what is the average reading test score of males?
tapply(pisa_train$readingScore,pisa_train$male, mean, na.rm=T)
summary(pisa_train)

# to remove observations with any missing value from pisaTrain and pisaTest
pisa_train = na.omit(pisa_train)
pisa_test = na.omit(pisa_test)

##########################
# Unordered factors in regression models 
###############################
# Factor variables are variables that take on a discrete set of values.
# An ordered factor has a natural ordering between the levels
# (an example would be the classifications "large," "medium," and "small").
###############################
# To include unordered factors in a linear regression model, we define one level as 
# the "reference level" and add a binary variable for each of the remaining levels. 
# In this way, a factor with n levels is replaced by n-1 binary variables. The reference 
# level is typically selected to be the most frequently occurring level in the dataset.
# 
# As an example, consider the unordered factor variable "color", with levels "red", "green",
# and "blue". If "green" were the reference level, then we would add binary variables
# "colorred" and "colorblue" to a linear regression problem. All red examples would have
# colorred=1 and colorblue=0. All blue examples would have colorred=0 and colorblue=1. All
# green examples would have colorred=0 and colorblue=0.



# Because the race variable takes on text values, it was loaded as a factor variable
# However, by default R selects the first level alphabetically ("American Indian/Alaska 
# Native") as the reference level of our factor instead of the most common level ("White"). 
# Set the reference level of the factor by typing the following two lines in your R console
pisa_train$raceeth = relevel(pisa_train$raceeth, "White")
pisa_test$raceeth = relevel(pisa_test$raceeth, "White")


# R provides the shorthand notation "readingScore ~ ." to mean "predict readingScore 
# using all the other variables in the data frame." The period is used to replace listing 
# out all of the independent variables. As an example, if your dependent variable is 
# called "Y", your independent variables are called "X1", "X2", and "X3", and your
# training data set is called "Train", instead of the regular notation:
#   
#   LinReg = lm(Y ~ X1 + X2 + X3, data = Train)
# 
# You would use the following command to build your model:
#   
#   LinReg = lm(Y ~ ., data = Train)

lmScore= lm(readingScore ~ ., data= pisa_train)
summary(lmScore)
SSE= sum((lmScore$residuals)^2)
RMSE= sqrt(SSE/nrow(pisa_train))

pred_score= predict(lmScore,newdata= pisa_test)
summary(pred_score)

baseline= mean(pisa_train$readingScore)
# Q:What is the range between the maximum and minimum predicted reading score on the test set?
summary(pred_score)[6]-summary(pred_score)[1]

# attenzione a quando usare test data e quando train data
SSE= sum((pred_score - pisa_test$readingScore)^2)
RMSE= sqrt(SSE/nrow(pisa_test))

SST = sum((mean(pisa_test$readingScore)-pisa_train$readingScore)^2)
R_sq= 1- SSE/SST


# baseline model
baseline= mean(pisa_train$readingScore)
SST_base= sum((baseline- pisa_test$readingScore)^2)
# Q: What is the test-set R-squared value of lmScore?
#The test-set R^2 is defined as 1-SSE/SST, where SSE is the sum of squared errors of 
# the model on the test set and SST is the sum of squared errors of the baseline model.
R_sq_base = 1-SSE/SST_base

#####################################################################################
FluTrain <- read.csv("D:/Scuola/Uni/2018-2019/Programming/R/TheAnalyticsEdge/Unit2/FluTrain.csv")

which.max(FluTrain$Queries)
FluTrain$Week[303]
# Q:Most of the ILI values are small, with a relatively small number of much 
# larger values (in statistics, this sort of data is called "skew right"). 
hist(FluTrain$ILI)

# Plot the natural logarithm of ILI versus Queries.
plot(FluTrain$Queries,log(FluTrain$ILI))

FluTrend1= lm(log(ILI)~ Queries, data= FluTrain)
summary(FluTrend1)


# For a single variable linear regression model, there is a direct relationship between
# the R-squared and the correlation between the independent and the dependent variables.
Correlation = cor(FluTrain$Queries, log(FluTrain$ILI))
Correlation^2 
# Correlation^2 is equal to the R-squared value. It can be proved that this is always the case. 

################# out of sample data
PredTest1 = exp(predict(FluTrend1, newdata=FluTest))
summary(PredTest1)
FluTest$Week

#What is our estimate for the percentage of ILI-related physician visits for 
# the week of March 11, 2012?
which(FluTest$Week == "2012-03-11 - 2012-03-17")
PredTest1[11] 

# What is the relative error betweeen the estimate (our prediction) and the 
# observed value for the week of March 11, 2012? Note that the relative error is
# calculated as "(Observed ILI - Estimated ILI)/Observed ILI"
obs= FluTest$ILI[which(FluTest$Week== "2012-03-11 - 2012-03-17")]
1- PredTest1[11] /obs

#What is the Root Mean Square Error (RMSE) between our estimates and the actual observations for the 
# percentage of ILI-related physician visits, on the test set?
SSE= sum((PredTest1 - FluTest$ILI)^2)
RMSE= sqrt(SSE/nrow(FluTest))

library(zoo)
# create the ILILag2 variable in the training set:
#  the value of -2 passed to lag means to return 2 observations before the current one
# na.pad=TRUE means to add missing values for the first two weeks of our dataset, where we can't 
# compute the data from 2 weeks earlier.
ILILag2 = lag(zoo(FluTrain$ILI), -2, na.pad=TRUE)
FluTrain$ILILag2 = coredata(ILILag2)

# log of ILILag2 against the log of ILI. 
plot(log(FluTrain$ILILag2), log(FluTrain$ILI))

FluTrend2= lm(log(ILI) ~ Queries + log(ILILag2) , data= FluTrain)
summary(FluTrend2)

# To make predictions with our FluTrend2 model, we will also need to add ILILag2 to the FluTest data frame
# Modify the code from the previous subproblem to add an ILILag2 variable to the FluTest data frame
ILILag2 = lag(zoo(FluTest$ILI), -2, na.pad=TRUE)
FluTest$ILILag2= coredata(ILILag2)
summary(ILILag2)

# Fill in the missing values for ILILag2 in FluTest. 
FluTest$ILILag2[1] = FluTrain$ILI[416]
FluTest$ILILag2[2] = FluTrain$ILI[417]

# Obtain test set predictions of the ILI variable from the FluTrend2 model
PredTest2 = exp(predict(FluTrend2, newdata=FluTest))
SSE_2= sum((PredTest2 - FluTest$ILI)^2)
RMSE_2= sqrt(SSE/nrow(FluTest))
rm(SSE)
rm(RMSE)

######################################################################################
# load built-in data set
data(state)
statedata = cbind(data.frame(state.x77), state.abb, state.area, state.center,  state.division, state.name, state.region)
