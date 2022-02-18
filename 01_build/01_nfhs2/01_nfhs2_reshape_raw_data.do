*Caste and mortality - Reshape raw NFHS 2 HH data
*Last modified feb 11 2021 by ag

*Preamble

	clear all
	set more off
	
	if "$dir"=="" {
	
		*Set user
		local user "aashish" // "nikkil" // 
		
		if "`user'"=="nikkil" {
			global dir "/Users/Nikkil/Dropbox/India Mortality/data_analysis"
		}
		if "`user'"=="aashish" {
			global dir "D:\RDProfiles\aashishg\Dropbox\My PC (PSCStat02)\Desktop\caste"
		}

	}


	*Log
	cap log close
	log using "$dir/02_logs/01build_nfhs2_reshape_raw_data.txt", text replace
	
*Start
	
	*Load raw hh data
	use "$dir/00_raw/IAHR42FL.DTA", clear

	*Index the households
	cap drop hid
	gen hid = _n

	*Rename variables for dead individuals to start at id 51
	foreach var in idxh5 sh54 sh55u sh55n sh55c sh56m sh56y ///
	sh56c sh57 sh58 sh59 sh60 sh61 sh62 {
		forval i=1(1)4 {
			rename `var'_`i' `var'_5`i'
		}

	}
 
	*Rename the suffixes from 0i to i (for reshaping later)
	foreach var in hvidx hv101 hv102 hv103 hv104 hv105 hv106 ///
	hv107 hv108 hv109 hv110 hv111 hv112 hv113 hv114 hv115 ///
	hv116 hv117 hv118 sh09 sh11 sh12 sh13 sh14 sh16 sh17 ///
	sh18 sh19 sh20 sh21 sh22 sh23 sh24 sh25 sh26 sh27 shed4 ///
	shed6 shage idxh4 {
		forval i=1(1)9 {
			rename `var'_0`i' `var'_`i'
		}
	}

	*Reshape the data to be one line per indv
	reshape long hvidx_ hv101_ hv102_ hv103_ hv104_ ///
	hv105_ hv106_ hv107_ hv108_ hv109_ hv110_ ///
	hv111_ hv112_ hv113_ hv114_ hv115_ hv116_ ///
	hv117_ hv118_ idxh4_ sh09_ sh11_ sh12_ sh13_ ///
	sh14_ sh16_ sh17_ sh18_ sh19_ sh20_ sh21_ sh22_ ///
	sh23_ sh24_ sh25_ sh26_ sh27_ shed4_ shed6_ ///
	shage_ idxh5_ sh54_ sh55u_ sh55n_ sh55c_ sh56m_ ///
	sh56y_ sh56c_ sh57_ sh58_ sh59_ sh60_ sh61_ ///
	sh62_, i(hid) j(pid)

	*Remove the underscore from all the variable ends
	foreach var in hvidx hv101 hv102 hv103 hv104 ///
	hv105 hv106 hv107 hv108 hv109 hv110 ///
	hv111 hv112 hv113 hv114 hv115 hv116 ///
	hv117 hv118 idxh4 sh09 sh11 sh12 sh13 ///
	sh14 sh16 sh17 sh18 sh19 sh20 sh21 sh22 ///
	sh23 sh24 sh25 sh26 sh27 shed4 shed6 ///
	shage idxh5 sh54 sh55u sh55n sh55c sh56m ///
	sh56y sh56c sh57 sh58 sh59 sh60 sh61 sh62 {
		rename `var'_ `var'
	}

*Label all the variables

	label variable	idxh5	"id of people dying"
	label variable	sh54	"sex of people dying"
	label variable	sh55u	"age at death - units"
	label variable	sh55n	"age at death - number"
	label variable	sh55c	"age at death, computed months"
	label variable	sh56m	"date of death - month"
	label variable	sh56y	"date of death - year"
	label variable	sh56c	"date of death cmc"
	label variable	hv102	"usual resident"
	label variable	hv103	"slept last night"
	label variable	hv104	"sex of household member"
	label variable	hv105	"age of household member"
	
*Keep only necessary variables
	keep hid pid hv005 hv006 hv007 hv008 sh54 sh55u ///
	sh55n sh55c sh56m sh56y sh56c hv102 hv104 hv105 idxh5 ///
	hvidx sh39 sh41 hv024 hv025 hv023 hv001 

*Save the reshaped dataset

	save "$dir/03_intermediate/nfhs2_reshaped_raw.dta", replace

log close
