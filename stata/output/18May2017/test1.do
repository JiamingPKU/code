*-------------------------------------------------------
* project 检查一个错误
* dofile name: test1.do
* May 18th, 2017, version1
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

*观测值1000， X为merge时参考的序列
clear
set obs 1000
gen x = _n
* 生成一个y1便于merge
gen y1 = x*2
label var x "编号"
save test1.dta, replace

clear
set obs 1000
gen x  = _n
gen y2 = runiform()
label var x "编号"
gen z2 = (y2>0.5)
label value z2 z2lb
label define z2lb 1 "gr" 0 "lr"
gen m = z2
label 
save test2.dta, replace

clear
set obs 1000
gen x  = _n
gen y3 = rnormal()
label var x "序号"
gen z3 = (y3>0)
label value z3 z3lb
label define z3lb 1 "gr" 0 "lr"
save test3.dta, replace

clear
set obs 1000
gen x  = _n
gen y4 = runiform()
gen z4 = (y4>0.5)
save test4.dta, replace


***测试Merge函数
**merge函数会使用merge1—file的标签，并不会发生冲突。
use test2.dta, clear
merge 1:1 x using test3.dta
drop _merge

merge 1:1 x using test4.dta
drop _merge


use test2.dta, clear
merge m:m x using test3.dta
drop _merge
/*
* -------------------------------------------------------
// Close the log, end the file
log close
exit
