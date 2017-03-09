## TS with Application in R
#@chapter 1
#@Jack
#@Mar 8th, 2017

library(leaps)
library(locfit)
library(mgcv)
library(nlme)
library(tseries)
library(TSA)
win.graph(width=4.875, height=2.75, pointsize = 8)
data("larain")
plot(larain, ylab="Inches", xlab="Year", type="o")


win.graph(width=4.875, height=2.75, pointsize = 8)
data("color")
plot(color, ylab="Color Property", xlab="Batch", type="o")

win.graph(width=4.875, height=2.75, pointsize = 8)
data("hare")
plot(hare, ylab="Abundance", xlab="Year", type="o")

win.graph(width=4.875, height=2.75, pointsize = 8)
data("tempdub")
plot(tempdub, ylab="Temperature", type="o")

win.graph(width=4.875, height=2.75, pointsize = 8)
data("oilfilters")
plot(oilfilters, ylab="sales",type="o")

plot(oilfilters, ylab="sales",type="l")
points(y=oilfilters, x=time(oilfilters), 
       pch=as.vector(season(oilfilters))) #add season


