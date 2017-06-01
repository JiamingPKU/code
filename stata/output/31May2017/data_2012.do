//任庆杰
//1400015500

//合并表格2012

forvalues i = 1/23{
	import excel using "test\2012-`i'.xlsx",clear allstring
	
	rename * v#_`i', addnumber
	
	
	gen n = _n if `i'==1
	tostring n, replace
	
	

	*调整一些特殊的观测（根据merge的assertion结果来写）
	replace v1_`i'="奉贤区" if v1_`i'=="奉贤1区"
	replace v1_`i'="宿州市" if v1_`i'=="亳州市" & v2_`i'=="Suzhou City"
	replace v1_`i'="阿里地区" if v1_`i'=="阿里地1区"	
	replace v1_`i'="德州市" if v1_`i'=="惠州市" & v2_`i'=="Dezhou City"
	
	
	*去除数据中的特殊符号
	foreach var of varlist * {
		replace `var'=subinstr(`var'," ","",.) //空格
		//replace `var'=subinstr(`var',"　","",.) //中文全角空格
		//replace `var' = `var'[1]+`var'[2] in 1
	}	

	
	*添加城市名称的变量名及标签
	rename v1_`i' cityname 
	label var cityname "区域名称"
	ren v2_`i' cityname_en
	label var cityname_en "区域名称(英文)"

	*去掉表头及空行
	drop if ustrregexm(cityname,"^.*([0-9]|[a-zA-Z])+.*$")
	drop if cityname==""
	drop if cityname=="`=cityname[1]'" & _n!=1
	drop if cityname=="其他"



	*去掉所有城市名称中的非中文字符
	replace cityname=ustrregexra(cityname,"[^\u4e00-\u9fa5]+","")

	*更正城市名称中的错别字（根据merge的assertion结果来写）
	replace cityname="贵州省" if cityname=="责州省"
	replace cityname="海北藏族自治州" if cityname=="诲北藏族自治州"
	replace cityname="揭阳市" if cityname=="掲阳市"
	replace cityname="荆门市" if cityname=="荊门市"
	replace cityname="榆林市" if cityname=="输林市"
	replace cityname="怒江傈僳族自治州" if cityname=="怒江傈粟族自治州"
	replace cityname="淮安市" if cityname=="准安市"
	replace cityname="海淀区" if cityname=="诲淀区"
	replace cityname="宝坻区" if cityname=="全坻区"
	replace cityname="菏泽市" if cityname=="荷泽市"
	replace cityname="克孜勒苏柯尔克孜自治州" if cityname=="克孜勒苏柯尔克孜自治外"
	replace cityname="恩施土家族苗族自治州" if cityname=="恩施士家族苗族自治州"
	replace cityname="浙江省" if cityname=="新江省"
	replace cityname="亳州市" if cityname=="毫州市"
	replace cityname="荆州市" if cityname=="荊州市"
	replace cityname="滨海新区" if cityname=="滨诲新区"
	replace cityname="日照市" if cityname=="日昭市"
	replace cityname="德宏傣族景颇族自治州" if cityname=="德宏傣族景颇族治州"
	replace cityname="文山壮族苗族自治州" if cityname=="文山壮族苗族自冶州"
	replace cityname="舟山市" if cityname=="丹山市"
	replace cityname="北海市" if cityname=="北诲市"
	replace cityname="博尔塔拉蒙古自治州" if cityname=="博尔塔拉蒙古自冶州"
	replace cityname="延边朝鲜族自治州" if cityname=="延边朝鲜族自冶州"
	replace cityname="杨浦区" if cityname=="杨南区"
	replace cityname="宿迁市" if cityname=="宿辽市"
	replace cityname="酒泉市" if cityname=="洒泉市"
	replace cityname="北京经济技术开发区" if cityname=="北京经济技木开发区"
	replace cityname="鹤壁市" if cityname=="鸥壁市"
	replace cityname="潍坊市" if cityname=="维坊市"
	replace cityname="滨州市" if cityname=="宾州市"
	replace cityname="江西省" if cityname=="工西省"
	replace cityname="聊城市" if cityname=="柳城市"
	replace cityname="河南省" if cityname=="可南省"
	replace cityname="乌兰察布市" if cityname=="乌兰察市市"
	replace cityname="洛阳市" if cityname=="各阳市"
	replace cityname="菏泽市" if cityname=="苛泽市"
	replace cityname="济宁市" if cityname=="齐宁市"
	replace cityname="红河哈尼族彝族自治州" if cityname=="红河哈尼族彝族自冶州"

	
	save "2012_`i'_temp.dta", replace	
}



use "2012_1_temp.dta", clear
forvalues i = 2/23{
	merge 1:1 cityname using "2012_`i'_temp.dta"
	sort _m
	display `i'
	assert _m ==3  //11、15出现问题
	drop _m
}



save "city_2012_temp.dta",replace
destring n, replace
sort n

*设置变量名称和标签
use "city_2012_temp.dta",clear
	duplicates list cityname
	drop if cityname=="其他"
	gen temp_id=(cityname!="地区")
	sort temp_id
	drop temp_id

foreach var of varlist v* {
	replace `var'=ustrunescape(subinstr(ustrtohex(`var'[1]),"\u000d\u000a","",.)) if _n==1 //去掉表头中的换行符
	replace `var'=ustrregexs(1) if ustrregexm(`var',"^(.*?)[a-zA-Z]+.*$") & _n==1
	//replace `var'=ustrregexs(1) if ustrregexm(`var',"^(.*?\u0028.*?\u0029).*$") & _n==1 //保留中文标签
	//replace `var'=ustrregexs(1) if ustrregexm(`var',"^.*?([\u4e00-\u9fa5]+).*$") & strpos(`var',"(")==0 & _n==1 //保留中文标签
	//replace `var'="#"+`var' if strpos(`var',"(")==0 & _n==1
}

destring n,replace

//为变量名加上标签
sort n
tostring n, replace

foreach var of varlist * {
	replace `var' = subinstr(`var'[2], "(","",1) in 2
	replace `var' = subinstr(`var'[2], "（","",1) in 2
	replace `var' = subinstr(`var'[2],")", "",1) in 2
	replace `var' = subinstr(`var'[2], "）","",1) in 2
}
foreach var of varlist * {
	if substr("`var'",1,1)=="v" {    //stata里面的条件语句太难用了……
		local x = `var'[1]
		label var `var' "`x'"	
	}
	
}
//删去标签
drop in 1

save city_2012_temp.dta, replace

