# creo un data frame 
Country = c("Ita","Fra","Esp","Deu")
LifeExp = c(82, 81, 79, 76)

CountryData= data.frame(Country,LifeExp)

Pop= c(62000,75000,56000,82000)
# aggiunge colonne a un dataframe già esistente
CountryData$Population= Pop
CountryData

# creo un altro data frame
Country= c("Eng","Bel")
LifeExp=c(75,79)
Population=c(42000,8000)

NewCountryData= data.frame(Country,LifeExp,Population)

#metto insieme i due data frames
AllCountryData= rbind(CountryData,NewCountryData)

AllCountryData

#######################
## WHO.csv

#structure of a data frame: all variables and their types
str(WHO)

#summary stats of a data frame
summary(WHO)

#create a subset of existing data frame
WHO_europe= subset(WHO,Region == 'Europe')

str(WHO_europe)
summary(WHO_europe)

#mostra current working directory
getwd()

#set new working directory
# setwd("D:/Scuola/Uni/2018-2019/Programming/R/TheAnalyticsEdge")

# esporta dati un in csv
write.csv(WHO_europe,"WHO_Europe.csv")

# show what variables are saved in global environment
ls()
#remove variables from global environment
rm(VARIABLENAME)


mean(WHO$Under15)
sd(WHO$Under15)

# summary() vs fivenum()
summary(WHO$Under15)
fivenum(WHO$Under15)

# trova l'osservazione che ha min{Under15  ie %pop under 15} in tutto il data frame
which.min(WHO$Under15)
WHO$Country[86]

which.max(WHO$Under15)
WHO$Country[124]

# plots
plot(WHO$GNI,WHO$FertilityRate)
outliers= subset(WHO,GNI>10000 & FertilityRate> 2.5)
nrow(outliers)

# mostra alcune colonne di un data frame
outliers[c("Country","GNI","FertilityRate")]

###### exercices
mean(WHO$Over60)
which.min(WHO$Over60)
WHO$Country[183]
which.max(WHO$LiteracyRate)
WHO$Country[44]

# other kinds of plots
hist(WHO$CellularSubscribers)
# box plot con due variabili
# description: box è definito da 1Q,3Q; thick line: median(2Q); 
# the extremum are given by max and min values; the outlier are
#s.t. {obs> 3Q+(3Q-1Q := iqr)} for obs above maximum
boxplot(WHO$LifeExpectancy~WHO$Region)

########## tables
# counts no. observations for each variable
table(WHO$Region)

# splits obs by region of the variable "Over60", and shows the mean of 
# this variable
tapply(WHO$Over60,WHO$Region,mean) 

tapply(WHO$LiteracyRate,WHO$Region,min,na.rm=T)

tapply(WHO$ChildMortality,WHO$Region,mean,na.rm=T)
