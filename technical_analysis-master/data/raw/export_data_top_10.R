## ========== upload libraries ========
## library(quantmod, purrr, magrittr,xts)
library(magrittr)
library(purrr)
library(quantmod)


## ====== get prices, first batch
## get prices of desider securities (specified in "symbols" )
symbols_1= c("FP.PA","MC.PA", "SAN.PA", "AIR.PA","OR.PA")
symbols_2= c("AI.PA","BN.PA","DG.PA","BNP.PA","SAF.PA")

prices_1 =
  quantmod::getSymbols(symbols_1,
                       src = 'yahoo',
                       from = "2012-12-28",
                       to = "2018-12-31",
                       auto.assign = TRUE,
                       # na.exclude(), # won't work. see %>% add below as argument
                       warnings = FALSE) %>%
  # na.exclude() %>%
  map(~Ad(get(.))) %>% # map(), reduce() in purrr
  reduce(merge) %>% # Add() in ?? quantmod
  'colnames<-'(symbols_1)

# check for NA
sum(is.na(index(symbols_1)))


## ========== EXPORT DATA IN CVS

write.csv(as.data.frame(prices_1),file="D:/2017-2018/data_analysis/technical_analysis/data/raw/closing_prices_1.csv",quote= FALSE)
write.csv(as.data.frame(AIR.PA), file='D:/2017-2018/data_analysis/technical_analysis/data/raw/AIR.PA_airbus.csv', quote= FALSE)
write.csv(as.data.frame(FP.PA), file='D:/2017-2018/data_analysis/technical_analysis/data/raw/FP.PA_total.csv', quote= FALSE)
write.csv(as.data.frame(OR.PA), file='D:/2017-2018/data_analysis/technical_analysis/data/raw/OR.PA_oreal.csv', quote= FALSE)
write.csv(as.data.frame(SAN.PA), file='D:/2017-2018/data_analysis/technical_analysis/data/raw/SAN.PA_sanofi.csv', quote= FALSE)
write.csv(as.data.frame(MC.PA), file='D:/2017-2018/data_analysis/technical_analysis/data/raw/MC.PA_LVMH.csv', quote= FALSE)

## ========= second batch of retreived data

prices_2 =
  quantmod::getSymbols(symbols_2,
                       src = 'yahoo',
                       from = "2012-12-28",
                       to = "2018-12-31",
                       auto.assign = TRUE,
                       # na.exclude(), # won't work. see %>% add below as argument
                       warnings = FALSE) %>%
  # na.exclude() %>%
  map(~Ad(get(.))) %>% # map(), reduce() in purrr
  reduce(merge) %>% # Add() in ?? quantmod
  'colnames<-'(symbols_2)

## eliminate NA
## maybe not needed if can be embedded in function above
# prices_1= na.exclude(prices_1)

# check for NA
sum(is.na(index(symbols_2)))

## ============== EXPORT DATA IN CVS

write.csv(prices_2,file="D:/2017-2018/data_analysis/technical_analysis/data/raw/closing_prices_2.csv",quote= FALSE)
write.csv(as.data.frame(AI.PA), file='D:/2017-2018/data_analysis/technical_analysis/data/raw/I.PA_airliquid.csv', quote= FALSE)
write.csv(as.data.frame(BN.PA), file='D:/2017-2018/data_analysis/technical_analysis/data/raw/BN.PA_danone.csv', quote= FALSE)
write.csv(as.data.frame(BNP.PA), file='D:/2017-2018/data_analysis/technical_analysis/data/raw/BNP.PA_bnp.csv', quote= FALSE)
write.csv(as.data.frame(DG.PA), file='D:/2017-2018/data_analysis/technical_analysis/data/raw/DG.PA_vinci.csv', quote= FALSE)
write.csv(as.data.frame(SAF.PA), file='D:/2017-2018/data_analysis/technical_analysis/data/raw/SAF.PA_safran.csv', quote= FALSE)