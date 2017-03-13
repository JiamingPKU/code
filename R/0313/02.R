## Analysis of Variance

## comparason in 2 groups
x1 <- c(20.5, 19.8, 19.7, 20.4, 20.1, 20.0, 19.0, 19.9)
x2 <- c(20.7, 19.8, 19.5, 20.8, 20.4, 19.6, 20.2,20.3)
wilcox.test(x1, x2)
wilcox.test(x1, x2, paired=TRUE)

## chi-square test



