**************************************************
*Project: Caste and mortality
*Purpose: Clean reshaped NFHS 2 data for adults
**************************************************

**************************************************
*Preamble
**************************************************

	clear all
	set more off
	
	*Set user


	*Log
	cap log close
	log using "$dir/02_logs/01build_nfhs2_clean_reshaped_data.txt", text replace

**************************************************	
*Prepare dataset
**************************************************

	*Load in dataset
	use "$dir/03_intermediate/nfhs2_reshaped_raw.dta", clear
	
	*Drop non-people observations created by reshape
	drop if hvidx == . & idxh5 == .
	
	*Drop people who were below age 5 (either at death or at interview)
	drop if hv105 < 5
	drop if inlist(sh55u,1,2)
	drop if sh55n < 5 & sh55u == 3

	*Restrict sample to only usual residents
	drop if hv102==0

**************************************************	
*Set up key dates
**************************************************

	*Date of entry
	gen entry_date = ym(1996,1)
	format entry_date %tm
	
	*Date of death
	
		*Make an indicator for died
		cap drop died
		gen died = (idxh5<.)
		
		*Set missing codes to missing
		replace sh56m = . if sh56m == 98
		replace sh56y = . if sh56y == 9998
		
		*Make date of death
		gen death_date = ym(sh56y, sh56m) + 1
		sum death_date, detail
		local median = r(p50)
		replace death_date = `median' if death_date == . & died == 1
		format death_date %tm
		
	*Date of interview
		
		*Recode year
		recode hv007 0 = 2000 98 = 1998 99 = 1999

		*Gen date
		cap drop interview_date
		gen interview_date = ym(hv007,hv006)
		format interview_date %tm
		
	*Make a single date exit
	g exit_date = death_date if died == 1
	replace exit_date = interview_date if died == 0
	replace exit_date = exit_date + 0.1 if entry_date == exit_date
	
	*Birth date (by back calculation)
	
		*Gen a random month of birth
		g birth_month = floor((12)*runiform() + 1)
			
		*Make age at exit variable
		
			*Clean death age
			drop if sh55u == 9
			recode sh55n 96=. 97=. 98=.

			*Age at interview for those who survived (already clean)

			*Make exit age
			cap drop exit_age
			g exit_age = sh55n if died == 1
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
	replace female=(sh54==2) if died==1
	
	*Make caste/religion variable
	cap drop caste_religion
	gen caste_religion=.
	replace caste_religion=1 if sh41==1
	replace caste_religion=2 if sh41==2
	replace caste_religion=3 if sh39==2 & sh41>2
	replace caste_religion=4 if sh41==3 & sh39 == 1 
	replace caste_religion=5 if sh41==4 & sh39==1
	replace caste_religion=5 if sh41==. & sh39==1
	replace caste_religion=6 if sh39>2 & sh41>2
	replace caste_religion=6 if sh39>2 & sh41==.
	label define caste_religion_label 1 "SC" 2 "ST" 3 "Muslim" ///
	4 "OBC" 5 "HC" 6 "Others/Missing"
	label values caste_religion caste_religion_label	
	tab caste_religion, m
	tab caste_religion sh41, m
	tab caste_religion sh39, m
	tab sh39 sh41, m
	

	
	*Regions
	g region = .
	replace region = 1 if inlist(hv024,2,10,11,22) // South
	replace region = 2 if inlist(hv024,5,6,13) // West
	replace region = 3 if inlist(hv024,18,23) // East
	replace region = 4 if inlist(hv024,7,19,30,8,9) // North
	replace region = 5 if inlist(hv024,4,12,20,24) // Hindi belt 
	replace region = 6 if inlist(hv024,3,14,15,16,17,21,34,35) // North east 
	la de region 1 "1.South" 2 "2. West" 3 "3.East" 4 "4.North" 5 "5.Hindi belt" 6 "6.Northeast"
	la val region region
	
	*Make sample weight
	cap drop sample_weight
	gen sample_weight = hv005/1000000 //This is what DHS says to do
	
	*Clean the h out of variables 
	rename hv025 v025
	rename hv024 v024
	rename hv023 v023
	rename hv001 v001

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

	*save person years 
	keep v024 v023 v025 v001 ///
	region age_group female caste_religion sample_weight _d _t0
	
	*deaths and person years by sample weights 
	g deaths = _d*sample_weight
	g person_years = sample_weight / 12 
	replace person_years = sample_weight / 24 if _d == 1 & _t0 == 0
	
	*note on variables in this dataset: 
	*v001, v023, v024, v025, female, caste_religion, region, sample_weight, 
	*_d, _t0, age_group, deaths, person_years
	
	save "$dir/04_input/nfhs2_adult_person_years.dta", replace
			
log close
