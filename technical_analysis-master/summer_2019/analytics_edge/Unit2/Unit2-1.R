wine <- read.csv("D:/Scuola/Uni/2018-2019/Programming/R/TheAnalyticsEdge/Unit2/wine.csv")

model1 = lm(Price~ AGST,data=wine)
summary(model1)
str(model1)
model1$residuals
SSE= sum(model1$residuals^2)

model2= lm(Price~ AGST +HarvestRain, data=wine)
summary(model2)
SSE2= sum(model2$residuals^2)

model3= lm(Price ~ AGST + HarvestRain + WinterRain + Age + FrancePop, data=wine)
summary(model3)
SSE3= sum(model3$residuals^2)

model4= lm(Price ~ HarvestRain + WinterRain, data= wine)
summary(model4)
SSE4= sum(model4$residuals^2)

# best model
model5= lm(Price ~ AGST + HarvestRain + WinterRain +Age, data= wine)
summary(model5)
SSE5= sum(model5$residuals^2)


# correlation matrix
# to check for multicollinearity!
cor(wine)

###################### part 2: out-of-sample data
wineTest= read.csv("D:/Scuola/Uni/2018-2019/Programming/R/TheAnalyticsEdge/Unit2/wine_test.csv")

predictTest= predict(model5, newdata = wineTest)
predictTest
str(wineTest)

SSE_test1= sum((wineTest$Price - predictTest)^2)
SST_test1= sum((wineTest$Price- mean(wine$Price))^2)
R_sq= 1-(SSE_test1/SST_test1)

###############################################################################################
baseball <- read.csv("D:/Scuola/Uni/2018-2019/Programming/R/TheAnalyticsEdge/Unit2/baseball.csv")
moneyball = subset(baseball, Year <2002)

# aggiungi al volo una variabile al dataframe
moneyball$RD= moneyball$RS- moneyball$RA
str(moneyball)

plot(moneyball$RD,moneyball$W)

wins_reg= lm(W ~ RD, data=moneyball)
summary(wins_reg)

runs_reg= lm(RS ~ OBP + SLG,data= moneyball)
summary(runs_reg)

opp_runs= lm(RA ~ OOBP + OSLG, data= moneyball)
summary(opp_runs)

# "Quick question"
quick <- read.delim("D:/Scuola/Uni/2018-2019/Programming/R/TheAnalyticsEdge/Unit2/quick.csv")
predictTest= predict(runs_reg, newdata = quick)
summary(predictTest)
str(predictTest)
predictTest

##################################################################################

NBA <- read.csv("D:/Scuola/Uni/2018-2019/Programming/R/TheAnalyticsEdge/Unit2/NBA_train.csv")

str(NBA)
table(NBA$W, NBA$Playoffs)

NBA$PTSdiff= NBA$PTS - NBA$oppPTS
plot(NBA$PTSdiff,NBA$W)

wins_reg= lm(W ~PTSdiff, data= NBA)
summary(wins_reg)

points_reg = lm(PTS ~ X2PA+ X3PA+ FTA+AST+DRB+ORB+TOV+STL+BLK, data=NBA)
summary(points_reg)

u_hat= points_reg$residuals
SSE= sum(u_hat^2)
RMSE= sqrt(SSE/nrow(NBA))
mean(NBA$PTS)

# elimina dal modello precedente la variabilie con 
# coeff non significativo con p-val più elevato
points_reg2 = lm(PTS ~ X2PA+ X3PA+ FTA+AST+DRB+ORB+STL+BLK, data=NBA)
summary(points_reg2)

points_reg3 = lm(PTS ~ X2PA+ X3PA+ FTA+AST+ORB+STL+BLK, data=NBA)
summary(points_reg3)

points_reg4 = lm(PTS ~ X2PA+ X3PA+ FTA+AST+ORB+STL, data=NBA)
summary(points_reg4)

SSE_4= sum(points_reg4$residuals^2)
RMSE4= sqrt(SSE_4/nrow(NBA))

########################### out of sample data
NBA_test <- read.csv("D:/Scuola/Uni/2018-2019/Programming/R/TheAnalyticsEdge/Unit2/NBA_test.csv")
points_prediction= predict(points_reg4, newdata= NBA_test)
SSE_test= sum((points_prediction- NBA_test$PTS)^2)
SST_test= sum((mean(NBA$PTS)-NBA_test$PTS)^2)
R_sq = 1- SSE_test/SST_test
RMSE= sqrt(SSE_test/nrow(NBA_test))

