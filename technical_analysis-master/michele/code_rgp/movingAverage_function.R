ma <- function(x, k) {
  if (!is.vector(x)) 
    stop('x must be a vector')
  if (!is.numeric(x)) 
    stop('x must be numeric')
  if (!is.numeric(k))
    stop('k must be numeric')
  if (1 != length(k))
    stop('k must be a single number')
  
  movAv <- rep("", times=length(x)-k)
  j = 0
  lag = c(rep(NA, k), x)[1 : length(x)]
  # z = lag[!is.na(lag)]
  for (i in (k+1:length(lag)-k)) {
    j = j +1
    m = (sum(lag[i : i+k]))/k
    movAv[j] = m }
  # movAv <<- movAv
  print(movAv)
}
ma(y,10)


