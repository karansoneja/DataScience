### TREND ESTIMATION
####################

# install.packages("xxx")
# library(xxx)

# two equivalent approaches, one for .csv and one for .txt

# atlanta <- read.csv("D:/Scuola/Uni/2018-2019/Programming/R/TimeSeries/atlanta.csv", sep="")
data= read.table("atlanta.txt", header = T)

# get the labels of the columns
names(data)

# use as.vector() to stack columns into a vector.
# take transpose with function t(), because we want to preserve order of the rows
temp = as.vector(t(data[,-c(1,14)]))

# use "ts()" creates an object named "time-series" out of the 
# fitted values we found
temp= ts(temp, start= 1879, frequency= 12)
# make a plot of the series 
ts.plot(temp, ylab= "Temperature")

############################################
# Estimation of the trend 
# a. moving averages

# create equally spaced time points for fitting trends
time.pts = c(1:length(temp))
time.pts = c(time.pts - min(time.pts))/max(time.pts)

# create a moving average by kernel regression with ksmooth(); recall that MA is a particular
# case of kernel regression (ie when has a constant kernel)
mav.fit = ksmooth(time.pts, temp, kernel= "box")
# get now a time series out of the estimation :
temp.fit.mav = ts(mav.fit$y, start=1902, frequency = 12 )

# get the plots and draw lines to highlight trends(if any)
ts.plot(temp, ylab= "temperature")
# fitted moving average trend in purple
lines(temp.fit.mav, lwd=2, col="purple")
# add a constant line for comparison
abline(temp.fit.mav[1], 0 , lwd=2 , col="blue")


##############################
# b. parametric regression

# fit a parametric quadratic polynomial
x1= time.pts
x2= time.pts^2
lm.fit= lm(temp ~ x1 + x2)
summary(lm.fit)

# is there a trend? create a time series to find out
temp.fit.lm= ts(fitted(lm.fit),  start= 1879, frequency = 12)
# then create the plot
ts.plot(temp, ylab= "temperature")
# a draw of the fitted values
lines(temp.fit.lm, lwd=2, col= "green")
abline(temp.fit.mav[1], 0 , lwd=2 , col="blue")

#######################################
# c. non parametric estimation

# 1. local polynomial trend estimation
loc.fit = loess(temp ~ time.pts)
temp.loc.fit = ts(fitted(loc.fit), start= 1879,frequency = 12)

# 2. splines trend estimation
# the command "s(time.pts))" indicates the spline splits. Deafult is a linear model
library(mgcv)
gam.fit= gam(temp ~ s(time.pts))
temp.fit.gam= ts(fitted(gam.fit),start= 1879,frequency = 12)

# is there a trend? 
ts.plot(temp, ylab= "temperature")
lines(temp.loc.fit, lwd=2, col="brown")
lines(temp.fit.gam, lwd=2, col= "red")
abline(temp.fit.mav[1], 0 , lwd=2 , col="blue")

####################################
# comparing all estimations

# first two commands define a scaling for the plot
all.val = c(temp.fit.mav,temp.fit.lm,temp.fit.gam,temp.loc.fit)
ylim= c(min(all.val),max(all.val))
# plot the four trends we had found before
ts.plot(temp.fit.lm,lwd=2,col="green",ylim=ylim,ylab="Temperature")
lines(temp.fit.mav,lwd=2,col="purple")
lines(temp.fit.gam,lwd=2,col="red")
lines(temp.loc.fit,lwd=2,col="brown")
legend(x=1900,y=64,legend=c("MAV","LM","GAM","LOESS"),lty = 1, col=c("purple","green","red","brown"))

  

######################################################################################
####### SEASONALITY ESTIMATION###
#################################

# load data frame
data= read.table("atlanta.txt", header = T)

#install.packages("TSA")
library(TSA)

# use as.vector() to stack columns into a vector.
# take transpose with function t(), because we want to preserve order of the rows
temp = as.vector(t(data[,-c(1,14)]))

# use "ts()" creates an object named "time-series" out of the 
# fitted values we found
temp= ts(temp, start= 1879, frequency= 12)

# Extract the season info from a time series: get dummy variables
month= season(temp)

######################
# a. linear regression


# drop January, ie 'create' intercept 
# here each coefficient is the differenence from the obs in January
model1= lm(temp~ month)
summary(model1)

# equiv , can have no intercept and 12 dummies
model2= lm(temp~ month-1)
summary(model2)
# here, each coefficient is the mean for each of the twelve months.
# very high R^2 implies that seasonality determines most of the variability 
# in the monthly averages over the years

#######################
# b. cos-sin model

# harmonic() takes  a time series as an input, and the frequenny( here=1)
har1= harmonic(temp,1)
model3= lm(temp ~ har1)
summary(model3)

har2= harmonic(temp,2)
model4= lm(temp ~ har2)
summary(model4)
# the four coefficients are the beta_hat
# between the two models with different R^2, we see that the one for
# higher frequency harmonics is higher than for freq=1, so it means that 
# higher frequency is improving our model 

#############################
# comparing  models ########

# seasonal means model
st1= coef(model2)
# cos-sin model
st2= fitted(model4)[1:12]
# notice that we are using two different commands to extract the seasonality from the two models
# compare the two:
plot(1:12, st1, lwd=2, type="l", xlab="month", ylab="seasonality")
lines(1:12, st2, lwd=2, col="brown")

################################
# seasonality and trend together

# a. parametric model

# Estimation of the trend with moving averages
# create equally spaced time points for fitting trends
time.pts = c(1:length(temp))
time.pts = c(time.pts - min(time.pts))/max(time.pts)

x1= time.pts
x2= time.pts^2

# varables for trend (x1, x2) and seasoality(har2)
lm.fit= lm(temp ~ x1+x2+ har2)
summary(lm.fit)

# look at the residuals after removing trend and seasonality
dif.fit.lm= ts((temp- fitted(lm.fit)), start= 1879, frequency = 12)
ts.plot(dif.fit.lm, ylab="residuals")


# b. non parametric model for trend, and linear model for seasonality
library(mgcv)
gam.fit= gam( temp~ s(time.pts) + har2)
dif.fit.gam= ts((temp-fitted(gam.fit)),  start= 1879, frequency = 12)

# compare approaches in a. and b.
ts.plot(dif.fit.lm, ylab= "Residuals", col= "brown")
lines(dif.fit.gam, col="blue")

###############################################################
### STATIONARITY OF THE RESIDUALS

# Examine the autocorrelation function of the process
# use acf() for estimation of sample autocorrelation matrix
# Notice that here trend and seasonlaity were removed from previuos lines 
acf(temp, lag.max= 12*4 , main="")
# Here, on the x-axis have the lag h at which we estimate the autocorrelation funciton.
# On the y-axis, the autocorr of the sample
# From the plot, you can see a clear seasonality pattern.
# However the trend cannot be figured by this plot. Remember, before we saw 
# it was moving very slowly

# acf() for the residual process

# Graph of estimates with parametric regression
# Here you can see some cyclical pattern reflecting the seasonality showed in the previous plot.
acf(dif.fit.lm, lag= 12*4 , main="")

# Graph of estimates from non -parametric regression

acf(dif.fit.gam, lag= 12*4 , main="")
