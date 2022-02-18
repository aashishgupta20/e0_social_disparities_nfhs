******************************************************
*File to get estimates into latex  
******************************************************

**************************************************
*Preamble
**************************************************
	set more off
	
	*Set user

	
	*Log
	cap log close
	log using "$dir/02_logs/02analysis_nfhs_tables.txt", text replace

*append and merge life tables 

	use "$dir\05_out\estimates\nfhs2_group_life_tables_se.dta", clear
	
	append using "$dir\05_out\estimates\nfhs4_group_life_tables_se.dta"
	

*export tables in latex 
	
	keep female caste_religion age_group nmx lx ex round 
	 
	cap drop survivors
	gen survivors = lx * 1000
	drop lx 
			
	
	format survivors %8.0f
	format ex %8.1f
	format nmx %8.4f
	
	drop if caste_religion == 6 
	
	gen agerange = ""
	replace agerange = "0-1" if age_group == 0
	replace agerange = "1-4" if age_group == 1
	replace agerange = "5-9" if age_group == 5
	replace agerange = "10-14" if age_group == 10
	replace agerange = "15-19" if age_group == 15
	replace agerange = "20-24" if age_group == 20
	replace agerange = "25-29" if age_group == 25
	replace agerange = "30-34" if age_group == 30
	replace agerange = "35-39" if age_group == 35
	replace agerange = "40-44" if age_group == 40
	replace agerange = "45-49" if age_group == 45
	replace agerange = "50-54" if age_group == 50
	replace agerange = "55-59" if age_group == 55
	replace agerange = "60-64" if age_group == 60
	replace agerange = "65-69" if age_group == 65
	replace agerange = "70-74" if age_group == 70
	replace agerange = "75-79" if age_group == 75
	replace agerange = "80-84" if age_group == 80
	replace agerange = "85+" if age_group == 85
	
	*nfhs 2 female
	preserve
	keep if round == 2 
	keep if female==1 

	*1 = sc, 2 = st, 3 = muslim, 4 = obc, 5 = hc 
	
	reshape wide nmx ex survivors, i(agerange age_group) j(caste_religion)
	
	sort age_group
	

	listtab ///
	agerange ///
	nmx1 survivors1 ex1  ///
	nmx2 survivors2 ex2  ///
	nmx3 survivors3 ex3  ///
	nmx4 survivors4 ex4  ///
	nmx5 survivors5 ex5  ///
	using "$dir\05_out\estimates\round2_female.tex", ///
	rstyle(tabular) replace ///
	head("\begin{tabular}{cccccccccc}") ///
	foot("\bottomrule" "\end{tabular}")

	restore
	
	*nfhs2 male
	
	preserve
	keep if round == 2 
	keep if female==0

	*1 = sc, 2 = st, 4 = obc, 5 = hc 
	
	reshape wide nmx ex survivors, i(age_group) j(caste_religion)

	sort age_group
	

	listtab ///
	agerange ///
	nmx1 survivors1 ex1  ///
	nmx2 survivors2 ex2  ///
	nmx3 survivors3 ex3  ///
	nmx4 survivors4 ex4  ///
	nmx5 survivors5 ex5  ///
	using "$dir\05_out\estimates\round2_male.tex", ///
	rstyle(tabular) replace ///
	head("\begin{tabular}{cccccccccc}") ///
	foot("\bottomrule" "\end{tabular}")

	restore
	
		
	*nfhs 4 female
	preserve
	keep if round == 4
	keep if female==1 

	*1 = sc, 2 = st, 4 = obc, 5 = hc 
	
	reshape wide nmx ex survivors, i(age_group) j(caste_religion)

	sort age_group
	

	listtab ///
	agerange ///
	nmx1 survivors1 ex1  ///
	nmx2 survivors2 ex2  ///
	nmx3 survivors3 ex3  ///
	nmx4 survivors4 ex4  ///
	nmx5 survivors5 ex5  ///
	using "$dir\05_out\estimates\round4_female.tex", ///
	rstyle(tabular) replace ///
	head("\begin{tabular}{cccccccccc}") ///
	foot("\bottomrule" "\end{tabular}")

	restore
	
	*nfhs2 male
	
	preserve
	keep if round == 4 
	keep if female==0

	*1 = sc, 2 = st, 4 = obc, 5 = hc 
	
	reshape wide nmx ex survivors, i(age_group) j(caste_religion)

	sort age_group
	

	listtab ///
	agerange ///
	nmx1 survivors1 ex1  ///
	nmx2 survivors2 ex2  ///
	nmx3 survivors3 ex3  ///
	nmx4 survivors4 ex4  ///
	nmx5 survivors5 ex5  ///
	using "$dir\05_out\estimates\round4_male.tex", ///
	rstyle(tabular) replace ///
	head("\begin{tabular}{cccccccccc}") ///
	foot("\bottomrule" "\end{tabular}")

	restore
	
	
	
	
