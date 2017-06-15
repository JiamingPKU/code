********** 模型建立和模型识别 **********

****** 生成相关变量
tsset pref year
xtdes

*** 核心变量
* 政府规模,被解释变量 财政预算支出/GDP
gen govsize	= fisexp / gdp
* 政府的教育投入力度
gen govedu  = fisexp_edu / gdp			//相对于GDP
gen govedu1 = fisexp_edu / fisexp		//相对于财政支出
* 政府的社保等投入力度
gen govsec  = fisexp_security / gdp		//相对于GDP
gen govsec1 = fisexp_security / fisexp	//相对于财政支出

* 开放程度,核心解释变量 进出口总额/GDP
gen	open = im_ex_port /10000/gdp
* 开放程度1, 进出口总额/(GDP-第三产业增加值), 参考Feenstra(1998)
gen open1 = im_ex_port /10000 / (gdp-gdp_thi)

*** 控制变量
* 经济发展水平 人均GDP对数
gen lngdppc = log(gdp_per)
* 地区规模 总人口取对数(常住人口/户籍人口)
gen lnpop = log(pop)
* 是否是自治区 Autonomous Region
gen anr = ((prov == 15) | (prov == 45) | (prov == 54) | (prov == 64) | (prov == 65))
* 是否是直辖市 Municipal,(好像并没有)
* gen mun = ((prov == 11) | (prov == 12) | (prov == 50) | (prov == 31))


*** 固定效应
* 年份固定效应
tab year, gen(y)
* 省份固定效应
tab prov, gen(p)

*** 滞后项
gen lgovsize = L.govsize
gen lopen = L.open

save city.dta, replace

****** 描述统计
sum govsize govedu govedu1 govsec govsec1 open open1 lngdppc lnpop
outreg2 using stats, tex sum(log) keep(govsize govedu govedu1 govsec govsec1 open open1 lngdppc lnpop ) replace


****** 回归估计
*** 截面估计
forvalues i= 2006/2013{
	reg govsize open lngdppc lnpop anr p1-p27 if year == `i'
	if `i' == 2006 {
		outreg2 using estcross, tex drop(p* o.p*) ctitle(`i') replace title("安")
	}
	else{
		outreg2 using estcross, tex drop(p* o.p*) ctitle(`i') append
	}
	di `i'
}

*** 截面回归2
forvalues i= 2006/2013{
	reg govsize open1 lngdppc lnpop anr p1-p27 if year == `i'
	if `i' == 2006 {
		outreg2 using estcross2, tex drop(p* o.p*) ctitle(`i') replace title("安")
	}
	else{
		outreg2 using estcross2, tex drop(p* o.p*) ctitle(`i') append
	}
	di `i'
}

*** 截面回归3
forvalues i= 2007/2013{
	reg lgovsize open lngdppc lnpop anr p1-p27 if year == `i'
	if `i' == 2007 {
		outreg2 using estcross3, tex drop(p* o.p*) ctitle(`i') replace title("安")
	}
	else{
		outreg2 using estcross3, tex drop(p* o.p*) ctitle(`i') append
	}
	di `i'
}

*** 截面估计4
forvalues i= 2007/2013{
	reg govsize lopen lngdppc lnpop anr p1-p27 if year == `i'
	if `i' == 2007 {
		outreg2 using estcross4, tex drop(p* o.p*) ctitle(`i') replace title("安")
	}
	else{
		outreg2 using estcross4, tex drop(p* o.p*) ctitle(`i') append
	}
	di `i'
}



*** pooled 估计, 只放入一个回归结果即可
/*
* robust回归
reg govsize open lngdppc lnpop anr p1-p27 y1-y8, robust
est store est1
outreg2 using est, tex replace ctitle(pool robust) drop(p* o.p* y* o.y)
*/

* cluster回归
reg govsize open lngdppc lnpop anr p1-p27 y1-y8, vce(cluster prov)
est store est2
outreg2 using est, tex replace  ctitle(pool P_clus) drop(p* o.p* y* o.y*)
/*
* cluster回归
reg govsize open lngdppc lnpop anr p1-p27 y1-y8, vce(cluster year)
est store est3
outreg2 using est, tex append  ctitle(pool Y_clus) drop(p* o.p* y* o.y*)
*/


*** 面板估计,固定效应模型
* Hausman 检验, P值很小，固定效应
xtreg govsize open lngdppc lnpop anr p1-p27 y1-y8, fe
est store est4
xtreg govsize open lngdppc lnpop anr p1-p27 y1-y8, re
est store est5
hausman est4 est5, constant sigmamore

* 双向固定效应
xtreg govsize open lngdppc lnpop anr p1-p27 y1-y8, fe vce(cluster prov)
est store est6
outreg2 using est, tex append	ctitle(FE P_clus) drop(p* o.p* y* o.y*)


/*
*	同时加入了省份固定效应,
xtreg govsize open lngdppc lnpop anr p1-p27 y1-y8, fe robust
est store est4
outreg2 using est, tex append	ctitle(FE robust) drop(p* o.p* y* op*)
*/
*	横向和纵向的固定效应,
/*
*	随机效应模型,考虑到现实意义和豪斯曼检验,舍去
xtreg govsize open lngdppc lnpop anr p1-p27 y1-y8  //, re vce(cluster prov)
xttest0
est store est6
outreg2 using est, tex append	ctitle(RE P_clus) drop(p* o.p* y* o.y*)
xtreg govsize open lngdppc lnpop anr p1-p27, re vce(cluster prov)
est store est6
outreg2 using est, tex append	ctitle(RE P_clus) drop(p* o.p* y* o.y*)
*/

* 时间虚拟变量显著性检验 
* 组间异方差问题 xttest3
xttest3 
* 序列自相关检验 xtserial
xtserial govsize open lngdppc lnpop
xtserial govsize
xtserial open
xtserial lngdppc
xtserial lnpop		//不显著

* 单位根检验
xtcd govsize

***随机效应的FGLS估计
/*
xtgls govsize open lngdppc lnpop anr p1-p27, i(code) t(year) panels(hetero) corr(i) force
est store est7
outreg2 using est, tex append ctitle(FGLS AR(1)) drop(p* o.p* y* o.y*)

xtgls govsize open lngdppc lnpop anr p1-p27, i(code) t(year) panels(hetero) corr(ar1) force
est store est8
outreg2 using est, tex append ctitle(FGLS PSAR(1)) drop(p* o.p* y* o.y*)
*/
*** 至此得到了 

******* 面板协整

*** 平稳性检验
*** 协整关系建立
* MG 结果I(0) 但是检验方法不对
xtmg govsize open lngdppc , trend res(r_mg)   
est store est21
outreg2 using est, tex append ctitle(MG) drop(_*)

* CCE 结果I(0) 但是检验方法不对
xtmg govsize open lngdppc, cce res(r_cmg) 
est store est22
outreg2 using est, tex append ctitle(CMG) drop(_*)

* CCE2 结果I(0) 但是检验方法不对
xtmg govsize open lngdppc, cce trend res(r_cmg2)
est store est23
outreg2 using est, tex append ctitle(CMG) drop(_*)

*结果检验
xtserial r_mg
xtserial r_cmg
xtserial r_cmg2
