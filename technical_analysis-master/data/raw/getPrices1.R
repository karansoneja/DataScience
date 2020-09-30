## ==== import libraries ====================

library(magrittr)
library(purrr)
library(quantmod)


## get path of current script
# rstudioapi::getSourceEditorContext()$path


## ======== get prices from Yahoo! ===========

symbols= c("FP.PA","MC.PA", "SAN.PA", "AIR.PA","OR.PA")

prices <-
  quantmod::getSymbols(symbols, src = 'yahoo',
                       from = "2012-12-28",
                       to = "2018-12-31",
                       auto.assign = TRUE,
                       warnings = FALSE) %>%
  map( ~ Ad(get(.)) ) %>%
  reduce(merge) %>%
  `colnames<-`(symbols)




## ================ export data ==============

## EXPORT DATA IN CVS
write.csv(as.data.frame(prices),
          file="D:/2017-2018/data_analysis/technical_analysis/data/raw/closing_prices_1.csv",
          quote= FALSE)

# write.csv(as.data.frame(prices_monthly),
#           file="D:/2017-2018/data_analysis/technical_analysis/data/processed/closing_month_1.csv",
#           quote= FALSE)

## ~~ make sure to go the cvs and add 'date' as a label for first column ~~


# write.csv(as.data.frame(AIR.PA), file='D:/2017-2018/data_analysis/technical_analysis/data/raw/AIR.PA_airbus.csv', quote= FALSE)
# write.csv(as.data.frame(FP.PA), file='D:/2017-2018/data_analysis/technical_analysis/data/raw/FP.PA_total.csv', quote= FALSE)
# write.csv(as.data.frame(OR.PA), file='D:/2017-2018/data_analysis/technical_analysis/data/raw/OR.PA_oreal.csv', quote= FALSE)
# write.csv(as.data.frame(SAN.PA), file='D:/2017-2018/data_analysis/technical_analysis/data/raw/SAN.PA_sanofi.csv', quote= FALSE)
# write.csv(as.data.frame(MC.PA), file='D:/2017-2018/data_analysis/technical_analysis/data/raw/MC.PA_LVMH.csv', quote= FALSE)

## ======= import from csv to xts ==============

symbols= c("FP.PA","MC.PA", "SAN.PA", "AIR.PA","OR.PA")

library(magrittr) #to get the pipe operator %>% to work
prices <- 
  readr::read_csv("D:/2017-2018/data_analysis/technical_analysis/data/raw/closing_prices_1.csv", 
           col_types = readr::cols(date = readr::col_date(format ="%d/%m/%Y" ))) %>% 
           timetk::tk_xts(date_var = date)


## to subset the xts, do the following - creates an xts object
AIR.PA= prices[,"AIR.PA"]

## upload one stock full time series - if you want to retain the volumes


## ===== convert to monthly returns ================

prices_monthly <- 
  to.monthly(prices, indexAt = "lastof", OHLC = FALSE)

## ==== compute returns ==========================

asset_returns_xts <- 
  PerformanceAnalytics::Return.calculate(prices_monthly, method = "log") %>%
  na.omit()


## ========== visualize xts returns ================

library(highcharter)

hc <- highchart(type = "stock") %>% 
  hc_title(text = "Monthly Log Returns") %>% 
  hc_add_series(asset_returns_xts[, symbols[1]], name = symbols[1]) %>%
  hc_add_series(asset_returns_xts[, symbols[2]], name = symbols[2]) %>%
  hc_add_series(asset_returns_xts[, symbols[3]], name = symbols[3]) %>%
  hc_add_series(asset_returns_xts[, symbols[4]], name = symbols[4]) %>%
  hc_add_series(asset_returns_xts[, symbols[5]], name = symbols[5]) %>%
  hc_add_theme(hc_theme_flat()) %>% 
  hc_navigator(enabled = FALSE) %>% 
  hc_scrollbar(enabled = FALSE) %>% 
  hc_exporting(enabled = TRUE) %>% 
  hc_legend(enabled = TRUE)

## this exports the chart in a .js file
# highcharter::export_hc (hc, 
# filename = "D:/2017-2018/data_analysis/technical_analysis/michele/output/month_ret_top5", 
# as = "variable", name = NULL)

## =============================================================== ##
## ===== convert xts into tidyverse object : create tibble object =====


## ~~ error solved

library(xts)
library(tibble)
library(tidyr)
library(dplyr)

asset_returns_dplyr_byhand <- 
  prices %>% 
  to.monthly(indexAt = "lastof", OHLC = FALSE) %>% 
  # convert the index to a date 
  data.frame(date = index(.)) %>% 
  # now remove the index because it got converted to row names 
  remove_rownames() %>%
  gather(asset, prices, -date) %>% 
  group_by(asset) %>% 
  mutate(returns = (log(prices) - log(lag(prices)))) %>% 
  select(-prices) %>% 
  spread(asset, returns) %>% 
  # make sure the 'symbols' string with stocks labels is in the env
  select(date, symbols)


# asset_returns_dplyr_byhand <-
#   prices %>%
#   xts::to.monthly(indexAt = "lastof", OHLC = FALSE) %>%
#   # convert the index to a date
#   data.frame(date = index(.)) %>%
#   # now remove the index because it got converted to row names
#   tibble::remove_rownames() %>%
#   tidyr::gather(asset, prices, -date) %>%
#   dplyr::group_by(asset) %>%
#   dplyr::mutate(returns = (log(prices) - log(lag(prices)))) %>%
#   dplyr::select(-prices) %>%
#   tidyr::spread(asset, returns) %>%
#   dplyr::select(date, symbols)


asset_returns_dplyr_byhand <- 
  asset_returns_dplyr_byhand %>% 
  na.omit() # to remove the first raw

## ================================================================ ##
## ========== get ready for using ggplot2 ========================== 

asset_returns_long <- 
  asset_returns_dplyr_byhand %>% 
  gather(asset, returns, -date) %>% 
  group_by(asset)

# asset_returns_long <- 
#   asset_returns_dplyr_byhand %>% 
#   tidyr::gather(asset, returns, -date) %>% 
#   dplyr::group_by(asset)

## create histogram 
library(ggplot2)

asset_returns_long %>% 
  ggplot(aes(x = returns, fill = asset)) + 
  geom_histogram(alpha = 0.45, binwidth = .005) + 
  ggtitle("Monthly Returns Since 2013")

ggsave("month_histog_superimp_top5-1.png", 
       device= "png", 
       path = "D:/2017-2018/data_analysis/technical_analysis/michele/output/",  
       width = 9, height = 6, units= "in" , dpi = 300 , limitsize = TRUE)

## create panel with 5 plots    
asset_returns_long %>% 
  ggplot(aes(x = returns, fill = asset)) + 
  geom_histogram(alpha = 0.45, binwidth = .01) +
  facet_wrap(~asset) + 
  ggtitle("Monthly Returns Since 2013") + 
  theme_update(plot.title = element_text(hjust = 0.5))

ggsave("month_histog_top5-1.png", 
       device= "png", 
       path = "D:/2017-2018/data_analysis/technical_analysis/michele/output/",  
       width = 9, height = 6, units= "in" , dpi = 300 , limitsize = TRUE)

## plot densities 
asset_returns_long %>% 
  ggplot(aes(x = returns, colour = asset)) + 
  geom_density(alpha = 1) + 
  ggtitle("Monthly Returns Density Since 2013") + 
  xlab("monthly returns") + 
  ylab("distribution") + 
  theme_update(plot.title = element_text(hjust = 0.5))

ggsave("month_densities_top5-1.png", 
       device= "png", 
       path = "D:/2017-2018/data_analysis/technical_analysis/michele/output/",  
       width = 9, height = 6, units= "in" , dpi = 300 , limitsize = TRUE)


## put last three commands together 

asset_returns_long %>% 
  ggplot(aes(x = returns)) + 
  geom_density(aes(color = asset), alpha = 1) + 
  geom_histogram(aes(fill = asset), alpha = 0.45, binwidth = .01) + 
  guides(fill = FALSE) + facet_wrap(~asset) + 
  ggtitle("Monthly Returns Since 2013") + 
  xlab("monthly returns") + 
  ylab("distribution") + 
  theme_update(plot.title = element_text(hjust = 0.5)) 

ggsave("month_histog_densities_top5-2.png", 
       device= "png", 
       path = "D:/2017-2018/data_analysis/technical_analysis/michele/output/",  
       width = 6, height = 4, units= "in" , dpi = 300 , limitsize = TRUE)



## ========================================================== ## 
## ============ tidyquant world ================================= 

# library(PerformanceAnalytics)
# 
# asset_returns_tq_builtin <- prices %>% 
#   timetk::tk_tbl(preserve_index = TRUE, rename_index = "date") %>%
#   tidyr::gather(asset, prices, -date) %>% 
#   dplyr::group_by(asset) %>% 
#   tidyquant::tq_transmute(mutate_fun = periodReturn, period = "monthly", type = "log") %>%
#   tidyr::spread(asset, monthly.returns) %>% 
#   dplyr::select(date, symbols) %>% 
#   dplyr::slice(-1)

## ==== tbltime

# asset_returns_tbltime <- 
#   prices %>% 
#   timetk::tk_tbl(preserve_index = TRUE, rename_index = "date") %>%
#   # this is the the tibbletime function 
#   tibbletime::as_tbl_time(index = date) %>% 
#   tibbletime::as_period(period = "month", side = "end") %>%
#   tidyr::gather(asset, returns, -date) %>% 
#   dplyr::group_by(asset) %>% 
#   tidyquant::tq_transmute(mutate_fun = periodReturn, type = "log") %>%
#   tidyr::spread(asset, monthly.returns) %>% 
#   dplyr::select(date, symbols) %>% 
#   dplyr::slice(-1)


## =============================================================================









