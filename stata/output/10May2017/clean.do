*-------------------------------------------------------
* PF Paper
* 清理数据
* May 10th, version1
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

*需要先进行转码
unicode analyze "F:\data\pf\city.dta"
unicode encoding set gb18030
unicode translate "F:\data\pf\city.dta"
use "F:\data\pf\city.dta", clear



/*
* -------------------------------------------------------
// Close the log, end the file
log close
exit
