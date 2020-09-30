install.packages("SDSFoundations")
library(SDSFoundations)
animaldata <- AnimalData
  
head(animaldata)
table(animaldata$Sex)

# bar chart for categorical data
plot(animaldata$Sex,main='Barchart of animal genders',xlab='Animal gender', ylab='Frequency')

# histogram of numeric variable
hist(animaldata$Age.Intake, main='Histogram of Age intake',xlab='Age at intake')

femaleage<- animaldata$Age.Intake[animaldata$Sex == 'Female']
maleage <- animaldata$Age.Intake[animaldata$Sex== 'Male']

hist(femaleage,main='Hist of female ages',xlab='age of intake of females')
hist(maleage,main = 'Hist of male ages', breaks = 15)

max(maleage)
max(femaleage)

#quale animale nel dataset è più vecchio. restituisce il numero di riga di quella osservazione
which (animaldata$Age.Intake== 17)
#tiro fuori l'osservazione relativa al numero di riga trovata attraverso la ricerca con 'which'function
animaldata[415,]

mean(animaldata$Age.Intake)
median(animaldata$Age.Intake)
sd(animaldata$Age.Intake)

# minumum;first quartile; median(second quartile); thrid quartile; max
fivenum(animaldata$Age.Intake)


table(animaldata$Outcome.Type)
#seleziono solo animali adottati
adopted<- animaldata[animaldata$Outcome.Type =='Adoption',]
# prendi il vettore 'numero dei giorni prima di adozione'
daysadopted <- adopted$Days.Shelter
hist(daysadopted)
fivenum(daysadopted)
which(animaldata$Days.Shelter==max(daysadopted))
adult <- animaldata[animaldata$Age.Intake >1,]

weightadopted <- adult$Weight
catweight <- weightadopted[adult$Animal.Type=='Cat']
dogweight <- weightadopted[adult$Animal.Type=='Dog']

hist(dogweight)
hist(catweight)

mean(weightadopted)
mean(dogweight)
mean(catweight)

median(weightadopted)
median(dogweight)
median(catweight)

sd(weightadopted)
sd(dogweight)
sd(catweight)

#hist(weightadopted)
zscore_cat <- (13-mean(catweight))/sd(catweight)
zscore_dog <- (13-mean(dogweight)/sd(dogweight))

pnorm(zscore_cat)
fivenum(catweight)

table(animaldata$Intake.Type)
dogs_owner <- animaldata[animaldata$Animal.Type=='Dog',]
table(dogs_owner$Intake.Type)
81/length(dogs_owner$Intake.Type)
returned <- dogs_owner[dogs_owner$Outcome.Type=='Return to Owner',]
mean(returned$Days.Shelter)
hist()