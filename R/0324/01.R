###### Group 11, Data Analysis and Statistical Software
###### Mar 25th
###### Ren Qingjie
###### renqingjie@pku.edu.cn


getwd()
setwd("F:\\code\\R\\")
#save the output
sink(file="note2.txt")
#read the data
library(haven)
csdps <- read_dta("F:/data/CSDPS.dta", encoding="UTF-8")

#list some useful variables
###i7 家庭经济状况
###a23 幸福自评
###h1 发展满意度
###h2 发展乐观度
###b404 自信
###d1 年级


##########单因素方差分析########
#group by i7
require(dplyr)
d1 <- filter(csdps, ! is.na(csdps$i7)) #remove observations if i7 is missing
d1 <- filter(d1, ! is.na(d1$h1)) #remove observations if h1 is missing
d1 <- filter(d1, ! is.na(d1$h2)) #remove observations if h2 is missing
d1 <- filter(d1, ! is.na(d1$a23)) #remove observations if a23 is missing
attach(d1)
i7_f <- factor(i7, ordered=TRUE) #change i7 into an ordered factor variable

#a general view of data
table(i7_f);
require(ggplot2)
ggplot(data=d1, aes(x=h1))+geom_histogram()+
  labs(title="Distribution of Degree of Satisfaction with Development",x="Degree of Satisfaction")
hist(h1)
summary(h1)

###发展满意度和家庭经济状况
#explore the data
table(i7)
ggplot(data=d1, aes(x=h1))+geom_histogram()+
  labs(title="Distribution of Degree of Satisfaction with Development",x="Degree of Satisfaction")
hist(h1)
tapply(h1, i7, mean)
tapply(h1, i7, sd)

#model specification and estimation
aov1 <- aov(h1~ i7_f)
summary(aov1)

##check the adequacy of the model
#check for constant error variance
standresid <- rstandard(aov1)
aov1_d <- data.frame(standresid, aov1$fitted)
ggplot(data=aov1_d,aes(y=standresid, x=aov1.fitted))+geom_point()+
    labs(title="Check for Constant Error Variance")
plot(standresid~aov1$fitted, main="check for constant error variance")
#check for independence of errors
n=dim(d1)[1]
index=seq(1:n)
aov1_d <- data.frame(aov1_d, index)
ggplot(data=aov1_d, aes(y=standresid, x=index))+geom_point()+
  labs(title="Check for Independence of Errors")
plot(standresid~index, main="Check for Independence of Errors")
#check for normality
require(car)
qqPlot(aov1, main="QQPlot")
gg_qq(aov1_d$standresid)#需要先运行appendix中的自定义函数


#check for influential observations
dffits = dffits(aov1)
dfbetas = dfbetas(aov1)
cooks = cooks.distance(aov1)
cbind(dffits, dfbetas, cooks) # get the output here
dfbetaPlots(aov1)
par(mfrow=c(1,2))
plot(dffits~index)
plot(aov1, which=c(4))
par(mfrow=c(1,1))

#多重比较
pairwise.t.test(h1, i7_f, p.adj="none")
pairwise.t.test(h1, i7_f, p.adj="bonf")

TukeyHSD(aov1)
plot(TukeyHSD(aov1))

detach(d1)

sink()
################# Appendix #################

# re-define the qqPlot function in ggplot package
gg_qq <- function(x, distribution = "norm", ..., line.estimate = NULL, conf = 0.95,
                  labels = names(x)){
  q.function <- eval(parse(text = paste0("q", distribution)))
  d.function <- eval(parse(text = paste0("d", distribution)))
  x <- na.omit(x)
  ord <- order(x)
  n <- length(x)
  P <- ppoints(length(x))
  df <- data.frame(ord.x = x[ord], z = q.function(P, ...))
  
  if(is.null(line.estimate)){
    Q.x <- quantile(df$ord.x, c(0.25, 0.75))
    Q.z <- q.function(c(0.25, 0.75), ...)
    b <- diff(Q.x)/diff(Q.z)
    coef <- c(Q.x[1] - b * Q.z[1], b)
  } else {
    coef <- coef(line.estimate(ord.x ~ z))
  }
  
  zz <- qnorm(1 - (1 - conf)/2)
  SE <- (coef[2]/d.function(df$z)) * sqrt(P * (1 - P)/n)
  fit.value <- coef[1] + coef[2] * df$z
  df$upper <- fit.value + zz * SE
  df$lower <- fit.value - zz * SE
  
  if(!is.null(labels)){ 
    df$label <- ifelse(df$ord.x > df$upper | df$ord.x < df$lower, labels[ord],"")
  }
  
  p <- ggplot(df, aes(x=z, y=ord.x)) +
    geom_point() + 
    geom_abline(intercept = coef[1], slope = coef[2]) +
    geom_ribbon(aes(ymin = lower, ymax = upper), alpha=0.2) 
  if(!is.null(labels)) p <- p + geom_text( aes(label = label))
  print(p)
  coef
}
