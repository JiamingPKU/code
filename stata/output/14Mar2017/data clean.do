*Stata��������̳�
*author������Ƚ
*data source���й�����ͳ�����2015���й�����ͳ�����2015�����о�
*special thanks to��������ʦ��Ԭ����ʦ������ѧԺ12����Ҷ

*------------------СTips------------------

/*
��ݼ�������

	Ctrl+S
	����do�ĵ�

	Ctrl+D
	��do�ĵ���ѡ��Ҫִ������һ���ֻ���ȫ����Ctrl+D�󣬻�ִ��(do)

	Ctrl+R
	��do�ĵ���ѡ��Ҫִ������һ���ֻ���ȫ����Ctrl+R�󣬻�����(run)

	Ctrl+L
	ѡ�й��������

	Ctrl+shift+Home\End
	ѡ�й�����ڼ����ϣ����£������еĴ���
	
	Stata������������ȿ���ֻдǰ�����ַ������ô��ȫ��

�淶�Բ�����

	ʹ��Tab�����������ִ�����߼���
	
	��ʱ���ע�ͣ�//��*��/*��*/����ע�ͷ���
	
	ʹ��dofile����������ע�ⲻҪ����Դ�ļ����ڳ���ʱ���Դ�ͷִ�д���ָ����
	
	��ʹ��help�����ѯ����Ϥ������÷�
	
	*������Stata��ռ�����ַ���ɾ��ʱע��Ҫ������backspace����������·������дע��ʱ�����������ĵ�ʹ��
*/
	
*------------------��һ���֣����û���-----------------

*���ù���·��
	cd C:\Users\john\OneDrive\�ٶ���ͬ����\working\����\ͳ��ѧ\����������\����ʾ��_����ͳ����������򾭼�ͳ����� 
	
*Ҳ���Լ�˫���ţ����������ļ����д��ڿո�ʱ������Ӳ���ʶ��
	cd "C:\Users\john\OneDrive\�ٶ���ͬ����\working\����\��������ѧ\����������ʾ�ļ�"

	set more off //��moreѡ��رգ�ʹ���������ȫ��ʾ��Results����
	clear        //��֮ǰStata�����п��ܴ��е�����ɾ��

*------------------�ڶ����֣����벢��������-----------------

*����excel�������import excel��insheet�ȣ����ǲ���import���
	import excel using "����ͳ������_12����Ҷ.xlsx", clear firstrow allstring //���ź�Ϊoption������ʵ�ָ���Ч��������

*���Ƚ�����������ͳһ���ɣ�������һ��������
	rename * v#,addnumber           										  //ʹ��rename������б�������Ϊv1 v2 v3�����ĸ�ʽ��ע��ʹ��*��ʾ���б�������#��ʾ�������֣���ͨ����ĸ��

*�˹��ȶԱ�������ʵ�ʺ��壬Ϊÿ������������ʹ��excel���ַ���������ñ�����
*˼�������֪�����������Ƿ��и��Ӽ���code��	
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

*����ֵ���������ַ���ת��Ϊ��ֵ�ͣ�

	foreach var of varlist * {                 //ʹ��ѭ����䣬�����еı���������ѭ����������*��ʾ���б�������var�������ǡ��ꡱ���������Ϊһ���ĵ��еģ��������ݼ��еģ�����
		replace `var'=subinstr(`var'," ","",.) //ȥ�������еĿո�С�ģ��Ƿ����������о�����ȥ���ո񣿣������ú�ʱ����Ҫ���������Ž�������������ע�ⲻ�����������ţ�������λ��Tab���Ϸ�?
		destring `var',replace                 //destring��ȥ�ַ������෴����tostring
	}
	
*------------------�������֣������򱣴�����-----------------

*�����ݱ���ΪStata�������ļ���.dta����
	save "���򾭼�ͳ�����2015.dta",replace    //ע������ʱ���ļ������Լ������ͬ���ļ��Ƿ񸲸ǵ�ѡ��

*��ʱҲ��Ҫ����Ϊexcel��.csv��.xls��.xlsx������export excel����ɣ����ﲻ��ʾ��




*------------------����׼����ʹ�ø��༼��-----------------
*����֪ʶ����
	local lname=1
	display `lname'
	display "`lname'"	//ΪʲôҪ��""�������������͵�����
	
	local lname "hello world"
	display "`lname'"
	
*����֪ʶ��˳�򡢷�֧��ѭ�����ֳ���ṹ
/*
	��֧�ṹ��
	1.	if exp command
	2.	if exp {
			commands
		}
	
	ѭ���ṹ��
	1.	forvalues lname = range {
			commands
		}
	2.1	foreach lname of varlist {
			commands
		}
	2.2	foreach lname in anylist {
			commands
		}
*	���ӣ�
*/
	forvalues i = 1 / 5 {
		display `i'
	}
	foreach i in "a" "b" "c" {
		display "`i'"
	}
	
*����֪ʶ��merge����
*	merge 1:1 varlist using filename [, options]
*	varlist��һ������index���ܹ�Ψһȷ���۲�ġ�λ�á�
*	��1:1ģʽ֮�⣬������1�Զࡢ���1��merge��ʽ�����help merge��


*------------------����һ������������ӵ�����-----------------

*�۲�excel�е��������ݣ���sheet1�ж������ݣ�
	import excel using "�����£��й�����ͳ�����2015.xls", clear sheet("1") allstring //��������excel�е����ݣ�ָ���ļ�����sheet��

*�޸ı���������ӱ�����ǩ��
	foreach var of varlist * {
		if `var'[2]=="" drop `var'						//�������
	}
	rename * v#,addnumber           					//ʹ��rename������б�������Ϊv1 v2 v3�����ĸ�ʽ��ע��ʹ��*��ʾ���б�������#��ʾ�������֣���ͨ����ĸ��
	local var_num=c(k)              					//c(k)�������Է���dataset�б����ĸ�����local�������ڶ��塰�ꡱ
	forvalues i=3/`var_num' {       					//forvalues��ѭ����䣬i��3����ѭ�������������������������б���������ѭ�����еĲ���
		replace v`i'=v`=`i'-1' if _n==1 & v`i'==""      //�����ú�ʱ��Ҫ�ں������ҷֱ��`��'��=��ʾ�ȼ���һ�εȺ��Ҳ��ֵ
		label var v`i' "`=v`i'[1]'"                     //label var�������ڸ�������ӱ�ǩ������ʹ�õ�һ�й۲��ֵ��Ϊ��ǩ����
	}
	drop if _n==1 | _n==3 | _n==4  						//��ǰ���й۲�ɾ��������_n��ʾ�۲��������ע��sort�������ı�_n����if�����ʾ�߼��жϣ�&��|��==��!=��>��<�ȷ��ű�ʾ�߼�����
	
*�������������������
	save temp_citydata_1.dta,replace

*�۲�excel�е��������ݣ����ֿ�������ѭ�������루ע��sheet3�е����е����⣩
	forvalues j=1/3 {
		import excel using "�����£��й�����ͳ�����2015.xls", clear sheet("`j'") allstring
		foreach var of varlist * {
			if "`var'"!="A" & "`var'"!="B" & `var'[2]=="" drop `var'								
		}
		rename * v`j'_#,addnumber
		local var_num=c(k)              			
		forvalues i=3/`var_num' {       
			replace v`j'_`i'=v`j'_`=`i'-1' if _n==1 & v`j'_`i'==""     
			label var v`j'_`i' "`=v`j'_`i'[1]'"                     
		}
		if `j'==3 {													//if��������һ���÷������ڽṹ�У���������֮���ʾ�Թ۲����ж�
			drop if _n==1 | _n==3 | _n==4 | _n==5
		}
		else {
			drop if _n==1 | _n==3 | _n==4
		}
		rename v`j'_1 code											//���ؼ��д��������Ƶ�����������Ϊ����dataset�ж��У���Ψһ������
		rename v`j'_2 name											//�����λ�ý���rename����Ϊ����iѭ��ʱ����Ҫ����v`j'_2�������������ִ���
		label var code "�ؼ���������"								//�ֶ�Ϊ�������������б�ע
		label var name "�ؼ���������"
		replace code="level" if _n==1								//Ϊ���ݲ㼶�������б�ע��Ϊ�����������ݲ㼶����dataset�ṩ����
		replace name="���ݲ㼶" if _n==1
		drop if code=="" | name==""									//ɾ���չ۲⣨��code��nameΪ�жϱ�׼��
		save temp_citydata_`j'.dta,replace
	}

*����merge����ϲ����ݼ���
	merge 1:1 code name using temp_citydata_2
	
*�õ��ϲ�������ݼ���������_merge������¼�˺ϲ������������δ�����쳣������ɾ�����ٴν��кϲ���
	drop _merge
	merge 1:1 code name using temp_citydata_1
	drop _merge

*�����������ͱ�ǩ��������ǰ�����
	preserve																			//preserve��restore��һ������м�Ĵ��벻���dataset����������Ӱ��
		import excel using "���ָ�������������ǩ_final.xlsx",clear sheet(diqu) firstrow
		rename name varname																//��ֹ������dataset�е�name������ͻ
		save temp_rename_diqu.dta, replace												//��Ȼrestore֮��ͻָ�dataset���������ǿ��Խ��ı���data�����ȥ
		import excel using "���ָ�������������ǩ_final.xlsx",clear sheet(shiqu) firstrow
		rename name varname
		save temp_rename_shiqu.dta, replace
	restore
	
*��ʾ���ݲ㼶�Ĺ۲������һ�У��ݴ˽��з���������dataset
	preserve																			
		foreach var of varlist * {
			if `var'[_N]=="����" | `var'[_N]=="��Ͻ��" | `var'[_N]=="������" drop `var' //���������������ݣ�if�������ֻ��һ�У����Բ��ô����ŵ�д����ֱ�ӷ��ں���
		}
		drop if _n==_N
		order *,alphabetic																//�����������ֵ�������

		merge 1:1 _n using temp_rename_diqu.dta											//�������й����������
		count if _m==3
		local n=r(N)
		forvalues i=1/`n' {
			ren `=name_ori[`i']' `=varname[`i']'
		}
		drop varname-_m
		save "�й�����ͳ�����2015_��������.dta",replace								
		//keep if _n==1
		//export excel using temp_rename.xlsx, sheet("diqu") firstrow(var) replace		//�ֱ�varname��varlabel�����excel�н���ƥ�䣬����дrename��code��Ҳ������describe�������
		//export excel using temp_rename.xlsx, sheet("diqu") firstrow(varlabels) cell(A3) sheetmodify
	restore
	
	foreach var of varlist * {
		if `var'[_N]=="������" label var `var' "���������������ƽ�����"				//�Խ��������ݵı�ǩ����������  
		if `var'[_N]=="����" | `var'[_N]=="ȫ��" drop `var'  							//���������������ݣ���������������Ľ��������ݣ�
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
	save "�й�����ͳ�����2015_��������.dta",replace
	//keep if _n==1
	//export excel using temp_rename.xlsx, sheet("shiqu") firstrow(var) sheetreplace
	//export excel using temp_rename.xlsx, sheet("shiqu") firstrow(varlabels) cell(A3) sheetmodify
