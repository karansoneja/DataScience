activeReturn = function(y) {
  returns= rep("", times= length(y)-1)
  j=0
  for (i in (2:length(y))){
    j= j+1
    r= log10(y[i+1])-log10(y[i])
    returns[j]= r  
  }
  actRet <- exp(sum(returns[1]: returns[length(returns)-1], na.rm = TRUE)) -1 # use  <-- instead if you want to save this variable as global rather than local
  print("Active return:") 
  print(actRet )
  
}


activeReturn(y)
