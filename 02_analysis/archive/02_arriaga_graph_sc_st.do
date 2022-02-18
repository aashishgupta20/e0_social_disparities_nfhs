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
	
	*drops 
	drop te_mu_hc te_obc_hc

	*gen age cut points that are broader 
	egen age_a = cut(age_group), at(0, 5, 15, 30, 45, 60, 85)
	replace age_a = 60 if age_group == 85

	*gen contributions 
	gen contribution_sc = te_sc_hc
	gen contribution_st = te_st_hc
	*gen contribution_mu = te_mu_hc
	drop te* 
	
	*reshape 
	collapse (sum) contribution*, by(female round age_a)	
	
	save "$dir\05_out\estimates\nfhs_arriaga_contributions_collapsed_scst.dta", replace 

********************************************************************************
*GENERATE ARRIAGA SEs
********************************************************************************

	*bring in the arriaga contributions bootstraps
	use "$dir\04_input\resamples\arriaga_bstraps\round2_rep1.dta", clear
	
	forval rep = 2(1)100 {
	append using "$dir\04_input\resamples\arriaga_bstraps\round2_rep`rep'.dta"
	}
	
	forval rep = 1(1)100 {
	append using "$dir\04_input\resamples\arriaga_bstraps\round4_rep`rep'.dta"
	}
	
	*drops 
	drop te_mu_hc te_obc_hc

	*gen age cut points that are broader 
	egen age_a = cut(age_group), at(0, 5, 15, 30, 45, 60, 85)
	replace age_a = 60 if age_group == 85

	*gen contributions 
	gen contribution_sc = te_sc_hc
	gen contribution_st = te_st_hc
	*gen contribution_mu = te_mu_hc
	drop te* 
	
	*reshape 
	collapse (sum) contribution*, by(female round rep age_a)	
	bysort female round age_a: egen sd_c_sc = sd(contribution_sc)
	bysort female round age_a: egen sd_c_st = sd(contribution_st)

	*generate total contributions for each rep, round, and rep
	sort female round age_a rep
	bysort female round rep: egen total_c_sc = total(contribution_sc)
	bysort female round rep: egen total_c_st = total(contribution_st)

	*gen proportional contriutions 
	gen prop_c_sc = contribution_sc * 100 / total_c_sc 
	gen prop_c_st = contribution_st * 100 / total_c_st 

	*check if the totals include 100
	bysort female round rep: egen total_prop_sc = total(prop_c_sc)
	*works
	drop total_prop_sc
	
	
	*generate SDs for proportoon 
	bysort female round age_a: egen sd_p_sc = sd(prop_c_sc)
	bysort female round age_a: egen sd_p_st = sd(prop_c_st)
	
	*save summary stats for merge 
	collapse sd_c_sc sd_c_st sd_p_sc sd_p_st, by(round female age_a)
	
	merge 1:1 round female age_a using ///
	"$dir\05_out\estimates\nfhs_arriaga_contributions_collapsed_scst.dta", nogen
	
	*generte total contribution 
	bysort female round: egen total_c_sc = total(contribution_sc)
	bysort female round: egen total_c_st = total(contribution_st)
	
	*generate relative contribution
	gen p_c_sc = contribution_sc * 100 / total_c_sc
	gen p_c_st = contribution_st * 100 / total_c_st
	drop total*
	
	
	
	reshape long contribution_ p_c_ sd_c_ sd_p_, i(female round age_a) j(comparison) string
	rename contribution_ contribution 
	rename sd_c_ se_c 
	rename sd_p_ se_p 
	rename p_c_ proportion

	*stacked bar 
	sort female comparison round age_a

	*reshape 
	egen id = group(female comparison round)
	reshape wide contribution proportion se_c se_p, i(id)  j(age_a)
	
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
	
	replace comparison = "SC v HC" if comparison == "sc"
	replace comparison = "ST v HC" if comparison == "st"
	*replace comparison = "2. Mu. v HC" if comparison == "mu"
	
	
*	reshape long contribution_, i(female round age_a) j(comparison) string
*	rename contribution_ contribution 
	

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
	xsize(18) ysize(10)
	
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


	