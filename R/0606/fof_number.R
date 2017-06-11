setwd("/Users/wangzhe/time-series/finalproject/final-data")
rm(list=ls())

library(readxl)
library(TSA)
library(forecast)

data <- read_excel("API.xlsx", sheet = "R", col_types = c("skip", "numeric", "numeric"))

num = data[2] # num represents asset
num = ts(num, frequency = 12,start = c(1995,1)) # number of FOF

GR_num = diff(log(num)) # growth ratio of total net asset
GR_num = ts(GR_num * 100, frequency = 12,start = c(1995,2), names = 'GR_num')

par(mfrow = c(2,1))
plot(num)
plot(GR_num)

adf.test(num)
adf.test(GR_num)

m = arima(GR_num,order = c(3,0,3)) 
print(m)
tsdiag(m)

r = m$residuals
t = Box.test(r, lag = 24, type = 'Ljung-Box', fitdf = 6)
t$p.value 
McLeod.Li.test(y=r)








#future = forecast.Arima(m, h = 12, level = c(80,90,95,99.5))
#print(future)
#par(mfrow=c(1,1))
#plot(future)

#mm = garch(r) #(p=1,q=1)
#rr = mm$residuals
#tt = Box.test(rr, lag = 24, type = 'Ljung-Box', fitdf = 9)
#tt$p.value #0.359

#g=garchFit(~arma(3,3)+garch(1,1),data = GR_num,cond.dist = "std",trace = F)
#summary(g)

#建模的阶数反复操作选定。


spec=ugarchspec(mean.model = list(armaOrder=c(3,5),archm=F),variance.model = list(model="eGARCH",garchOrder=c(1,1)),distribution.model ="norm",fixed.pars = list() )
g1=ugarchfit(spec = spec,data = GR_num,fit.control = list(fixed.se=1,stationarity=1),out.sample = 10)
show(g1)

boot=ugarchboot(g1,method = c("Partial")[1],n.ahead = 100,n.bootpred = 269)
show(boot)
plot(boot)
f=ugarchforecast(g1,n.ahead = 10,out.sample = 10,n.roll = 10)
plot(f)
