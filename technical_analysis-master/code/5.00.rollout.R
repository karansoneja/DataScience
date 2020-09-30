## =============================================== ##
## =============  FINAL // SETUP =======================


## ======== upload packages ==========

if(!require(quantmod)) install.packages("quantmod")
if(!require(FinancialInstrument)) install.packages("FinancialInstrument")
if(!require(PerformanceAnalytics)) install.packages("PerformanceAnalytics")
if(!require(foreach)) install.packages("foreach")
if(!require(devtools)) install.packages("devtools")
if(!require(blotter)) devtools::install_github("braverock/blotter")
if(!require(quantstrat)) install_github("braverock/quanstrat")



## ref: https://github.com/R-Finance/quantstrat/blob/master/demo/macd.R
## correct for TZ issues if they crop up
oldtz<-Sys.getenv('TZ')
if(oldtz=='') {
  Sys.setenv(TZ="GMT")
}

library(quantmod)
library(blotter)
library(quantstrat)
library(magrittr)
library(purrr)
# library(PerformanceAnalytics)
# library(IKTrading)


## ============ get data ========

# options("getSymbols.warning4.0"=FALSE)
from ="2012-12-28"
to ="2018-12-31"
symbols = c("FP.PA","MC.PA","SAN.PA","AIR.PA","OR.PA" )

prices <-
quantmod::getSymbols(symbols,index.class = "POSIXct",
                     from=from, to=to, adjust=TRUE) #%>%
  purrr::map( ~ (get(.)) ) %>%
  purrr::reduce(merge)


## or can upload from local dir 
# FP.PA = 
#   readr::read_csv("D:/2017-2018/data_analysis/technical_analysis/data/raw/FP.PA_total.csv", 
#                   col_types =  readr::cols(date = readr::col_date(format ="%d/%m/%Y" ))) %>% 
#   timetk::tk_xts(date_var = date)
# 
# MC.PA =
#   readr::read_csv("D:/2017-2018/data_analysis/technical_analysis/data/raw/MC.PA_LVMH.csv", 
#                   col_types =  readr::cols(date = readr::col_date(format ="%d/%m/%Y" ))) %>% 
#   timetk::tk_xts(date_var = date)
# 
# SAN.PA = 
#   readr::read_csv("D:/2017-2018/data_analysis/technical_analysis/data/raw/SAN.PA_sanofi.csv", 
#                   col_types =  readr::cols(date = readr::col_date(format ="%d/%m/%Y" ))) %>% 
#   timetk::tk_xts(date_var = date)
# 
# AIR.PA= 
#   readr::read_csv("D:/2017-2018/data_analysis/technical_analysis/data/raw/AIR.PA_airbus.csv", 
#                   col_types =  readr::cols(date = readr::col_date(format ="%d/%m/%Y" ))) %>% 
#   timetk::tk_xts(date_var = date)
# 
# OR.PA = 
#   readr::read_csv("D:/2017-2018/data_analysis/technical_analysis/data/raw/OR.PA_oreal.csv", 
#                   col_types =  readr::cols(date = readr::col_date(format ="%d/%m/%Y" ))) %>% 
#   timetk::tk_xts(date_var = date)
# 
# 
# 
# prices= merge.xts(Cl(FP.PA),Cl(MC.PA),Cl(SAN.PA),Cl(AIR.PA),Cl(OR.PA))

