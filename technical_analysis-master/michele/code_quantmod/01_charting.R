

## ===== charting with quantmod ==========

## subset the xts prices
AIR.PA= prices[,"AIR.PA"]


## =================== line chart ============
chartSeries(AIR.PA,
            type="line",
            name = "Line chart, Daily closing, Air France",
            subset='2013',
            theme=chartTheme('white'))

## files are named after the chart 'name' attribute in chartSeries
saveChart("png",width= 12,
          #path = "D:/2017-2018/data_analysis/technical_analysis/michele/output/linechart.png",
          # path can't be set. it goes to the working direcory
          width = 9, height = 6, units= "in", res= 300 )

## =================== bars ==============

chartSeries(AIR.PA,
            type="bar",
            name = "Bar chart, Daily closing, Air France",
            subset='2013',
            theme=chartTheme('white'))

saveChart("png",width= 12,
          #path = "D:/2017-2018/data_analysis/technical_analysis/michele/output/linechart.png",
          # path can't be set. it goes to the working direcory
          width = 9, height = 6, units= "in", res= 300 )

## =================== candlesticks ===============

# candlestick is default type
chartSeries(AIR.PA,
            type="candlesticks",
            name = "Candle chart, Daily closing, Air France",
            subset='2013',
            theme=chartTheme('white'))

## 
## Very simply functioning: after running chartSeries, one can run any addXXX() from   
## quantmod pkg so that this wil be overimposed. Once done, can save the plot.
##

addSMA(n=20,on=1,col = "red")
addSMA(n=50,on=1,col = "blue")
addSMA(n=250,on=1,col = "purple") # not sensible if only 1yr subset


saveChart("png",width= 12, 
          #path = "D:/2017-2018/data_analysis/technical_analysis/michele/output/linechart.png",
          # path can't be set. it goes to the working direcory
          width = 9, height = 6, units= "in", res= 300 )

## ============================================= ##
## ========= different stocks plotted together ====

NS <- function(xdat) xdat / coredata(xdat)[1]
AirFrance = NS(Cl(AIR.PA))-1 # takes closing with Cl()
LVMH = NS(Cl(MC.PA))-1
Total = NS(Cl(FP.PA))-1

chartSeries(AirFrance,
            name = "Compare AirFrance, LVMH, Total",
            subset = '2013',
            theme=chartTheme('white'))

addTA(LVMH, on=1, col="red", lty="dotted") # lty is to make the line becomes other line styles
addTA(Total, on=1, col="blue", lty="dashed")

saveChart("png",width= 12, 
          #path = "D:/2017-2018/data_analysis/technical_analysis/michele/output/linechart.png",
          # path can't be set. it goes to the working direcory
          width = 9, height = 6, units= "in", res= 300 )
