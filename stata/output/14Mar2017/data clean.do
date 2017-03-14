*Stata数据清理教程
*author：刘晨冉
*data source：中国城市统计年鉴2015、中国县域统计年鉴2015（县市卷）
*special thanks to：刘冲老师、袁诚老师、经济学院12级宋叶

*------------------小Tips------------------

/*
快捷键操作：

	Ctrl+S
	保存do文档

	Ctrl+D
	在do文档中选中要执行语句的一部分或者全部，Ctrl+D后，会执行(do)

	Ctrl+R
	在do文档中选中要执行语句的一部分或者全部，Ctrl+R后，会运行(run)

	Ctrl+L
	选中光标所在行

	Ctrl+shift+Home\End
	选中光标所在及以上（以下）所有行的代码
	
	Stata的命令、变量名等可以只写前几个字符，不用打出全名

规范性操作：

	使用Tab来缩进，保持代码的逻辑性
	
	及时添加注释：//、*与/*、*/三种注释方法
	
	使用dofile操作，并且注意不要覆盖源文件，在出错时可以从头执行代码恢复结果
	
	多使用help命令查询不熟悉命令的用法
	
	*中文在Stata中占两个字符，删除时注意要按两次backspace，所以命名路径或者写注释时尽量减少中文的使用
*/
	
*------------------第一部分：设置环境-----------------

*设置工作路径
	cd C:\Users\john\OneDrive\百度云同步盘\working\助教\统计学\数据清理技巧\课堂示例_城市统计年鉴与县域经济统计年鉴 
	
*也可以加双引号，尤其是在文件名中存在空格时必须添加才能识别
	cd "C:\Users\john\OneDrive\百度云同步盘\working\助教\福利经济学\数据清理演示文件"

	set more off //将more选项关闭，使结果可以完全显示在Results窗口
	clear        //将之前Stata程序中可能存有的数据删除

*------------------第二部分：导入并整理数据-----------------

*导入excel的命令常用import excel、insheet等，我们采用import命令：
	import excel using "县域统计资料_12级宋叶.xlsx", clear firstrow allstring //逗号后为option，可以实现更多效果（？）

*首先将变量的名称统一规律，方便下一步操作：
	rename * v#,addnumber           										  //使用rename命令将所有变量命名为v1 v2 v3……的格式，注意使用*表示所有变量名，#表示任意数字（即通配符的概念）

*人工比对变量名与实际含义，为每个变量命名（使用excel的字符串函数获得便利）
*思考：如果知道命名规则，是否有更加简洁的code？	
	rename v1 code
	rename v10 employ_indus
	rename v11 employ_service
	rename v12 num_tele_user
	rename v13 gdp
	rename v14 agri
	rename v15 agri1
	rename v16 agri2
	rename v17 indus
	rename v18 fisrev
	rename v19 taxrev
	rename v2 name
	rename v20 fisexp
	rename v21 saving
	rename v22 saving_fin
	rename v23 agri_power
	rename v24 jsmj
	rename v25 ssnyzdmj
	rename v26 produce
	rename v27 cotton
	rename v28 oil
	rename v29 meat
	rename v3 provcode
	rename v30 firms
	rename v31 firms_value
	rename v32 investment
	rename v33 midstu
	rename v34 vacstu
	rename v35 pristu
	rename v36 hos_bed
	rename v37 charity_house
	rename v38 charity_bed
	rename v4 provnamme
	rename v5 area
	rename v6 num_x
	rename v7 num_z
	rename v8 num_j
	rename v9 pop

*将数值型数据由字符型转换为数值型：

	foreach var of varlist * {                 //使用循环语句，在所有的变量中依次循环操作（用*表示所有变量）；var在这里是“宏”，可以理解为一个文档中的（而非数据集中的）变量
		replace `var'=subinstr(`var'," ","",.) //去掉数据中的空格（小心：是否所有数据中均可以去除空格？）；调用宏时，需要用左右引号将宏名括起来（注意不是两个右引号，左引号位于Tab键上方?
		destring `var',replace                 //destring是去字符化，相反的是tostring
	}
	
*------------------第三部分：导出或保存数据-----------------

*将数据保存为Stata的数据文件（.dta）：
	save "县域经济统计年鉴2015.dta",replace    //注明保存时的文件名，以及如果有同名文件是否覆盖的选项

*有时也需要导出为excel（.csv、.xls或.xlsx），用export excel命令即可，这里不演示了




*------------------进阶准备：使用更多技巧-----------------
*补充知识：宏
	local lname=1
	display `lname'
	display "`lname'"	//为什么要加""？——变量类型的问题
	
	local lname "hello world"
	display "`lname'"
	
*补充知识：顺序、分支与循环三种程序结构
/*
	分支结构：
	1.	if exp command
	2.	if exp {
			commands
		}
	
	循环结构：
	1.	forvalues lname = range {
			commands
		}
	2.1	foreach lname of varlist {
			commands
		}
	2.2	foreach lname in anylist {
			commands
		}
*	例子：
*/
	forvalues i = 1 / 5 {
		display `i'
	}
	foreach i in "a" "b" "c" {
		display "`i'"
	}
	
*补充知识：merge命令
*	merge 1:1 varlist using filename [, options]
*	varlist是一个或多个index，能够唯一确定观测的“位置”
*	在1:1模式之外，还存在1对多、多对1等merge方式（详见help merge）


*------------------更进一步：整理更复杂的数据-----------------

*观察excel中的数据内容，从sheet1中读入数据：
	import excel using "（最新）中国城市统计年鉴2015.xls", clear sheet("1") allstring //导入存放在excel中的数据，指名文件名和sheet名

*修改变量名与添加变量标签：
	foreach var of varlist * {
		if `var'[2]=="" drop `var'						//清除空列
	}
	rename * v#,addnumber           					//使用rename命令将所有变量命名为v1 v2 v3……的格式，注意使用*表示所有变量名，#表示任意数字（即通配符的概念）
	local var_num=c(k)              					//c(k)函数可以返回dataset中变量的个数；local命令用于定义“宏”
	forvalues i=3/`var_num' {       					//forvalues是循环语句，i从3递增循环到变量个数，这样遍历所有变量，进行循环体中的操作
		replace v`i'=v`=`i'-1' if _n==1 & v`i'==""      //在引用宏时，要在宏名左右分别加`和'，=表示先计算一次等号右侧的值
		label var v`i' "`=v`i'[1]'"                     //label var命令用于给变量添加标签，这里使用第一行观测的值作为标签内容
	}
	drop if _n==1 | _n==3 | _n==4  						//将前三行观测删掉，其中_n表示观测的行数（注意sort等命令会改变_n）；if命令表示逻辑判断，&、|、==、!=、>、<等符号表示逻辑运算
	
*将基本结果保存下来：
	save temp_citydata_1.dta,replace

*观察excel中的数据内容，发现可以利用循环语句读入（注意sheet3中第四行的问题）
	forvalues j=1/3 {
		import excel using "（最新）中国城市统计年鉴2015.xls", clear sheet("`j'") allstring
		foreach var of varlist * {
			if "`var'"!="A" & "`var'"!="B" & `var'[2]=="" drop `var'								
		}
		rename * v`j'_#,addnumber
		local var_num=c(k)              			
		forvalues i=3/`var_num' {       
			replace v`j'_`i'=v`j'_`=`i'-1' if _n==1 & v`j'_`i'==""     
			label var v`j'_`i' "`=v`j'_`i'[1]'"                     
		}
		if `j'==3 {													//if语句的另外一种用法，用在结构中，而非命令之后表示对观测做判断
			drop if _n==1 | _n==3 | _n==4 | _n==5
		}
		else {
			drop if _n==1 | _n==3 | _n==4
		}
		rename v`j'_1 code											//将地级市代码与名称单独命名，因为三个dataset中都有，是唯一的索引
		rename v`j'_2 name											//在这个位置进行rename是因为上文i循环时还需要引用v`j'_2变量，否则会出现错误
		label var code "地级区划代码"								//手动为这两个变量进行标注
		label var name "地级区划名称"
		replace code="level" if _n==1								//为数据层级单独进行标注，为后文区分数据层级建立dataset提供方便
		replace name="数据层级" if _n==1
		drop if code=="" | name==""									//删除空观测（以code和name为判断标准）
		save temp_citydata_`j'.dta,replace
	}

*利用merge命令合并数据集：
	merge 1:1 code name using temp_citydata_2
	
*得到合并后的数据集，新增了_merge变量记录了合并的情况，检查后未发现异常，将其删除并再次进行合并：
	drop _merge
	merge 1:1 code name using temp_citydata_1
	drop _merge

*将变量命名和标签的数据提前整理好
	preserve																			//preserve与restore是一对命令，中间的代码不会对dataset产生永久性影响
		import excel using "年鉴指标变量命名及标签_final.xlsx",clear sheet(diqu) firstrow
		rename name varname																//防止跟后面dataset中的name变量冲突
		save temp_rename_diqu.dta, replace												//虽然restore之后就恢复dataset，但是我们可以将改变后的data保存出去
		import excel using "年鉴指标变量命名及标签_final.xlsx",clear sheet(shiqu) firstrow
		rename name varname
		save temp_rename_shiqu.dta, replace
	restore
	
*表示数据层级的观测在最后一行，据此进行分样本建立dataset
	preserve																			
		foreach var of varlist * {
			if `var'[_N]=="市区" | `var'[_N]=="市辖区" | `var'[_N]=="建成区" drop `var' //保留下来地区数据；if语句里面只有一行，可以不用大括号的写法而直接放在后面
		}
		drop if _n==_N
		order *,alphabetic																//将变量按照字典序排列

		merge 1:1 _n using temp_rename_diqu.dta											//利用现有规则快速命名
		count if _m==3
		local n=r(N)
		forvalues i=1/`n' {
			ren `=name_ori[`i']' `=varname[`i']'
		}
		drop varname-_m
		save "中国城市统计年鉴2015_地区数据.dta",replace								
		//keep if _n==1
		//export excel using temp_rename.xlsx, sheet("diqu") firstrow(var) replace		//分别将varname和varlabel输出到excel中进行匹配，并编写rename的code；也可以用describe命令完成
		//export excel using temp_rename.xlsx, sheet("diqu") firstrow(varlabels) cell(A3) sheetmodify
	restore
	
	foreach var of varlist * {
		if `var'[_N]=="建成区" label var `var' "建成区土地面积（平方公里）"				//对建成区数据的标签单独调整下  
		if `var'[_N]=="地区" | `var'[_N]=="全市" drop `var'  							//保留下来市区数据（及土地面积变量的建成区数据）
	}
	drop if _n==_N
	order *,alphabetic
	
	merge 1:1 _n using temp_rename_shiqu.dta											
	count if _m==3
	local n=r(N)
	forvalues i=1/`n' {
		ren `=name_ori[`i']' `=varname[`i']'
	}
	drop varname-_m
	save "中国城市统计年鉴2015_市区数据.dta",replace
	//keep if _n==1
	//export excel using temp_rename.xlsx, sheet("shiqu") firstrow(var) sheetreplace
	//export excel using temp_rename.xlsx, sheet("shiqu") firstrow(varlabels) cell(A3) sheetmodify
