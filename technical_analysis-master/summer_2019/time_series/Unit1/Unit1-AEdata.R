edvoldata= read.csv("EGDailyVolume.csv", header=T)

# process dates
year= edvoldata$Year
month= edvoldata$Month
day= edvoldata$Day


datemat= cbind(as.character(day),as.character(month), as.character(year))

# create a function translating three strings of characters into a date
datemat= cbind(as.character(day),as.character(month),as.character(year))
paste.dates= function(date){
  day = date[1]; month=date[2]; year = date[3]
  return(paste(day,month,year,sep="/"))
  }

dates = apply(datemat,1,paste.dates)
# date strings turned into dates
dates = as.Date(dates, format="%d/%m/%Y")

Volume= edvoldata$Volume

## Plot the time series
library(ggplot2)
ggplot(edvoldata, aes(dates, Volume)) + geom_line() + xlab("Time") + ylab("Daily ED Volume")
# Notice: there are some outilers (2011,2014); generally increasing trend; some (weak) cyclical patterns;

# The "Volume" var is a count data, hence ~  Poisson distribution. SO to use a lienar model
# that assumes homosked, we'll need to transform the data using a Variance stabilizing transformation. 
# This will also normalize the count data

# Classical normalization of count data X: sqrt(X + 3/8)
Volume.tr= sqrt(edvoldata$Volume + 3/8)

# Compare distributions
hist(edvoldata$Volume, nclass=20, xlab="ED Volume", col="brown")
hist(Volume.tr, nclass=20, xlab="Transformed ED Volume", col="blue")

##############################################################
## TREND AND SEASONALITY

# Non-parametric estimation approach
time.pts= c(1:length(Volume))
time.pts= c(time.pts - min(time.pts))/max(time.pts)

# a. Local polynomial trend estimaiton with loess()
loc.fit = loess(Volume.tr~time.pts)
vol.fit.loc = fitted(loc.fit)

# b. Splines Trend estimation through gam()
library(mgcv)
gam.fit = gam(Volume.tr~s(time.pts))
vol.fit.gam = fitted(gam.fit)


# Overlay the plots
plot(dates, Volume.tr, ylab="ED Volume" )
lines(dates, vol.fit.loc, lwd=2, col="brown")
lines(dates, vol.fit.gam, lwd=2, col="red")
# BOth patterns increase over time. Spline captures more variation

##########################################

## Model Trend + Monthly Seasonality
month = as.factor(format(dates,"%b"))
gam.fit.seastr.1 = gam(Volume.tr~s(time.pts)+month-1)
summary(gam.fit.seastr.1)
vol.fit.gam.seastr.1 = fitted(gam.fit.seastr.1)
ggplot(edvoldata, aes(dates, sqrt(Volume+3/8))) + geom_line() + xlab("Time") + ylab("Transformed Daily ED Volume")
lines(dates,vol.fit.gam.seastr.1,lwd=2,col="red")

# Add day-of-the-week seasonality
week= as.factor(weekdays(dates))
gam.fit.seastr.2= gam(Volume.tr~ s(time.pts)+ month + week)
summary(gam.fit.seastr.2)
vol.fit.gam.seastr.2= fitted(gam.fit.seastr.2)


# Compare the two fits -- DOES NOT WORK
ggplot(edvoldata, aes(dates, vol.fit.seastr.1)) + geom_line()+ xlab("Time") +ylab("Seasonality and trend: month")
ggplot(edvoldata, aes(dates, vol.fit.gam.seastr.2)) + geom_line()+ xlab("Time") +ylab("Seasonality and trend: week")


# plot(dates, Volume.tr, ylab="ED Volume" )
# plot(dates, vol.fit.seastr.1, ylab="ED Volume" )
lines(dates, vol.fit.seastr.1, lwd=2, col="red")

####################################################################
## ## Does the addition of seasonality of day of the week adds predictive power?
lm.fit.seastr.1 = lm(Volume.tr~month)
lm.fit.seastr.2 = lm(Volume.tr~month+week)
anova(lm.fit.seastr.1,lm.fit.seastr.2)
# anova() performs partial F-test. For a small p-val, we reject the null that 
# model with only month (w/out week) is as good as the other . So both layers of seasonality are best choice

## Compare with & without trend
# 1. full model
ggplot(edvoldata, aes(dates, vol.fit.gam.seastr.2)) + geom_line() + xlab("Time") + ylab("Seasonality and Trend: Daily ED Volume")
# 2. seasonaity with two layers excluding trend
lines(dates,vol.fit.lm.seastr.2,lwd=2,col="blue")
# 3. fitted trend alone
lines(dates,vol.fit.gam,lwd=2,col="red")

##################################################################
### Model Trend and seasonality
# Volume <- read.csv("D:/Scuola/Uni/2018-2019/Programming/R/TimeSeries/Unit2/EGDailyVolume.csv")
# library(mgcv)

time.pts= c(1:length(Volume))
time.pts= c(time.pts - min(time.pts))/max(time.pts)

month= as.factor(format(dates, "%b"))
week= as.factor(weekdays(dates))
# Splines Trend estimation through gam()
gam.fit.seastr= gam(Volume.tr~ s(time.pts)+month+week)
vol.fit.gam.seastr= fitted(gam.fit.seastr)
# Difference between trasformed Volume data counts and estimated
# trend and seasonality to obtain the residuals 
resid.process= Volume.tr- vol.fit.gam.seastr

# # ACF is AutoCorrelation Function
acf(resid.process, lag.max= 12*4, main="ACF: residual plot")
# PACF (partial autocorrelation function)
pacf(resid.process, lag.max = 12*4, main="PACF: Residual plot")


### Fit an ARMA model
# Fit an AR(p) process for p<= order.max
mod= ar(resid.process, order.max= 20)
# what is the selected order of this residual process?
print(mod$order)
# what's inside the object 'mod'? 
summary(mod)
#  plot log(AIC): minimum AIC shows the order of the process (same as previous line)
plot((0:20), mod$aic+0.001, type="b", log="y", xlab="order", ylab="log-AIC values")

# check stationarity & casuality: the roots of the fitted AR 
# ought to be within the unit circle

# extract roots
roots= polyroot(c(1,(-mod$ar)))
# Adjust the axis limits
plot(roots, xlim=c(-1.2, 1.2), ylim = c(-1.2, 1.2))
# Draw a unit root circle
lines(complex(arg=seq(0.2*pi, len=300)))

## Obtain the standardized residuals
resids = mod$resid[(mod$order+1): length(mod$resid)]
## Plot the residuals
par(mfrow=c(2,2))
plot(resids,xlab="",ylab="Model Residuals")
acf(resids,main='ACF of the Model Residuals')
pacf(resids,main='PACF of the Model Residuals')
# Q-Q plot is  (hypothesis) tests for normality. If so, the plot should be approx linear
qqnorm(resids)

################
## Now fit an ARMA model (6,1)
modarma = arima(resid.process, order = c(6,0,1),method = "ML")
## Residual Analysis
par (mfrow=c(2,2))
plot(resid(modarma), ylab='Standardized Residuals')
abline(h=0)
acf(as.vector(resid(modarma)),main= 'ACF of the Model Residuals')
pacf(as.vector(resid(modarma)),main='PACF of the Model Residuals')
qqnorm(resid(modarma))
qqline(resid(modarma))

###################4
### Model selecton: which is the best order ?

## Use EACF (Extended AutoCorrelation Function) (Tsay and Tiao, 1984)
library(TSA)
eacf(resid.process,ar.max = 6, ma.max = 6)

## Either way, can use AIC criterion: test many combinantions of AR,MA orders,put them together 
# and pick the ARMA with minimum AIC value
n = length(resid.process)
norder = 6
p = c(1:norder)-1; q = c(1:norder)-1
aic = matrix(0,norder,norder)
for(i in 1:norder){
  for(j in 1:norder){
    modij = arima(resid.process,order = c(p[i],0,q[j]), method='ML')
    aic[i,j] = modij$aic-2*(p[i]+q[j]+1)+2*(p[i]+q[j]+1)*n/(n-p[i]-q[j]-2)
  }  
}

## Which order to select?
aicv = as.vector(aic)  
plot(aicv,ylab="AIC values")
indexp = rep(c(1:norder),norder)
indexq = rep(c(1:norder),each=norder)
indexaic = which(aicv == min(aicv))
porder = indexp[indexaic]-1
qorder = indexq[indexaic]-1
## Final Model
final_model = arima(resid.process,order = c(porder,0,qorder), method='ML')

#####################
# #### Test for Independence of the residuals for final model
Box.test(final_model$resid, lag = (porder+qorder+1), type = "Box-Pierce", fitdf = (porder+qorder))
Box.test(final_model$resid, lag = (porder+qorder+1), type = "Ljung-Box", fitdf = (porder+qorder))
#### Test for Independence for smaller model
Box.test(modarma$resid, lag = (porder+qorder+1), type = "Box-Pierce", fitdf = (porder+qorder))
Box.test(modarma$resid, lag = (porder+qorder+1), type = "Ljung-Box", fitdf = (porder+qorder))
