**************************************************
*Project: Caste and mortality							 *
*Purpose: Clean the bootstraps by regiopn 		 *
*Last modified: 27 July 2020 by AG					 *
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
	log using "$dir/02_logs/02analysis_nfhs4_region_clean_merge.txt", text replace
	
****************************************************
*clean etc 
****************************************************

*caste
	
	*bring in the random draws for caste regions
	
	forval x = 1(1)100 {
	use "$dir\04_input\resamples\bstraps\nfhs4\region\bstrap_nfhs4_region_rep`x'.dta", clear 
	keep female caste_religion age_group ex region
	rename ex ex_rep`x'
	save "$dir\04_input\resamples\bstraps\nfhs4\region\nfhs4_region_rep`x'.dta", replace
	}
	
	*fmerge all reps 
	use "$dir\04_input\resamples\bstraps\nfhs4\region\nfhs4_region_rep1.dta", clear 
	
	forval x = 2(1)100 {
	fmerge 1:1 region female caste_religion age_group using ///
	"$dir\04_input\resamples\bstraps\nfhs4\region\nfhs4_region_rep`x'.dta", nogen 
	}
	
	*ex se 	
	egen mean = rowmean(ex_rep1-ex_rep100)
	
	forval x = 1(1)100 {
	gen dev`x' = (ex_rep`x' - mean)^2
	}
	
	egen dev_total = rowtotal(dev1-dev100)
	gen se_ex = sqrt(dev_total / 99) 
	
	*keep only necessary variables 
	keep region female caste_religion age_group se_ex 
	
	*save 
	save "$dir\04_input\resamples\bstraps\nfhs4\nfhs4_ex_se_group_region.dta", replace

********************************************************************************
	*estimate expectancies 
********************************************************************************

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
		
		*merge standard errors
		merge 1:1 region caste_religion female age_group using ///
		"$dir\04_input\resamples\bstraps\nfhs4\nfhs4_ex_se_group_region.dta", nogen

		*gen 95% CIs
		gen ex_lci = ex - 1.96*se_ex
		gen ex_uci = ex + 1.96*se_ex
	
		*save	
		saveold "$dir/05_out/estimates/nfhs4_group_region_life_tables_se.dta", replace 

	
**************************************************************************************
**************************************************************************************
**************************************************************************************
*tribes
	
	*bring in the random draws for adivasi regions
	
	forval x = 1(1)100 {
	use "$dir\04_input\resamples\bstraps\nfhs4\adivasi_region\bstrap_nfhs4_region_rep`x'.dta", clear 
	keep female caste_religion age_group ex adivasi_region
	rename ex ex_rep`x'
	save "$dir\04_input\resamples\bstraps\nfhs4\adivasi_region\nfhs4_adivasi_region_rep`x'.dta", replace
	}
	
	*fmerge all reps 
	use "$dir\04_input\resamples\bstraps\nfhs4\adivasi_region\nfhs4_adivasi_region_rep1.dta", clear 
	
	forval x = 2(1)100 {
	fmerge 1:1 adivasi_region female caste_religion age_group using ///
	"$dir\04_input\resamples\bstraps\nfhs4\adivasi_region\nfhs4_adivasi_region_rep`x'.dta", nogen 
	}
	
	*ex se 	
	egen mean = rowmean(ex_rep1-ex_rep100)
	
	forval x = 1(1)100 {
	gen dev`x' = (ex_rep`x' - mean)^2
	}
	
	egen dev_total = rowtotal(dev1-dev100)
	gen se_ex = sqrt(dev_total / 99) 
	
	*keep only necessary variables 
	keep adivasi_region female caste_religion age_group se_ex 
	
	*save 
	save "$dir\04_input\resamples\bstraps\nfhs4\nfhs4_ex_se_group_adivasi_region.dta", replace

********************************************************************************
	*estimate expectancies 
********************************************************************************

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
			
		*defie adivsi region
		cap drop adivasi_region 
		gen adivasi_region = 1  // rest of india
		replace adivasi_region = 2 if inlist(v024,3,4,21,22,23,24,30,32) // north east
		replace adivasi_region = 3 if inlist(v024,6,8,15,18,19,26) // central india 
		label define adivasi_region 1 "1.ROI" 2 "2.Northeast" 3 "3.Central"
		label values adivasi_region adivasi_region
	
		*fcollapse 
		fcollapse (sum) deaths person_years, by(age_group female caste_religion adivasi_region)
		
		*Estimate nmx
		g nmx = deaths / person_years
		
		*Merge srs
		merge m:1 female age_group using `srs', nogen

		*Sort and order
		sort female caste_religion age_group

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
			by adivasi_region female caste_religion: replace lx = (lx[_n-1]*(1-nqx[_n-1])) if _n==`i'
		}
		
		*nLx
		cap drop nLx
		gen nLx=.
		forval i=1(1)18 {
			by adivasi_region female caste_religion: replace nLx = (lx[_n+1]*n) + (lx*nqx*nax) if _n==`i'
		}
		by adivasi_region female caste_religion: replace nLx = lx/nmx if _n==19
		
		*Total PY (for Tx)
		cap drop total_py
		bysort adivasi_region female caste_religion: egen total_py = total(nLx) 

		*Tx
		cap drop Tx
		gen Tx = .
		by adivasi_region female caste_religion: replace Tx = total_py - sum(nLx) + nLx

		*ex
		cap drop ex
		gen ex = Tx / lx
		*replace ex = round(ex, .1)
		
		*Keep only ex's
		keep adivasi_region female caste_religion age_group nmx nmx_srs ex lx
		
		*create a round variable 
		gen round = 4 
		
		*merge standard errors
		merge 1:1 adivasi_region caste_religion female age_group using ///
		"$dir\04_input\resamples\bstraps\nfhs4\nfhs4_ex_se_group_adivasi_region.dta", nogen

		*gen 95% CIs
		gen ex_lci = ex - 1.96*se_ex
		gen ex_uci = ex + 1.96*se_ex
	
		*save	
		saveold "$dir/05_out/estimates/nfhs4_group_adivasi_region_life_tables_se.dta", replace 

	
	