**************************************************
*Project: Caste and mortality
*Purpose: Use birth history data to gen child mortality
*Last modified: 20 Feb 2021 by AG
**************************************************

**************************************************
*Preamble
**************************************************
	
	clear all
	set more off
	set maxvar  32767, perm 
	
	
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
	log using "$dir/02_logs/01build_nfhs4_clean_births_data.txt", text replace

**************************************************
*Prepare dataset
**************************************************

	*save dataset with caste religion information
	use "$dir/00_raw/IAHR71FL.DTA", clear
	keep hv001 hv002 sh36 sh35 sh34
	save "$dir/03_intermediate/nfhs4_hh_social_group.dta", replace
	
	*Load in data
	use "$dir/00_raw/IABR71FL.DTA", clear
	
	*Keep only necessary variables
	keep v001 v002 v003 v005 v006 v007 v016 v024 v025 v130 v131 v135 ///
	b1 b2 b3 b4 b5 b6 b7 b16
	
	*Drop non-residents
	drop if v135==2
	
**************************************************	
*Set up key dates
**************************************************

	*Date of birth
	cap drop birth_date 
	gen birth_date = ym(b2, b1)
	format birth_date %tm

	*Date of exit

		*Make an indicator for died
		cap drop died
		gen died = b5 == 0 
				
		*Date of death for those who died
		cap drop death_date
		gen death_date = birth_date + b7 + 1 if died==1
		format death_date %tm

		*Date of interview for those who survived	
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

	*Make caste/religion variable (this is not the same as other waves)
	*need to bring in information on caste and religion from household dataset 
	
		*Merge hh_data
		rename v001 hv001
		rename v002 hv002
		merge m:1 hv001 hv002 using "$dir/03_intermediate/nfhs4_hh_social_group.dta", ///
		keepus(sh36 sh35 sh34)
		drop if _merge == 2
		
		*Make the social group variable
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
		tab sh34 caste_religion, m
		tab caste_religion sh36, m
			
		*Regions
		g region = .
		replace region = 1 if inlist(v024,2,16,17,27,31,36) // South
		replace region = 2 if inlist(v024,8,9,10,11,18,20) // West
		replace region = 3 if inlist(v024,1,26,35) // East
		replace region = 4 if inlist(v024,6,12,13,14,25,28) // North
		replace region = 5 if inlist(v024,5,7,15,19,29,33,34) // Hindi belt 
		replace region = 6 if inlist(v024,3,4,21,22,23,24,30,32) // North east 
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
	
	*deaths and person years by sample weights 
	g deaths = _d*sample_weight
	g person_years = sample_weight / 12
	replace person_years = sample_weight / 24 if _d == 1 & _t0 == 0
	
	*keep necessary variables 
	keep region age_group female caste_religion deaths person_years sample_weight ///
	hv001 region v024 v025
	
	rename hv001 v001 

	*save as person years 
	save "$dir/04_input/nfhs4_child_person_years.dta", replace 

log close
	
