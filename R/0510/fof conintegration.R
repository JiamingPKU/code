'''
#### 说明
本部分对fof和retire进行协整分析。 
1. **平稳性**。fof与retire都是非平稳的，取对数后仍然非平稳。但它们的增长率都是平稳序列（对数再差分）
2. **协整建模1**。 $fof$**~ **$retire$ 。结果残差是平稳的，说明2个I(1)的过程结果得到了I(0)的过程。协整向量为(1, -0.15)。同时建立ECM方程。
3. **协整建模2**。$log(fof)$**~ **$log(retire)$ 。结果残差是平稳的。同上。协整向量为(1, -1.9)。同时建立ECM方程。
4. **协整建模3**。使用*Lecture11* 中的$ca.jo()$函数建模。结果：
1. 对fof与retire分析时不存在协整关系。
2. 对log(fof)与log(retire)分析时也不存在协整关系。
3. 对GR_fof与GR_retire分析时存在协整关系。但是这个是平稳序列。
'''
##### 导入数据####
getwd()
x=c("readxl","TSA","forecast", "FinTS","e1071","fGarch","MTS", "urca", "dynlm")
lapply(x, require, character.only = T)
rm(list=ls())

data2 <- read_excel("F:\\data\\ts\\API.xlsx", sheet = "RR", col_types = c("skip", "skip", "skip", "skip", "numeric", "numeric", "skip"))
# 提取协整分析的数据，养老金和fof数量，从2007年开始
retire = ts(data2[1], frequency = 4,start = c(2007,1),names = 'retire')
fof = ts(data2[2], frequency = 4,start = c(2007,1),names = 'fof')
FinTS.stats(retire)
FinTS.stats(fof)

####描述统计####
# 获得增长率
GR_retire = diff(log(retire))
GR_fof = diff(log(fof))
par(mfrow=c(2,1))
# 基数的协整关系比较复杂，不容易查看
ts.plot(retire, fof*10, col = rainbow(8), gpars = list(xlab="Year", ylab="Number" ))
title("Time Trends of Retire and FOF in Last 10 Years")
# legend(x=2007,y=9000, c("Retire","FOF*10"), text.col = rainbow(8), bty="n")
legend(x=2007, y= 9500, c("Retire"), text.col=rainbow(8)[1], bty="n")
legend(x=2007, y= 7500, c("FOF * 10"), text.col=rainbow(8)[2], bty="n")
# 增长率之间趋势相同，可以看出有协整关系
ts.plot(GR_retire, GR_fof, col=rainbow(8), gpars = list(xlab="Year", ylab="Growth Rate"))
title("Growth Rates of Retire and FOF in Last 10 years")
legend(x=2010, y= -0.05, c("the Growth Rate of Retire"), text.col=rainbow(8)[1], bty="n")
legend(x=2007, y= 0.22, c("the Growth Rate of FOF"), text.col=rainbow(8)[2], bty="n")
# ts.plot(diff(fof), diff(retire),col=rainbow(8))

####单位根检验####
# df-test/pp-test的原假设是非平稳， kpss-test的原假设是平稳
summary(ur.df(retire, lags = 3)) # 不拒绝
# adf.test(retire)
summary(ur.kpss(retire)) #拒绝
summary(ur.pp(retire)) # 不拒绝 （临界值附近）

summary(ur.df(diff(retire),lags=3)) #拒绝
summary(ur.kpss(diff(retire))) #不拒绝
summary(ur.pp(diff(retire))) #小于临界值


summary(ur.df(fof)) #不拒绝
summary(ur.kpss(fof)) # 拒绝
summary(ur.pp(fof)) # 不拒绝

summary(ur.df(diff(fof))) #拒绝
summary(ur.kpss(diff(fof))) #不拒绝
summary(ur.pp(diff(fof))) #拒绝

#### Model 1 ####
# 模型m1, 得到残差序列 r1
# m1 = fof ~ retire
m1 = lm(fof~retire)
# r1 = m1$residuals
r1 <- m1$residuals
par(mfrow=c(1,1))
plot(r1, xlab = 'time (seasonal)')
# t = adf.test(resid, alternative = 'explosive')
print(summary(m1))

summary(ur.df(r1)) #拒绝
summary(ur.kpss(r1)) #不拒绝
summary(ur.pp(r1)) #不拒绝
