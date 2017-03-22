require(R2wd)
if (!require(rcom)) warning("Install rcom first")
wdGet(T)
wdNewDoc("f:\this.docx")
wdApplyTemplate("f:\this.docx")

wdTitle("Test of R2wd")
wdSection("Section1")
wdHeading(level=2,"Head 2")
wdBody("this is the body in the word")
wdBody("another body")

wdSection("Section2")
wdBody("newbody")
wdBody("Table using format")
wdTable(format(head(mtcars)))
wdBody("Table without using 'formart'")
wdTable(head(mtcars))

wdSection("Section 3")

ctl <- c(4.17,5.58,5.18,6.11,4.50,4.61,5.17,4.53,5.33,5.14)
trt <- c(4.81,4.17,4.41,3.59,5.87,3.83,6.03,4.89,4.32,4.69)
group <- gl(2,10,20, labels=c("Ctl","Trt"))
weight <- c(ctl, trt)

wdBody.anything <- function(output)
{
    a<-capture.output(output)
    for(i in seq_along(a))
    {
        wdBody(format(a[i]))
    }
}

temp <- summary(lm(weight~group))
wdBody.anything(temp)

wdSection("Section 4")
wdPlot("rnorm(100), plotfun=plot")