library(SDSFoundations)
acl<- AustinCityLimits

gtab<- table(acl$Grammy)
prop.table(gtab)

gtab2 <- table(acl$Grammy,acl$Gender)
prop.table(gtab2)

#within no-grammy row
prop.table(gtab2,1)

#within females 
prop.table(gtab2,2)

barplot(gtab,main='ACL grammy winners',xlab='grammy winner', ylab='counts')
barplot(gtab2, legend=T,main='gender by grammy winners', ylab='counts',xlab='gender', beside=T)

##########
older <-acl[acl$Age>=30,]
genre <- table(older$Genre)
gender <- table(older$Gender)
twoway <- table(older$Gender,older$Genre)

barplot(twoway,legend=T,beside = T)

#questo comando non ha senso!
table(genre)
# questo invece sì!
# Calculate P(A): the probability of each genre being played
prop.table(genre)

# Calculate P(A|B): the probability of each genre being played, given the artist's gender
prop.table(twoway,1)

###############
gender <- table(acl$Gender)
barplot(twoway, legend=TRUE, beside=TRUE)

prop.table(twoway,1)

gender_grammy <- table(acl$Gender, acl$Grammy)
#errore
prop.table(acl$Gender, acl$Grammy,1)
# giusto : perché prop.table vuole una 'table' come argomento, non le variabili
prop.table(gender_grammy)

######
table(older$Gender)
jazz <- older[older$Genre=='Jazz/Blues',]
length(jazz)/length(older$Genre)

rock<- older[older$Genre=='Rock/Folk/Indie',]
length(rock)/length(older$Genre)

#What is the probability that a randomly selected artist from 
#the dataset performed rock/folk/indie music?
prop.table(genre)

prop.table(twoway,1)

#############
males <- acl[acl$Gender=='M',]
genre_grammy <- table(males$Grammy,males$Genre)
prop.table(genre_grammy,1)
table(genre_grammy)
table(acl$Grammy)

#############
popular <- acl[acl$Facebook.100k ==1,]
table(popular$Age.Group)

#For each age group, find the proportion of artists who
# have 100,000 or more likes on Facebook.
pop_age <- table(acl$Age.Group,acl$Facebook.100k)
prop.table(pop_age,1)

#################################################################
#############
grades <- read.delim("D:/Scuola/Uni/2018-2019/Programming/R/FoundationsOfDataAnalysis/w4q2.csv")
A<- sum(grades$A)
B<- sum(grades$B)
C<- sum(grades$C)
D<- sum(grades$D)
F<- sum(grades$F)
A/(A+B+C+D+F)

#elimina la prima colonna con le etichette
#numero di freshman, sophomore etc
fresh<- sum(grades[1,2:6])
sopho<- sum(grades[2,2:6])
junior<- sum(grades[3,2:6])
senior<- sum(grades[4,2:6])

#What proportion of the students were upperclassmen (juniors and seniors)? 
(junior+senior)/(fresh+sopho+junior+senior)

#What is the probability that a freshman received a failing grade of F?
6/fresh

#What is the probability that a randomly selected student from the class would 
# be a sophomore that received a grade of B? 
10/(fresh+sopho+junior+senior)

#What proportion of juniors passed the course with a grade of D or better? 
junior_pass <- sum(grades[3,2:5])
24/junior

#  probability that a randomly selected student from this class would be a senior? 
24/(fresh+sopho+junior+senior)

# Q: if a student received a grade of D in the class, what is the probability that the student was a senior? 
2/D
# vs 
senior/(fresh+sopho+junior+senior)
