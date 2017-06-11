#setwd("/Users/wangzhe/time-series/finalproject/final-data")
rm(list=ls())

library(readxl)
library(TSA)
library(forecast)

data <- read_excel("F:/git/R/0606/API.xlsx", sheet = "R", col_types = c("skip", "numeric", "numeric"))

ast = data[1] # ast represents asset
ast = ts(ast, frequency = 12,start = c(1995,1)) # total net assets

GR_ast = diff(log(ast)) # growth ratio of total net asset
GR_ast = ts(GR_ast * 100, frequency = 12,start = c(1995,2), names = 'GR_ast')

par(mfrow = c(2,1))
plot(ast,ylab="Asset  /millions of dollars")
plot(GR_ast,ylab="GR_ast / diff(log(ast))")

arrows(2005,60, 2002.7,76, length=.1,angle=20)
text(2005.5,59, "IO")


adf.test(ast)
adf.test(GR_ast)

#这是频谱分析，类似于找周期，深入分析的话有用
par(mfrow = c(1,1))
periodogram(GR_ast)

#不要用auto.arima定阶，因为不准，通过eacf,acf,pacf观察，反复试验。
#m = auto.arima(GR_ast,max.d = 0,seasonal = F,ic="bic") #ARIMA(2,0,2)
#print(m)
m1=arima(GR_ast,order = c(0,0,5),fixed = c(0,0,NA,0,NA,NA))
print(m1)

#r = m$residuals
r1=m1$residuals
#t = Box.test(r, lag = 24, type = 'Ljung-Box', fitdf = 4)
t1=Box.test(r1, lag = 24, type = 'Ljung-Box', fitdf = 2)
#t$p.value #0.384
t1$p.value#box检验通过！
McLeod.Li.test(y=r1)#就是对r1^2 进行很多不同阶的box检验。p-value都很大，发现没有二阶相关性！

Ad_GR_ast=GR_ast
Ad_GR_ast[90]=23#把异常值处理掉

m2=arima(Ad_GR_ast,order = c(0,0,5),fixed=c(0,0,NA,0,NA,NA))
print(m2)
r2=m2$residuals
t2=Box.test(r2, lag = 24, type = 'Ljung-Box', fitdf = 2)
t2$p.value
McLeod.Li.test(y=r2)

spec=ugarchspec(mean.model = list(armaOrder=c(0,5),archm=F),variance.model = list(model="sGARCH",garchOrder=c(1,1)),distribution.model ="std",fixed.pars = list(ma1=0,ma2=0,ma4=0) )
g1=ugarchfit(spec = spec,data = Ad_GR_ast,fit.control = list(fixed.se=0,stationarity=1),out.sample = 10)
show(g1)

f=ugarchforecast(g1,n.ahead = 10,out.sample = 10,n.roll = 10)
plot(f)

boot=ugarchboot(g1,method = c("Partial","Full")[1],n.ahead = 100,n.bootpred = 269)
plot(boot)




#future = forecast.Arima(m, h = 12, level = c(80,90,95))
#print(future)
#par(mfrow=c(1,1))
#plot(future)

