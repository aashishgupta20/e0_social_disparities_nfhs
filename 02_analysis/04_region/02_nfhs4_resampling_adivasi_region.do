**************************************************
*Project: Caste and mortality							 *
*Purpose: Resample for bootstraps - NFHS 4 		 *
**************************************************

**************************************************
*Preamble													 *
**************************************************
	
	clear all
	set more off
	set maxvar  32767, perm 
	
	
	*Log
	cap log close
	log using "$dir/02_logs/02analysis_nfhs4_resampling_group_adivasi_region.txt", text replace
	
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
		
	*adivasi or not 
	cap drop adivasi
	gen adivasi = caste_religion == 2 
	
	*defie adivsi region
	cap drop adivasi_region 
	gen adivasi_region = 1  // rest of india
	replace adivasi_region = 2 if inlist(v024,3,4,21,22,23,24,30,32) // north east
	replace adivasi_region = 3 if inlist(v024,6,8,15,18,19,26) // central india 
	label define adivasi_region 1 "1.ROI" 2 "2.Northeast" 3 "3.Central"
	label values adivasi_region adivasi_region
	
	
************************************************************
*Generate bootsrap id and other related variables			  *
*lets do it for overall regions first							  *
************************************************************

	*collapse
	fcollapse (sum) deaths person_years (mean) v024 v025 ///
	, by(v001 age_group female caste_religion adivasi_region)


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
	fcollapse (sum) deaths person_years, by(age_group female caste_religion adivasi_region)
	
	*Estimate nmx
	g nmx = deaths / person_years
	
	*Merge srs
	merge m:1 female age_group using `srs', nogen

	*Sort and order
	sort adivasi_region female caste_religion age_group

	*Order
	order adivasi_region female caste_religion age_group n nmx nax 

*Make life tables
	
	*nqx
	cap drop nqx
	gen nqx = (n*nmx) / (1 + (n-nax)*nmx)
	replace nqx = 1 if nqx==.
		
	*radix
	cap drop lx
	sort adivasi_region female caste_religion age_group
	by adivasi_region female caste_religion: gen lx = 1 if _n==1
		
	*lx
	forval i=2(1)19 {
		bysort adivasi_region female caste_religion: replace lx = (lx[_n-1]*(1-nqx[_n-1])) if _n==`i'
	}
	
	*nLx
	cap drop nLx
	gen nLx=.
	forval i=1(1)18 {
		bysort adivasi_region female caste_religion: replace nLx = (lx[_n+1]*n) + (lx*nqx*nax) if _n==`i'
	}
	by adivasi_region female caste_religion: replace nLx = lx/nmx if _n==19
	
	*Total PY (for Tx)
	cap drop total_py
	bysort adivasi_region female caste_religion: egen total_py = total(nLx) 

	*Tx
	cap drop Tx
	gen Tx = .
	bysort adivasi_region female caste_religion: replace Tx = total_py - sum(nLx) + nLx

	*ex
	cap drop ex
	gen ex = Tx / lx
	*replace ex = round(ex, .1)
	
	*Keep only ex's
	keep adivasi_region female caste_religion age_group nmx nmx_srs ex lx
	
	*create a round variable 
	gen round = 4 
	
	*Generate replication id 
	gen rep = `z'

	*Save life tables
	
	saveold "$dir\04_input\resamples\bstraps\nfhs4\adivasi_region\bstrap_nfhs4_region_rep`z'.dta", replace
	
	restore
	}
	

	saveold "$dir\04_input\resamples\nfhs4_resampling_group_adivasi_region.dta", replace

	
	
	

	