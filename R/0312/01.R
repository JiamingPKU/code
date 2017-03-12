#### 
#### version: 2010-12-02
#### Jack Q.Ren
#### renqingjie@pku.edu.cn



## pre-work
setwd("0310\\")
ls()
rm(list=ls())
ls()


######Chapter 1: Basic R code

## section 1: introduction
x1 <- 1:100
x2 <- x1 * 2 * pi/100 #another vector
y1 <- sin(x2) # use function to generate vector

plot(x2, y1, type="l")
abline(h=0, lwd=2)
abline(v=(0:4)/2*pi, lty=3, col="gray")
y2 <- cos(x2)
lines(x2, y2, lty=2, col="green")

sink("log1.txt",split=1) #use sink to log the output into a file
sum(y1)
print(y1)
sink() #end the log


## SECTION 2: vector and assignment
marks <-c(10, 6, 4, 7, 8)
x <-c(1:3, 10:13)
x1 <- c(1,2)
x2 <- c(x, x1)
## arguments of vector
mode(x)
length(x)
## calculations of vector with scalar
x+2
x-2
x*2
x/2
x^2
2/x
2^x
## calculations of vector with vector
x1 <- c(1,10)
x2 <- c(4,2)
x1+x2
x1-x2
x1*x2
x1/x2
x1^x2
x1 <- c(1,10)
x3 <- c(1,3,5,7)
x4 <- c(1,3,5,7,9)
x1+x3
x1-x3
x1*x3
x1/x3
x1^x3
x1+x4
x1-x4
x1*x4
x1/x4
x1^x4
## functions of vector
sqrt(x1);log(x1);exp(x1);sin(x1);cos(x1);tan(x1) 
sum(x1);mean(x1);var(x1);sd(x1);min(x1);max(x1);range(x1)
cumsum(x1);cumprod(x1)
sort(x);order(x)
## functions to generate a vector
seq(6);seq(2,5);seq(11,15,by=2);seq(0,2*pi,length=100);seq(to=2,from=5)
rep(0,5); rep(c(1,3),2);rep(c(1,3),c(2,4)); rep(c(1,3),each=2)
## character-vectors
paste(c("ab","cd")) #return a character
paste(c("a","b"),c("c","d"));paste(c("x", 1:3));paste("x",1:3)
paste("x",1:3,sep="~");paste("ab","cd",collapse="")
## complex

x<-1:100
y<-list(x)
x[1]
y[1]
dim(x)
dim(y)
x1 <- c("a","b","c")

## input and output
cat("x=",x,"\n",file="1.txt",append = 1)
save(x, y, file="x-y.RData")

rm(list=ls());load("x-y.RData");
sink("allres.txt", split=TRUE)

