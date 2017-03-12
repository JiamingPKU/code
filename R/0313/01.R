# 总体与样本

#example1
x1 <- rnorm(30, 10, 2)
summary(x1)
hist(x1)
boxplot(x1)
qqnorm(x1); qqline(x1)

#example2
x2 <-exp(rnorm(30,0,1))
hist(x2); locator(1)
y <- log(x)
hist(y)

x3 <- rnorm(30,10,3)^2
hist(x);locator(x)
y <- sqrt(x)
hist(y)

library(MASS)
boxcox(x3~1)

# 参数估计

