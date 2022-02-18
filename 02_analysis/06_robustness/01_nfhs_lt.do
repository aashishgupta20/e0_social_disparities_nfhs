**************************************************
*Project: Caste and mortality							 *
*Purpose: bring in life-tables and estimate 0-5 and 15-60 mortality
*Last modified: April 10, 2021 by AG					 *
**************************************************

**************************************************
*Preamble													 *
**************************************************
	
	clear all
	set more off
	set maxvar  32767, perm 
	
	
	*Set user
	local user  "aashish" // "nikkil" // 
	
		if "`user'"=="nikkil" {
			global dir "/Users/Nikkil/Dropbox/India Mortality/data_analysis"
		}
		if "`user'"=="aashish" {
			global dir "D:\RDProfiles\aashishg\Dropbox\My PC (PSCStat02)\Desktop\caste"
		}

	
	*Log
	cap log close
	log using "$dir/02_logs/02analysis_nfhs_compile.txt", text replace
	
******************************************************
*Work with data
*******************************************************

	use "$dir\05_out\estimates\nfhs2_overall_life_tables_se.dta", clear 
	
	append using "$dir\05_out\estimates\nfhs4_overall_life_tables_se.dta"
	
	*save nmx 
	preserve 
	keep round age_group nmx* female
	save "$dir\01_do\02_analysis\06_robustness\nfhs_nmx.dta", ///
	replace
	restore
	
	gen caste_religion = 7 
	
	append using "$dir\05_out\estimates\nfhs2_group_life_tables_se.dta"
	
	append using "$dir\05_out\estimates\nfhs4_group_life_tables_se.dta"

	
	keep female age_group nmx lx ex round caste_religion 
	
	label define sgroup 1 "SC" 2 "ST" 3 "Muslim" 4 "OBC" 5 "HC" 6 "Others/Missing" 7 "Overall"
	lab val caste_religion sgroup 
	
	*save e0
	preserve 
	keep if age_group == 0 
	keep round caste_religion ex female
	tempfile e0
	save `e0'
	export excel using "$dir\01_do\02_analysis\06_robustness\nfhs_ex.xls", ///
	firstrow(variables) replace
	restore 
	
	
	*save 5q0
	preserve 
	keep if age_group == 0
	rename lx l0 
	keep female round caste_religion l0
	tempfile l0
	save `l0'
	restore
	
	preserve 
	keep if age_group == 5
	rename lx l5 
	keep female round caste_religion l5
	merge 1:1 female round caste_religion using `l0', nogen 
	gen stat_5q0 = l0 - l5 
	tempfile stat_5q0
	save `stat_5q0'
	export excel using "$dir\01_do\02_analysis\06_robustness\nfhs_5q0.xls", ///
	firstrow(variables) replace
	restore 
	
	*save 45q15
	preserve 
	keep if age_group == 15
	rename lx l15
	keep female round caste_religion l15
	tempfile l15
	save `l15'
	restore
	
	preserve 
	keep if age_group == 60
	rename lx l60
	keep female round caste_religion l60
	merge 1:1 female round caste_religion using `l15', nogen 
	gen stat_45q15 = (l15 - l60) / l15 
	tempfile stat_45q15
	save `stat_45q15'
	export excel using "$dir\01_do\02_analysis\06_robustness\nfhs_45q15.xls", ///
	firstrow(variables) replace
	restore 
	
	use `e0', clear 
	merge  1:1 female round caste_religion using `stat_5q0', nogen 
	merge  1:1 female round caste_religion using `stat_45q15', nogen 
	keep female round caste_religion stat* e*
	order female round caste_religion stat* e*
	sort round female caste_religion
	drop if caste_religion == 6 
	export excel using "$dir\01_do\02_analysis\06_robustness\nfhs_stats.xls", ///
	firstrow(variables) replace
	drop if caste_religion == 6 
	
	
	