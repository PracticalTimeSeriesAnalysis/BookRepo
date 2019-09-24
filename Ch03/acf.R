## R uses radians so to set frequency we'll do radians

x = 1:100

## Noiseless series
y = sin(x * pi / 4) 
plot(y, type = 'b')
acf(y)
pacf(y)

y = sin(x * pi / 10)
plot(y, type = 'b')
acf(y)
pacf(y)

y = sin(x * pi / 4) + sin(x * pi / 10)
plot(y, type = 'b')
acf(y)
pacf(y)

par(mfrow = c(3, 3))
## Somewhat noisy series
noise1 = rnorm(100, sd = 0.05)
noise2 = rnorm(100, sd = 0.05)
par(mfrow = c(3, 3))
y = sin(x * pi / 4) + noise1
plot(y, type = 'b')
acf(y)
pacf(y)

y = sin(x * pi / 10) + noise2
plot(y, type = 'b')
acf(y)
pacf(y)

y = sin(x * pi / 4) + sin(x * pi / 10) + noise1 + noise2
plot(y, type = 'b')
acf(y)
pacf(y)

## Very noisy series
noise1 = rnorm(100, sd = 0.3)
noise2 = rnorm(100, sd = 0.3)
par(mfrow = c(3, 3))
y = sin(x * pi / 4) + noise1
plot(y, type = 'b')
acf(y)
pacf(y)

y = sin(x * pi / 10) + noise2
plot(y, type = 'b')
acf(y)
pacf(y)

y = sin(x * pi / 4) + sin(x * pi / 10) + noise1 + noise2
plot(y, type = 'b')
acf(y)
pacf(y)


