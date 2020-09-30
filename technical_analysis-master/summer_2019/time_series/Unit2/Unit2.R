#############################
######### ARMA MODELS ######
############################

# Simulate white noise process
w1= rnorm(1000, 0,1)
w2= rexp(1000,1)

# Standardize WN
w1= (w1- mean(w1))/sqrt(var(w1))
w2= (w2- mean(w2))/sqrt(var(w2))

# use "ts()" creates an object named "time-series" out of the 
# fitted values we found
w1= ts(w1, start=1, deltat = 1)
w2= ts(w2, start=1, deltat=1)

##### Plot of WN processes and ACFs(?) in the same 2*2 panel
par(mfrow=c(2,2))
ts.plot(w1, main="Normal")
ts.plot(w2, main="Exponentional")
# ACF is AutoCorrelation Function
acf(w1, main="")
acf(w2, main="")


#### Create a filtered AR to obtain a MA
w1= rnorm(502)
w2= rexp(502)-1

# set coefficients (thetas) for the MA(q) 
a= c(1, -0.5, 0.2)
a1= c(1, +0.5, 0.2)
# Create MA(2) process with the two WN's from above. Note that "side=1"
# specifies the MA process
ma2.11= filter(w1, filter= a , side=1)
ma2.11= ma2.11[3:502]

ma2.12= filter(w1, filter=a1, side=1)
ma2.12= ma2.12[3:502]

ma2.21= filter(w2, filter=a, side=1)
ma2.21= ma2.21[3:502]

ma2.22= filter(w2, filter=a1, side=1)
ma2.22= ma2.22[3:502]

# plots of the MA created above
par(mfrow=c(2,2))
ts.plot(ma2.11, main= "ma2.11")
ts.plot(ma2.12, main= "ma2.12")
ts.plot(ma2.21, main= "ma2.21")
ts.plot(ma2.22, main= "ma2.22")

# ACF (autocorr function) of the MA's
acf(ma2.11, main= "")
acf(ma2.12, main= "")
acf(ma2.21, main="")
acf(ma2.22, main="")
# Notice high variance of first few lags

##########################################
### MA(3) with non stationary noise
w1= rnorm(502)
a4= c(1, 0.2, 0.8, 1.2)

ma2.4= filter( w1*(2*(1:502)+ 0.5), filter= a4, side=1)
ma2.4= ma2.4[4:502]

ts.plot(ma2.4, main= "ma2.4")
acf(ma2.4, main="")

##########################################
### AR processes
## Nonstationary AR(2). "method = "recursive" specifies an AR
# Vectors 'a' are the phi coefficients of the process
w2= rnorm(1500)
a2= c(0.8, 0.2)
ar2= filter(w2, filter= a2, method = "recursive")
ar2= ar2[1251: 1500]

## Stationary AR(1) process
a1= 0.5
ar1= filter(w2, filter=a1, method="recursive")
ar1= ar1[1251: 1500]

# As before, can do plots of the two precesses and their ACF's  
# ACF of AR(2) decreases slowly: it indicates the non-stationarity feature

########################################################
# AR(1) Causal
# |phi| = 0.5

# WN process
w2= rnorm(1500)

a1= 0.1
ar1= filter(w2, filter=a1, method= "recursive")
ar1.1= ar1[1251:1500]

ar1= -0.1
ar1= filter(w2, filter=a1, method= "recursive")
ar1.2= ar1[1251:1500]

# AR causal process reaching nonstationarity
a1= 0.9
ar1= filter(w2, filter=a1, method= "recursive")
ar1.3= ar1[1251:1500]

a1= -0.9
ar1= filter(w2, filter=a1, method="recursive")
ar1.4= ar1[1251:1500]

# plots of the AR's 
par(mfrow=c(2,2))
ts.plot(ar1.1, main= "phi= 0.1")
ts.plot(ar1.2, main= "phi= -0.1")
ts.plot(ar1.3, main= "phi= 0.9")
ts.plot(ar1.4, main= "phi= -0.9")

##############################################################

w2= rnorm(1500)

# nonstationary AR(2): x_t = 0.8*x_(t-1) + 0.2*x_(t-2)+ z_t
a2= c(0.8, 0.2)
ar2.n= filter(w2, filter=a2, method="recursive")
ar2.n= ar2.n[1251:1500]

# stationary AR(2)
a2= c(1.8, -0.9)
ar2.s= filter(w2, filter=a2, method="recursive")
ar2.s= ar2.s[1251:1500]

# compare PACF (partial autocorrelation function)
par(mfrow=c(2,2))
ts.plot(ar2.n, main="Nonstationary AR(2)")
ts.plot(ar2.s, main="stationary AR(2)")

pacf(ar2.n, main="")
pacf(ar2.s, main="")


#################
## New command for ARMA process
######################
arma22= arima.sim(n=500, list(ar=c(0.88, -0.49), ma= c(-0.23, 0.25)), sd= sqrt(0.18))
# plots
par(mfrow=c(1,2))
ts.plot(arma22)
pacf(arma22)

#####################################################
### Estimation of ARMA models

w2= rnorm(1500)
b= c(1.2, -0.5)
ar2= filter(w2, filter= b, method="recursive")
ar2= ar2[1001:1500]

## Fit linear regression to AR(2)
data2= data.frame(cbind(x1= ar2[1:498],x2= ar2[2:499], y=ar2[3:500]))
model2= lm(y~ x1+x2, data= data2)
summary(model2)


# HP test: { null: beta_1 = 0.5}

# t.value= (beta_obs + beta_null)/st.er
t.value=  (-0.481520+ 0.5)/0.0394
pvalue= 2*(1-pnorm(t.value))
pvalue



####### 
## Fit an AR(2) model 
w2 = rnorm(1500)
b = 0.5
ar1 = filter(w2,filter=b,method='recursive')
ar1 = ar1[1001:1500]

#  Fit an AR(2) to an AR(1) process using linear regression -- ie misspecification
data3 = data.frame(cbind(x1=ar1[1:498],x2=ar1[2:499],y=ar1[3:500]))


## Fit an AR(3) to an AR(2) model 
# Form gamma(1) & Gamma_3 Matrix 
covf = acf(ar2,type='covariance',plot=FALSE)
Gamma1 = covf$acf[2:4,,1]
Gammamatrix = matrix(0,3,3)

for(i in 1:3){
  if(i>1){
    Gammamatrix[i,] = c(covf$acf[i:2,,1],covf$acf[1:(3-i+1),,1]) }
  else{
    Gammamatrix[i,] = covf$acf[1:(3-i+1),,1] }
}
## Estimate phi
phi.estim = solve(Gammamatrix,Gamma1)

#########
#### Compare Yule-Walker & AR Estimation
phi.estim.yw = NULL
for(s in 1:500){
  w2 = rnorm(1500)
  b = c(1.2,-0.5)
  ar2 = filter(w2,filter=b,method='recursive')
  ar2 = ar2[1001:1500]
  ## Fit Yule-Walker to AR(2)
  covf = acf(ar2,type='covariance',plot=FALSE)
  Gammamatrix = matrix(0,2,2)
  Gammamatrix[2,] = c(covf$acf[2,,1],covf$acf[1,,1])
  Gammamatrix[1,] = covf$acf[1:2,,1]
  Gamma1 = covf$acf[2:3,,1]
  phi.estim = solve(Gammamatrix,Gamma1)
  phi.estim.yw = rbind(phi.estim.yw,phi.estim)
}

#######################################################################################################
#################### RECITATION #######################################################
