##Lesson 2
#@Jack
#@Mar 8th, 2017

#page 5: MA
w=rnorm(500,0,1) #500 variables
v=filter(w, sides = 2, rep(1/3,3)) #moving average
par(mfrow=c(2,1)) # 2 row and 1 line
plot.ts(w, main="white noise")
plot.ts(v, main="moving average")

#page 6: AR
w = rnorm(550, 0, 1) # 50 extra to avoid startup problems
x = filter(w, filter=c(1,-.9), method = "recursive") [-(1:50)]
plot.ts(x, main="autoregression")

#page 7: Random Walk
set.seed(154) # to reproduce the results
w=rnorm(200, 0, 1)
x=cumsum(w) #cumulative sums
wd = w + .2; xd=cumsum(wd)
plot.ts(xd, ylim=c(-5,55), main="random walk")
lines(x); lines(.2*(1:200), lty="dashed") 
