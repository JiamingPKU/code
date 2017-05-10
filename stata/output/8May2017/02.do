*-------------------------------------------------------
* project
* do* 全球化对地方政府规模的影响
* 01.do
* May 8th, 2017, Version 2
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

use "F:\data\pf\区域经济统计年鉴_final.dta", clear
codebook year
keep if year == 2014
codebook year
codebook gdp
codebook export
codebook import
codebook fdi

use "F:\data\pf\city_jianshe.dta", clear
save city.dta, replace
clear
unicode analyze city.dta
unicode encoding set gb18030
unicode translate city.dta
use city.dta, clear



* -------------------------------------------------------
// Close the log, end the file
log close
exit
