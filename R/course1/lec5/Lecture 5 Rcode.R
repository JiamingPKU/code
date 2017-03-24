
ls()
rm(list=ls())
ls()
setwd("C:\\Users\\admin\\Dropbox\\GSM PKU\\2017 Spring\\Data Analysis and Statistical Software\\Lecture 5 上机数据")
tce=read.csv("TCE.csv", header=T,sep=',')
tce

library(lattice)
dotplot(land.use~y/n, col=as.numeric(tce$sewer), data=tce, horizontal=T)

#plot(y/n~nitrate,data=tce)
#plot(y/n~chloride,data=tce)

model_null <- glm(cbind(y,n-y) ~ 1, data=tce, family=binomial)
#model_null <- glm(cbind(y,n-y) ~ 1, data=tce, family=binomial(link="logit"))
#model_null <- glm(cbind(y,n-y) ~ 1, data=tce, family=binomial(link="probit"))
#model_null <- glm(cbind(y,n-y) ~ 1, data=tce, family=binomial(link="cloglog"))
summary(model_null)
?glm
?family

model1 <- glm(cbind(y,n-y) ~ land.use + sewer, data=tce, family=binomial)
summary(model1)

anova(model_null, model1)

tce[tce$land.use=='undev',]

tapply(tce$y, tce$land.use,sum)

tapply(tce$y, tce$land.use, sum)/tapply(tce$n, tce$land.use, sum)

tce$land.use2 <- factor(ifelse(tce$land.use %in% c('undev', 'agri'), 'rural', as.character(tce$land.use)))
tce

model2 <- glm(cbind(y,n-y) ~ land.use2 + sewer, data=tce, family=binomial)
summary(model2)

model2 <- glm(cbind(y,n-y) ~ land.use2 + sewer-1, data=tce, family=binomial) # to compare the nine landuses' effects on logits of contamination
summary(model2)

dotplot(coef(model2)[1:9], xlab='Log odds of contamination')

tce$land.use3 <- factor(ifelse(tce$land.use2 %in% c('inst', 'recr', 'resL', 'resM', 'trans'), 'mixed', as.character(tce$land.use2)))
tce

model3<- glm(cbind(y,n-y) ~ land.use3 + sewer-1, data=tce, family=binomial)
summary(model3)

sapply(list(model2, model3), AIC)
sapply(list(model2, model3), logLik)
anova(model2, model3, test='Chisq')

summary(model3)$coefficients

tce$land.use4 <- factor(ifelse(tce$land.use3 %in% c('resH','comm','indus'), 'high.use', as.character(tce$land.use3)))
tce


model4 <- glm(cbind(y,n-y) ~ land.use4 + sewer-1, data=tce, family=binomial)
summary(model4)

sapply(list(model2, model3, model4), AIC)

anova( model3, model4, test='Chisq') 

model4<- glm(cbind(y,n-y) ~ land.use4 + sewer, data=tce, family=binomial)
summary(model4)

model5 <- glm(cbind(y,n-y) ~ land.use4*sewer, data=tce, family=binomial)
summary(model5)

anova(model4, model5, test='Chisq')

sapply(list(model4, model5), AIC)

model4$deviance/model4$df.residual

model6<- glm(cbind(y,n-y)~land.use4 + sewer, data=tce, family=quasibinomial)
summary(model6)

model7 <- glm(cbind(y,n-y) ~ land.use4 + sewer + nitrate, data=tce, family=binomial)
summary(model7)
model8<- glm(cbind(y,n-y) ~ land.use4 + sewer + chloride, data=tce, family=binomial)
summary(model8)
model9<- glm(cbind(y,n-y) ~ land.use4 + sewer + chloride + nitrate, data=tce, family=binomial)
summary(model9)

sapply(list(model4, model7, model8, model9), AIC)

anova(model4, model7, test='Chisq')

model7$deviance/model7$df.residual

model10<- glm(cbind(y,n-y)~land.use4 + sewer + nitrate, data=tce, family=quasibinomial)
summary(model10)

## Diagnositc
#deviance residuals
residuals(model7) 
#standardized  deviance residuals
dev_res=rstandard(model7) 
#Pearson’s residuals
residuals(model7, type="pearson")
#standardized  Pearson’s residuals
pearson_res=rstandard(model7, type="pearson")


plot(dev_res~model7$fitted)
plot(pearson_res~model7$fitted)
plot(dev_res~nitrate, data=tce)
plot(pearson_res~nitrate, data=tce)
n=dim(tce)[1]
index=seq(1:n)
plot(dev_res~index)
plot((pearson_res~index)
     #Q-Q plot
     plot(model7, which=c(2))
     dfbetas=dfbetas(model7)
     dffits=dffits(model7)
     cooks=cooks.distance(model7)
     cbind(dfbetas,dffits,cooks)
     par(mfrow=c(1,2)) 
     plot(dffits~index)
     plot(model7, which=c(4))
     
     ##Prediction
     #predicted logits
     predict(model7)
     
     #fitted probabilities
     fitted(model7)
     
     #expected counts under model
     expected_y <- fitted(model7)*tce$n
     expected_y
     
     #re-tabulate variables 
     observed<- xtabs(cbind(y,n-y) ~ land.use4 + sewer, data=tce)
     observed
     expected <- xtabs(cbind(expected_y ,n-expected_y ) ~ land.use4 + sewer, data=tce)
     expected
     
     
     write.table(tce,"E:/数据分析和统计软件/Lecture 5 上机数据/TCE2.csv",row.name=FALSE,sep=',')
     
     
     