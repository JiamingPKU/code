*-------------------------------------------------------
* 全球化对地方政府规模的影响
* 01.do
* May 7th, 2017, Version 1
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
*import delimited using "F:\data\pf\paper\pf1.csv", clear
use "F:\data\pf\区域经济统计年鉴_final.dta", clear

codebook code
codebook year
codebook gdp
codebook export
codebook import
codebook fdi

* -------------------------------------------------------
// Close the log, end the file
log close
exit
