setwd("/Users/wangzhe/time-series/finalproject/final-data")
rm(list=ls())

library(readxl)
library(TSA)
library(forecast)

data <- read_excel("API.xlsx", sheet = "RR", col_types = c("skip", "skip", "skip", "skip", "numeric", "numeric", "skip"))
d1 = ts(data[1], frequency = 4,start = c(2007,1),names = 'retire')
d2 = ts(data[2], frequency = 4,start = c(2007,1),names = 'fof')

#retire = ts(d1[25:40], frequency = 4,start = c(2013,1),names = 'retire')
#fof = ts(d2[25:40], frequency = 4,start = c(2013,1),names = 'fof')
retire = ts(d1[13:40], frequency = 4,start = c(2010,1),names = 'retire')
fof = ts(d2[13:40], frequency = 4,start = c(2010,1),names = 'fof')

#s = log(retire) - log(fof)
adf.test(retire, alternative = 'e')
adf.test(fof, alternative = 'explosive')
adf.test(diff(retire), alternative = 's')
adf.test(diff(fof), alternative = 's')

m = lm(fof ~ retire)
resid = m$residuals
par(mfrow=c(1,1))
plot(resid, xlab = 'time (seasonal)')
t = adf.test(resid, alternative = 'explosive')
print(summary(m))
print(t)


