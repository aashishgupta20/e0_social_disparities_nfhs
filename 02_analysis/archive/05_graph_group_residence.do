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
	log using "$dir/02_logs/02analysis_nfhs_graph_group_rural.txt", text replace
	
*create individual graphs 

	use "$dir/05_out/estimates/nfhs2_group_rural_life_tables_se.dta", clear 

	append using "$dir/05_out/estimates/nfhs4_group_rural_life_tables_se.dta"

*modify variables

	*keep only e0
	keep if age_group == 0
	
	*keep only necessary variables 
	drop nmx* lx* se_nmx se_lx
	
	*keep only core caste groups 
	keep if inlist(caste_religion, 1, 2, 4, 5)
	
	gen sgroup = caste_religion 
	replace sgroup = sgroup - 1 if caste_religion > 3

	*position
	gen pos = 50.5
	
	replace ex_lci = 49.5 if ex_lci < 49.5
	replace ex_uci = 75 if ex_lci > 75

	
	gen urban = rural == 0
	
	
	
	*create a variable 
	egen by_group = group(female round urban)
	replace by_group = by_group + 8 if by_group < 5 
	
	lab def by_group ///
	9 "male, rural, 1997-2000" ///
	10 "male, urban, 1997-2000" ///
	11 "male, rural, 2013-2016" ///
	12 "male, urban, 2013-2016" ///
	5 "female, rural, 1997-2000" ///
	6 "female, urban, 1997-2000" ///
	7 "female, rural, 2013-2016" ///
	8 "female, urban, 2013-2016" 
	lab val by_group by_group
	
	
*make a graph 

	graph twoway ///
	(bar ex sgroup if sgroup==1, ///
		barwidth(.8) fcolor(navy*.75) lcolor(navy)) ///
	(bar ex sgroup if sgroup==2, ///
		barwidth(.8) fcolor(dkgreen*.75) lcolor(dkgreen)) ///
	(bar ex sgroup if sgroup==3, ///
		barwidth(.8) fcolor(maroon*.75) lcolor(maroon)) ///
	(bar ex sgroup if sgroup==4, ///
		barwidth(.8) fcolor(orange*.75) lcolor(orange)) ///
	(rcap ex_uci ex_lci sgroup, ///
		lcolor(black) lwidth(thin) msize(0)) ///
	(scatter pos ex sgroup, ///
		ms(none ..) mlab(ex) mlabcolor(white) mlabpos(0) mlabsize(*.7) mlabf(%2.1f)) ///
	, ///
	by(by_group, ///
		graphregion(lcolor(white) fcolor(white)) ///
		note("") ///
		legend(off) ///
		col(2) ///
		note("Note: 95% CIs calculated using a cluster-bootstrap approach." ///
	"The number of bootstrap samples drawn was 100. Some CIs may extend beyond y-axis limits.", size(*.6) pos(6))) ///
	graphregion(lcolor(white) fcolor(white)) ///
	subtitle(, fcolor(white) ///
		lcolor(white) size(*.7)) ///
	ylabel(50(5)75, nogrid labsize(*.6)) ///
	ysc(r(49.5 75)) ///
	xlabel(1 `" "Scheduled" "Caste" "' 2 `" "Scheduled" "Tribe" "' 3 `" "Other" "Backward Class" "' ///
	4 `" "High" "Caste" "', labsize(*.6)) ///
	xtitle("") ///
	ytitle("life expectancy at birth (e{sub:0}), years", size(*.8)) ///
	xsize(2.2) ysize(3)
	
	graph save ///
	"$dir\05_out\figures\ex_caste_residence.gph", ///
	replace
	
	graph export ///
	"$dir\05_out\figures\ex_caste_residence.tif", ///
	width(3000) replace
	
	graph export ///
	"$dir\05_out\figures\ex_caste_residence.pdf", ///
	replace
	

*make a graph for presentation 
	graph twoway ///
	(bar ex sgroup if sgroup==1, ///
		barwidth(.8) fcolor(navy*.75) lcolor(navy)) ///
	(bar ex sgroup if sgroup==2, ///
		barwidth(.8) fcolor(dkgreen*.75) lcolor(dkgreen)) ///
	(bar ex sgroup if sgroup==3, ///
		barwidth(.8) fcolor(maroon*.75) lcolor(maroon)) ///
	(bar ex sgroup if sgroup==4, ///
		barwidth(.8) fcolor(orange*.75) lcolor(orange)) ///
	(rcap ex_uci ex_lci sgroup, ///
		lcolor(black) lwidth(thin) msize(0)) ///
	(scatter pos ex sgroup, ///
		ms(none ..) mlab(ex) mlabcolor(white) mlabpos(0) mlabsize(*.7) mlabf(%2.1f)) ///
	, ///
	by(by_group, ///
		graphregion(lcolor(white) fcolor(white)) ///
		note("") ///
		legend(off) ///
		col(4) ///
		note("Note: 95% CIs calculated using a cluster-bootstrap approach." ///
	"The number of bootstrap samples drawn was 100. Some CIs may extend beyond y-axis limits.", size(*.6) pos(6))) ///
	graphregion(lcolor(white) fcolor(white)) ///
	subtitle(, fcolor(white) ///
		lcolor(white) size(*.7)) ///
	ylabel(50(5)75, nogrid labsize(*.6)) ///
	ysc(r(49.5 75)) ///
	xlabel(1 `" "Scheduled" "Caste" "' 2 `" "Scheduled" "Tribe" "' 3 `" "Other" "Backward Class" "' ///
	4 `" "High" "Caste" "', labsize(*.6)) ///
	xtitle("") ///
	ytitle("life expectancy at birth (e{sub:0}), years", size(*.8)) ///
	xsize(2) ysize(1)
	
	graph save ///
	"$dir\05_out\figures\ex_caste_residence_present.gph", ///
	replace
	
	graph export ///
	"$dir\05_out\figures\ex_caste_residence_present.tif", ///
	width(3000) replace
	
	graph export ///
	"$dir\05_out\figures\ex_caste_residence_present.pdf", ///
	replace
	
	