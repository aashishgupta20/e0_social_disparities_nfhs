******************************************************
*File to create 100 samples from nfhs 
*Last modified: July 4 2020, AG
******************************************************

**************************************************
*Preamble
**************************************************
	set more off
	
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
	log using "$dir/02_logs/nfhs2_overall_ci.txt", text replace

**************************************************
*append and merge
**************************************************

	forval x = 1(1)100 {
	use "$dir\04_input\resamples\bstraps\nfhs2\overall\nfhs2_rep`x'_overall.dta", clear 
	keep female age_group nmx lx ex 
	cap rename nmx nmx_rep`x'
	cap rename lx lx_rep`x' 
	cap rename ex ex_rep`x'
	save "$dir\04_input\resamples\bstraps\nfhs2\overall\nfhs2_rep`x'_overall.dta", replace
	}
	
	*fmerge all reps 
	use "$dir\04_input\resamples\bstraps\nfhs2\overall\nfhs2_rep1_overall.dta", clear 
	
	forval x = 2(1)100 {
	fmerge 1:1 female age_group using ///
	"$dir\04_input\resamples\bstraps\nfhs2\overall\nfhs2_rep`x'_overall.dta", nogen 
	}
	

********************************************************
*calculate se	
********************************************************
	preserve
	*ex se 
	keep female age_group ex*
	
	egen mean = rowmean(ex_rep1-ex_rep100)
	
	forval x = 1(1)100 {
	gen dev`x' = (ex_rep`x' - mean)^2
	}
	
	egen dev_total = rowtotal(dev1-dev100)
	gen se_ex = sqrt(dev_total / 99)
	
	keep female age_group se_ex
	gen round = 2
	
	save "$dir\04_input\resamples\bstraps\nfhs2\nfhs2_ex_se_overall.dta", replace
	
	restore 
	
	*nmx se 
	keep female age_group nmx*
	
	egen mean = rowmean(nmx_rep1-nmx_rep100)
	
	forval x = 1(1)100 {
	gen dev`x' = (nmx_rep`x' - mean)^2
	}
	
	egen dev_total = rowtotal(dev1-dev100)
	gen se_nmx = sqrt(dev_total / 99)
	
	keep female age_group se_nmx
	gen round = 2
	
	save "$dir\04_input\resamples\bstraps\nfhs2\nfhs2_nmx_se_overall.dta", replace

	
*********************************************************
*gen estimates, lci and uci 
*********************************************************

	*Import SRS
	use "$dir/00_raw/srs_1997.dta", clear 
	
	gen female = sex == 1 
	
	keep female n nax nmx_srs age_group
	
		*Save
		tempfile srs
		save `srs'

	*Import child person years and append adult person years 
	use "$dir/04_input/nfhs2_child_person_years.dta", clear 
	
	append using "$dir/04_input/nfhs2_adult_person_years.dta"	
	
	*collapse
	fcollapse (sum) deaths person_years ///
	, by(age_group female)
	
		g nmx = deaths / person_years
	
	*Merge srs
	merge m:1 female age_group using `srs', nogen

	*Sort and order
	sort female age_group

	*Order
	order female age_group n nmx nax 

	**Make life tables
	
	*nqx
	cap drop nqx
	gen nqx = (n*nmx) / (1 + (n-nax)*nmx)
	replace nqx = 1 if nqx==.
		
	*radix
	cap drop lx
	sort female age_group
	by female: gen lx = 1 if _n==1
		
	*lx
	forval i=2(1)19 {
		by female : replace lx = (lx[_n-1]*(1-nqx[_n-1])) if _n==`i'
	}
	
	*nLx
	cap drop nLx
	gen nLx=.
	forval i=1(1)18 {
		by female : replace nLx = (lx[_n+1]*n) + (lx*nqx*nax) if _n==`i'
	}
	by female: replace nLx = lx/nmx if _n==19
	
	*Total PY (for Tx)
	cap drop total_py
	bysort female: egen total_py = total(nLx) 

	*Tx
	cap drop Tx
	gen Tx = .
	by female: replace Tx = total_py - sum(nLx) + nLx

	*ex
	cap drop ex
	gen ex = Tx / lx
	
	*Keep only ex's
	keep female age_group nmx nmx_srs ex lx
	
	merge 1:1 female age_group using ///
	"$dir\04_input\resamples\bstraps\nfhs2\nfhs2_ex_se_overall.dta", nogen

	gen ex_lci = ex - 1.96*se_ex
	gen ex_uci = ex + 1.96*se_ex
	
	merge 1:1 female age_group using ///
	"$dir\04_input\resamples\bstraps\nfhs2\nfhs2_nmx_se_overall.dta", nogen 

	gen nmx_lci = nmx - 1.96*se_nmx
	gen nmx_uci = nmx + 1.96*se_nmx
	

********************************************************
*save 
*******************************************************

	saveold "$dir/05_out/estimates/nfhs2_overall_life_tables_se.dta", replace 
	
************************************************************
*make a graph 
***********************************************************
		
	*make a male variable
	cap drop male 
	gen male = female == 0 
	lab def male 0 "female" 1 "male"
	lab val male male 
	
	*labels for graphs 
	format ex %9.1f
	format ex_lci %9.2f
	format ex_uci %9.2f
	
	local e0_srs_male = 60.6
	local e0_srs_female = 61.3
	
	*replace 
	replace nmx = nmx * 1000
	replace nmx_srs = nmx_srs * 1000
	replace nmx_lci = nmx_lci * 1000
	replace nmx_uci = nmx_uci * 1000
	
	local x = 1
	local male1 = "male"
	local male2 = "female"
	
	local e0_srs_r4_s0 = 61.2
	local e0_srs_r4_s1 = 62.7
	
	local e0_nfhs_r4_s0 = 60.6
	local e0_nfhs_r4_s1 = 61.3
	
	*male 
	# d ;
		twoway
		(connected nmx age_group if female==0, msymbol(S) msize(small))
		(connected nmx_srs age_group if female==0, lpattern(dash)) ///
		(rarea nmx_lci nmx_uci age_group if female == 0, color(navy%50) lwidth(none)),
		xlabel(0 "0" 10 "10 years" 20(10)80,  labs(*1.25)) 
		ylabel(.5 2 20 250, nogrid  labs(*1.25)) 
		ysc(log r(.4 275)) ///
		xtitle("")
		graphregion(fcolor(white) lcolor(white)) 
		ytitle("mortality rates per 1,000 ({subscript:n}m{subscript:x})", size(*1.3))
		text(.75 47.6 `"e{subscript:0} SRS (1997-2001) = 61.4 years"', size(*.9) color(maroon))
		text(1 55 `"e{subscript:0} NFHS (1997-2000) = 60.6 years [95% CI 60.0-61.1]"', size(*.9) color(navy))
		legend(off)
		subtitle("Male", size(*1.5))
	;
	# d cr
	graph save "$dir/05_out/figures/srs_nfhs2_nmx_male.gph", replace
	
	*female
	# d ;
		twoway
		(connected nmx age_group if female==1, msymbol(S) msize(small))
		(connected nmx_srs age_group if female==1, lpattern(dash)) ///
		(rarea nmx_lci nmx_uci age_group if female == 1, color(navy%50) lwidth(none)),
		xlabel(0 "0" 10 "10 years" 20(10)80,  labs(*1.25)) 
		ylabel(.5 2 20 250, nogrid  labs(*1.25)) 
		ysc(log r(.4 275)) ///
		xtitle("")
		graphregion(fcolor(white) lcolor(white)) 
		ytitle("mortality rates per 1,000 ({subscript:n}m{subscript:x})", size(*1.3))
		text(.75 47.6 `"e{subscript:0} SRS (1997-2001) = 63.3 years"', size(*.9) color(maroon))
		text(1 55 `"e{subscript:0} NFHS (1997-2000) = 61.3 years [95% CI 60.7-62.0]"', size(*.9) color(navy))
		legend(order(2 "SRS" 1 "NFHS") row(1) pos(11) ring(0) bmargin(tiny) lcolor(white) region(lcolor(white)) size(*1.5))
		subtitle("Female", size(*1.5))
	;
	# d cr
	graph save "$dir/05_out/figures/srs_nfhs2_nmx_female.gph", replace
	
	*combine
	graph combine /// 
	"$dir/05_out/figures/srs_nfhs2_nmx_female.gph" ///
	"$dir/05_out/figures/srs_nfhs2_nmx_male.gph", ///
	row(1) ///
	xsize(4) ysize(1.4) ///
	graphregion(fcolor(white) lcolor(white)) 
	graph save "$dir/05_out/figures/srs_nfhs2_nmx.gph", replace
	graph export "$dir/05_out/figures/srs_nfhs2_nmx.pdf", replace
	

	
