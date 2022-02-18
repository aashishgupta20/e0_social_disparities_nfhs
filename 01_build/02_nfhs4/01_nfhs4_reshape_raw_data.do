**************************************************
*Project: Caste and mortality
*Purpose: Reshape the raw NFHS 4 data for adults
**************************************************

**************************************************
*Preamble
**************************************************

	clear all
	set more off
	set maxvar 20000

	*Set user


	*Log
	cap log close
	log using "$dir/02_logs/01build_nfhs4_clean_hh.txt", text replace

**************************************************
*Start
**************************************************

	*Load in raw hh data
	use "$dir/00_raw/IAHR71FL.DTA", clear
	
	*Keep only necessary files
	keep hv001 hv002 hv003 hv005 hv006 hv007 ///
	hv008 hv016 hv024 hv025 sh34 sh35 sh36 hvidx* hv102* ///
	hv104* hv105* sh73* sh74* sh75* 
	
	*Index households
	cap drop hid 
	gen hid = _n 

	*Rename variables for dead individuals to start at id 51
	foreach var in sh73 sh74u sh74n sh75m sh75y {
		forval i=1(1)5 {
			rename `var'_`i' `var'_5`i'
		}
	}

	*Rename the suffixes from 0i to i (for reshaping later)
	foreach var in hvidx hv102 hv104 hv105 {
			forval i=1(1)9 {
				rename `var'_0`i' `var'_`i'
			}
		}

	*Reshape the data to be one line per indv
	reshape long hvidx_ hv102_ hv104_ hv105_ sh73_ sh74u_ ///
	sh74n_ sh75m_ sh75y_ ///
	,i(hid) j(pid)

	*Remove the underscore from all the variable ends
	foreach var in hvidx hv102 hv104 hv105 sh73 sh74u ///
	sh74n sh75m sh75y {
		rename `var'_ `var'
	}

**************************************************
*Label all the variables	
**************************************************

	label var hvidx "line number"
	label var hv102 "usual resident"
	label var hv104 "sex of household member"
	label var hv105 "age of household member"
	label var sh73  "sex of deceased member"
	label var sh74u "age when died (units)"
	label var sh74n "age when died (number)"
	label var sh75m "month of death"
	label var sh75y "year of death"

**************************************************
*Save the reshaped data
**************************************************

	save "$dir/03_intermediate/nfhs4_reshaped_raw.dta", replace

log close
 
