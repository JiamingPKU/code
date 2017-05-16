*-------------------------------------------------------
* project
* dofile name
* date, version
* Ren Qingjie, Peking University, renqingjie@pku.edu.cn
*-------------------------------------------------------

*-------------------------------------------------------
* Program Setup
*-------------------------------------------------------

version 14              // Set Version number for backward compatibility
set more off            // Disable partitioned output
clear all               // Start with a clean slate
set linesize 80         // Line size limit to make output more readable
set matsize 5000		// Set Workspace 
						// Set Work Directory
global root "F:\git\stata"
cap noi mkdir ${root}\output
global output = "${root}\output\"

cd ${output}
local D = c(current_date)
global D = subinstr("`D'"," ","",.)
cap noi mkdir "$D"
global today = "${output}\${D}"
cd $today

macro drop _all         // clear all macros
capture log close       // Close existing log files
log using logfile.txt, replace       // Open log file
* -------------------------------------------------------
use "F:\data\pf\traffic.dta",clear
rename perincK perinck


*设置个体和时间
tsset state year //平衡性很好

*描述数据
describe //得到每个变量的所有观测值的描述统计
xtdescribe //面板结构：56*7

version 13
line beertax year
xtline beertax year
xtline beertax


*OLS估计
reg fatal beertax spircons unrate perinck
*固定效应
xtreg fatal beertax spircons unrate perinck, fe
*随机效应（默认）
xtreg fatal beertax spircons unrate perinck, re


**Hausman test
qui xtreg fatal beertax spircons unrate perinck, fe
qui est store fixed
qui xtreg fatal beertax spircons unrate perinck, re
qui est store random
hausman fixed random
**如果从大样本中抽样，如人群家庭等，则固定效应也具有RE的特征；但是如果省份，则有差别。

* 汇报每个州的固定效应
* xi可省，如果存在交互项则必须
reg fatal beertax spircons unrate perinck i.state
xi: reg fatal beertax spircons unrate perinck i.state

* -------------------------------------------------------
* 非平衡数据

use "F:\data\pf\nlswork.dta", clear
tsset idcode year

xtdescribe,  patterns(9)


* -------------------------------------------------------
* 其他问题

* 聚类稳健的标准差
use "F:\data\pf\traffic.dta",clear
rename perincK perinck
xtset state year
reg fatal beertax spircons unrate perinck,vce(cluster state)   
xtreg fatal beertax spircons unrate perinck,fe vce(cluster state)   
xtreg fatal beertax spircons unrate perinck,re vce(cluster state)   

*MLE估计
xtreg fatal beertax spircons unrate perinck, mle   

*双向固定效应
tab year, gen(yr)
xtreg fatal beertax spircons unrate perinck yr*,fe


*异方差、序列相关和截面相关
xttest2   //横截面的相关性
xttest3   //组间异方差
xtserial  //个体时间相关


*结果输出
qui reg fatal beertax spircons unrate perinck
est store a1
qui xtreg fatal beertax spircons unrate perinck, fe
est store a2
qui xtreg fatal beertax spircons unrate perinck, re
est store a3
qui reg fatal beertax spircons unrate perinck,vce(cluster state)
est store a4
outreg2 a* using output.xls  
qui xtreg fatal beertax spircons unrate perinck,fe vce(cluster state)   
qui xtreg fatal beertax spircons unrate perinck,re vce(cluster state)




/*
* -------------------------------------------------------
// Close the log, end the file
log close
exit
