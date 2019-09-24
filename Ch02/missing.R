require(zoo)
require(data.table)

unemp <- fread("data/UNRATE.csv")
unemp[, DATE := as.Date(DATE)]
setkey(unemp, DATE)

## generate a data set where data is randomly missing
rand.unemp.idx <- sample(1:nrow(unemp), .1*nrow(unemp))
rand.unemp <- unemp[-rand.unemp.idx]

## generate a data set where data is more likely to be missing if it's high
high.unemp.idx <- which(unemp$UNRATE > 8)
high.unemp.idx <- sample(high.unemp.idx, .5 * length(high.unemp.idx))
bias.unemp <- unemp[-high.unemp.idx]

    
## we will use data.table's rolling joins in the cases with missing data to identify the missing data
all.dates <- seq(from = unemp$DATE[1], to = tail(unemp$DATE, 1), by = "months")

rand.unemp = rand.unemp[J(all.dates), roll=0]
bias.unemp = bias.unemp[J(all.dates), roll=0]

rand.unemp[, rpt := is.na(UNRATE)]

## forward filling
rand.unemp[, impute.ff := na.locf(UNRATE, na.rm = FALSE)]
bias.unemp[, impute.ff := na.locf(UNRATE, na.rm = FALSE)]

## to plot a sample graph showing the flat portions
png("ffplot.png")
unemp[350:400, plot(DATE, UNRATE, col = 1, type = 'b')]
rand.unemp[350:400, lines(DATE, impute.ff, col = 2)]
rand.unemp[350:400][rpt == TRUE, points(DATE, impute.ff, col = 2, lwd = 3)]
dev.off()

## rolling mean with a lookahead
rand.unemp[, impute.rm.nolookahead := rollapply(c(NA, UNRATE, NA), 3,
             function(x) {
                         if (!is.na(x[1])) x[1] else mean(x, na.rm = TRUE)
                         })]         
bias.unemp[, impute.rm.nolookahead := rollapply(c(NA, UNRATE, NA), 3,
             function(x) {
                         if (!is.na(x[1])) x[1] else mean(x, na.rm = TRUE)
                         })]         

## rolling mean without a lookahead
rand.unemp[, impute.rm.lookahead := rollapply(c(NA, NA, UNRATE), 3,
             function(x) {
                         if (!is.na(x[3])) x[3] else mean(x, na.rm = TRUE)
                         })]         
bias.unemp[, impute.rm.lookahead := rollapply(c(NA, NA, UNRATE), 3,
             function(x) {
                         if (!is.na(x[3])) x[3] else mean(x, na.rm = TRUE)
                         })]         

## to plot a sample graph showing the flat portions
png("maplot.png")
use.idx = 150:200
unemp[use.idx, plot(DATE, UNRATE, col = 1, type = 'b')]
rand.unemp[use.idx, lines(DATE, impute.rm.nolookahead, col = 2)]
rand.unemp[use.idx][rpt == TRUE, points(DATE, impute.rm.nolookahead, col = 2, lwd = 3)]
rand.unemp[use.idx, lines(DATE, impute.rm.lookahead, col = 3)]
rand.unemp[use.idx][rpt == TRUE, points(DATE, impute.rm.lookahead, col = 3, lwd = 3)]
dev.off()



## linear interpolation
rand.unemp[, impute.li := na.approx(UNRATE)]
bias.unemp[, impute.li := na.approx(UNRATE)]

## polynomial interpolation
rand.unemp[, impute.sp := na.spline(UNRATE)]
bias.unemp[, impute.sp := na.spline(UNRATE)]

png("splineplot.png")
use.idx = 650:680
unemp[use.idx, plot(DATE, UNRATE, col = 1, type = 'b')]
rand.unemp[use.idx, lines(DATE, impute.li, col = 2)]
rand.unemp[use.idx][rpt == TRUE, points(DATE, impute.li, col = 2, lwd = 3)]
rand.unemp[use.idx, lines(DATE, impute.sp, col = 3)]
rand.unemp[use.idx][rpt == TRUE, points(DATE, impute.sp, col = 3, lwd = 3)]
dev.off()


## we can compare the sum square difference for each method to the true values
sort(rand.unemp[ , lapply(.SD, function(x) mean((x - unemp$UNRATE)^2, na.rm = TRUE)),
             .SDcols = c("impute.ff", "impute.rm.nolookahead", "impute.rm.lookahead", "impute.li", "impute.sp")])

sort(bias.unemp[ , lapply(.SD, function(x) mean((x - unemp$UNRATE)^2, na.rm = TRUE)),
             .SDcols = c("impute.ff", "impute.rm.nolookahead", "impute.rm.lookahead", "impute.li", "impute.sp")])



smoothed = unemp[, HoltWinters(UNRATE, alpha = 0.1, beta = FALSE, gamma = FALSE)]
plot(unemp$UNRATE, lty = 4, lwd = 1, type = 'l')
lines(smoothed$fitted[, "xhat"], lty = 2, lwd = 2)



air.passengers = fread("data/AirPassengers.csv")
air.passengers[, V1 := as.Date(V1, format = "%Y-%m")]
data = as.ts(air.passengers$V2, deltat = 1/2)

