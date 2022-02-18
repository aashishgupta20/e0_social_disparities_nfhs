******************************************************
*File to create graph life expectancy disparities 
*by group, for e0
*Last modified: Feb 23 2021, AG
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
	log using "$dir/02_logs/02analysis_graph_ex_group.txt", text replace
	
****************************************************
*append datasets from the two rounds 
****************************************************

	use "$dir/05_out/estimates/nfhs2_group_life_tables_se.dta", clear 

	append using "$dir/05_out/estimates/nfhs4_group_life_tables_se.dta"
	
**********************************************************************
*lx 
**********************************************************************

	cap drop survivors
	gen survivors = lx * 1000
	
	cap drop survivors_uci 
	cap drop survivors_lci
	
	gen survivors_uci = lx_uci * 1000
	gen survivors_lci = lx_lci * 1000


	local x = 0
	local male0 = "male"
	local male1 = "female"
	
	local y = 2 
	local round2 = "1997-2000"
	local round4 = "2013-2016"
	
	
	
	
	foreach round in 2 4 {
	
	foreach sex in 0 1 {
	
	graph twoway ///
	(connected survivors age_group ///
		if female == `sex' & round == `round' ///
		& caste_religion==1, ///
		msymbol(Dh) msize(vsmall) lcolor(navy) mcolor(navy%50) lpattern(dash_dot)) ///
	(connected survivors age_group ///
		if female == `sex' & round == `round' ///
		& caste_religion==2, ///
		msymbol(Sh)  msize(vsmall) lcolor(sienna) mcolor(sienna%50) lpattern(dash)) ///
	(connected survivors age_group ///
		if female == `sex' & round == `round' ///
		& caste_religion==3, ///
		msymbol(Sh)  msize(vsmall) lcolor(dkgreen) mcolor(dkgreen%50) lpattern(dash_dot)) ///
	(connected survivors age_group ///
		if female == `sex' & round == `round' ///
		& caste_religion==4, ///
		msymbol(Dh)  msize(vsmall) lcolor(red) mcolor(red%50) lpattern(longdash)) ///
	(connected survivors age_group ///
		if female == `sex' & round == `round' ///
		& caste_religion==5, ///
		msymbol(Th)  msize(vsmall) lcolor(orange) mcolor(orange%50) lpattern(longdash_dot)) ///
	(rarea survivors_uci survivors_lci age_group  ///
		if female == `sex' & round == `round' & ///
		caste_religion==1, ///
		color(navy%20) lwidth(none)) ///
	(rarea survivors_uci survivors_lci age_group ///
		if female == `sex' & round == `round' ///
		& caste_religion==2, ///
		color(sienna%20) lwidth(none)) ///
	(rarea survivors_uci survivors_lci age_group ///
		if female == `sex' & round == `round' ///
		& caste_religion==3, ///
		color(dkgreen%20) lwidth(none)) ///
	(rarea survivors_uci survivors_lci age_group ///
		if female == `sex' & round == `round' ///
		& caste_religion==4, ///
		color(red%20) lwidth(none)) ///
	(rarea survivors_uci survivors_lci age_group ///
		if female == `sex' & round == `round' ///
		& caste_religion==5, ///
		color(orange%20) lwidth(none))  ///	
	, ///
	graphregion(fcolor(white) lcolor(white)) ///
	legend(order(1 "Scheduled Caste" 2 "Scheduled Tribes" 3 "Muslim" 4 "Other Backward Classes" 5 "High Caste") ///
	subtitle("") region(lcolor(white)) row(1) size(vsmall) stack symp(12) keygap(*-1.5)) ///
	xtitle("") xlabel(0 "0" 10 "10 years" 20(10)80) ///
	ytitle("") ///
	ylabel(0(250)1000,nogrid) ///
	subtitle("`male`sex'', `round`round''", pos(1) ring(0) margin(small)) 
	graph save "$dir\05_out\figures\lx_group_round`round'_male`sex'.gph", replace

	local x = `x'+1

	}
	
	local y = `y' + 2 
	
	}
	
	
	grc1leg ///
	"$dir\05_out\figures\lx_group_round2_male0.gph" ///
	"$dir\05_out\figures\lx_group_round2_male1.gph" ///
	"$dir\05_out\figures\lx_group_round4_male0.gph" ///
	"$dir\05_out\figures\lx_group_round4_male1.gph" ///
	, ///
	graphregion(fcolor(white) lcolor(white)) ///
	xcom row(2) name(lx_caste, replace) ///
	span note("{break}" ///
	"Note: 95% CIs calculated using a cluster-bootstrap approach." ///
	"The number of bootstrap samples drawn was 100.", size(vsmall) pos(6))
	
	graph display lx_caste, xsize(3) ysize(2) 
	graph export "$dir\05_out\figures\lx_caste_present.pdf", replace

	
	
	
********************************************************************************************************
*nmx, caste religion 

	cap drop ln_nmx
	gen ln_nmx = ln(nmx*1000)

	
	
	foreach round in 2 4 {
	
	foreach sex in 0 1 {
	
	graph twoway ///
	(connected ln_nmx age_group if female == `sex' & round == `round' & caste_religion==1, ///
		msymbol(Dh) msize(vsmall) lcolor(navy%50) mcolor(navy%50) lpattern(solid)) ///
	(connected ln_nmx age_group if female == `sex' & round == `round' & caste_religion==2, ///
		msymbol(Th)  msize(vsmall) lcolor(sienna%50) mcolor(sienna%50) lpattern(solid)) ///
	(connected ln_nmx age_group if female == `sex' & round == `round' & caste_religion==3, ///
		msymbol(Sh)  msize(vsmall) lcolor(dkgreen%50) mcolor(dkgreen%50) lpattern(solid)) ///
	(connected ln_nmx age_group if female == `sex' & round == `round' & caste_religion==4, ///
		msymbol(Dh)  msize(vsmall) lcolor(red%50) mcolor(red%50) lpattern(solid)) ///
	(connected ln_nmx age_group if female == `sex' & round == `round' & caste_religion==5, ///
		msymbol(Th)  msize(vsmall) lcolor(orange%50) mcolor(orange%50) lpattern(solid)) ///
	, ///
	graphregion(fcolor(white) lcolor(white)) ///
	legend(order(1 "Scheduled Caste" 2 "Scheduled Tribes" 3 "Muslim" 4 "Other Backward Classes" 5 "High Caste") ///
	subtitle("") region(lcolor(white)) row(1) size(vsmall) stack symp(12) keygap(*-1.5)) ///
	xtitle("") xlabel(0 "0" 10 "10 years" 20(10)80) ///
	ytitle("") ///
	ylabel(-1.3862944 ".25" .91629073 "2.5" 3.22 "25" 5.52 "250",nogrid) ///
	yscale(range(-1.3862944 5.52)) ///
	subtitle("`male`sex'', `round`round''", pos(11) ring(0) margin(small)) 
	graph save "$dir\05_out\figures\nmx_caste_religion_round`round'_male`sex'.gph", replace

	local x = `x'+1

	}
	
	local y = `y' + 2 
	
	}
	
	
	grc1leg ///
	"$dir\05_out\figures\nmx_caste_religion_round2_male0.gph" ///
	"$dir\05_out\figures\nmx_caste_religion_round2_male1.gph" ///
	"$dir\05_out\figures\nmx_caste_religion_round4_male0.gph" ///
	"$dir\05_out\figures\nmx_caste_religion_round4_male1.gph" ///
	, ///
	graphregion(fcolor(white) lcolor(white)) ///
	xcom row(2) name(nmx_caste, replace) ///
	span
	
	graph display nmx_caste, xsize(3) ysize(2) 
	graph export "$dir\05_out\figures\nmx_caste_religion_present.pdf", replace
