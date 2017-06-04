getwd()
library(haven)
csdps <- read_dta("F:/data/CSDPS.dta", encoding="UTF-8")
city <- read_dta("F:/git/stata/output/4Jun2017/city.dta", encoding = "UTF-8")
city0 <- read_dta("F:/git/stata/output/4Jun2017/city.dta", encoding = "UTF-8")


coplot(govsize~year|pref,type="b",data=city0)
library(car)
