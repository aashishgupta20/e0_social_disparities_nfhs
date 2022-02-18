**************************************************
*Project: Caste and mortality							 *
*Purpose: look at sample composition
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