**************************************************
*Project: Caste and mortality							 *
*Purpose: graph arriaga contributions by age		 *
*Last modified: March 4, 2021 by AG					 *
**************************************************

**************************************************
*Preamble													 *
**************************************************
	
	clear all
	set more off
	set maxvar  32767, perm 
	
	
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
	log using "$dir/02_logs/02analysis_nfhs_arriaga_graph.txt", text replace
	
******************************************************
*Work with data
******************************************************

	*bring in estimates
	use "$dir\05_out\estimates\nfhs_arriaga_contributions.dta", clear 

	*gen age cut points that are broader 
	egen age_a = cut(age_group), at(0, 5, 20, 50, 70, 85)
	replace age_a = 70 if age_group == 85

	*gen contributions 
	gen contribution_sc = te_sc_hc
	gen contribution_st = te_st_hc
	gen contribution_mu = te_mu_hc
	drop te* 
	
	*reshape 
	collapse (sum) contribution*, by(female round age_a)
	
	bysort female round: gen agelabel1 = _n * 3 - 2 
	bysort female round: gen agelabel2 = _n * 3 - 1 
	
	foreach group in sc st mu {
		bysort female round: egen total_`group' = total(contribution_`group')
		gen rc_`group' = contribution_`group' *100 / total_`group'
	}
	
	*graph
	foreach group in sc st mu {

	graph twoway ///
	(bar contribution_`group' agelabel1 if round==2) /// 
	(bar contribution_`group' agelabel2 if round==4), /// 
	by(female) name(`group') 
	
	}
	
	*graph
	foreach group in sc st mu {

	graph twoway ///
	(bar rc_`group' agelabel1 if round==2) /// 
	(bar rc_`group' agelabel2 if round==4), /// 
	by(female) name(`group'_rc) ysc(r(-105 150)) ///
	ylabel(-100(50)150)
	
	}
	
	
	
	reshape long contribution_, i(female round age_a) j(comparison) string
	rename contribution_ contribution 
	
	*total contribution
	bysort comparison female round: egen total = total(contribution)
	
	*relative contribition 
	gen relative = contribution * 100 / total 
	

	*stacked bar 
	sort female comparison round age_a
	drop total relative 


	egen id = group(female comparison round)
	reshape wide contribution, i(id) j(age_a) 
	
	label define round 2 "1997-2000" 4 "2013-2016" 
	label values round round
	
	label define sex 0 "Male" 1 "Female"
	label values female sex
	
	label variable contribution0 "0-5"
	label variable contribution5 "5-15"
	label variable contribution15 "15-30"
	label variable contribution30 "30-45"
	label variable contribution45 "45-60"
	label variable contribution60 "60+"
	
	replace comparison = "1. SC v HC" if comparison == "sc"
	replace comparison = "3. ST v HC" if comparison == "st"
	replace comparison = "2. Mu. v HC" if comparison == "mu"

	/*
	
	this graph doesn't work because some muslim contributions are negative, and can't be stacked
	
	sort female comparison 
	graph hbar (asis) ///
	contribution0 contribution5 ///
	contribution15 contribution30 ///
	contribution45 contribution60 ///
	, ///	
	over(round) ///
	by(female comparison, note("") ///
		graphregion(fcolor(white) lcolor(white))) ///
	stack ///
	legend(subtitle("age groups", size(medsmall)) row(1) region(lcolor(white)) size(small)) /// 
	bar(1, color("240 249 232")) bar(2, color("204 249 197")) ///
	bar(3, color("168 221 181")) bar(4, color("123 204 196")) ///
	bar(5, color("67 162 202")) bar(6, color("8 104 172")) ///
	subtitle(, fcolor(white) bcolor(white))  ylabel(, nogrid) note("") caption("") ///
	blabel(bar, position(center) format(%9.2fc) size(vsmall) orient(vertical)) ///
	xsize(27) ysize(10)
	graph export "$dir\05_out\figures\arriaga_stack_four.pdf", replace 
	
	
	graph hbar (asis) ///
	contribution0 contribution5 ///
	contribution15 contribution30 ///
	contribution45 contribution60 ///
	, ///		
	over(round) by(comparison female, note("") ///
	graphregion(fcolor(white) lcolor(white))) stack percent  ///
	legend(subtitle("age groups", size(medsmall)) row(1) region(lcolor(white)) size(small)) ytitle("") /// 
	bar(1, color("240 249 232")) bar(2, color("204 249 197")) ///
	bar(3, color("168 221 181")) bar(4, color("123 204 196")) ///
	bar(5, color("67 162 202")) bar(6, color("8 104 172")) ///
	blabel(bar, position(center) format(%9.1fc) size(vsmall) orient(vertical)) ///	
	subtitle(, fcolor(white) bcolor(white))  ylabel(, nogrid) note("") caption("")
	graph export "$dir\05_out\figures\arriaga_stack_four_percent.pdf", replace 

	*/
	