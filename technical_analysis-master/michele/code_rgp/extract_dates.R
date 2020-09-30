library(magrittr)
library(purrr)
library(zoo)
library(quantmod)

## get prices of desider securities (specified in "symbols" above)
prices_1 =
  quantmod::getSymbols("AIR.PA",
                       src = 'yahoo',
                       from = "2012-12-28",
                       to = "2018-12-31",
                       auto.assign = TRUE,
                       # na.exclude(), # won't work. see %>% add below as argument
                       warnings = FALSE) %>%
  ## na.exclude() %>%
  map(~Ad(get(.))) %>% # map(), reduce() in purrr
  reduce(merge) %>% # Add() in ?? quantmod
  'colnames<-'("AIR.PA")

## exctract dates from xts object
dates= index(AIR.PA)

## create zoo object with dates and closing prices
close.dates = zoo(airbus$AIR.PA.Close, dates)

## export data to .csv
write.csv(AIR.PA, file="D:/2017-2018/data_analysis/technical_analysis/michele/data/raw/AIR.PA_airbus.csv", quote= FALSE)
write.csv(dates,file="D:/2017-2018/data_analysis/technical_analysis/michele/data/raw/stocks_dates.csv", quote= FALSE)



