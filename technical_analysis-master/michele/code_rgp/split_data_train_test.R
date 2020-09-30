airbus = read.csv("D:/2017-2018/data_analysis/technical_analysis/michele/data/processed/AIR.PA_airbus.csv", header = TRUE)
# closing= airbus$AIR.PA.Close

require(caTools)
set.seed(101) 
sample.airbus = sample.split(airbus$AIR.PA.Close, SplitRatio = .75)
train.airbus = subset(airbus, sample.airbus == TRUE)
test.airbus  = subset(airbus, sample.airbus == FALSE)

