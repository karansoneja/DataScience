stevens <- read.csv("D:/Programming/R/TheAnalyticsEdge/Unit4/stevens.csv")
str(stevens)

library(caTools)
set.seed(3000)
spl= sample.split(stevens$Reverse, 0.7)
train= subset(stevens, spl== T)
test = subset(stevens, spl== F)

#install.packages("rpart")
library(rpart)
#install.packages("rpart.plot")
library(rpart.plot)

# create TREE model
stevensTree= rpart(Reverse ~ Circuit + Issue + Petitioner+ Respondent + LowerCourt + Unconst, data= train, method="class", minbucket= 25)
# draw the plot
prp(stevensTree)


# prediction on the out-of-sample data
# " type= "class" " to get probabilities

# Recall that CART= Classification And Regression Tree
predictCART = predict(stevensTree, newdata = test, type= "class")
# confusion matrix
table(test$Reverse,predictCART)

# accuracy
(41+71)/(41+36+22+71)

# ROC curve: receiver operating characteristic
library(gplots,OCR)
# notice here we don't need to specify the 'type'
predictROC= predict(stevensTree,newdata = test)
# ogni riga è un 'bucket' (ie subset) in cui tutte le osservazioni sono state suddivise
predictROC

# plot of ROC curve
pred= prediction(predictROC[,2], test$Reverse)
perf= performance(pred,"tpr","fpr")
plot(perf) 

# Area Under the Curve (AUC)
as.numeric(performance(pred, "auc")@y.values)

##########################################################################
# create model
stevensTree2= rpart(Reverse ~ Circuit + Issue + Petitioner+ Respondent + LowerCourt + Unconst, data= train, method="class", minbucket= 5)
# draw the plot
prp(stevensTree2)

# create model
stevensTree3= rpart(Reverse ~ Circuit + Issue + Petitioner+ Respondent + LowerCourt + Unconst, data= train, method="class", minbucket= 100)
# draw the plot
prp(stevensTree3)

## --> higher 'minibucket' parameter implies less splits

###############################################
## RANDOM FORESTS

library(randomForest)
StevensForests = randomForest(Reverse ~ Circuit + Issue + Petitioner + Respondent + LowerCourt,  Unconst, data= train, nodesize= 25, ntrees= 200)

# WARNING: need to convert the "Reverse" variable into a factor for it 
# to be properly used by randomForest()
train$Reverse= as.factor(train$Reverse)
test$Reverse= as.factor(test$Reverse)
StevensForests = randomForest(Reverse ~ Circuit + Issue + Petitioner + Respondent + LowerCourt +  Unconst, data= train, nodesize= 25, ntrees= 200)
predictForest= predict(StevensForests, newdata = test)
#confusion matrix to check accuracy of predictions
table(test$Reverse, predictForest)

# accuracy
(43+75)/(43+34+18+75)
# improved accuracy than CART model above!

####################################
# CROSS-VALIDATION

# install.packages("caret")
library(caret)
# install.packages("e1071")
library(e1071)

# define the number of folds to split the sample in for the 
# cross validation
# The command " method="cv" means "cross validation"
numFolds= trainControl(method="cv", number=10)
# " cp" stands for "complexity parameter"
cpGrid= expand.grid(.cp=seq(0.01,0.5,0.01))
# the command " method="rpart" " is for cross-valid of CART models
train(Reverse ~ Circuit + Issue  + Petitioner + Respondent + LowerCourt + Unconst, data= train, method="rpart", trControl= numFolds, tuneGrid= cpGrid)

# COMMENT on the train() output: the first col 'cp'indicates the value of cp that was used; 
# 'Accuracy' stands for the cross-val accuracy for that cp value. 

# Now we can create a new tree model using the optimal cp value 
# we have just found
library(rpart)
library(rpart.plot)
StevensTreeCV = rpart(Reverse ~ Circuit + Issue + Petitioner + Respondent + LowerCourt + Unconst , data=train, method= "class", cp= 0.18)
# use ' type="class" ' to get type predicitons
PredictCV = predict(StevensTreeCV, newdata = test, type="class")
# confusion matrix
table(test$Reverse, PredictCV)
#  plot the tree
prp(StevensTreeCV)
