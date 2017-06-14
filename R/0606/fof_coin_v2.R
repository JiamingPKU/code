#### 导入数据 ####
getwd()
x=c("readxl","TSA","forecast", "FinTS","e1071","fGarch","MTS", "urca", "dynlm")
lapply(x, require, character.only = T)
rm(list=ls())
data2 <- read_excel("F:\\data\\ts\\API.xlsx", sheet = "RR", col_types = c("skip", "skip", "skip", "skip", "numeric", "numeric", "skip"))

# 提取协整分析的数据，养老金和fof数量，从2007年开始
retire = ts(data2[1], frequency = 4,start = c(2007,1),names = 'retire')
fof = ts(data2[2], frequency = 4,start = c(2007,1),names = 'fof')

# 描述性统计
FinTS.stats(retire)
FinTS.stats(fof)

# 获得增长率
GR_retire = diff(log(retire))
GR_fof = diff(log(fof))

# 资产绝对数量的协整关系示意
ts.plot(retire, fof*10, col = rainbow(8), gpars = list(xlab="year", ylab="number" ))
legend(x=2007, y= 9500, c("Retire"), text.col=rainbow(8)[1], bty="n")
legend(x=2007, y= 7500, c("FOF * 10"), text.col=rainbow(8)[2], bty="n")

# 增长率之间趋势相同，可以猜测有协整关系
ts.plot(GR_retire, GR_fof, col=rainbow(8))
legend(x=2010, y= -0.05, c("the Growth Rate of Retire"), text.col=rainbow(8)[1], bty="n")
legend(x=2007, y= 0.22, c("the Growth Rate of FOF"), text.col=rainbow(8)[2], bty="n")

#### 单位根检验 ####
# df-test/pp-test的原假设是非平稳， kpss-test的原假设是平稳

summary(ur.df(diff(retire),lags=3)) #拒绝
summary(ur.kpss(diff(retire))) #不拒绝
summary(ur.pp(diff(retire))) #小于临界值

summary(ur.df(retire, lags = 3)) # 不拒绝
summary(ur.kpss(retire)) #拒绝
summary(ur.pp(retire)) # 不拒绝 （临界值附近）

summary(ur.df(fof)) #不拒绝
summary(ur.kpss(fof)) # 拒绝
summary(ur.pp(fof)) # 不拒绝

summary(ur.df(diff(fof))) #拒绝
summary(ur.kpss(diff(fof))) #不拒绝
summary(ur.pp(diff(fof))) #拒绝

#### 协整模型 ####
# 模型m1, 得到残差序列 r1
# m1 = fof ~ retire
m1 = lm(fof~retire)
# r1 = m1$residuals
r1 <- m1$residuals
print(summary(m1))

# 对残差序列进行 单位根检验
summary(ur.df(r1)) #拒绝
summary(ur.kpss(r1)) #不拒绝
summary(ur.pp(r1)) #不拒绝

# r1 可以认为是平稳的，说明二者之间存在协整关系。
# 系数为 0.1524，则协整向量为 (1, -0.15)

#### 误差修正模型 ####

# bind the data
y = diff(fof); x = diff(retire)
r <- r1[1:39]
ecmdat1 <- cbind(y,x, r)

# 建立ECM模型，4期滞后项以及x的当期与滞后项与误差修正项
ecm1 <- dynlm(y~  L(y, 1)  +L(y,2)+L(y,3)+L(y,4)+ L(x, 1) + L(x,0)+L(r, 1), data = ecmdat1)
summary(ecm1)
