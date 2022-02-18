**************************************************
*Project: Caste and mortality							 *
*Purpose: look at sample composition
**************************************************

**************************************************
*Preamble													 *
**************************************************
	
	clear all
	set more off
	set maxvar  32767, perm 
	
	
	*Set user

	*Log
	cap log close
	log using "$dir/02_logs/02analysis_nfhs_compile.txt", text replace
	
******************************************************
*bring in file to capture deaths and person years 
*****************************************************

	*nfhs2 
	use "$dir/04_input/nfhs2_child_person_years.dta", clear 
	
	append using "$dir/04_input/nfhs2_adult_person_years.dta"	
	
	*collapse
	fcollapse (sum) deaths person_years ///
	, by(caste_religion female)
	
	sort female caste_religion
	fcollapse (sum) deaths person_years ///
	, by(female)
	
	
	*nfhs4
	use "$dir/04_input/nfhs4_child_person_years.dta", clear 
	
	append using "$dir/04_input/nfhs4_adult_person_years.dta"	
	
	*collapse
	fcollapse (sum) deaths person_years ///
	, by(caste_religion female)
	
	sort female caste_religion
	fcollapse (sum) deaths person_years ///
	, by(female)
