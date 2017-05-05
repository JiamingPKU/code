getwd()


######数据导入和清理######

##读入财务数据
far = read.table("F:\\data\\far.csv", sep=",", header=TRUE)
names(far)
table(far$Accper)
year <- as.Date(far$Accper, "%Y/%m/%d")
year <- format(year, "%y")

##读入风险系数数据
beta = read.table("F:\\data\\beta.csv",sep=",", header=TRUE)
names(beta)
table(beta$Trddt)

##读入税收数据
othertax = read.table("F:\\data\\othertax.csv",sep=",", header=TRUE)
table(othertax$Accper)
library(dplyr)
#使用filter和正则表达式筛选出合适的数据
othertax <- othertax %>% filter(grepl("/1/1", othertax$Accper))

##读入税收数据2
alltax = read.table("F:\\data\\alltax.csv", sep=",", header=T)
names(alltax)
table(alltax$Accper)
alltax <- alltax %>% filter(grepl("/1/1", alltax$Accper))

## Merge Data
mdata = merge(alltax,othertax, by=intersect(c("Stkcd","Accper"),c("Stkcd","Accper")))
names(mdata)
library(reshape)
mdata <- rename(mdata,c("B001100000"="revenue","B001207000"="revenueTax", "B002100000"="incomeTax"))
mdata$dif <- mdata$alltax-mdata$revenueTax-mdata$incomeTax
m2data <- mdata %>% filter(dif<5000 && dif >-5000)
m1data <- mdata %>% filter(alltax - incomeTax - revesnueTax <50 && alltax - incomeTax- revenueTax>-50 )
ggplot(m1data, aes(x=alltax))+geom_histogram()
ggplot(m1data, aes(x=incomeTax))+geom_histogram()
ggplot(m1data, aes(x=revenueTax))+geom_histogram()
ggplot(m2data, aes(x=dif))+geom_histogram()


##处理时间
far$year = as.Date(far$Accper,"%Y/%m/%d")
far$year = format(year, format="%y")
table(far$year)

##处理变量名称
library(reshape)
far1 <- rename(far, c(A100000="asset", B110101="income", D100000="cashflow", T30100="alratio"))
names(far1)

#install.packages("ggplot2")
library(ggplot2)
ggplot(data=far1, aes(x=Etaxrt)) + geom_histogram()
#发现有许多离群值，去除离群值；两端各去除0.5%的异常值
quantile(far1$Etaxrt, probs = c(0.005,0.995), na.rm=TRUE)
far1$Etaxrt <- winsor(far1$Etaxrt, fraction = 0.005)
ggplot(data=far1, aes(x=Etaxrt)) + geom_histogram()



mdata=merge(alltax, othertax, by=intersect(c("Stkcd","Accper"), c("Stkcd","Accper")) 
              ,all=TRUE )
?merge
?cbind

##使用Winsorizing 方法
## source: r-bloggers-Winsorization
winsor <- function (x, fraction=.05)
{
  if(length(fraction) != 1 || fraction < 0 || fraction > 0.5){
    stop("bad value for 'fraction'")
  }
  lim <- quantile(x, probs=c(fraction, 1-fraction), na.rm=TRUE)
  x[ x < lim[1] ] <- NA
  x[ x > lim[2] ] <- NA
  return(x)
}
