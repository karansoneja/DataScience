wealthy <- read.delim("D:/Scuola/Uni/2018-2019/Programming/R/FoundationsOfDataAnalysis/wealthy.csv")
linFit(wealthy$Population, wealthy$Millionaires)
(cor(wealthy$Population, wealthy$Millionaires))^2

#  You create a new variable, subtracting the lowest Population value in the sample from each Population value
new_pop = c(wealthy$Population - min(wealthy$Population))

# This gives a new result from linFit()
linFit(new_pop, wealthy$Millionaires)

########################################
WR <- WorldRecords
mens800 = WR[WR$Event== "Mens 800m",]

linFit(mens800$Year, mens800$Record)

str(WR)
table(WR$Event)

WR[WR$Athlete=="Usain Bolt",]

#Subset the data
menshot <- WR[WR$Event=='Mens Shotput',]
womenshot <- WR[WR$Event=='Womens Shotput',] 

#Create scatterplots
plot(menshot$Year,menshot$Record,main='Mens Shotput World Records',xlab='Year',ylab='World Record Distance (m)',pch=16)
plot(womenshot$Year,womenshot$Record,main='Womens Shotput World Records',xlab='Year',ylab='World Record Distance (m)',pch=16)

#Run linear models
linFit(menshot$Year, menshot$Record)
linFit(womenshot$Year,womenshot$Record)

#################################
# subset the data
menmile= subset(WR, Event== "Mens Mile")
womenmile= subset(WR, Event== "Womens Mile")

# create scatterplots
plot(menmile$Year,menmile$Record,pch=16, main ="Years vs Men's record on Mile")
plot(womenmile$Year,womenmile$Record,pch=16, main ="Years vs Women's record on Mile")

# run linear models
linFit(menmile$Year,menmile$Record)
linFit(womenmile$Year,womenmile$Record)
########################################
# Create a new data frame that contains the world record cases in the men's pole vault event in years 1970 and later. 
menpole = subset(WR, Event== "Mens Polevault" & Year>= 1970)
str(menpole)

which.max(menpole$Record)
menpole[37,]

menpole[menpole$Record> 6.00 & menpole$Event== "Mens Polevault",]
plot(menpole$Year,menpole$Record)
linFit(menpole$Year,menpole$Record)
