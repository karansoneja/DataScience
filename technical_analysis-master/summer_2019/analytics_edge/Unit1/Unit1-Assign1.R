mvt <- read.csv("D:/Scuola/Uni/2018-2019/Programming/R/TheAnalyticsEdge/mvtWeek1.csv",header=T)

summary(mvt)
str(mvt)
#restituisce la riga dell'osservazione corrispondente
which.max(mvt$ID)
mvt$ID[18134]

mvt$Beat[which.min(mvt$Beat)]

table(mvt$Arrest)
table(mvt$LocationDescription)

# R does not automatically recognize entries that look like dates. We need to 
# use a function in R to extract the date and time.
DateConvert = as.Date(strptime(mvt$Date, "%m/%d/%y %H:%M"))
summary(DateConvert)

# Now, let's extract the month and the day of the week, and add these variables to 
# our data frame mvt. We can do this with two simple functions.
mvt$Month = months(DateConvert)

mvt$Weekday = weekdays(DateConvert)
mvt$Date = DateConvert
summary(mvt)
str(mvt)
# Q:In which month did the fewest motor vehicle thefts occur?
table(mvt$Month)

# Q:On which weekday did the most motor vehicle thefts occur?
table(mvt$Weekday)

# Q:Which month has the largest number of 
# motor vehicle thefts for which an arrest was made?
table(mvt$Month,mvt$Arrest,na.rm=T)
arrest_by_month <- mvt[mvt$Arrest=='TRUE',]
table(arrest_by_month$Month)

# or equiv
table(mvt$Month,mvt$Arrest)

# First, let's make a histogram of the variable Date. We'll add an
# extra argument, to specify the number of bars we want in our histogram. 

# needs mvt$Date=NewDate to be converted through NewDate = as.Date(strptime(mvt$Date, "%m/%d/%y %H:%M"))
hist(mvt$Date, breaks=100)

# se scrivi "boxplot(mvt$Arrest ~ mvt$Date)" succede un casino !

# Q:Does it look like there were more crimes for which arrests were 
# made in the first half of the time period or the second half of the time period? 

# boxplot(y_axix ~ x_axis)
boxplot(mvt$Date ~ mvt$Arrest)

# Q:For what proportion of motor vehicle thefts in 2001 was an arrest made? 
year01<- mvt[mvt$Year == 2001,]

table(year01$Arrest)
prop.table(table(year01$Arrest))

year07<- mvt[mvt$Year == 2007,]
prop.table(table(year07$Arrest))

# Q: Which locations are the top five locations for motor vehicle thefts, 
# excluding the "Other" category?
sort(table(mvt$LocationDescription))

# Q:Create a subset of your data, only taking observations for which the 
# theft happened in one of these five locations, and call this new data set "Top5"
street<- mvt[mvt$LocationDescription=='STREET',]
parking <- mvt[mvt$LocationDescription =='PARKING LOT/GARAGE(NON.RESID.)',]
alley<- mvt[mvt$LocationDescription=='ALLEY',]
gas_station <- mvt[mvt$LocationDescription=='GAS STATION',]
driveway <- mvt[mvt$LocationDescription=='DRIVEWAY - RESIDENTIAL',]
top5<- rbind(street,parking,alley,gas_station,driveway)

# eq 
# top5 = subset(mvt, LocationDescription=="STREET" | 
# LocationDescription=="PARKING LOT/GARAGE(NON.RESID.)" | 
# LocationDescription=="ALLEY" | LocationDescription=="GAS STATION" | 
# LocationDescription=="DRIVEWAY - RESIDENTIAL")

# Another way of doing this would be to use the %in% operator in R. 
# This operator checks for inclusion in a set. You can create the same subset by
# typing the following two lines in your R console:

# TopLocations = c("STREET", "PARKING LOT/GARAGE(NON.RESID.)", "ALLEY",
# "GAS STATION", "DRIVEWAY - RESIDENTIAL")
 
# top5 = subset(mvt, LocationDescription %in% TopLocations)



# R will remember the other categories of the LocationDescription variable
# from the original dataset, so running table(Top5$LocationDescription) will 
# have a lot of unnecessary output. To make our tables a bit nicer to read, 
# we can refresh this factor variable.

# !!!
top5$LocationDescription = factor(top5$LocationDescription)



# Q:One of the locations has a much higher arrest rate than the other locations. 
# Which is it? 
table(top5$LocationDescription,top5$Arrest)
# you can then compute the fraction of motor vehicle thefts that resulted in 
# arrests at each location. Gas Station has by far the highest percentage of
# arrests, with over 20% of motor vehicle thefts resulting in an arrest.


# Q:On which day of the week do the fewest motor vehicle thefts in residential 
# driveways happen?
table(top5$Weekday,top5$LocationDescription)

##################################################################################

# The first argument to the as.Date function is the variable we want to convert, 
# and the second argument is the format of the Date variable. We can just
# overwrite the original Date variable values with the output of this function
CocaCola <- read.csv("D:/Scuola/Uni/2018-2019/Programming/R/TheAnalyticsEdge/CocaColaStock.csv")
IBM <- read.csv("D:/Scuola/Uni/2018-2019/Programming/R/TheAnalyticsEdge/IBMStock.csv")
Boeing <- read.csv("D:/Scuola/Uni/2018-2019/Programming/R/TheAnalyticsEdge/BoeingStock.csv")
GE <- read.csv("D:/Scuola/Uni/2018-2019/Programming/R/TheAnalyticsEdge/GEStock.csv")
ProcterGamble <- read.csv("D:/Scuola/Uni/2018-2019/Programming/R/TheAnalyticsEdge/ProcterGambleStock.csv")




IBM$Date = as.Date(IBM$Date, "%m/%d/%y")
GE$Date = as.Date(GE$Date, "%m/%d/%y")
CocaCola$Date = as.Date(CocaCola$Date, "%m/%d/%y")
ProcterGamble$Date = as.Date(ProcterGamble$Date, "%m/%d/%y")
Boeing$Date = as.Date(Boeing$Date, "%m/%d/%y")

# What is the earliest year in our datasets?
summary(IBM)
mean(IBM$StockPrice)
summary(GE)

# bellissimo il secondo comando!
plot(CocaCola$Date,CocaCola$StockPrice, main="Coke Stock Price 1970-2009")
plot(CocaCola$Date,CocaCola$StockPrice, type="l",main="Coke Stock Price 1970-2009",col="red",legend=T)
# Now, let's add the line for Procter & Gamble too. You can add a line to 
# a plot in R by using the lines function instead of the plot function. 
lines(ProcterGamble$Date, ProcterGamble$StockPrice,col="blue")

# This generates a vertical line at the date March 1, 2000. The argument lwd=2 makes 
# the line a little thicker.
abline(v=as.Date(c("2000-03-01")), lwd=2)

# Let's take a look at how the stock prices changed from 1995-2005 for all five companies.


plot(CocaCola$Date[301:432], CocaCola$StockPrice[301:432], type="l", col="red", ylim=c(0,210))
lines(ProcterGamble$Date[301:432],ProcterGamble$StockPrice[301:432],type="l",col="blue", ylim=c(0,210))

which(CocaCola$Date== "1997-09-01")
which(CocaCola$Date== "1997-12-01")
plot(CocaCola$Date[333:336], CocaCola$StockPrice[333:336], type="l", col="red", ylim=c(0,150))
lines(ProcterGamble$Date[333:336],ProcterGamble$StockPrice[333:336],type="l",col="blue", ylim=c(0,150))
lines(GE$Date[333:336],GE$StockPrice[333:336],type="l",col="green", ylim=c(0,150))
lines(IBM$Date[333:336],IBM$StockPrice[333:336],type="l",col="purple", ylim=c(0,150))
lines(Boeing$Date[333:336],Boeing$StockPrice[333:336],type="l", ylim=c(0,150))


# Q:In the last two years of this time period (2004 and 2005) which stock seems to 
# be performing the best, in terms of increasing stock price?
which(CocaCola$Date== "2004-01-01")
which(CocaCola$Date== "2005-12-01")
plot(CocaCola$Date[409:433], CocaCola$StockPrice[409:433], type="l", col="red", ylim=c(0,150))
lines(ProcterGamble$Date[409:433],ProcterGamble$StockPrice[409:433],type="l",col="blue", ylim=c(0,150))
lines(GE$Date[409:433],GE$StockPrice[409:433],type="l",col="green", ylim=c(0,150))
lines(IBM$Date[409:433],IBM$StockPrice[409:433],type="l",col="purple", ylim=c(0,150))
lines(Boeing$Date[409:433],Boeing$StockPrice[409:433],type="l", ylim=c(0,150))


# Q:se the tapply command to calculate the mean stock price of IBM, sorted by months. 
# Q: For IBM, compare the monthly averages to the overall average stock price. 
# In which months has IBM historically had a higher stock price (on average)? 
tapply(IBM$StockPrice,months(IBM$Date),mean, na.rm=T)
mean(IBM$StockPrice) >tapply(IBM$StockPrice,months(IBM$Date),mean, na.rm=T)
abs(mean(IBM$StockPrice) -tapply(IBM$StockPrice,months(IBM$Date),mean, na.rm=T))

tapply(CocaCola$StockPrice,months(CocaCola$Date),mean, na.rm=T)
abs(mean(CocaCola$StockPrice) -tapply(CocaCola$StockPrice,months(CocaCola$Date),mean, na.rm=T))

tapply(GE$StockPrice,months(GE$Date),mean, na.rm=T)
abs(mean(GE$StockPrice) -tapply(GE$StockPrice,months(GE$Date),mean, na.rm=T))

##################################################################################

CPS <- read.csv("D:/Scuola/Uni/2018-2019/Programming/R/TheAnalyticsEdge/CPSData.csv")
# sorts the regions by the number of interviewees from that region
sort(table(CPS$Region))
sort(table(CPS$State))
prop.table(table(CPS$Citizenship))

# Q:For which races are there at least 250 interviewees in the CPS dataset of Hispanic ethnicity?
table(CPS$Race, CPS$Hispanic)

# Q:he function is.na(CPS$Married) returns a vector of TRUE/FALSE values for 
# whether the Married variable is missing. We can see the breakdown of whether
# Married is missing based on the reported value of the Region variable with the
# following function :
table(CPS$Region, is.na(CPS$Married))
table(CPS$Sex, is.na(CPS$Married))
table(CPS$Age, is.na(CPS$Married))
table(CPS$Citizenship, is.na(CPS$Married))


# Q:How many states had all interviewees living in a non-metropolitan area?
# proporzioni relative alle 8 combinazioni{region, areacode}
table(CPS$State, is.na(CPS$MetroAreaCode))
prop.table(table(CPS$Region, is.na(CPS$MetroAreaCode)))

# proporzioni marginali secondo 
Midwest <- CPS[CPS$Region=="Midwest",]
a=prop.table(table(is.na(Midwest$MetroAreaCode)))

Northeast<- CPS[CPS$Region=="Northeast",]
b=prop.table(table(is.na(Northeast$MetroAreaCode)))

South<- CPS[CPS$Region=="South",]
c=prop.table(table(is.na(South$MetroAreaCode)))

West<- CPS[CPS$Region=="West",]
d=prop.table(table(is.na(West$MetroAreaCode)))

data= rbind(a,b,c,d)
rm(data)

tapply(CPS$MetroAreaCode,CPS$Region,median,na.rm=T)

##################################################################################

MetroAreaMap <- read.csv("D:/Scuola/Uni/2018-2019/Programming/R/TheAnalyticsEdge/MetroAreaCodes.csv")
CountryMap <- read.csv("D:/Scuola/Uni/2018-2019/Programming/R/TheAnalyticsEdge/CountryCodes.csv")


# The following command merges the two data frames on these columns, overwriting the 
# CPS data frame with the result:

# The first two arguments determine the data frames to be merged 
# (they are called "x" and "y", respectively, in the subsequent parameters to 
# the merge function). by.x="MetroAreaCode" means we're matching on 
# the MetroAreaCode variable from the "x" data frame (CPS), while by.y="Code"
# means we're matching on the Code variable from the "y" data frame (MetroAreaMap). 
# Finally, all.x=TRUE means we want to keep all rows from the "x" data frame (CPS), 
# even if some of the rows' MetroAreaCode doesn't match any codes in MetroAreaMap
CPS = merge(CPS, MetroAreaMap, by.x="MetroAreaCode", by.y="Code", all.x=TRUE)
sort(table(CPS$MetroArea))

# Q:Which metropolitan area has the highest proportion of interviewees of Hispanic ethnicity? 
sort(tapply(CPS$Hispanic,CPS$MetroArea,mean,na.rm=T))


# Q:determine the number of metropolitan areas in the United States from which 
# at least 20% of interviewees are Asian.
sort(tapply(CPS$Race == "Asian", CPS$MetroArea, mean))

# or eq ( but here we are shown abs values rather than percentages)
asian = table(CPS$MetroArea,CPS$Race=="Asian")
t= prop.table(asian,1)
asian20= t>.2
which(asian20[,2]== "TRUE")

# Q: determine which metropolitan area has the smallest proportion of 
# interviewees who have received no high school diploma.
sort(tapply(CPS$Education == "No high school diploma", CPS$MetroArea, mean,na.rm=T))


##################################
# , merge in the country of birth information from the CountryMap data frame, replacing 
# the CPS data frame with the result.
CPS = merge(CPS, CountryMap, by.x="CountryOfBirthCode", by.y="Code", all.x=TRUE)


# Q: What proportion of the interviewees from the "New York-Northern New Jersey-Long Island, NY-NJ-PA" metropolitan
# area have a country of birth that is not the United States? 

sort(tapply(CPS$Country != "United States", CPS$MetroArea,mean, na.rm=T))
# or eq and more quickly
(tapply(CPS$Country != "United States",CPS$MetroArea== "New York-Northern New Jersey-Long Island, NY-NJ-PA",mean, na.rm=T))


# Q:Which metropolitan area has the largest number (note -- not proportion) of interviewees with a country 
# of birth in India? 
sort(tapply(CPS$Country == "India",CPS$MetroArea,sum, na.rm=T))
sort(tapply(CPS$Country == "Brazil",CPS$MetroArea,sum, na.rm=T))
sort(tapply(CPS$Country == "Somalia",CPS$MetroArea,sum, na.rm=T))

#####################################################################

AnonymityPoll<- read.csv("D:/Scuola/Uni/2018-2019/Programming/R/TheAnalyticsEdge/AnonymityPoll.csv")

