
## thank you Alex Hagaman!

## rocket will take 100 time steps
ts.length <- 100

## the acceleration will drive the motion
a <- rep(0.5, ts.length)

## position and velocity start at 0
x <- rep(0, ts.length)
v <- rep(0, ts.length)
for (ts in 2:ts.length) {
  x[ts] <- v[ts - 1] * 2 + x[ts - 1] + 1/2 * a[ts - 1] ^ 2
  x[ts] <- x[ts] + rnorm(1, sd = 20) ## stochastic component
  v[ts] <- v[ts - 1] + 2 * a[ts - 1]
}

par(mfrow = c(3, 1))
plot(x, main = "Position",     type = 'l')
plot(v, main = "Velocity",     type = 'l')
plot(a, main = "Acceleration", type = 'l')

## simulate noisy sensor measurement
z <- x + rnorm(ts.length, sd = 300)
par(mfrow = c(1, 1))
plot(x, ylim = range(c(x, z)))
lines(z)

## apply a Kalman filter
kalman.motion <- function(z, Q, R, A, H) {
  dimState = dim(Q)[1]
  
  xhatminus <- array(rep(0, ts.length * dimState),
                     c(ts.length, dimState))
  xhat      <- array(rep(0, ts.length * dimState),
                     c(ts.length, dimState))
  
  Pminus  <- array(rep(0, ts.length * dimState * dimState),
                   c(ts.length, dimState, dimState))
  P       <- array(rep(0, ts.length * dimState * dimState),
                   c(ts.length, dimState, dimState))
  
  K <- array(rep(0, ts.length * dimState),
             c(ts.length, dimState)) # Kalman gain
  
  # initial guesses = starting at 0 for all metrics
  xhat[1, ] <- rep(0, dimState)
  P[1, , ]  <- diag(dimState)
  
  for (k in 2:ts.length) {
    # time update
    xhatminus[k, ] <- A %*% matrix(xhat[k-1, ])
    Pminus[k, , ] <- A %*% P[k-1, , ] %*% t(A) + Q
    
    K[k, ] <- Pminus[k, , ] %*% H %*%
                            solve( t(H) %*% Pminus[k, , ] %*% H + R )
    xhat[k, ] <- xhatminus[k, ] + K[k, ] %*%
                            (z[k] - t(H) %*% xhatminus[k, ])
    P[k, , ] <- (diag(dimState) - K[k, ] %*% t(H)) %*% Pminus[k, , ]
  }
  
  ## we return both the forecast and the smoothed value
  return(list(xhat = xhat, xhatminus = xhatminus))
}

## noise parameters
R <- 10^2 ## measurement variance - this value should be set
          ## according to known physical limits of measuring tool
          ## we set it consistent with the noise we added to x
          ## to produce x in the data generation above
Q <- 10   ## process variance - usually regarded as hyperparameter
          ## to be used to maximize performance

## dynamical parameters
A <- matrix(1) ## x_t = A * x_t - 1 (how prior x affects later x)
H <- matrix(1) ## y_t = H * x_t     (translating state to measurement)

## run the data through the Kalman filtering method
xhat <- kalman.motion(z, diag(1) * Q, R, A, H)[[1]]
xhatminus <- kalman.motion(z, diag(1) * Q, R, A, H)[[2]]

## visualization
plot(z, ylim = range(c(x, z)), type = 'l',
                 col = "black",  lwd = 2)
lines(x,         col = "red",    lwd = 2, lty = 2)
lines(xhat,      col = "orange", lwd = 1, lty = 3)
lines(xhatminus, col = "blue",   lwd = 1, lty = 4)
legend("topleft", 
       legend = c("Measured", "Actual", "Filtered", "Forecast"),
       col = c("black", "red", "orange", "blue"), 
       lty = 1:4)
