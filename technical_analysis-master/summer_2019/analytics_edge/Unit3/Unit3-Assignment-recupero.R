songs <- read.csv("D:/Scuola/Uni/2018-2019/Programming/R/TheAnalyticsEdge/Unit3/songs.csv")

# How many observations (songs) are from the year 2010?
table(songs$year)

# How many songs does the dataset include for which the artist name is "Michael Jackson"?
table(songs$artistname== "Michael Jackson")

mjackson= subset(songs,artistname== "Michael Jackson")

# which songs made it to the top10 ? 
mjackson_t10= mjackson[mjackson$Top10== 1,]
# or eq 
mjackson[c("songtitle", "Top10")]

table(songs$timesignature)

# Out of all of the songs in our dataset, which one has the highest tempo ?
songs[which.max(songs$tempo), c("songtitle","artistname","year", "Top10")]

# create training and testing data frames 
train= subset(songs, year<= 2009)
test= subset(songs, year>= 2010)

############################
# define a vector of variable names called nonvars - these are the variables that we won't use in our model.
nonvars = c("year", "songtitle", "artistname", "songID", "artistID")

# remove these variables from your training and testing sets
train = train[ , !(names(train) %in% nonvars) ]
test = test[ , !(names(test) %in% nonvars) ]

SongsLog1 = glm(Top10 ~ ., data=train, family=binomial)      
summary(SongsLog1)
# Given that these two variables are highly correlated, Model 1 suffers from multicollinearity. To avoid this
# issue, we will omit one of these two variables and rerun the logistic regression. 
cor(train$energy,train$loudness)


# create "Model 2", which is Model 1 without the independent variable "loudness"
SongsLog2 = glm(Top10 ~ . - loudness, data=train, family=binomial)
summary(SongsLog2)

SongsLog3 = glm(Top10 ~ . - energy, data=train, family=binomial)
summary(SongsLog3)
# NOTE  loudness has a positive coefficient estimate, meaning that 
# our model predicts that songs with heavier instrumentation tend to be more popular

######### making predictions
predict1 = predict(SongsLog3, newdata= test, type= "response")
#  create a confusion matrix with a threshold of 0.45 
table(test$Top10, predict1> 0.45)
# compute accuracy of the model
(309+19)/(309+5+40+19)

# accuracy of baseline model (need using test data frame!)
table(test$Top10)
314/(314+59)

# How many songs does Model 3 correctly predict as Top 10 hits in 2010
# ans: 19
# How many non-hit songs does Model 3 predict will be Top 10 hits 
# ans : 5

# sensitivity of model 3
19/59

# specificity
309/314


## specificity preferred over sensitivity!!
#########################################################################
parole <- read.csv("D:/Scuola/Uni/2018-2019/Programming/R/TheAnalyticsEdge/Unit3/parole.csv")

table(parole$violator)
summary(parole)
str(parole)

# there are two variables which are 'unordered factors' (ref Unit2-assignment).
# to have R reading these variables differently, use "as.factor()"
parole$state = as.factor(parole$state)
parole$crime = as.factor(parole$crime)

# To ensure consistent training/testing set splits, run the following
set.seed(144)
library(caTools)
split = sample.split(parole$violator, SplitRatio = 0.7)
train = subset(parole, split == TRUE)
test = subset(parole, split == FALSE)

# train a model 
model1= glm (violator ~ . , data= train, family= "binomial")
summary(model1)

# Q: Consider a parolee who is male, of white race, aged 50 years at prison release, 
# from the state of Maryland, served 3 months, had a maximum sentence of 12 months, 
# did not commit multiple offenses, and committed a larceny. 
log_odds= -4.2411574 + 0.3869904 +0.8867192+ 50*(-0.0001756 )+3*(-0.1238867)+0.0802954*12 +0.6837143
P_1= 1/(1+exp(-log_odds))

pred= predict(model1, newdata= test,  type="response")
# What is the maximum predicted probability of a violation?
summary(pred)

table(test$violator, pred> 0.6)
# sensitivity
12/23
# specificity
167/179
#What is the model's accuracy?
(167+12)/(167+12+11+12)

# baseline model
table(test$violator)

songs <- read.csv("D:/Scuola/Uni/2018-2019/Programming/R/TheAnalyticsEdge/Unit3/songs.csv")

# How many observations (songs) are from the year 2010?
table(songs$year)

# How many songs does the dataset include for which the artist name is "Michael Jackson"?
table(songs$artistname== "Michael Jackson")

mjackson= subset(songs,artistname== "Michael Jackson")

# which songs made it to the top10 ? 
mjackson_t10= mjackson[mjackson$Top10== 1,]
# or eq 
mjackson[c("songtitle", "Top10")]

table(songs$timesignature)

# Out of all of the songs in our dataset, which one has the highest tempo ?
songs[which.max(songs$tempo), c("songtitle","artistname","year", "Top10")]

# create training and testing data frames 
train= subset(songs, year<= 2009)
test= subset(songs, year>= 2010)

############################
# define a vector of variable names called nonvars - these are the variables that we won't use in our model.
nonvars = c("year", "songtitle", "artistname", "songID", "artistID")

# remove these variables from your training and testing sets
train = train[ , !(names(train) %in% nonvars) ]
test = test[ , !(names(test) %in% nonvars) ]

SongsLog1 = glm(Top10 ~ ., data=train, family=binomial)      
summary(SongsLog1)
# Given that these two variables are highly correlated, Model 1 suffers from multicollinearity. To avoid this
# issue, we will omit one of these two variables and rerun the logistic regression. 
cor(train$energy,train$loudness)


# create "Model 2", which is Model 1 without the independent variable "loudness"
SongsLog2 = glm(Top10 ~ . - loudness, data=train, family=binomial)
summary(SongsLog2)

SongsLog3 = glm(Top10 ~ . - energy, data=train, family=binomial)
summary(SongsLog3)
# NOTE  loudness has a positive coefficient estimate, meaning that 
# our model predicts that songs with heavier instrumentation tend to be more popular

######### making predictions
predict1 = predict(SongsLog3, newdata= test, type= "response")
#  create a confusion matrix with a threshold of 0.45 
table(test$Top10, predict1> 0.45)
# compute accuracy of the model
(309+19)/(309+5+40+19)

# accuracy of baseline model (need using test data frame!)
table(test$Top10)
314/(314+59)

# How many songs does Model 3 correctly predict as Top 10 hits in 2010
# ans: 19
# How many non-hit songs does Model 3 predict will be Top 10 hits 
# ans : 5

# sensitivity of model 3
19/59

# specificity
309/314


## specificity preferred over sensitivity!!
#########################################################################
parole <- read.csv("D:/Scuola/Uni/2018-2019/Programming/R/TheAnalyticsEdge/Unit3/parole.csv")

table(parole$violator)
summary(parole)
str(parole)

# there are two variables which are 'unordered factors' (ref Unit2-assignment).
# to have R reading these variables differently, use "as.factor()"
parole$state = as.factor(parole$state)
parole$crime = as.factor(parole$crime)

# To ensure consistent training/testing set splits, run the following
set.seed(144)
library(caTools)
split = sample.split(parole$violator, SplitRatio = 0.7)
train = subset(parole, split == TRUE)
test = subset(parole, split == FALSE)

# train a model 
model1= glm (violator ~ . , data= train, family= "binomial")
summary(model1)

# Q: Consider a parolee who is male, of white race, aged 50 years at prison release, 
# from the state of Maryland, served 3 months, had a maximum sentence of 12 months, 
# did not commit multiple offenses, and committed a larceny. 
log_odds= -4.2411574 + 0.3869904 +0.8867192+ 50*(-0.0001756 )+3*(-0.1238867)+0.0802954*12 +0.6837143
P_1= 1/(1+exp(-log_odds))

pred= predict(model1, newdata= test,  type="response")
# What is the maximum predicted probability of a violation?
summary(pred)

table(test$violator, pred> 0.6)
# sensitivity
12/23
# specificity
167/179
#What is the model's accuracy?
(167+12)/(167+12+11+12)

# baseline model
table(test$violator)

# out-of-sample AUC(area under the curve) ie on the testing set
# meaning of AUC here: The probability the model can correctly 
# differentiate between a randomly selected parole violator and a randomly 
# selected parole non-violator.
library(ROCR)
ROOCpred= prediction(pred, test$violator)
as.numeric(performance(ROOCpred, "auc")@y.values)



