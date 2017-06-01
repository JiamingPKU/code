*-------------------------------------------------------
* project: 财政学研究方法，学期论文
* dofile name: pf01.do
* May31st, 2017, Version 0.
* Ren Qingjie, Peking University, renqingjie@pku.edu.cn
*-------------------------------------------------------

*-------------------------------------------------------
* Program Setup
*-------------------------------------------------------

version 14              // Set Version number for backward compatibility
set more off            // Disable partitioned output
clear all               // Start with a clean slate
set linesize 80         // Line size limit to make output more readable
*set matsize 5000		// Set Workspace 
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

/*
macro drop _all         // clear all macros
capture log close       // Close existing log files
log using logfile.txt, replace       // Open log file
* -------------------------------------------------------
*/




****** 清理数据

*** 处理地区编码
** 导入地区编码的数据
clear
cd "F:\data\pf\统一的编码文件"
unicode analyze citycode_0.dta
unicode encoding set gb18030
unicode translate citycode_0.dta
** 导入数据
cd $today
use "F:\data\pf\统一的编码文件\citycode_0.dta", clear
* 删除重复项，包括“县”，“市辖区”等
duplicates drop city1, force
rename city city_shortname
rename city1 city
save newcitycode.dta, replace


****** 导入数据

*** 数据编码方式修改
clear
cd "F:\data\pf\"
unicode analyze city_quyu.dta
unicode encoding set gb18030
unicode translate city_quyu.dta
*** 导入数据
cd $today
use "F:\data\pf\city_quyu.dta", clear

*** 处理原数据
* 将城市名称统一
replace city=ustrregexs(1) if ustrregexm(city,"^.*?([\u4e00-\u9fa5]+).*$")
* 重命名变量名 (非常长，大约100行)
rename q1_1		land			//土地面积
rename q1_3		pop				//年底总人口
rename q1_3_1	pop_male		//男
rename q1_3_2	pop_female		//女
rename q1_3_3	pop_birth		//出生人口
rename q1_3_4	pop_death		//死亡人口
rename q1_4		family			//年底总户数
rename q2_1		gdp				//地区生产总值
rename q2_2		gdp_pri			//第一产业地区生产总值
rename q2_3		gdp_sec			//第二产业地区生产总值
rename q2_4		gdp_ind			//工业生产总值
rename q2_5		gdp_thi			//第三产业地区生产总值
rename q2_6		gdp_per			//人均地区生产总值
rename q3_1 	gdp_index		//地区生产总值指数
rename q3_2		gdp_index_pri	//第一产业地区生产总值指数
rename q3_3 	gdp_index_sec
rename q3_4		gdp_index_ind
rename q3_5		gdp_index_thi
rename q3_6		gdp_index_per
rename q4_0		investment				//全社会固定资产投资
rename q4_1		investment_urban 		//不含农户
rename q4_2		investment_realestate	//房地产开发投资
rename q4_2_1	investment_rural		//农村投资
rename q6_1		fisrev					//公共预算收入
rename q6_2		fisrev_tax				//税收收入
rename q6_3		fisrev_tax_vat			//增值税
rename q6_4		fisrev_tax_op			//营业税
rename q6_5		fisrev_tax_firm			//企业所得税
rename q6_6		fisrev_tax_person		//个人所得税
rename q7_1		fisexp					//公共财政预算支出
rename q7_2		fisexp_edu				//教育
rename q7_3 	fisexp_security			//社会保障和就业
rename q8_1		income_rural			//农村居民人均可支配收入
rename q8_2		expend_rural			//农村居民人均消费支出
rename q8_3		expend_rural_food		//食品支出
rename q8_4		income_urban			//城镇居民人均可支配收入
rename q8_5		expend_urban			//城镇居民人均消费支出
rename q8_6		expend_urban_food		//食品支出
rename q9_1		num_ind					//规模以上工业企业单位数
rename q9_1_1	num_ind_large			//大型企业数量
rename q9_1_2	num_ind_medium			//中型企业
rename q9_1_3	num_ind_small			//小型企业
rename q9_0		output_ind				//工业总产值
rename q9_0_4_2	output_ind_state		//国有及国有控股
rename q9_0_5	output_ind_domestic		//内资企业
rename q9_0_6	output_ind_hmt		//港澳台投资企业
rename q9_0_7	output_ind_frn		//外商投资企业
rename q9_2_1	inc_ind				//工业企业增加值
rename q9_2_2	index_inc_ind		//工业企业增加值指数
rename q9_2		asset				//资产合计
rename q9_3		debt				//负债合计
rename q9_5		revenue				//主营业务收入
rename q9_7		profit				//利润总额
rename q10_1	miles				//公路里程
rename q10_2	miles_grade			//等级公路
rename q10_3	veh_civil			//民用汽车
rename q10_4	veh_private			//私人汽车
rename q11_0	post_telecom		//邮电业务总量
rename q11_2	telecom				//电信业务总量
rename q11_3	landline			//固定电话用户
rename q11_4	mobile				//移动电话用户
rename q5_1		im_ex_port			//货物进出口总额
rename q5_2		import				//进口额
rename q5_3		export				//出口额
rename q5_4		fdi					//外商直接投资实际使用额
rename q12_2	savings				//金融机构人民币存款
rename q12_2_3	savings_firm		//企业存款
rename q12_2_4	savings_resident	//居民储蓄存款
rename q12_2_5	savings_fixed		//定期存款
rename q12_5	loan				//金融机构人民币贷款
rename q12_5_2	loan_ind			//工业贷款
rename q12_5_3	loan_busi			//商业贷款
rename q12_5_4	loan_agri			//农业贷款
rename q7_5		fisexp_agri			//农林水利事务财政支出
rename q7_4		fisexp_health		//医疗卫生
rename q8_7		house_rural			//农村人均住房面积
rename q9_1_5	num_ind_dom			//内资企业个数
rename q9_1_6	num_ind_hmt			//港澳台投资企业个数
rename q9_1_7	num_ind_frn			//外商投资企业
rename q9_0_3	output_ind_large	//大型企业工业总产值
rename q9_0_4	output_ind_medium	//中型企业工业总产值
rename q9_0_4_1 output_ind_small	//小型企业工业总产值
rename q9_4		total_equity		//所有者权益
rename q9_8		total_vat			//本年应交增值税
rename q9_9		num_employee		//从业人员年平均人数
rename q11_5	internet			//互联网宽带接入用户数
rename q1_2		pop_per				//常住人口
rename q9_0_1	output_ind_light	//轻工业
rename q9_0_2	output_ind_heavy	//重工业
rename q12_1	savings_rmbfrn		//金融机构本外币存款
rename q12_2_6	savings_cur			//活期存款
rename q12_4	loan_rmbfrn			//金融机构本外币贷款
rename q12_6	loan_short			//短期贷款
rename q12_7	loan_long			//中长期贷款
rename q12_7_1	loan_frn			//境外贷款
rename q4_3		comhouse_sales		//商品房销售额
rename q4_4		house_sales			//住宅销售额
rename q4_5		comhouse_sales_area	//商品房销售面积
rename q4_6		house_sales_area	//住宅销售面积
rename q8_8		house_area_urban	//城市人均住房面积
rename q11_1	post				//邮电业务总量
rename q12_2_1	savings_danwei		//单位存款
rename q12_2_2	savings_geren		//个人存款
rename q12_3	savings_deposit		//储蓄存款
rename q7_6		house_security		//住房保障
rename q9_6		cost				//主营业务成本  //终于结束了$-$

* 转字符型变量为数值型
foreach var of varlist pop-cost{
	destring `var', replace force
}

* 和地区编码合并，便于进一步处理数据（比如施加省份的固定效应）
merge m:1 city using newcitycode.dta

*** 处理成为平衡面板
drop if city=="其他"
encode city, gen(cit)
tsset cit year
xtbalance, range(2006 2013)
drop _merge


*** 区分为省级数据和市级的数据，删去县（区）级的数据
* 保存省级数据
preserve 
keep if level == 1
save province.dta, replace
restore
* 保存市级数据
keep if level == 2
save city.dta, replace




* svvarlbl test.txt, replace  //生成变量名和标签


****** 模型建立和模型识别
****** 生成相关变量
tsset pref year
xtdes

* 政府规模
gen govsize	= fisexp / gdp
* 开放程度
gen	open = im_ex_port /10000/gdp
* 描述统计
by year, sort: sum govsize open
xtsum govsize open



* pooled 估计
reg govsize open
* by year 估计
by year, sort: reg govsize open
* 面板估计
xtreg govsize open, fe vce(cluster prov)
xtreg govsize open, re vce(cluster prov)
* hansman test
* 时间虚拟变量显著性检验 

* 组间异方差问题 xttest3
* 序列自相关检验 xtserial

***随机效应的FGLS估计
xtgls govsize open, i(code) t(year) panels(hetero) corr(ar1) force
xtgls govsize open, i(code) t(year) panels(hetero) corr(psar1) force






/*
by year, sort: sum fisrev fisrev_tax fisexp fisexp_edu gdp
第一组基本是平衡的
by year, sort: sum output_ind im_ex_port loan num_ind_frn num_ind_hmt q12_5_1
第二组只有im_ex_port相对平衡，其它的都有缺失，集中在2007年。
*/

*** 平稳性检验
*** 协整关系建立
*** 格兰杰因果检验


/*
* -------------------------------------------------------
// Close the log, end the file

log close
exit
