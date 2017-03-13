## population and sample

#example1
x1 <- rnorm(30, 10, 2)
summary(x1)
hist(x1)
boxplot(x1)
qqnorm(x1); qqline(x1)

#example2
x2 <-exp(rnorm(30,0,1))
hist(x2); locator(1)
y <- log(x2)
hist(y)

x3 <- rnorm(30,10,3)^2
hist(x3);locator(x3)
y <- sqrt(x)
hist(y);

## fint the value of lambda to use boxcox transformation
library(MASS)
boxcox(x3~1)
boxcox(x2~1)
boxcox(x1~1)

## point estimation Q
objf <- function(theta, x){
  mu <- theta[1]
  s2 <- exp(theta[2])
  n <- length(x)
  res <- n*log(s2) + 1/s2*sum((x - mu)^2)
  res
}

sim <- function(n=30){
  mu0 <- 20
  sigma0 <- 2
  x <- rnorm(n, mu0, sigma0)
  theta0 <- c(0,0)
  ores <- optim(theta0, objf, x=x)
  print(ores)
  theta <- ores$par
  mu <- theta[1]
  sigma <- exp(0.5*theta[2])
  cat("mu: ", mu, " ==> ", mu0, "\n")
  cat("sigma: ", sigma, " ==> ", sigma0, "\n")
}


x4 <- c(11.67, 9.29, 10.45, 9.01, 12.67,16.24, 11.64, 7.73, 12.23)
t.test(x4)
prop.test(30,100) ## confidence interval
x5 <- prop.test(30,100)

## hypothesis testing
x6 <- c(20.5, 19.8, 19.7, 20.4, 20.1, 20.0, 19.0, 19.9)
x7 <- c(20.7, 19.8, 19.5, 20.8, 20.4, 19.6, 20.2)
t.test(x6, x7)
var.test(x6, x7)

## normality test
hist(x4);locator(1)
qqnorm(x4);qqline(x4)
shapiro.test(x4)  ## Shapiro=Wilk normality test

## proportion test

