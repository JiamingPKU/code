#####Analysis of Variance



#####Part1: Comparason Between 2 Groups

###1.1 位置检验的非参数方法
#位置检验的非参数方法
x <- c(20.5, 19.8, 19.7, 20.4, 20.1, 20.0, 19.0, 19.9)
y <- c(20.7, 19.8, 19.5, 20.8, 20.4, 19.6, 20.2)
wilcox.test(x,y)
#成对比较的符号检验
x <- c(20.5, 19.8, 19.7, 20.4, 20.1, 20.0, 19.0, 19.9)
y <- c(20.7, 19.8, 19.5, 20.8, 20.4, 19.6, 20.2, 20.5)
t.test(x, y, paired=TRUE )
#成对比较的符号检验的另一种方法
z <- x-y
binom.test(sum(z>0), sum(z !=0), p=0.5) 
#成对比较的符号秩检验
wilcox.test(x,y,paired = TRUE)

### 1.2 卡方检验
#单总体分布检验
x <- c(18, 13, 17, 21, 15, 16)
p <- rep(1/6, 6)
chisq.test(x, p=p)
#单个比例的卡方检验
#两个总体独立性检验
tab <- matrix(c(60,3, 32,11),nrow=2,ncol=2, byrow=TRUE, dimnames=list(c("病人","健康人"),c("吸烟","不吸烟")))
chisq.test(tab)
#Fisher精确检验
fisher.test(tab)



#####Part2: Single Factor ANOVA
# 2.1单因素方差分析
A <- factor(rep(1:5, each=4))
y <-c(25.6, 22.2, 28.0, 29.8,
      24.4, 30.0, 29.0, 27.5,
      25.0, 27.7, 23.0, 32.2,
      28.8, 28.0, 31.5, 25.9,
      20.6, 21.2, 22.0, 21.2)
d <- data.frame(y, A)
plot(y~A, data=d)
plot(y~A) #data=d 并没有什么卵用

aov1 <- aov(y~A)
summary(aov1)
tapply(d$y, d$A, mean)

# 2.2多重比较
pairwise.t.test(y, A, p.adjust="none")
pairwise.t.test(y, A)
pairwise.t.test(y, A, p.adjust="fdr")

TukeyHSD(aov1)
# 2.3方差齐性检验
bartlett.test(y~A) #Bartlett test
require(car)
leveneTest(y~A) #Levene test

oneway.test(y~A) #welch test
# 2.4非参数 Kruskal-Wallis 检验
kruskal.test(y~A)




#####Part3: Multi-Factors ANOVA
# there are some problems with the code in this part
rats <- data.frame(
y =  c(0.31, 0.45, 0.46, 0.43, #(1,1)
       0.82, 1.10, 0.88, 0.72, #(1,2)
       0.43, 0.45, 0.63, 0.76, #(1,3)
       0.45, 0.71, 0.66, 0.62, #(1,4)
       
       0.36, 0.29, 0.40, 0.23, #(2,1)
       0.92, 0.61, 0.49, 1.24, #(2,2)
       0.44, 0.35, 0.31, 0.40, #(2,3)
       0.56, 1.02, 0.71, 0.38, #(2,4)
       
       0.22, 0.21, 0.18, 0.23, #(3,1)
       0.30, 0.37, 0.38, 0.29, #(3,2)
       0.23, 0.25, 0.24, 0.22, #(3,3)
       0.30, 0.36, 0.31, 0.33, #(3,4)
       Toxicant=factor(rep(1:3, each=4*4)),
       Cure=factor(rep(1:4, each=4),3)
       ))
plot(y~Toxicant+Cure, data=rats)
plot(y~Cure, data=rats)
aov2 <- aov(y~ Toxicant+Cure+Toxicure:Cure, data=rats)
summary(aov2)




#####Part4: Analysis of Covirence 
d1 <- data.frame(A=1,
                 x=c(15, 13, 11, 12, 12, 16, 14, 17),
                 y=c(85, 83, 65, 76, 80, 91, 84, 90))
d2 <- data.frame(A=2,
                 x=c(22, 24, 20, 23, 25, 27, 30, 32),
                 y=c(89, 91, 83, 95, 100, 102, 105, 110))
d3 <- data.frame(A=3,
                 x=c(17, 16, 18, 18, 21, 22, 19, 18),
                 y=c(97, 90, 100, 95, 103, 106, 99, 94))
d <- rbind(d1, d2, d3)
d$A <- factor(d$A)

require(HH)
ancova(y~A+x, data=d)  # ancova
ancova1 <- ancova(y~A+x, data=d)
summary(ancova1)

anova(lm(y~A+x, data=d), ancova1) #compare ancova and line-model






#####Part5: Orthogonal experiment
A <- factor(rep(1:3, each=3))
B <- factor(rep(1:3, 3))
C <- factor(c(1,2,3,2,3,1,3,1,2))
y <- c(16.9, 19.1, 16.7, 19.8, 23.7,
       19.0, 25.0, 20.4, 23.1)
d <- data.frame(A, B, C, y)

plot(y~A+B+C, data=d)

aov3 <- aov(y~A+B+C, data=d)
summary(aov3)


