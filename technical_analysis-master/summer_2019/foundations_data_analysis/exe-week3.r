bull <- BullRiders
#simple plot of points, prima x, poi y
plot(bull$YearsPro,bull$BuckOuts14,xlab='Years Pro',ylab='Buckouts',main='Plot of years pro vs Buckouts')
#linear regression + regression line plotted down
abline(lm(bull$BuckOuts14 ~ bull$YearsPro))

plot(bull$Events12,bull$BuckOuts12,xlab='no of events',ylab='buckouts',main = 'No. events vs buckouts')
abline(lm(bull$BuckOuts12~bull$Events12))

cor(bull$YearsPro,bull$BuckOuts14)
cor(bull$Events12,bull$BuckOuts12)

############################################################
new_bull<- bull[bull$Events13 >=1,]
hist(new_bull$Events13)
fivenum(new_bull$Events13)
mean(new_bull$Rides13)
sd(new_bull$Rides13)

hist(new_bull$Top10_13)
fivenum(new_bull$Top10_13)
mean(new_bull$Top10_13)
sd(new_bull$Top10_13)


plot(new_bull$Rides13,new_bull$Top10_13)
abline(lm(new_bull$Top10_13~new_bull$Rides13))
cor(new_bull$Top10_13,new_bull$Rides13)
#correlation matrix
# creo oggetto da riempire
vars <-c("Top10_13", "Rides13")
cor(new_bull[,vars])

median(new_bull$Rides13)

top <- bull[(bull$Rank13>0)&(bull$Rank13<=10),]
median(top$Top10_13)

#identify a specific record
which(new_bull$Top10_13==2 & new_bull$Rides13==22)

#############################
new_bull12 <- bull[bull$Events12>0,]
hist(new_bull12$Earnings12)
fivenum(new_bull12$Earnings12)
mean(new_bull12$Earnings12)
median(new_bull12$Earnings12)
sd(new_bull12$Earnings12)

vars_2 <- c("Earnings12", "RidePer12","CupPoints12")
cor(new_bull12[,vars_2])
plot(new_bull12$RidePer12,new_bull12$Earnings12)
plot(new_bull12$CupPoints12,new_bull12$Earnings12)

cor(new_bull12$RidePer12,new_bull12$Earnings12)
cor(new_bull12$CupPoints12,new_bull12$Earnings12)

# identify specific case
which(new_bull12$Earnings12 == max(new_bull12$Earnings12))

#Subset the data
nooutlier <- new_bull12[new_bull12$Earnings12 < 1000000 ,] 
cor(nooutlier[,vars_2])
plot(nooutlier$RidePer12,nooutlier$Earnings12)
plot(nooutlier$CupPoints12,nooutlier$Earnings12)

###################################################
rides14<- new_bull$Rides14
events14 <- new_bull$Events14
RidesPerEvent14 <- rides14/events14
hist(RidesPerEvent14)
fivenum(RidesPerEvent14)
rank14 <- new_bull$Rank14
plot(RidesPerEvent14,rank14)
abline(lm(rank14~RidesPerEvent14))
cor(RidesPerEvent14,rank14)


####################
# question2 <- read.delim("D:/Scuola/Uni/2018-2019/Programming/R/FoundationsOfDataAnalysis/question2.csv")
# View(question2)

cor(question2$Minutes.Spent.Studying,question2$Exam.Grade)
x <- question2$Minutes.Spent.Studying
y <-question2$Exam.Grade
plot(x,y)
abline(lm(y~x))
which (x== max(x))

new_question <- question2[y!=92,]
cor(new_question$Minutes.Spent.Studying,new_question$Exam.Grade)