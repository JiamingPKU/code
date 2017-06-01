//任庆杰
//1400015500


//加上城市编码
clear
set more off


use city_2012_temp, clear //每个同学应该打开的是自己整理好的每个年份的文件
generate city2=cityname
***生成序号，merge之后按照master文件观测值的顺序进行排序


rename city2 city2
label var city2 "原始年鉴文件中的城市名称"
generate city=substr(city2, 1,6)
label var city "城市名称的前两个汉字"

replace city="吉林市" if  city2=="吉林市"
replace city="河北区" if  city2=="河北区"
replace city="海南藏族自治州" if city2=="海南藏族自治州"
replace city="大兴安岭地区" if city2=="大兴安岭地区"
replace city="天津滨海高新区" if city2=="天津滨海高新区"
replace city="天津港保税区" if city2=="天津港保税区"
replace city="天津经济技术开发区" if city2=="天津经济技术开发区"
replace city="张家口" if city2=="张家口市"
replace city="张家界" if city2=="张家界市"
replace city="大兴安岭地区" if city2=="大兴安岭地区"
replace city="阿拉山口" if city2=="阿拉山口市" 
replace city="阿拉尔" if city2=="阿拉尔市" 
replace city="乌兰察布" if city2=="乌兰察布市" 
replace city="乌兰浩特" if city2=="乌兰浩特市" 
replace city="北京经济技术开发区" if city2=="北京经济技术开发区"
replace city="朝阳区" if city2=="朝阳区"  
***首先，把省份代码merge进来
merge 1:1 city using prov 

drop if _m==2
drop _m

***给每个地区添加省份代码
destring n,replace
sort n


replace prov=prov[_n-1] if prov==.
generate city1 = city
replace city1=city1[_n-1] if city1==""
/*
***把第二个出现的吉林的level设置为地级市2，利用吉林市的前后省份编码一样
replace level=2 if prov[_n]==prov[_n-1] & city2=="吉林"
replace code=. if prov[_n]==prov[_n-1] & city2=="吉林"
replace city="吉林省" if level==1 & city2=="吉林"
replace city="吉林市" if level==2 & city2=="吉林"

*/
***接下来，把地级市代码merge进来，把省份信息加入匹配条件
merge 1:1 city prov using pref, update

drop if _m==2
drop _m

***最后，把县级市代码merge进来，把省份信息和地级市信息加入匹配条件
merge 1:1 city prov using citycode, update

drop if _m==2
drop _m

br if code==.


****************************************************************************
*下述地区的没有添加上行政代码
*北宁*超大城市*大城市*东部地区*毫州*华莹*胶南*潞西*满州里*米泉*特大城市*铁法*通什*西部地区*襄樊*小城市*翼州*中部地区*中等城市
*分析原因：上网搜索
**改名+错别字+行政撤销+using的行政代码文件缺失（为保证前两个字的地名不重复，删除了个别地区）
*行政代码的原始文件请参阅citycode_0
*****************************************************************************
*****以下部分手动更正部分是同学们工作的重点*******
********************************************************

***错别字
replace city="亳州" if city2=="毫州"
replace city="冀州" if city2=="翼州"
replace city="华蓥" if city2=="华莹"
replace city="巴彦" if city=="巴彥"

***改名
replace city="北镇" if city2=="北宁"
replace city="襄阳" if city2=="襄樊市"
replace city="芒市" if city2=="潞西"
replace city="调兵" if city2=="铁法" //2002年建市20周年的铁法市经国务院批准更名为调兵山市
replace city="五指" if city2=="通什" //改名为五指山市
replace city="呼伦" if city2=="满州里" //应为满洲里，后改为呼伦贝尔市
replace city="朝阳" if city2=="朝阳区"
replace city="海南" if city2=="海南藏族自治州"
replace city="张家" if city2=="张家口市"
replace city="张家" if city2=="张家界市"
replace city="河北" if city2=="河北区"
replace city="大兴" if city2=="大兴安岭地区"



***已撤销，原来代码可网上搜索
replace code=370284 if city=="胶南" 
replace code=652303 if city=="米泉" 
replace code=500110 if city=="万盛"
replace code=110104 if city=="宣武"
replace code=110103 if city=="崇文"
replace code=120107 if city=="塘沽"
replace code=120108 if city=="汉沽"
replace code=310103 if city=="卢湾"
replace code=500111 if city=="双桥"
replace code=610403 if city=="杨凌"
replace code=120109 if city=="大港"
replace code=650091 if city=="生产"


***再进行地级市和县级市的merge
merge 1:1 city prov using pref, update
drop if _m==2
drop _m

merge 1:1 city prov using citycode, update
drop if _m==2
drop _m

br if code==.


order n city city1 city2 code pro prov pref

save city_2012_final, replace




use city_2012_final.dta, clear


drop n
drop city
drop city1
drop city2
drop pro
drop prov
drop pref
rename cityname region
rename cityname_en region_en
rename v3_1 area
rename v4_1 pop_per
rename v5_1 pop
rename v6_1 pop_male
rename v7_1 pop_female
rename v8_1 pop_birth
rename v9_1 pop_death
rename v10_1 households
rename v3_2 gdp
rename v4_2 gdp_pri
rename v5_2 gdp_sec
rename v6_2 gdp_ind
rename v7_2 gdp_tert
rename v8_2 pcgdp
rename v3_3 gdp_index
rename v4_3 gdp_index_pri
rename v5_3 gdp_index_sec
rename v6_3 gdp_index_ind
rename v7_3 gdp_index_tert
rename v8_3 pcgdp_index
rename v3_4 employ
rename v4_4 employ_urban
rename v5_4 employ_soe
rename v6_4 employ_collective
rename v7_4 employ_private
//rename v8_4 城乡登记失业率
//rename v9_4 城镇单位就业人员平均工资
rename v10_4 wage_soe
rename v11_4 wage_collective
rename v3_5 investment
//rename v4_5 固定资产投资（不含农户）
rename v5_5 investment_realestate
rename v6_5 comhouse_sales
rename v7_5 house_sales
rename v8_5 comhouse_area
rename v9_5 house_area
rename v3_6 fisrev
rename v4_6 fisrev_tax
rename v5_6 fisrev_tax_va
rename v6_6 fisrev_tax_op
rename v7_6 fisrev_tax_firm
rename v8_6 fisrev_tax_person
rename v3_7 fisexp
rename v4_7 fisexp_edu
rename v5_7 fisexp_security
rename v6_7 fisexp_med
rename v7_7 fisexp_agri
rename v3_8 income_rural
rename v4_8 expend_rural
rename v5_8 expend_rural_food
rename v6_8 income_urban
rename v7_8 expend_urban
rename v8_8 expend_urban_food
rename v9_8 housing_area_rural
rename v10_8 housing_area_urban
rename v3_9 households_rural
rename v4_9 area_arable
rename v5_9 agri_power
rename v6_9 fertilizer
rename v7_9 electricity_rural
rename v8_9 area_irrigation
rename v9_9 area_sown
rename v10_9 crop_area
rename v3_10 yiled_grain
rename v4_10 yield_cotton
rename v5_10 yield_oil
rename v6_10 yield_vegetable
rename v7_10 yield_fruit
rename v8_10 yield_meat
rename v9_10 yield_dairy
rename v10_10 yield_eggs
rename v11_10 yield_aquatic
rename v3_11 ouput_ind
rename v4_11 output_ind_light
rename v5_11 output_ind_heavy
rename v6_11 output_ind_large
rename v7_11 output_ind_medium
rename v8_11 output_ind_domestic
rename v9_11 output_ind_hmt
rename v10_11 output_ind_frn
rename v3_12 total_asset
rename v4_12 total_debt
rename v5_12 total_equity
rename v6_12 total_revenue
rename v7_12 total_profit
rename v8_12 total_vatax
rename v9_12 num_ind
rename v10_12 employ_ind
rename v3_13 num_ind_construct
rename v4_13 employ_ind_construct
rename v5_13 output_ind_construct
rename v6_13 area_construct
rename v7_13 area_finish
rename v3_14 mileage
rename v4_14 mileage_express
rename v5_14 num_car
rename v6_14 num_car_private
rename v3_15 post_telecom
//rename v4_15 "post"
rename v5_15 telecom
rename v6_15 landline
rename v7_15 mobile
rename v8_15 internet
rename v3_16 comsumption
rename v4_16 num_wholesale_retail
rename v5_16 wholesale_retail_employ
rename v6_16 wholesale_retail
rename v7_16 hotel_cater_firm
rename v8_16 hotel_cater_employ
rename v9_16 hotel_cater
rename v3_17 im_ex_port
//rename v4_17 "import"
//rename v5_17 "export"
rename v6_17 fdi
rename v3_18 tourist
rename v4_18 tourist_frn
rename v5_18 tourism_frn_exchange
rename v6_18 tourist_domestic
rename v7_18 tourism_domestic_revenue
rename v8_18 starhotels
rename v3_19 savings_rmbfrc
rename v4_19 savings
rename v5_19 loan_rmbfrn
rename v6_19 loan
rename v7_19 loan_domestic
rename v8_19 savings_short
rename v9_19 savings_long
rename v10_19 loan_overseas
rename v3_20 kindergarten
rename v4_20 kindergarten_student
rename v5_20 prischool
rename v6_20 prischool_teacher
rename v7_20 prischool_matri
rename v8_20 prischool_student
rename v9_20 prischool_grad
rename v3_21 midschool
rename v4_21 midschool_teacher
rename v5_21 midschool_matri
rename v6_21 midschool_student
rename v7_21 midschool_grad
rename v3_22 univ
rename v4_22 univ_teacher
rename v5_22 univ_matri
rename v6_22 univ_student
rename v7_22 univ_grad
rename v8_22 library
rename v3_23 num_hygiene
rename v4_23 num_hospital
rename v5_23 bed_hygiene
rename v6_23 bed_hospital
rename v7_23 employ_hygiene
rename v8_23 employ_medperson
rename v9_23 employ_doctor
rename v10_23 employ_nurse

save city_2012_final, replace
