**************************************************
*Project: Caste and mortality							 *
*Purpose: Bootstraps for group estimates-NFHS2 *
*Last modified: 22 Feb 2020 by AG					 *
**************************************************

**************************************************
*Preamble													 *
**************************************************
	
	clear all
	set more off
	set maxvar  32767, perm 
	
	*Set directory
	
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
	log using "$dir/02_logs/02analysis_nfhs2_resampling_group.txt", text replace
	
********************************************************
*Data import and cleaning										 *
********************************************************

	*Import SRS
	use "$dir/00_raw/srs_1997.dta", clear 
	
	gen female = sex == 1 
	
	keep female n nax nmx_srs age_group
	
		*Save
		tempfile srs
		save `srs'

	*Import and appsend 
	use "$dir/04_input/nfhs2_child_person_years.dta", clear 
	
	append using "$dir/04_input/nfhs2_adult_person_years.dta"	
	
	*create a cluster variable 
	egen cluster = group(v024 v023 v025 v001)

	
************************************************************
*Generate bootsrap id and other related variables			  *
************************************************************

	*collapse
	fcollapse (sum) deaths person_years (mean) v023 v024 v025 ///
	, by(cluster caste_religion female age_group)


	*weights for resamples 
	gen weight=. 
		
	forvalues i = 1(1)100 {
		qui gen w`i' = .
		bsample, cluster(cluster) strata(v023 v024 v025) weight(w`i')
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
	fcollapse (sum) deaths person_years, by(caste_religion age_group female)
	
	*Estimate nmx
	g nmx = deaths / person_years
	
	*Merge srs
	merge m:1 female age_group using `srs', nogen

	*Sort and order
	sort caste_religion female age_group

	*Order
	order caste_religion female age_group n nmx nax 

*Make life tables
	
	*nqx
	cap drop nqx
	gen nqx = (n*nmx) / (1 + (n-nax)*nmx)
	replace nqx = 1 if nqx==.
		
	*radix
	cap drop lx
	sort caste_religion female age_group
	by caste_religion female: gen lx = 1 if _n==1
		
	*lx
	forval i=2(1)19 {
		by caste_religion female : replace lx = (lx[_n-1]*(1-nqx[_n-1])) if _n==`i'
	}
	
	*nLx
	cap drop nLx
	gen nLx=.
	forval i=1(1)18 {
		by caste_religion female : replace nLx = (lx[_n+1]*n) + (lx*nqx*nax) if _n==`i'
	}
	by caste_religion female: replace nLx = lx/nmx if _n==19
	
	*Total PY (for Tx)
	cap drop total_py
	bysort caste_religion female: egen total_py = total(nLx) 

	*Tx
	cap drop Tx
	gen Tx = .
	by caste_religion female: replace Tx = total_py - sum(nLx) + nLx

	*ex
	cap drop ex
	gen ex = Tx / lx
	*replace ex = round(ex, .1)
	
	*Keep only ex's
	keep caste_religion female age_group nmx nmx_srs ex lx
	
	*create a round variable 
	gen round = 2 
	
	*Generate replication id 
	gen rep = `z'

	*Save life tables
	
	saveold "$dir\04_input\resamples\bstraps\nfhs2\group\nfhs2_rep`z'_group.dta", replace
	
	restore
	}
	

	saveold "$dir\04_input\resamples\nfhs2_resampling_group.dta", replace
	
	
	

	