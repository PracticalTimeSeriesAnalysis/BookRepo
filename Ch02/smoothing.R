require(data.table)

air = fread('data/AirPassengers.csv')
names(air) = c("Date", "Num")
air[, Date:= as.Date(paste0(Date, "-01"), format = "%Y-%m-%d")]

## loess smoothing
loess.smooth(air$Date, air$Num)
