library(SDSFoundations)
world = WorldBankData
str(world)
gbr = subset(world, Country == "United Kingdom")
gbr2000= subset(world, Country == "United Kingdom" & year >= 2000 & year <2010)

# create a new var to rescale the time dimention in order to 
# start from t=0
time= gbr2000$year-2000
mv= gbr2000$motor.vehicles
plot(time, mv)

# regression analysis
expFit(time,mv)
logisticFit(time, mv)
tripleFit(time,mv)

# prediction for exp model
expFitPred(time,mv, 12)
logisticFitPred(time,mv, 12)
#########################################
usa = subset(world, Country == "United States")

usa90 = subset(usa,  year >= 1990 )
# Create a new variable in our datset called internet.mil to
# make the number of users more interpretable (into millions)
usa90$internet.mil <- usa90$internet.users / 1000000

# create a new var to rescale the time dimention in order to 
# start from t=0
usa90$time= usa90$year-1990

usa10 = subset(usa90,time<10 )

expFit(usa10$time,usa10$internet.users )
logisticFit(usa10$time,usa10$internet.users )
# predictions
expFitPred(usa10$time,usa10$internet.users ,16)
logisticFitPred(usa10$time,usa10$internet.users ,16)
