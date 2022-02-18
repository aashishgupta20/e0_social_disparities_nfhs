**************************************************
*Project: Caste and mortality
*Purpose: Clean reshaped NFHS 4 data for adults
*Last modified: 9 June 2019 by NSud
**************************************************

**************************************************
*Preamble
**************************************************

	clear all
	set more off

	*Set directory
	
	*Set user
	local user "aashish" // "nikkil" // 
	
		if "`user'"=="nikkil" {
			global dir "/Users/Nikkil/Dropbox/India Mortality/data_analysis"
		}
		if "`user'"=="aashish" {
			global dir "D:\RDProfiles\aashishg\Dropbox\My PC (PSCStat02)\Desktop\caste"
		}
	
	*Log
	cap log close
	log using "$dir/02_logs/01build_nfhs4_clean_hh.txt", text replace

**************************************************	
*Prepare dataset
**************************************************

	*Load in dataset
	use "$dir/03_intermediate/nfhs4_reshaped_raw.dta", clear

	*Drop no-people observations created by reshape
	drop if hvidx == . & sh73 == .

	*Drop people who were below age 5 (either at death or at interview)
	drop if hv105 < 5
	drop if inlist(sh74u,1,2)
	drop if sh74n < 5 & sh74u == 3

	*Restrict sample to only usual residents
	drop if hv102==0

**************************************************	
*Set up key dates
**************************************************

	*Date of entry
	gen entry_date = ym(2013,1)
	format entry_date %tm
	
	*Date of death
	
		*Make an indicator for died
		cap drop died
		gen died = (sh73<.)
		
		*Set missing codes to missing
		replace sh75m = . if sh75m == 98
		replace sh75y = . if sh75y == 9998
		
		*Make date of death
		gen death_date = ym(sh75y, sh75m) + 1
		sum death_date, detail
		local median = r(p50)
		replace death_date = `median' if death_date == . & died == 1
		format death_date %tm
		
	*Date of interview
	cap drop interview_date
	gen interview_date = ym(hv007,hv006)
	format interview_date %tm
	
	*Make a single date exit
	g exit_date = death_date if died == 1
	replace exit_date = interview_date if died == 0
	replace exit_date = exit_date + 0.1 if entry_date == exit_date
	format exit_date %tm
	
	
	*drop people with an ext date before feb 2013 
	drop if exit_date < entry_date
	
	*Birth date (by back calculation)
	
		*Gen a random month of birth
		set seed 201188
		g birth_month = floor((12)*runiform() + 1)
			
		*Make age at exit variable
		
			*Drop missing death ages
			drop if sh74u == 8

			*Drop missing ages at interview
			drop if hv105 == 98

			*Make exit age
			cap drop exit_age
			g exit_age = sh74n if died == 1
			replace exit_age = hv105 if died == 0
			
		*Now calculate birth year
		
			*Extract exit month
			g exit_month = month(dofm(exit_date))
			g exit_year = year(dofm(exit_date))
		
			*Calculate birth year
			g birth_year = exit_year - exit_age if exit_month >= birth_month
			replace birth_year = exit_year - exit_age - 1 if exit_month < birth_month
			
			*Date of birth
			g birth_date = ym(birth_year, birth_month)
			format birth_date %tm
		
	*Age at entry
	g entry_age = (entry_date - birth_date)/12

**************************************************	
*Clean other important variables
**************************************************
	
	*Make female variable
	cap drop female
	gen female=(hv104==2) if died==0
	replace female=(sh73==2) if died==1
	drop if sh73 == 8
	
	*create a variable for caste & religion
	cap drop caste_religion
	gen caste_religion=.
	replace caste_religion=1 if sh36==1
	replace caste_religion=2 if sh36==2
	replace caste_religion=3 if sh34==2 & sh36>2
	replace caste_religion=4 if sh36==3 & sh34 == 1 
	replace caste_religion=5 if sh34==1 & sh36>3
	replace caste_religion=6 if sh34>2 & sh36>2 
	label define caste_religion 1 "SC" 2 "ST" 3 "Muslim" 4 "OBC" 5 "HC" 6 "Others"
	label values caste_religion caste_religion
	tab caste_religion, m 
	tab caste_religion sh34, m
	tab caste_religion sh36, m

	
	*Regions
	cap drop region 
	g region = .
	replace region = 1 if inlist(hv024,2,16,17,27,31,36) // South
	replace region = 2 if inlist(hv024,8,9,10,11,18,20) // West
	replace region = 3 if inlist(hv024,1,26,35) // East
	replace region = 4 if inlist(hv024,6,12,13,14,25,28) // North
	replace region = 5 if inlist(hv024,5,7,15,19,29,33,34) // Hindi belt 
	replace region = 6 if inlist(hv024,3,4,21,22,23,24,30,32) // North east 
	la de region 1 "1.South" 2 "2. West" 3 "3.East" 4 "4.North" 5 "5.Hindi belt" 6 "6.Northeast"
	la val region region
	
	*Make sample weight
	cap drop sample_weight
	gen sample_weight = hv005/1000000 //This is what DHS says to do

**************************************************	
*Convert to person-month time
**************************************************	

	*Gen an id
	gen id = _n
	
	*STset
	stset exit_date, failure(died) origin(entry_date) id(id)
	
	*STsplit
	stsplit split, every(1)
	
	*Running count of person-month obs
	bysort id: gen pm_obs = _n
	
	*Time varying age
	gen tv_age = entry_age + (1/12)*(pm_obs-1)

	*Time varying date
	gen tv_date = entry_date + pm_obs - 1
	format tv_date %tm 

	*Restrictions
	
		*Drop below 5 obs
		drop if tv_age < 5

		*Restrict to two years prior to interview date
		drop if tv_date < interview_date - 24
		
	*Make an age group with the time varying age
	egen age_group = cut(tv_age), at(5(5)85)
	replace age_group = 85 if tv_age >= 85 & tv_age < .
	
	*Drop people with missing age
	drop if  age_group == .

**************************************************	
*Collapse into death rates
**************************************************	

	*deaths and person years by sample weights 
	g deaths = _d*sample_weight
	g person_years = sample_weight / 12 
	replace person_years = sample_weight / 24 if _d == 1 & _t0 == 0

	*Keep only necessary variables 
	keep deaths person_years age_group female caste_religion region ///
	hv001 sample_weight hv024 hv025 
	
	rename hv001 v001 
	rename hv024 v024
	rename hv025 v025

	*Save person_years data 
	saveold "$dir\04_input\nfhs4_adult_person_years.dta", replace
	
			
log close
