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

import excel using "F:\data\ts\fund\fund.xlsx", clear

replace B = "长安鑫利" in 1
replace C = "华夏大盘" in 1
replace D = "工银瑞信国企" in 1
label var A `=A[1]'
label var B `=B[1]'
label var C `=C[1]'
label var D `=D[1]'

drop in 1
destring B, replace
destring C, replace
destring D, replace

runtest B
gen t = _n
tsset t
gen b = d.B/ l.B
gen c = d.C/ l.C
gen d = d.D/ l.D
gen lB = log(B)
gen lC = log(C)
gen lD = log(D)
gen lb = d.lB
gen lc = d.lC
gen ld = d.lD

wntestq b
wntestq c
wntestq d
wntestq lb
wntestq lc
wntestq ld

runtest b

/*
* -------------------------------------------------------
// Close the log, end the file
log close
exit
