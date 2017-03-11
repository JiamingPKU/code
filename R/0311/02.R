###### Data Structure in R #####


## vector
a<-c(1,2,3,4)
b<-c("one","two","three","four")
c<-c(TRUE, TRUE, FALSE)
a
d<-c(a=1,b=2,c=3)
names(d);d[1];d["a"];
## list
a <- list(1,2,"a",TRUE)
a[1];a[-1];a[0];a[10];  
b <- list(list(list())) #list can be recursive
## array

## list

## factor
a <- factor(c("x","y","y","x"))
levels(a);
## matrix

## data frame