###############Example1##################
##Read the data into R
ls()
rm(list=ls())
ls()
Example1=read.csv("0309\\data\\Example1.csv", header=T, sep=',')
setwd("0309\\data")
Example1=read.csv("Example1.csv", header=T, sep=',')
Example1
names(Example1)

names##Explore the data
summary(Example1)

cor(Example1)
plot(TV_sales~Working_month, data=Example1)

##Model specification and estimation
lm1=lm(TV_sales~Working_month,data=Example1)
summary(lm1)
names(lm1)
lm1$coefficients

##Checking the adequacy of the model
###Check for linearity
standresid=rstandard(lm1)
#par(mfrow=c(2,2))
par(mfrow=c(2,2))
plot(standresid~Working_month, data=Example1, main="check for the linearity")
#it seems that the resid is a 
##Refit the model
Working_month2=Example1$Working_month^2
lm2=lm(TV_sales~Working_month+Working_month2,data=Example1)
summary(lm2)
anova(lm1,lm2) #2 models are different

##Checking the adequacy of the new model
standresid=rstandard(lm2)
###Check for Constant Error Variance
plot(standresid~lm2$fitted, data=Example1, main="New Model:Constant Error Variance")
###install.packages("car")
library(car)
ncvTest(lm2) #Breusch-Pagan test


###Check for linearity
plot(standresid~Working_month, data=Example1, main="New Model: Check for linearity")



###Check for Independence of Errors
n=dim(Example1)[1]
index=seq(1:n)
plot(standresid~index, main="Check for Independence of Errors")
###install.packages("TSA")
library(TSA)
library(car)
durbinWatsonTest(lm2) #p-value is generate by a random series, so it may change every time
library(lmtest)
dwtest(lm2)
###Check for normality
qqPlot(lm2,main="QQ Plot")

###Check for Influential Observations
dfbetas=dfbetas(lm2) 
dffits=dffits(lm2)
cooks=cooks.distance(lm2)
cbind(dfbetas,dffits,cooks)
dfbetasPlots(lm2)
par(mfrow=c(1,2)) 
plot(dffits~index)
plot(lm2, which=c(4))


###############Example2##################
##Read the data into R
Example2=read.csv("Example2.csv", header=T, sep=',')
Example2

##Explore the data
summary(Example2)
cor(Example2)
plot(Carbohydrate~Age, data=Example2)
plot(Carbohydrate~Weight, data=Example2)
plot(Carbohydrate~Protein, data=Example2)
pairs(Example2)

##Model specification and estimation
lm1=lm(Carbohydrate~Age+Weight+Protein,data=Example2)
summary(lm1) # Age is unremarkable
##Refit the model
lm2=lm(Carbohydrate~Weight+Protein,data=Example2)
summary(lm2)
anova(lm2,lm1)

##Checking the adequacy of the new model

###Check for Constant Error Variance
standresid=rstandard(lm2) 
plot(standresid~lm2$fitted, data=Example2)
ncvTest(lm1)

###Check for linearity
par(mfrow=c(1,2))
plot(standresid~Weight, data=Example2)
plot(standresid~Protein, data=Example2)


###Check for Independence of Errors
n=dim(Example2)[1]
index=seq(1:n)
plot(standresid~index)

durbinWatsonTest(lm1)

###Check for normality
qqPlot(lm2,main="QQ Plot")

###Check for Influential Observations

dfbetas=dfbetas(lm2)
dffits=dffits(lm2)
cooks=cooks.distance(lm2)
cbind(dfbetas,dffits,cooks)

dfbetasPlots(lm2)
par(mfrow=c(1,2)) 
plot(dffits~index)
plot(lm2, which=c(4))


###Check for Multicollinearity
library(car)
round(vif(lm2),2)



###############Example3##################
##Read the data into R
Example3=read.csv("Example3.csv", header=T, sep=',')
Example3
names(Example3)

##Explore the data
summary(Example3)
cor(Example3)
par(mfrow=c(2,3))
plot(Survival_time~Blood_clotting_score, data=Example3)
plot(Survival_time~Prognostic_index, data=Example3)
plot(Survival_time~Enzyme_function_score, data=Example3)
plot(Survival_time~Liver_function_score, data=Example3)
plot(Survival_time~Age, data=Example3)


##Model specification and estimation
lm1=lm(Survival_time~.,data=Example3)
summary(lm1)
###Check for Constant Error Variance
standresid=rstandard(lm1) 
plot(standresid~lm1$fitted, data=Example3)
####ncvTest(lm1)###Need to add

##Transformation and Refit the model
ln_survival_time=log(Example3$Survival_time)
lm2=lm(ln_survival_time~Blood_clotting_score+Prognostic_index+Enzyme_function_score+Liver_function_score+Age+Gender,data=Example3)
summary(lm2)

##Checking the adequacy of the new model
###Check for Constant Error Variance
standresid=rstandard(lm2) 
plot(standresid~lm2$fitted, data=Example3)
ncvTest(lm2)

###Check for linearity
par(mfrow=c(2,3))
plot(standresid~Blood_clotting_score, data=Example3)
plot(standresid~Prognostic_index, data=Example3)
plot(standresid~Enzyme_function_score, data=Example3)
plot(standresid~Liver_function_score, data=Example3)
plot(standresid~Age, data=Example3)

###Check for Independence of Errors
n=dim(Example3)[1]
index=seq(1:n)
plot(standresid~index)

durbinWatsonTest(lm1)

###Check for normality
qqPlot(lm2,main="QQ Plot")

###Check for Influential Observations
dfbetas=dfbetas(lm2)
dffits=dffits(lm2)
cooks=cooks.distance(lm2)
cbind(dfbetas,dffits,cooks)
 
plot(lm1, which=c(4))

###Check for Multicollinearity
library(car)
round(vif(lm2),2)

dfbetasPlots(lm2)
par(mfrow=c(1,2)) 
plot(dffits~index)
plot(lm2, which=c(4))


###############Example4##################
##Read the data into R
Example4=read.csv("Example4.csv", header=T, sep=',')
Example4
names(Example4)

attach(Example4)
tapply(Weight,Factory, mean)
tapply(Weight,Factory, sd)

##Model specification and estimation
lm1=aov(Weight ~ as.factor(Factory), data=Example4)
summary(lm1)

##Checking the adequacy of the new model

standresid=rstandard(lm1) 
###Check for Constant Error Variance
plot(standresid~lm1$fitted, data=Example4)
lm2=lm(Weight ~ Factory, data=Example4)
ncvTest(lm2)

###Check for Independence of Errors
n=dim(Example4)[1]
index=seq(1:n)
plot(standresid~index)

durbinWatsonTest(lm1)

###Check for normality
qqPlot(lm1,main="QQ Plot")
#there are many functions in r to do normalTest

###Check for Influential Observations
dffits=dffits(lm1)
dfbetas=dfbetas(lm1)
cooks=cooks.distance(lm1)
cbind(dffits,dfbetas,cooks)

dfbetasPlots(lm1)
par(mfrow=c(1,2)) 
plot(dffits~index)
plot(lm1, which=c(4))

##Multiple comparisons
 

pairwise.t.test(Weight, Factory, p.adj = "none", data=Example4)
pairwise.t.test(Weight, Factory, p.adj = "bonf", data=Example4)
TukeyHSD(lm1)


###############Practice1##################
##Read the data into R
Practice1=read.csv("Practice1.csv", header=T, sep=',')
Practice1
names(Practice1)

##Explore the data
summary(Practice1)
cor(Practice1)
plot(Memory_score~Play_length,col =Version, data=Practice1)
mtext("Version 1",line=1,col=1)
mtext("Version 2",line=2,col=2)

##Model specification and estimation
lm1=lm(Memory_score~Play_length+as.factor(Version),data=Practice1)
summary(lm1)
Version2=Practice1$Version-1
lm1=lm(Memory_score~Play_length+Version2,data=Practice1)
summary(lm1)
Inter=Practice1$Play_length*Version2
lm2=lm(Memory_score~Play_length+Version2+Inter,data=Practice1)
summary(lm2)
anova(lm1,lm2)

##Checking the adequacy of the new model
###Check for linearity
standresid=rstandard(lm1) 
plot(standresid~Play_length, data=Practice1)

###Check for Constant Error Variance
plot(standresid~lm1$fitted, data=Practice1)
ncvTest(lm1)

###Check for Independence of Errors
durbinWatsonTest(lm1)

###Check for normality
qqPlot(lm1,main="QQ Plot")

###Check for Influential Observations
dffits(lm1)
dfbetas(lm1)
dfbetasPlots(lm1)
cooks=cooks.distance(lm1) 
plot(lm2, which=c(4))


###############Practice2##################
#Read the data into R
Practice2=read.csv("Practice2.csv", header=T, sep=',')
Practice2
names(Practice2)

##Explore the data
summary(Practice2)
cor(Practice2)
plot( Num_of_tourists~Yesterday_Num_of_visitors,col = (Weekend+1), data=Practice2)
mtext("Not Weekend",line=1,col=1)
mtext("Weekend",line=2,col=2)

plot( Num_of_tourists~Yesterday_Num_of_visitors,col = (Sunny+3), data=Practice2)
mtext("Not Sunny",line=1,col=3)
mtext("Sunny",line=2,col=4)


##Model specification and estimation
lm1=lm(Num_of_tourists~Yesterday_Num_of_visitors+Weekend+Sunny,data=Practice2)
summary(lm1)

##Checking the adequacy of the model
###Check for linearity
standresid=rstandard(lm1) 
par(mfrow=c(2,2))
plot(standresid~Yesterday_Num_of_visitors, data=Practice2)

###Check for Constant Error Variance
plot(standresid~lm1$fitted, data=Practice2)
ncvTest(lm1)

###Check for Independence of Errors
durbinWatsonTest(lm2)

###Check for normality
qqPlot(lm1,main="QQ Plot")

###Check for Influential Observations
dfbetas(lm1)
dfbetasPlots(lm1)
cooks=cooks.distance(lm1) 
plot(lm1, which=c(4))