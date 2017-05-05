getwd()


######数据导入和清理######

##读入财务数据
far = read.table("F:\\data\\far.csv", sep=",", header=TRUE)
names(far)
table(far$Accper)
far$year <- as.Date(far$Accper, "%Y/%m/%d")
far$year <- format(far$year, "%y")
table(far$year)

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

#处理时间
names(mdata)
mdata$year <- as.Date(mdata$Accper,"%Y/%m/%d")
mdata$year <- format(mdata$year, "%y")


library(ggplot2)
ggplot(data=far, aes(x=Etaxrt)) + geom_histogram()
#发现有许多离群值，去除离群值；两端各去除0.5%的异常值
quantile(far$Etaxrt, probs = c(0.005,0.995), na.rm=TRUE)
far1 <- far
#需要先执行后面的函数定义部分，然后再调用winsor函数
far1$Etaxrt <- winsor(far1$Etaxrt, fraction = 0.005)
ggplot(data=far1, aes(x=Etaxrt)) + geom_histogram()+
  labs(x="实际税率",y="数量")
ggplot(data=far1, aes(x=Etaxrt)) + geom_density()+
  labs(x="实际税率",y="数量")
ggplot(data=far1, aes(x=Etaxrt, fill=year)) + geom_density()+
  labs(x="实际税率",y="数量")+facet_grid(~year~.)

######对15年数据查看#####
library(dplyr)
far15 <- far1 %>% filter(year==15)
table(far15$year)
##生成一个税率区间
far15$tax <- (far15$Etaxrt>-0.05) + (far15$Etaxrt >0.1)+(far15$Etaxrt>0.2)+(far15$Etaxrt>0.3)
far15$tax <- as.factor(far15$tax)
#far15$check = !is.na(far15$tax)
far15 <- far15 %>% filter(! is.na(tax))
table(far15$tax)

##作图
ggplot(data=far15, aes(x=Etaxrt, fill=tax)) + geom_density()+
  labs(x="实际税率",y="数量")
##资产负债率
library("dplyr")
library("reshape")
far15 <- rename(far15, c("T30100"="debt","T40700"="mr","T60300"="pstk"))
far15$debt <- winsor(far15$debt, fraction = 0.005)
far15$mr <- winsor(far15$mr, fraction = 0.005)
far15$pstk <- winsor(far15$pstk, fraction = 0.005)

ggplot(data=far15, aes(x=debt, fill=tax)) + geom_density()+
  labs(x="实际税率",y="数量")
ggplot(data=far15, aes(x=debt, fill=tax)) + geom_density()+
  labs(x="资产负债率",y="数量")+facet_grid(tax~.)
ggplot(data=far15, aes(x=mr, fill=tax))+geom_density()+
  labs(x="边际利润率",y="数量")+facet_grid(tax~.)
ggplot(data=far15, aes(x=pstk, fill=tax))+geom_density()+
  labs(x="每股净资产",y="数量")+facet_grid(tax~.)


ggplot(data=far15, aes(x=debt, y=mr,color=tax))+ 
  geom_point()


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
