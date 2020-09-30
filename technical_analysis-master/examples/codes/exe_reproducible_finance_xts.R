symbols= c("SPY","EFA", "IJS", "EEM","AGG")

library(zoo, xts)
library(TTR, quantmod, purrr, magrittr)

prices = # keeps length(symbols) number of different objects
  getSymbols(symbols,
             src = 'yahoo',
             from = "2012-12-31",
             to = "2017-12-31",
             auto.assign = TRUE,
             warnings = FALSE) %>%
  map(~Ad(get(.))) %>%
  reduce(merge) %>%
  'colnames<-'(symbols)

prices_monthly <- to.monthly(prices, # merges all xts object closing prices from before in one
                             indexAt = "lastof",# can also have "firstof"
                             OHLC = FALSE)


asset_returns_xts <-
  PerformanceAnalytics::Return.calculate(prices_monthly,
                   method = "discrete") %>% #can use also "log"
  na.omit() # very important


library(highcharter)
highchart(type = "stock") %>%
  hc_title(text = "Monthly discrete Returns") %>%
  hc_add_series(asset_returns_xts[, symbols[1]],
                name = symbols[1]) %>%
  hc_add_series(asset_returns_xts[, symbols[2]],
                name = symbols[2]) %>%
  hc_add_series(asset_returns_xts[, symbols[3]],
                name = symbols[3]) %>%
  hc_add_series(asset_returns_xts[, symbols[4]],
                name = symbols[4]) %>%
  hc_add_series(asset_returns_xts[, symbols[5]],
                name = symbols[5]) %>%
  hc_add_theme(hc_theme_flat()) %>%
  hc_navigator(enabled = FALSE) %>%
  hc_scrollbar(enabled = FALSE) %>%
  hc_exporting(enabled = TRUE) %>%
  hc_legend(enabled = TRUE)  
