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
	egen age_a = cut(age_group), at(0, 5, 15, 30, 45, 60, 85)
	replace age_a = 60 if age_group == 85

	*gen contributions 
	gen contribution_sc = te_sc_hc
	gen contribution_st = te_st_hc
	gen contribution_mu = te_mu_hc
	gen contribution_obc = te_obc_hc

	drop te* 
	
	*reshape 
	collapse (sum) contribution*, by(female round age_a)	
	
	saveold "$dir\05_out\estimates\nfhs_arriaga_contributions_collapsed_scstmu.dta", replace 

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
	

	*gen age cut points that are broader 
	egen age_a = cut(age_group), at(0, 5, 15, 30, 45, 60, 85)
	replace age_a = 60 if age_group == 85

	*gen contributions 
	gen contribution_sc = te_sc_hc
	gen contribution_st = te_st_hc
	gen contribution_mu = te_mu_hc
	gen contribution_obc = te_obc_hc
	drop te* 
	
	*reshape 
	collapse (sum) contribution*, by(female round rep age_a)	
	bysort female round age_a: egen sd_c_sc = sd(contribution_sc)
	bysort female round age_a: egen sd_c_st = sd(contribution_st)
	bysort female round age_a: egen sd_c_mu = sd(contribution_mu)
	bysort female round age_a: egen sd_c_obc = sd(contribution_obc)

	*generate total contributions for each rep, round, and rep
	sort female round age_a rep
	bysort female round rep: egen total_c_sc = total(contribution_sc)
	bysort female round rep: egen total_c_st = total(contribution_st)
	bysort female round rep: egen total_c_mu = total(contribution_mu)
	bysort female round rep: egen total_c_obc = total(contribution_obc)

	*gen proportional contriutions 
	gen prop_c_sc = contribution_sc * 100 / total_c_sc 
	gen prop_c_st = contribution_st * 100 / total_c_st
	gen prop_c_mu = contribution_mu * 100 / total_c_mu 
	gen prop_c_obc = contribution_obc * 100 / total_c_obc

	*check if the totals include 100
	bysort female round rep: egen total_prop_sc = total(prop_c_sc)
	*works
	drop total_prop_sc
	
	
	*generate SDs for proportoon 
	bysort female round age_a: egen sd_p_sc = sd(prop_c_sc)
	bysort female round age_a: egen sd_p_st = sd(prop_c_st)
	bysort female round age_a: egen sd_p_mu = sd(prop_c_mu)
	bysort female round age_a: egen sd_p_obc = sd(prop_c_obc)
	
	*save summary stats for merge 
	collapse sd_c_sc sd_c_st sd_c_mu sd_c_obc sd_p_sc sd_p_st sd_p_mu sd_p_obc, by(round female age_a)
	
	merge 1:1 round female age_a using ///
	"$dir\05_out\estimates\nfhs_arriaga_contributions_collapsed_scstmu.dta", nogen 
	
	*generte total contribution 
	bysort female round: egen total_c_sc = total(contribution_sc)
	bysort female round: egen total_c_st = total(contribution_st)
	bysort female round: egen total_c_mu = total(contribution_mu)
	bysort female round: egen total_c_obc = total(contribution_obc)
	
	*generate relative contribution
	gen p_c_sc = contribution_sc * 100 / total_c_sc
	gen p_c_st = contribution_st * 100 / total_c_st
	gen p_c_mu = contribution_mu * 100 / total_c_mu
	gen p_c_obc = contribution_obc * 100 / total_c_obc
	drop total*
	
	
*gen 95%CIs 

	foreach group in sc st mu {
	gen uci_c_`group' = contribution_`group' + 1.96 * sd_c_`group'
	gen lci_c_`group' = contribution_`group' - 1.96 * sd_c_`group'
	replace lci_c_`group' = -0.7 if lci_c_`group' < -0.7
	replace uci_c_`group' = 2.5 if  uci_c_`group' > 2.5
	}


	
	
*make a graph 
	gen male = female == 0
	sort female round age_a  
	bysort female round: gen agelabel1 = _n * 3 - 2 
	bysort female round: gen agelabel2 = _n * 3 - 1 
		
	label define sex 0 "Female" 1 "Male"
	label values male sex
	
	local sc1 "b) SC v HC"
	local st1 "a) ST v HC"
	local mu1 "c) Muslim v HC"

	
	*graph
	foreach group in sc st mu {

	graph twoway ///
	(bar contribution_`group' agelabel1 if round==2, ///
		barwidth(.95) fcolor(navy%20)) /// 
	(bar contribution_`group' agelabel2 if round==4, ///
		barwidth(.95) fcolor(maroon%20)) ///
	(rcap uci_c_`group' lci_c_`group' agelabel1 if round==2, lcolor(navy%30) lwidth(thin) msize(0)) ///
	(rcap uci_c_`group' lci_c_`group' agelabel2 if round==4, lcolor(maroon%30) lwidth(thin) msize(0)) ///
	, /// 
	by(male, ///
		note("") ///
		subtitle("``group'1'", size(*.8)) ///
		graphregion(fcolor(white) lcolor(white))) ///
	name(`group') ///
	subtitle(, fcolor(white) bcolor(white)) ///
	ysc(r(-.7 2.5)) ylabel(-0.5(0.5)2.5) ////
	legend(order(1 "1997-2000" 2 "2013-2016") ///
		region(lcolor(none)) size(*.8)) ///
	xlabel(1.5 "0-5" 4.5 "5-10" 7.5 "15-30" 10.5 "30-45" 13.5 "45-60" 16.5 "60+") 
	graph save "$dir/03_intermediate/arriaga_absolute_`group'.gph", replace
	
	}
	
	grc1leg ///
	"$dir/03_intermediate/arriaga_absolute_st.gph" ///
	"$dir/03_intermediate/arriaga_absolute_sc.gph" ///
	"$dir/03_intermediate/arriaga_absolute_mu.gph", ///
	row(3) name(combine) ///
	graphregion(fcolor(white) lcolor(white)) ///
	note("Absolute contribution of age group to difference in life expectancy at birth (years)", ///
		size(*.9) pos(9) orientation(vertical)) ///
	imargin(tiny) ///
	caption("Note: 95% CIs calculated using a cluster-bootstrap approach." ///
	"The number of bootstrap samples drawn was 100. Some CIs may extend beyond y-axis limits.", size(*.5) pos(6))
	
	graph display combine, xsize(2) ysize(3) 
	gr_edit plotregion1.graph1.legend.draw_view.setstyle, style(no)
	gr_edit plotregion1.graph2.legend.draw_view.setstyle, style(no)
	gr_edit plotregion1.graph3.legend.draw_view.setstyle, style(no)
	graph save "$dir/03_intermediate/arriaga_absolute.gph", replace
	graph export "$dir/05_out/figures/arriaga_absolute.pdf", replace
	graph export "$dir/05_out/figures/arriaga_absolute.tif", width(3000) replace
	graph export "$dir/05_out/figures/arriaga_absolute.eps", replace

	
	*for presentation 
	*graph
	
	local sc1 "SC v HC"
	local st1 "ST v HC"
	local mu1 "Muslim v HC"
		
	foreach group in sc st mu {

	graph twoway ///
	(bar contribution_`group' agelabel1 if round==2, ///
		barwidth(.95) fcolor(navy%20)) /// 
	(bar contribution_`group' agelabel2 if round==4, ///
		barwidth(.95) fcolor(maroon%20)) ///
	(rcap uci_c_`group' lci_c_`group' agelabel1 if round==2, lcolor(navy%30) lwidth(thin) msize(0)) ///
	(rcap uci_c_`group' lci_c_`group' agelabel2 if round==4, lcolor(maroon%30) lwidth(thin) msize(0)) ///
	, /// 
	by(male, ///
		note("") ///
		subtitle("``group'1'", size(*1.1)) ///
		graphregion(fcolor(white) lcolor(white)) ///
		row(2)) ///
	name(`group'_present, replace) ///
	subtitle(, fcolor(white) bcolor(white)) ///
	ysc(r(-.7 2.5)) ylabel(-0.5(0.5)2.5) ////
	legend(order(1 "1997-2000" 2 "2013-2016") ///
		region(lcolor(none)) size(*.7)) ///
	xlabel(1.5 "0-5" 4.5 "5-10" 7.5 "15-30" 10.5 "30-45" 13.5 "45-60" 16.5 "60+") 
	graph save "$dir/03_intermediate/arriaga_absolute_`group'_present.gph", replace
	
	}
		
	grc1leg ///
	"$dir/03_intermediate/arriaga_absolute_st_present.gph" ///
	"$dir/03_intermediate/arriaga_absolute_sc_present.gph" ///
	"$dir/03_intermediate/arriaga_absolute_mu_present.gph", ///
	row(1) name(combine_present, replace) ///
	graphregion(fcolor(white) lcolor(white)) ///
	note("Absolute contribution of age group to" ///
	"difference in life expectancy at birth (years)", ///
		size(*.9) pos(9) orientation(vertical)) ///
	imargin(small) ///
	caption("Note: 95% CIs calculated using a cluster-bootstrap approach." ///
	"The number of bootstrap samples drawn was 100. Some CIs may extend beyond y-axis limits.", size(*.5) pos(6))
	
	graph display combine_present, xsize(5) ysize(3) 
	gr_edit plotregion1.graph1.legend.draw_view.setstyle, style(no)
	gr_edit plotregion1.graph2.legend.draw_view.setstyle, style(no)
	gr_edit plotregion1.graph3.legend.draw_view.setstyle, style(no)
	graph save "$dir/03_intermediate/arriaga_absolute_present.gph", replace
	graph export "$dir/05_out/figures/arriaga_absolute_present.pdf", replace
	graph export "$dir/05_out/figures/arriaga_absolute_present.tif", width(3000) replace

	
	