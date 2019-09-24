x <- 1:1024
y <- sin(x * pi / 5)
f <- fft(y)
plot(f * f)

## stats package
require(stats)
spectrum(y)

## TSA package
require(TSA)
periodogram(y)

## roll your own with stats fft package


## http://www.di.fc.ul.pt/~jpn/r/fourier/fourier.html
plot.frequency.spectrum <- function(X.k, xlimits=c(0,length(X.k))) {
  plot.data  <- cbind(0:(length(X.k)-1), Mod(X.k))

  plot.data[2:length(X.k),2] <- 2*plot.data[2:length(X.k),2] 
  
  plot(plot.data, t="h", lwd=2, main="", 
       xlab="Frequency (Hz)", ylab="Strength", 
       xlim=xlimits, ylim=c(0,max(Mod(plot.data[,2]))))
}

plot.frequency.spectrum(y)

acq.freq <- 100                    # data acquisition (sample) frequency (Hz)
time     <- 6                      # measuring time interval (seconds)
ts       <- seq(0,time-1/acq.freq,1/acq.freq) # vector of sampling time-points (s) 
f.0 <- 1/time

dc.component.   <- 1
component.freqs <- c(3,7,10)        # frequency of signal components (Hz)
component.delay <- c(0,0,0)         # delay of signal components (radians)
component.strength <- c(1.5,.5,.75) # strength of signal components

f   <- function(t,w) { 
  dc.component + 
  sum( component.strength * sin(component.freqs*w*t + component.delay)) 
}

plot.fourier(f,f.0,ts=ts)

w <- 2*pi*f.0
trajectory <- sapply(ts, function(t) f(t,w))
head(trajectory,n=30)

X.k <- fft(trajectory)                   # find all harmonics with fft()
plot.frequency.spectrum(X.k, xlimits=c(0,20))
