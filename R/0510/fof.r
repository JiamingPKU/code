setwd("C:/Users/j/Desktop/iCourse/大四下/毕业设计/FOF data")
rm(list=ls())

library(readxl)
library(TSA)
library(forecast)

data <- read_excel("bloomberg.xlsx", sheet = "total", col_types = c("skip", "numeric", "numeric"))
# View(data)

ast = data[1] # ast represents asset
num = data[2] # num represents number
ast = ts(ast, frequency = 12,start = 1995) # total net assets
num = ts(num, frequency = 12, start = 1995) # number of FOF funds

GR_ast = diff(log(ast)) # growth ratio of total net asset
GR_ast = ts(GR_ast, names = 'GR_ast')
GR_num = diff(log(num)) # growth ratio of number of FOF funds
GR_num = ts(GR_num, names = 'GR_num')

par(mfrow = c(2,2))
plot(ast)
plot(GR_ast)
plot(num)
plot(GR_num)

m_ast = auto.arima(ast) # ARIMA(0,2,2)
m_GR_ast = auto.arima(GR_ast) # ARIMA(0,1,1)
m_num = auto.arima(num) # ARIMA(0,2,1)(0,0,1)[12] 
m_GR_num = auto.arima(GR_num) # ARIMA(1,1,1)

mm_ast = auto.arima(diff(ast, differences = 2)) # ARIMA(0,0,2) with zero mean
mm_GR_ast = auto.arima(diff(GR_ast, differences = 1)) # ARIMA(0,0,1) with zero mean
mm_num = auto.arima(diff(num, differences = 2)) # ARIMA(0,0,1)(0,0,1)[12] with zero mean 
mm_GR_num = auto.arima(diff(GR_num, differences = 1)) # ARIMA(1,0,1) with zero mean

# residuals
r_ast = mm_ast$residuals
r_GR_ast = mm_GR_ast$residuals
r_num = mm_num$residuals
r_GR_num = mm_GR_num$residuals

par(mfrow = c(2,2)) # plots of residuals
plot(r_ast)
plot(r_GR_ast)
plot(r_num)
plot(r_GR_num)

# test of white noise
t_ast = Box.test(r_ast, lag = 24, type = "Ljung-Box", fitdf = 2)
t_GR_ast = Box.test(r_GR_ast, lag = 24, type = "Ljung-Box", fitdf = 1)
t_num = Box.test(r_num, lag = 24, type = "Ljung-Box", fitdf = 2)
t_GR_num = Box.test(r_GR_num, lag = 24, type = "Ljung-Box", fitdf = 2)

par(mfrow=c(2,2)) # plots of ACF of assumed white noise
acf(r_ast)
acf(r_GR_ast)
acf(r_num)
acf(r_GR_num)

t_ast$p.value # 0.017
t_GR_ast$p.value # 0.134
t_num$p.value # 0.287
t_GR_num$p.value # 0.003

# other strange phenomena
par(mfrow=c(2,1))
acf(ast,lag=150)
acf(num,lag=150)