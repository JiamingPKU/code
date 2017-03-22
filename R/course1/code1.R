## save the output into the file
sink(file="note1.txt")

getwd()
galton = read.csv("F:\\data\\Galton.csv") #read the data
summary(galton)

attach(galton) #to use the data easily afterwards

galton$Gender <- factor(Gender) # change Gender into DV
galton$Family <- factor(Family) # change Family into DV


### first model
reg1 <- lm(Height~Father+Mother+Gender) #Height = a + b_1*Father + b_2*Mother+ b_3*Gender+residual
summary(reg1)

reg1$coefficients

#Check for linearity
standresid=rstandard(reg1)
par(mfrow=c(1,3))
plot(standresid~Father)
plot(standresid~Mother)
plot(standresid~Gender)

#Breusch-Pagan test
library(car)
ncvTest(reg1)

#Check for Independence of Errors
par(mfrow=c(1,1))
n <- dim(galton)[1]
index=seq(1:n)
plot(standresid~index, main="Check for Independence of Errors")

#dwtest
durbinWatsonTest(reg1)

#Check for normality
require(car)
qqPlot(reg1)


dfbetaPlots(reg1) # so MESSY!


h <- predict(reg1) # get the predict value


### second model
reg2 <- lm(Height~ Father+Father*Gender + Mother + Mother*Gender +Gender)
summary(reg2)

reg2$coefficients

#Check for linearity
standresid=rstandard(reg2)
par(mfrow=c(1,3))
plot(standresid~Father)
plot(standresid~Mother)
plot(standresid~Gender)

#Breusch-Pagan test
library(car)
ncvTest(reg2)

#Check for Independence of Errors
par(mfrow=c(1,1))
n <- dim(galton)[1]
index=seq(1:n)
plot(standresid~index, main="Check for Independence of Errors")

#dwtest
durbinWatsonTest(reg2)

#Check for normality
qqPlot(reg2)


### model comparason
anova(reg1,reg2)
AIC(reg1,reg2)
BIC(reg1,reg2)
# all the 3 results show that Model 1 is better


### third model
reg3 <- lm(Height~ Father + Father * Gender +Mother + Mother*Gender)
AIC(reg1,reg2,reg3)
BIC(reg1,reg2,reg3)
anova(reg1,reg2, reg3)
# well, Model 1 seems to be the best


sink() #close the file

