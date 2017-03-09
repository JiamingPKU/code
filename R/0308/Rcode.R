getwd()#get working directory 
setwd('/users/ying/desktop/r')

rm(list=ls())#remove (almost) everything in the working environment
#you can also use: remove(),rm()

#install package TSA, MTS

###generate AR or MA or random walk
w=rnorm(100,0,1)#rnorm(n, mean = 0, sd = 1)
v=filter(w,sides=2,filter=rep(1/3,3))#v[2]=ave(w[1:3]) 
par(mfrow=c(2,1))
plot.ts(w,main='white noise',col='blue')#title("white noise")
plot.ts(v,main='moving average')

w=rnorm(550,0,1)
x=filter(w,filter=c(1,-.9),method='recursive')[-(1:50)]
par(mfrow=c(2,1))
plot.ts(x,main='autoregression')

set.seed(154)
w=rnorm(200,0,1);x=cumsum(w)
wd=w+0.2;xd=cumsum(wd)
plot.ts(xd,ylim=c(-5,55),main='random walk')
lines(x);lines(.2*(1:200),lty='dashed')

ar2ma2=arima.sim(n = 63, list(order = c(2,0,2),ar = c(0.8897, -0.4858), ma = c(-0.2279, 0.2488)),
          sd = sqrt(0.1796))

#specify a ts model
#MA(1)
v=rnorm(200)
x=filter(v,sides=1,filter=c(1,0.8))[-1]
acf(x)
pacf(x)
eacf(x,c(6,6))

arma(x,order=c(0,1))
#AR(2)
w=rnorm(200,0,1)
x=filter(w,filter=c(0.5,0.3),method='recursive')
acf(x)
pacf(x)
eacf(x)

ar(x,aic=T)
#arma(x,order=c(2,0))

#ARMA(1,2)
u=rnorm(300)
x=u
for (i in 2:300)
{
  x[i]=0.5*x[i-1]+u[i]-0.7*u[i-1]}

plot.ts(x)
acf(x)
pacf(x)
eacf(x)


arima(x,order=c(1,0,1),seasonal = list(order=c(1,0,0),period=2))
fit1=arima(ar2ma2,order=c(2,0,2))
plot.ts(fit1$residuals)
acf(fit1$residuals)
pacf(fit1$residuals)
tsdiag(fit1)
predict(fit1,10)

#require the 'forecast' package
fore1=forecast.Arima(fit1,h=10)
fit2=auto.arima(WWWusage)
fit3=Arima(WWWusage,order=c(3,1,0))

####multivariate ts
p1=matrix(c(0.2,-0.6,0.3,1),2,2)
sig=matrix(c(4,0.8,0.8,1),2,2)
th1=matrix(c(-0.5,0,0,-0.6),2,2)
m1=VARMAsim(300,arlags=c(1),malags=c(1),phi=p1,theta=th1,sigma=sig)
zt=m1$series

arorder=VARorder(zt,maxp=4)
str(arorder)

var1=VAR(zt,p=arorder$bicor)
var2=VARMA(zt,p=1,q=1)

#linear regression
x1=rnorm(200,1,0.5)
x2=rnorm(200,0,2)
u=rnorm(200,0,1)
y=2+x1*2+x2*0.6+u
lm1=lm(y~x1+x2)#lm(y~x1+x2-1)
lm1$coefficients
lm1$effects
summary(lm1)
coef(lm1)
residuals(lm1)
str(lm1)


plot.ts(lm1$residuals,main='regression residual',col='red',ylim = c(-2,10),lty=2)
lines(y,lty='dotted')
lines(predict(lm1),col='blue',lty=1)
legend("topright",legend=c('res','y','yhat'),col=c('red','black','blue'),lty=c(2,3,1))
##export results
res=lm1$residuals
res=data.frame(res)
write.csv(res,file='residual1.csv')
write.csv(lm1$residuals,file='residual.csv')
write.table(lm1$residuals,file='residual.txt')
write.table(res,file='residual1.txt')

#import data
data=read.csv("residual.csv",header=TRUE)
data1=read.csv("residual1.csv",header=TRUE)

data=read.table("residual1.txt",header=TRUE)
head(data)#tail(data)
attach(data)
head(y)#tail(y)

y=data$y#y=data$y[20:50]
length(y)#dim(cbind(x1,x2))

###write your own function
source('plus.r')
a=plus(1,3)

