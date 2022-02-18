**************************************************
*Project: Caste and mortality							 *
*Purpose: Resample for bootstraps - NFHS 4 		 *
*Last modified: 3 July 2020 by AG					 *
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
	log using "$dir/02_logs/02analysis_nfhs4_resampling_group_region.txt", text replace
	
********************************************************
*Data import and cleaning										 *
********************************************************

	*Import SRS
	use "$dir/00_raw/srs_2012.dta", clear 
		
	keep female n nax nmx_srs age_group
	
		*Save
		tempfile srs
		save `srs'

	*Import and append 
	use "$dir/04_input/nfhs4_child_person_years.dta", clear 
	
	append using "$dir/04_input/nfhs4_adult_person_years.dta"	
	
	*drop singleton cluster 
	drop if v024 == 6 & v025 == 2 


	
************************************************************
*Generate bootsrap id and other related variables			  *
*lets do it for overall regions first							  *
************************************************************

	*collapse
	fcollapse (sum) deaths person_years (mean) v024 v025 ///
	, by(v001 age_group female caste_religion region)


	*weights for resamples 
	gen weight=. 
		
		
	*resample 
	set seed 201188
	forvalues i = 1(1)100 {
		qui gen w`i' = .
		bsample, cluster(v001) strata(v024 v025) weight(w`i')
	}

	*compress
	compress

************************************************************
*Loop through bootstrapped samples 								  *
************************************************************

forval z = 1(1)100{
	preserve 
	
	drop if w`z' == 0 
	
	expand w`z'
	
	*fcollapse 
	fcollapse (sum) deaths person_years, by(age_group female caste_religion region)
	
	*Estimate nmx
	g nmx = deaths / person_years
	
	*Merge srs
	merge m:1 female age_group using `srs', nogen

	*Sort and order
	sort female caste_religion age_group

	*Order
	order region female caste_religion age_group n nmx nax 

*Make life tables
	
	*nqx
	cap drop nqx
	gen nqx = (n*nmx) / (1 + (n-nax)*nmx)
	replace nqx = 1 if nqx==.
		
	*radix
	cap drop lx
	sort region female caste_religion age_group
	by region female caste_religion: gen lx = 1 if _n==1
		
	*lx
	forval i=2(1)19 {
		by region female caste_religion: replace lx = (lx[_n-1]*(1-nqx[_n-1])) if _n==`i'
	}
	
	*nLx
	cap drop nLx
	gen nLx=.
	forval i=1(1)18 {
		by region female caste_religion: replace nLx = (lx[_n+1]*n) + (lx*nqx*nax) if _n==`i'
	}
	by region female caste_religion: replace nLx = lx/nmx if _n==19
	
	*Total PY (for Tx)
	cap drop total_py
	bysort region female caste_religion: egen total_py = total(nLx) 

	*Tx
	cap drop Tx
	gen Tx = .
	by region female caste_religion: replace Tx = total_py - sum(nLx) + nLx

	*ex
	cap drop ex
	gen ex = Tx / lx
	*replace ex = round(ex, .1)
	
	*Keep only ex's
	keep region female caste_religion age_group nmx nmx_srs ex lx
	
	*create a round variable 
	gen round = 4 
	
	*Generate replication id 
	gen rep = `z'

	*Save life tables
	
	saveold "$dir\04_input\resamples\bstraps\nfhs4\region\bstrap_nfhs4_region_rep`z'.dta", replace
	
	restore
	}
	

	saveold "$dir\04_input\resamples\nfhs4_resampling_group_region.dta", replace

	
	

	