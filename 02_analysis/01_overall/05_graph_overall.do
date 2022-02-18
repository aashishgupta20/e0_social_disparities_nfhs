******************************************************
*File to merge 100 samples from nfhs 4
*And to create a graph with nmx from two sources
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
	log using "$dir/02_logs/nfhs_graph_overall_nmx.txt", text replace
	
*create individual graphs 

	use "$dir/05_out/estimates/nfhs2_overall_life_tables_se.dta", clear 

	append using "$dir/05_out/estimates/nfhs4_overall_life_tables_se.dta"

*modify variables

	*multiply rates by 1,000
	replace nmx = nmx * 1000
	replace nmx_srs = nmx_srs * 1000
	replace nmx_lci = nmx_lci * 1000
	replace nmx_uci = nmx_uci * 1000

	*sort
	sort round female age_group 
	
	*create a variable 
	gen round_female = . 
	replace round_female = 1 if round == 2 & female==1
	replace round_female = 2 if round == 2 & female==0
	replace round_female = 3 if round == 4 & female==1
	replace round_female = 4 if round == 4 & female==0
	lab def rf 1 "a) Female, 1997-2001" 2 "b) Male, 1997-2001" /// 
	3 "c) Female, 2012-2016" 4 "d) Male, 2012-2016"
	lab val round_female rf
	
	*srs labels 
	gen label_srs = "e{subscript:0} SRS (1997-2001)" if round_female == 1 & age_group == 0 
	replace label_srs = "e{subscript:0} SRS (1997-2001)" if round_female == 2 & age_group == 0 
	replace label_srs =  "e{subscript:0} SRS (2012-2016)" if round_female == 3 & age_group == 0 
	replace label_srs =  "e{subscript:0} SRS (2012-2016)" if round_female == 4 & age_group == 0 

	gen label_srs2 = "63.3 years" if round_female == 1 & age_group == 0 
	replace label_srs2 = "61.4 years" if round_female == 2 & age_group == 0 
	replace label_srs2 =  "70.2 years" if round_female == 3 & age_group == 0 
	replace label_srs2 =  "67.4 years" if round_female == 4 & age_group == 0 

	cap drop label_mid
	gen label_mid = "=" if age_group == 0
	
	*nfhs labels
	gen label_nfhs = "e{subscript:0} NFHS (1997-2000)" if round_female == 1 & age_group == 0 
	replace label_nfhs = "e{subscript:0} NFHS (1997-2000)" if round_female == 2 & age_group == 0 
	replace label_nfhs =  "e{subscript:0} NFHS (2013-2016)" if round_female == 3 & age_group == 0 
	replace label_nfhs =  "e{subscript:0} NFHS (2013-2016)" if round_female == 4 & age_group == 0 

	gen label_nfhs2 = "61.3 years [95% CI 60.7-62.0]" if round_female == 1 & age_group == 0 
	replace label_nfhs2 = "60.6 years [95% CI: 60.0-61.1]" if round_female == 2 & age_group == 0 
	replace label_nfhs2 =  "69.6 years [95% CI: 69.3-69.9]" if round_female == 3 & age_group == 0 
	replace label_nfhs2 =  "66.0 years [95% CI: 65.7-66.3]" if round_female == 4 & age_group == 0 

	gen label_join = "--" if age_group == 0 
	
	*srs label position 
	gen srs_lp_x = 28
	gen srs_lp_y = 0.65
	
	gen srs_lp2_x = 51
	gen srs_lp2_y = 0.65

	*nfhs label position 
	gen nfhs_lp_x = 28
	gen nfhs_lp_y = 1
	
	gen nfhs_lp2_x = 51
	gen nfhs_lp2_y = 1
	
	*equal to position
	gen join_lp_x = 49
	gen join_lp_y1 = 1
	gen join_lp_y2 = 0.65
	
*make a by-graph 

	# d ;
	graph twoway 
	(connected nmx age_group, msymbol(Sh) msize(*.9))
	(connected nmx_srs age_group, msymbol(Oh) lpattern(dash)) 
	(rarea nmx_lci nmx_uci age_group, color(navy%50) lwidth(none))
	(scatter srs_lp_y srs_lp_x, mlabel(label_srs) mlabsize(*.8) mlabcolor(maroon%75) msymbol(none))
	(scatter nfhs_lp_y nfhs_lp_x, mlabel(label_nfhs) mlabsize(*.8) mlabcolor(navy%75) msymbol(none))
	(scatter srs_lp2_y srs_lp2_x, mlabel(label_srs2) mlabsize(*.8) mlabcolor(maroon%75) msymbol(none))
	(scatter nfhs_lp2_y nfhs_lp2_x, mlabel(label_nfhs2) mlabsize(*.8) mlabcolor(navy%75) msymbol(none))
	(scatter join_lp_y2 join_lp_x, mlabel(label_join) mlabsize(*.8) mlabcolor(maroon%75) msymbol(none))
	(scatter join_lp_y1 join_lp_x, mlabel(label_join) mlabsize(*.8) mlabcolor(navy%75) msymbol(none))
	,
	by(round_female, ///
		note("") ///
		graphregion(fcolor(white) lcolor(white)) ///
		row(2) ///
		) ///
	xlabel(0 "0" 10 "10 years" 20(10)80,  labs(*1)) ///
	ylabel(.5 2.5 25 250, nogrid  labs(*1)) ///
	ysc(log r(.4 275)) ///
	xtitle("") ///
	graphregion(fcolor(white) lcolor(white)) ///
	ytitle("Mortality rates per 1,000 ({subscript:n}m{subscript:x})", size(*.95)) ///
	legend(order(2 "SRS" 1 "NFHS") ///
		row(1) bmargin(tiny) lcolor(white) region(lcolor(white)) size(*.95)) ///
	xsize(1.8) ysize(1) ///
	subtitle(, fcolor(white) lcolor(white))	
	;
	# d cr
	graph save "$dir\05_out\figures\nmx_overall.gph", replace
	graph export "$dir\05_out\figures\nmx_overall.pdf", replace
	graph export "$dir\05_out\figures\nmx_overall.tif", width(1000) replace
	graph export "$dir\05_out\figures\nmx_overall.eps", replace


