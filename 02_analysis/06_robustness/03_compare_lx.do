**************************************************
*Project: Caste and mortality							 *
*Purpose: bring in life-tables and estimate 0-5 and 15-60 mortality
*Last modified: April 10, 2021 by AG					 *
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
	log using "$dir/02_logs/02analysis_nfhs_compile.txt", text replace
	
******************************************************
*bring in csv do files from the log quad approach 
*****************************************************

	*nfhs2, female 
	import delimited ///
	"$dir\01_do\02_analysis\06_robustness\log_quad_lt\ex_india_nfhs2_f.csv", clear 
	
	*gen comparable age groups 
	gen x = 0 if _n == 1 
	replace x = 1 if _n == 2 
	replace x = _n * 5 - 10 if _n > 2 
		
	gen age_group = x 	
	replace age_group = 85 if x > 85 
	
	*generate nlx 
	gen n = 1 if x == 0 
	replace n = 4 if x == 1 
	replace n = 5 if x > 1 & x < 110 
	
	gen nlx = lx[_n+1] * n + dx * ax 
	replace nlx = lx / mx if x == 110
	
	collapse mx (sum) dx nlx, by(age_group)
	gen nmx_lq = dx/nlx
	
	drop mx dx nlx 
	gen round = 2 
	gen female = 1 
	
	tempfile nmx_r2_f
	save `nmx_r2_f'
	
	
	*nfhs2, male 
	import delimited ///
	"$dir\01_do\02_analysis\06_robustness\log_quad_lt\ex_india_nfhs2_m.csv", clear 
	
	*gen comparable age groups 
	gen x = 0 if _n == 1 
	replace x = 1 if _n == 2 
	replace x = _n * 5 - 10 if _n > 2 
		
	gen age_group = x 	
	replace age_group = 85 if x > 85 
	
	*generate nlx 
	gen n = 1 if x == 0 
	replace n = 4 if x == 1 
	replace n = 5 if x > 1 & x < 110 
	
	gen nlx = lx[_n+1] * n + dx * ax 
	replace nlx = lx / mx if x == 110
	
	collapse mx (sum) dx nlx, by(age_group)
	gen nmx_lq = dx/nlx
	
	drop mx dx nlx 
	gen round = 2 
	gen female = 0
	
	tempfile nmx_r2_m
	save `nmx_r2_m'
	
	
	*nfhs4, female 
	import delimited ///
	"$dir\01_do\02_analysis\06_robustness\log_quad_lt\ex_india_nfhs4_f.csv", clear 
	
	*gen comparable age groups 
	gen x = 0 if _n == 1 
	replace x = 1 if _n == 2 
	replace x = _n * 5 - 10 if _n > 2 
		
	gen age_group = x 	
	replace age_group = 85 if x > 85 
	
	*generate nlx 
	gen n = 1 if x == 0 
	replace n = 4 if x == 1 
	replace n = 5 if x > 1 & x < 110 
	
	gen nlx = lx[_n+1] * n + dx * ax 
	replace nlx = lx / mx if x == 110
	
	collapse mx (sum) dx nlx, by(age_group)
	gen nmx_lq = dx/nlx
	
	drop mx dx nlx 
	gen round = 4
	gen female = 1 
	
	tempfile nmx_r4_f
	save `nmx_r4_f'
	
	
	*nfhs2, male 
	import delimited ///
	"$dir\01_do\02_analysis\06_robustness\log_quad_lt\ex_india_nfhs4_m.csv", clear 
	
	*gen comparable age groups 
	gen x = 0 if _n == 1 
	replace x = 1 if _n == 2 
	replace x = _n * 5 - 10 if _n > 2 
		
	gen age_group = x 	
	replace age_group = 85 if x > 85 
	
	*generate nlx 
	gen n = 1 if x == 0 
	replace n = 4 if x == 1 
	replace n = 5 if x > 1 & x < 110 
	
	gen nlx = lx[_n+1] * n + dx * ax 
	replace nlx = lx / mx if x == 110
	
	collapse mx (sum) dx nlx, by(age_group)
	gen nmx_lq = dx/nlx
	
	drop mx dx nlx 
	gen round = 4
	gen female = 0
	
	tempfile nmx_r4_m
	save `nmx_r4_m'
	
	*append 4 fils 
	use `nmx_r2_f'
	append using `nmx_r2_m'
	append using `nmx_r4_f'
	append using `nmx_r4_m'
	
	merge 1:1 female round age_group using "$dir\01_do\02_analysis\06_robustness\nfhs_nmx.dta", nogen 
	
	*multiply rates by 1,000
	replace nmx = nmx * 1000
	replace nmx_lq = nmx_lq * 1000
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
	lab def rf 1 "female, 1997-2000" 2 "male, 1997-2000" /// 
	3 "female, 2013-2016" 4 "male, 2013-2016"
	lab val round_female rf
	
// 	*srs labels 
// 	gen label_srs = "e{subscript:0} SRS (1997-2001)" if round_female == 1 & age_group == 0 
// 	replace label_srs = "e{subscript:0} SRS (1997-2001)" if round_female == 2 & age_group == 0 
// 	replace label_srs =  "e{subscript:0} SRS (2012-2016)" if round_female == 3 & age_group == 0 
// 	replace label_srs =  "e{subscript:0} SRS (2012-2016)" if round_female == 4 & age_group == 0 
//
// 	gen label_srs2 = "63.3 years" if round_female == 1 & age_group == 0 
// 	replace label_srs2 = "61.4 years" if round_female == 2 & age_group == 0 
// 	replace label_srs2 =  "70.2 years" if round_female == 3 & age_group == 0 
// 	replace label_srs2 =  "67.4 years" if round_female == 4 & age_group == 0 
//
// 	cap drop label_mid
// 	gen label_mid = "=" if age_group == 0
//	
// 	*nfhs labels
// 	gen label_nfhs = "e{subscript:0} NFHS (1997-2000)" if round_female == 1 & age_group == 0 
// 	replace label_nfhs = "e{subscript:0} NFHS (1997-2000)" if round_female == 2 & age_group == 0 
// 	replace label_nfhs =  "e{subscript:0} NFHS (2013-2016)" if round_female == 3 & age_group == 0 
// 	replace label_nfhs =  "e{subscript:0} NFHS (2013-2016)" if round_female == 4 & age_group == 0 
//
// 	gen label_nfhs2 = "61.3 years [95% CI 60.7-62.0]" if round_female == 1 & age_group == 0 
// 	replace label_nfhs2 = "60.6 years [95% CI: 60.0-61.1]" if round_female == 2 & age_group == 0 
// 	replace label_nfhs2 =  "69.6 years [95% CI: 69.3-69.9]" if round_female == 3 & age_group == 0 
// 	replace label_nfhs2 =  "66.0 years [95% CI: 65.7-66.3]" if round_female == 4 & age_group == 0 
//
// 	gen label_join = "--" if age_group == 0 
//	
// 	*srs label position 
// 	gen srs_lp_x = 28
// 	gen srs_lp_y = 0.65
//	
// 	gen srs_lp2_x = 51
// 	gen srs_lp2_y = 0.65
//
// 	*nfhs label position 
// 	gen nfhs_lp_x = 28
// 	gen nfhs_lp_y = 1
//	
// 	gen nfhs_lp2_x = 51
// 	gen nfhs_lp2_y = 1
//	
// 	*equal to position
// 	gen join_lp_x = 49
// 	gen join_lp_y1 = 1
// 	gen join_lp_y2 = 0.65
//	
*make a by-graph 

	# d ;
	graph twoway 
	(connected nmx age_group, msymbol(Sh) msize(*.9))
	(connected nmx_lq age_group, msymbol(Oh) lpattern(dash)) 
	(rarea nmx_lci nmx_uci age_group, color(navy%50) lwidth(none))
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
	ytitle("mortality rates per 1,000 ({subscript:n}m{subscript:x})", size(*.95)) ///
	legend(order(2 "Log-Quad Estimates" 1 "NFHS Empirical estimates") ///
		row(1) bmargin(tiny) lcolor(white) region(lcolor(white)) size(*.95)) ///
	xsize(1.8) ysize(1) ///
	subtitle(, fcolor(white) lcolor(white))	
	;
	# d cr
	graph save "$dir\05_out\figures\nmx_nfhs_lq_overall.gph", replace
	graph export "$dir\05_out\figures\nmx_nfhs_lq_overall.pdf", replace
	graph export "$dir\05_out\figures\nmx_nfhs_lq_overall.tif", width(1000) replace
