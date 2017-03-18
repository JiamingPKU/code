getwd()

galton = read.csv("F:\\data\\Galton.csv")

summary(galton)
p=ggplot(aes(x="Height",y="Father"),data=galton)
p+geom_point()

attach(galton)

galton$Gender <- factor(Gender)
galton$Family <- factor(Family)


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
qqPlot(reg1)


dfbetaPlots(reg1)

?dfbetaPlots

h <- predict(reg1)
plot(h,Height)


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


anova(reg1,reg2)
AIC(reg1,reg2)
BIC(reg1,reg2)

### third model
reg3 <- lm(Height~ Father + Father * Gender +Mother + Mother*Gender)
AIC(reg1,reg2,reg3)
BIC(reg1,reg2,reg3)
anova(reg1,reg2, reg3)




