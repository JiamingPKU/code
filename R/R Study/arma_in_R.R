##### Time Series Analysis

# moving average
w = rnorm(500, 0, 1) # 500 variables
v = filter(w, sides=2, rep(1/3, 3)) #moving average
par(mfrow=c(2,1))
plot.ts(w, main="white noise")
plot.ts(v, main="moving average")
par(mfrow=c(1,1))

# autoregression
w = rnorm(550, 0, 1)
x = filter(w, filter=c(1, -0.9), method="recursive")[-(1:50)]
plot.ts(x, main="autoregression")

# random walk
w = rnorm(200, 0, 1); x=cumsum(w)
wd = w + 0.2; xd=cumsum(wd)
plot.ts(xd, main="Random Walk")
lines(x);lines(.2*(1:200), lty="dashed")

############# Ch3 AR model

##### Example3.1
gnp=scan("F:\\data\\ts\\dgnp82.txt")
gnp1 = ts(gnp, frequency = 4, start=c(1947,2))
plot(gnp)
points(gnp1, pch='*')

m1=ar(gnp, method="mle")
m1$order
m2=arima(gnp, order=c(3,0,0))
summary(m2)
sqrt(m2$sigma2)
p1=c(1, -m2$coef[1:3])
roots= polyroot(p1)
roots
Mod(roots)

ord = ar(gnp, method="mle")
ord$aic
ord$order

##### Example3.2
vw = read.table("F:\data\ts\m-ibm-6815.txt",header=T)[,3]
m3=arima(vw, order=c(3,0,0))
sqrt(m3$sigma2)

## Model Diagnostic Check
Box.test(m3$residuals, lag=12, type="Ljung")
pv=1-pchisq(16.35, 9)
m3 = arima(vw, order=c(3,0,0), fixed=c(NA, 0, NA, NA))
Box.test(m3$residuals, lag=12, type="Ljung")
pv = 1-pchisq(16.83, 10)


############# Ch4 MA Model

##### Simulated MA(1)
par(mfrow=c(2,1))
plot(arima.sim(list(order=c(0,0,1),ma=.5),n=100), ylab="x",
    main=(expression(MA(1)~~~theta==+.5)))
plot(arima.sim(list(order=c(0,0,1), ma=-.5), n=100), ylab="x",
    main=(expression(MA(1)~~~theta==-.5)))

require(TSA)
z=arima.sim(list(order=c(1,0,1), ma=0.5, ar=0.5), n=100)
eacf(z, ar.max=8, ma.max=8)

