**************************************************
*Project: Caste and mortality
*Purpose: Use birth history data to estimate child mortality
**************************************************

**************************************************
*Preamble
**************************************************

	clear all
	set more off
	
	*Set user


	*Log
	cap log close
	log using "$dir/02_logs/01build_nfhs2_clean_births_data.txt", text replace

**************************************************
*Prepare dataset
**************************************************

	*Load in data
	use "$dir/00_raw/IABR42FL.dta", clear
	
	*Keep only necessary variables
	keep bidx v001 v002 v003 v004 v005 v006 v007 v008 v016 v024 v023 v135 ///
	v130 v131 v024 bord b0 b1 b2 b3 b4 b5 b6 b7 v025

	*Drop non-residents
	drop if v135==2

**************************************************	
*Set up key dates
**************************************************
	
	*Date of birth

		*Clean birth year
		replace b2 = 1900 + b2 
		replace b2 = 2000 if b2 == 1900

		*Month of birth is clean

		*Make birth date	
		gen birth_date = ym(b2, b1)
		format birth_date %tm
		
	*Date of exit
	
		*Make an indicator for died
		cap drop died
		gen died = b5 == 0 
	
		*Date of death for those who died
		gen death_date = birth_date + b7 + 1 if died==1
		format death_date %tm
		
		*Date of interview for those who survived
		replace v007 = 1999 if v007 == 99
		replace v007 = 1998 if v007 == 98
		replace v007 = 2000 if v007 == 0
		cap drop interview_date 
		gen interview_date = ym(v007, v006)
		format interview_date %tm 
		
		*exit date 
		gen exit_date = . 
		replace exit_date = death_date if died == 1 
		replace exit_date = interview_date if died == 0 
		replace exit_date = exit_date + 0.1 if exit_date == birth_date
	
**************************************************
*Clean other important variables
**************************************************

	*Make caste/religion variable
	cap drop caste_religion
	gen caste_religion=.
	replace caste_religion=1 if v131==1
	replace caste_religion=2 if v131==2
	replace caste_religion=3 if v130==2 & v131>2
	replace caste_religion=4 if v131==3 & v130 == 1
	replace caste_religion=5 if v131==4 & v130==1
	replace caste_religion=5 if v131==. & v130==1
	replace caste_religion=6 if v130>2 & v131>2 
	replace caste_religion=6 if v130>2 & v131==.
	label define caste_religion_label 1 "SC" 2 "ST" 3 "Muslim" ///
	4 "OBC" 5 "HC" 6 "Others/Missing"
	label values caste_religion caste_religion_label
	tab caste_religion, m
	tab caste_religion v131, m 
	tab caste_religion v130, m 
	tab v131 v130, m 
	
	*Regions
	g region = .
	replace region = 1 if inlist(v024,2,10,11,22) // South
	replace region = 2 if inlist(v024,5,6,13) // West
	replace region = 3 if inlist(v024,18,23) // East
	replace region = 4 if inlist(v024,7,19,30,8,9) // North
	replace region = 5 if inlist(v024,4,12,20,24) // Hindi belt 
	replace region = 6 if inlist(v024,3,14,15,16,17,21,34,35) // North east 
	la de region 1 "1.South" 2 "2. West" 3 "3.East" 4 "4.North" 5 "5.Hindi belt" 6 "6.Northeast"
	la val region region

	*Create female variable
	cap drop female
	gen female = (b4==2)
	
	*Create sample weight
	cap drop sample_weight
	gen sample_weight=v005/1000000

**************************************************
*Convert to person-month time
**************************************************

	*Gen an id
	gen id = _n
	
	*STset
	stset exit_date, failure(died) origin(birth_date) id(id)
	
	*STsplit
	stsplit split, every(1)
	
	*Running count of person-month obs
	bysort id: gen pm_obs = _n
		
	*Time varying date
	gen tv_date = birth_date + pm_obs - 1 
	format tv_date %tm 

	*Time varying age
	gen tv_age = (pm_obs - 1) / 12 
	
*Restrictions
	
	*No person-months above 5
	drop if tv_age >=5 

	*Restrict to two years prior to interview date
	drop if tv_date < interview_date - 24
	
	*age groups of 0-1, 1-4
	egen age_group = cut(tv_age), at(0,1,5)
	drop if age_group == .

**************************************************
*Collapse into death rates
**************************************************
	*keep only what's necessary
	keep v024 v023 v025 v001 ///
	region age_group female caste_religion sample_weight _d _t0
	
	*deaths and person years by sample weights 
	g deaths = _d*sample_weight
	g person_years = sample_weight / 12
	replace person_years = sample_weight / 24 if _d == 1 & _t0 == 0
	
	*save person years 
	save "$dir/04_input/nfhs2_child_person_years.dta", replace
	
log close
