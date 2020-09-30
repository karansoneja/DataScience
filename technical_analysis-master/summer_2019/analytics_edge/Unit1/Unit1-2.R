str(USDA)
summary(USDA)
which.max(USDA$Sodium)
# mostra tutte le variabili presenti nel data frame
names(USDA)
USDA$Description[265]

HighSodium= subset(USDA,Sodium>10000)
nrow(HighSodium)
HighSodium$Description

# come trovare l'osservazione 'caviar' nella colonna 'descrizioni'
match("CAVIAR",USDA$Description)
USDA$Sodium[4154]
# o equivalentemente
USDA$Sodium[match("CAVIAR",USDA$Description)]

summary(USDA$Sodium)
sd(USDA$Sodium,na.rm=T)
##################

plot(USDA$Protein,USDA$TotalFat,xlab='Protein',ylab='Fat',main='Protein vs Fat',col="red")
# definisci range sull'asse x
hist(USDA$VitaminC,xlab='Vitamin C',xlim=c(0,100),breaks = 2000)

boxplot(USDA$Sugar,main='box plot of sugar level',ylab='Sugar in grams')

########## aggiungere variabili
# creo subset con boolean (TRUE/FALSE), dove grazie a 'as.numeric()'
# ottengo che TRUE:= 1 e FALSE:= 0
HighSodium= as.numeric(USDA$Sodium> mean(USDA$Sodium,na.rm = T))
USDA$HighSodium= HighSodium

HighProtein= as.numeric(USDA$Protein> mean(USDA$Protein,na.rm = T))
USDA$HighProtein=HighProtein

HighFat= as.numeric(USDA$TotalFat> mean(USDA$TotalFat,na.rm = T))
USDA$HighFat=HighFat

HighCarbs= as.numeric(USDA$Carbohydrate> mean(USDA$Carbohydrate,na.rm = T))
USDA$HighCarbs=HighCarbs

str(USDA)

table(USDA$HighSodium)
table(USDA$HighSodium, USDA$HighFat)

# descr: group arg1 by arg2 and apply arg3
#  sorts obs of iron based on their protein level(H/L) 
tapply(USDA$Iron,USDA$HighProtein,mean, na.rm=T)

tapply(USDA$VitaminC,USDA$HighCarbs,max,na.rm=T)
# confronta secondo summary()
tapply(USDA$VitaminC,USDA$HighCarbs,summary,na.rm=T)
