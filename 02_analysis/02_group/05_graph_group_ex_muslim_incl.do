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
	
	drop if caste_religion==6
	keep female caste_religion age_group ex ex_lci ex_uci round
	keep if age_group == 0 | age_group == 15 | age_group == 60
	egen group = group(age_group female)

	sort round caste_religion female age_group
******************************************************
*define lables and other things for figure 
******************************************************
	
	
	*gen labels for graph subtitles 
	label define sex_e0 0 "b) Male, e{sub:0}" 1 "a) Female, e{sub:0}"
	gen sex_e0 = female if age_group == 0
	lab val sex_e0 sex_e0
	
	label define sex_e15 0 "d) Male, e{sub:15}" 1 "c) Female, e{sub:15}"
	gen sex_e15 = female if age_group == 15
	lab val sex_e15 sex_e15

	label define sex_e60 0 "f) Male, e{sub:60}" 1 "e) Female, e{sub:60}"
	gen sex_e60 = female if age_group == 60
	lab val sex_e60 sex_e60
	
	
	
	*Adjust labels 
	format ex %3.1f
		
	*create labels 	
	local x = 1
	local male0 = "Male"
	local male1 = "Female"
	
	local range0 = "53(5)73"
	local range15 = "46(4)62"
	local range60 = "12(2)20"
	
	local labpos_st_10 = "5"
	local labpos_st_115 = "5"
	local labpos_st_160 = "5"
	
	local labpos_st_00 = "5"
	local labpos_st_015 = "5"
	local labpos_st_060 = "5"
	
	local labpos_sc_10 = "1"
	local labpos_sc_115 = "1"
	local labpos_sc_160 = "5"
	
	local labpos_sc_00 = "1"
	local labpos_sc_015 = "3"
	local labpos_sc_060 = "1"
	
	local labpos_muslim_00 = "3"
	local labpos_muslim_015 = "1"
	local labpos_muslim_060 = "1"
	
	local labpos_muslim_10 = "1"
	local labpos_muslim_115 = "3"
	local labpos_muslim_160 = "3"

	local labpos_obc_00 = "3"
	local labpos_obc_015 = "3"
	local labpos_obc_060 = "3"
	
	local labpos_obc_10 = "3"
	local labpos_obc_115 = "1"
	local labpos_obc_160 = "1"

	local labpos_hc_00 = "1"
	local labpos_hc_015 = "1"
	local labpos_hc_060 = "1"
	
	local labpos_hc_10 = "1"
	local labpos_hc_115 = "1"
	local labpos_hc_160 = "1"

	
	*all ages 
	foreach age in 0 15 60 {
	
	foreach sex in 0 1 {

	# d ;
	graph twoway 
	(connected ex round ///
		if caste_religion == 1 & female == `sex' & age_group == `age',
		mlabel(ex) ///
		mlabsize(medsmall) ///
		lcol(navy%75) ///
		msymbol(Dh) ///
		mcol(navy%75) ///
		mlabcol(navy%90) ///
		mlabpos(`labpos_sc_`sex'`age'') ///
		msize(small) ///
		mlabg(*.5) ///
		sort ///
		lpattern(longdash_dot)) ///
	(connected ex round ///
		if caste_religion == 2 & female == `sex' & age_group == `age',
		mlabel(ex) ///
		mlabsize(medsmall) ///
		lcol(sienna%75) ///
		msymbol(Th) ///
		mcol(sienna%75) ///
		mlabcol(sienna%90) ///
		mlabpos(`labpos_st_`sex'`age'') ///
		msize(small) ///
		mlabg(*.5) ///
		sort)
	(connected ex round ///
		if caste_religion == 3 & female == `sex' & age_group == `age',
		mlabel(ex) ///
		mlabsize(medsmall) ///
		lcol(dkgreen%75) ///
		msymbol(Sh) ///
		mcol(dkgreen%75) ///
		mlabcol(dkgreen%90) ///
		mlabpos(`labpos_muslim_`sex'`age'') ///
		msize(small) ///
		mlabg(*.5) ///
		sort ///
		lpattern(dash_dot))
	(connected ex round ///
		if caste_religion == 4 & female == `sex' & age_group == `age' ,
		mlabel(ex) ///
		mlabsize(medsmall) ///
		lcol(red%75) ///
		msymbol(Oh) ///
		msize(medlarge) ///
		mcol(red%75) ///
		mlabcol(red%90) ///
		mlabpos(`labpos_obc_`sex'`age'') ///
		msize(small) ///
		mlabg(*.5) ///
		sort ///
		lpattern(dash))
	(connected ex round ///
		if caste_religion == 5 & female == `sex' & age_group == `age',
		mlabel(ex) ///
		mlabsize(medsmall) ///
		lcol(orange%75) ///
		msymbol(X) ///
		mcol(orange%75) ///
		mlabcol(orange%90) ///
		mlabpos(`labpos_hc_`sex'`age'') ///
		msize(medsmall) ///
		mlabg(*.5) ///
		sort ///
		lpattern(shortdash_dot)) ///
	(rcapsym ex_lci ex_uci round ///
		if caste_religion==1 & age_group==`age' & female == `sex', ///
		lc(navy) msymbol(none)) ///
	(rcapsym ex_lci ex_uci round ///
		if caste_religion==3 & age_group==`age' & female == `sex', ///
		lc(dkgreen)  msymbol(none)) ///
	(rcapsym ex_lci ex_uci round ///
		if caste_religion==2 & age_group==`age' & female == `sex', ///
		lc(sienna)  msymbol(none)) ///
	(rcapsym ex_lci ex_uci round ///
		if caste_religion==4 & age_group==`age' & female == `sex', ///
		lc(red)  msymbol(none)) ///
	(rcapsym ex_lci ex_uci round ///
		if caste_religion==5 & age_group==`age' & female == `sex', ///
		lc(orange)  msymbol(none)), ///
	legend(order(2 "Scheduled Tribe" 1 "Scheduled Caste" 3 "Muslim" 4 "Other Backward Class" 5 "High Caste") ///
		region(lcolor(white) margin(medsmall)) ///
		rows(1) ///
		pos(5) ///
		ring(0) ///
		size(vsmall) ///
		bmargin(zero) ///
		stack ///
		symp(12) ///
		keygap(*.1)) ///
	note("  `male`sex'', e{subscript:`age'}", ///
		size(medium) ///
		pos(11) ring(0)) ///
	ytitle("")
	xtitle("")
	xlabel(2 "1997-2000" 4 "2013-16") ///
	graphregion(fcolor(white) lcolor(white)) ///
	ylabel(`range`age'', format(%6.0f) nogrid)
	;
	# d cr
	
	graph save ///
	"$dir/05_out/figures/e`age'_`male`sex''_caste_religion.gph", ///
	replace
	
	}
	
	}
	
	grc1leg ///
	"$dir\05_out\figures\e0_female_caste_religion.gph" ///
	"$dir\05_out\figures\e0_male_caste_religion.gph", ///
	graphregion(fcolor(white) lcolor(white)) ///
	xcom ycom row(1) imargin(0 8 0 0) ///
	note("Life expectancy at birth", pos(9) orientation(vertical))
	graph save ///
	"$dir\05_out\figures\e0_caste_religion.gph", ///
	replace
	
	*e0 graph just for presentations 
	grc1leg ///
	"$dir\05_out\figures\e0_female_caste_religion.gph" ///
	"$dir\05_out\figures\e0_male_caste_religion.gph", ///
	graphregion(fcolor(white) lcolor(white)) ///
	xcom ycom row(1) imargin(0 8 0 0) ///
	note("Life expectancy at birth", pos(9) orientation(vertical)) ///
	name(e0_caste_present)
	
	graph display e0_caste_present, xsize(5) ysize(3)
	graph export "$dir\05_out\figures\e0_caste_religion.pdf", ///
	replace
	
	
	grc1leg ///
	"$dir\05_out\figures\e15_female_caste_religion.gph" ///
	"$dir\05_out\figures\e15_male_caste_religion.gph", ///
	graphregion(fcolor(white) lcolor(white)) ///
	xcom ycom row(1) imargin(0 8 0 0) ///
	note("Life expectancy at age 15", pos(9) orientation(vertical))
	graph save ///
	"$dir\05_out\figures\e15_caste_religion.gph", ///
	replace
		
	grc1leg ///
	"$dir\05_out\figures\e60_female_caste_religion.gph" ///
	"$dir\05_out\figures\e60_male_caste_religion.gph", ///
	graphregion(fcolor(white) lcolor(white)) ///
	xcom ycom row(1) imargin(0 8 0 0) ///
	note("Life expectancy at age 60", pos(9) ///
	orientation(vertical))
	graph save ///
	"$dir\05_out\figures\e60_caste_religion.gph", ///
	replace
	
	*combine 6 graphs 
	grc1leg ///
	"$dir\05_out\figures\e0_caste_religion.gph" ///
	"$dir\05_out\figures\e15_caste_religion.gph" ///
	"$dir\05_out\figures\e60_caste_religion.gph", ///
	graphregion(fcolor(white) lcolor(white)) ///
	xcom row(3) name(ex_caste_main, replace) ///
	span note("Note: 95% CIs calculated using a cluster-bootstrap approach." ///
	"The number of bootstrap samples drawn was 100.", size(vsmall) pos(6))
	
	graph display ex_caste_main, xsize(2) ysize(3)

	graph save ///
	"$dir\05_out\figures\ex_caste_religion.gph", ///
	replace
	
	graph export ///
	"$dir\05_out\figures\ex_caste_religion.tif", ///
	width(1000) replace
	
	graph export ///
	"$dir\05_out\figures\ex_caste_religion.pdf", ///
	replace
	
	graph export ///
	"$dir\05_out\figures\ex_caste_religion.eps", ///
	replace
	
	
******************************************************************************	
	*present 
	/*
	
	local x = 1
	local male0 = "male"
	local male1 = "female"
	
	local range0 = "53(5)73"
	local range15 = "46(4)62"
	local range60 = "12(2)20"
	
	local labpos_st_10 = "5"
	local labpos_st_115 = "5"
	local labpos_st_160 = "5"
	
	local labpos_st_00 = "5"
	local labpos_st_015 = "5"
	local labpos_st_060 = "5"
	
	local labpos_sc_10 = "1"
	local labpos_sc_115 = "1"
	local labpos_sc_160 = "5"
	
	local labpos_sc_00 = "1"
	local labpos_sc_015 = "1"
	local labpos_sc_060 = "1"
	
	

*make graphs 
		
	foreach age in 0 15 60 {
	
	foreach sex in 0 1 {

	
	# d ;
	graph twoway 
	(connected ex round ///
		if caste_religion == 1 & female == `sex' & age_group == `age',
		mlabel(ex) ///
		mlabsize(medsmall) ///
		lcol(navy%75) ///
		msymbol(Dh) ///
		mcol(navy%75) ///
		mlabcol(navy%90) ///
		mlabpos(`labpos_sc_`sex'`age'') ///
		msize(vsmall) ///
		mlabg(*.5) ///
		sort) ///
	(connected ex round ///
		if caste_religion == 2 & female == `sex' & age_group == `age',
		mlabel(ex) ///
		mlabsize(medsmall) ///
		lcol(dkgreen%75) ///
		msymbol(Th) ///
		mcol(dkgreen%75) ///
		mlabcol(dkgreen%90) ///
		mlabpos(`labpos_st_`sex'`age'') ///
		msize(vsmall) ///
		mlabg(*.5) ///
		sort)
	(connected ex round ///
		if caste_religion == 4 & female == `sex' & age_group == `age' ,
		mlabel(ex) ///
		mlabsize(medsmall) ///
		lcol(maroon%75) ///
		msymbol(Oh) ///
		msize(medlarge) ///
		mcol(maroon%75) ///
		mlabcol(maroon%90) ///
		mlabpos(1) ///
		msize(vsmall) ///
		mlabg(*.5) ///
		sort)
	(connected ex round ///
		if caste_religion == 5 & female == `sex' & age_group == `age',
		mlabel(ex) ///
		mlabsize(medsmall) ///
		lcol(orange%75) ///
		msymbol(Sh) ///
		mcol(orange%75) ///
		mlabcol(orange%90) ///
		mlabpos(1) ///
		msize(vsmall) ///
		mlabg(*.5) ///
		sort) ///
	(rcapsym ex_lci ex_uci round ///
		if caste_religion==1 & age_group==`age' & female == `sex', ///
		lc(navy) msymbol(none)) ///
	(rcapsym ex_lci ex_uci round ///
		if caste_religion==2 & age_group==`age' & female == `sex', ///
		lc(dkgreen)  msymbol(none)) ///
	(rcapsym ex_lci ex_uci round ///
		if caste_religion==4 & age_group==`age' & female == `sex', ///
		lc(maroon)  msymbol(none)) ///
	(rcapsym ex_lci ex_uci round ///
		if caste_religion==5 & age_group==`age' & female == `sex', ///
		lc(orange)  msymbol(none)), ///
	legend(order(4 "High Caste" 3 "Other Backward Class"  1 "Scheduled Caste" 2 "Scheduled Tribe" ) ///
		region(lcolor(white) margin(zero)) ///
		rows(1) ///
		pos(5) ///
		ring(0) ///
		size(vsmall) ///
		bmargin(zero) ///
		stack ///
		symp(12) keygap(*-1.5)) ///
	note("  `male`sex'', e{subscript:`age'}", ///
		size(medium) ///
		pos(11) ring(0)) ///
	ytitle("")
	xtitle("")
	xlabel(2 "1997-2000" 4 "2013-16") ///
	graphregion(fcolor(white) lcolor(white)) ///
	ylabel(`range`age'', format(%6.0f) nogrid)
	;
	# d cr
	
	graph save ///
	"$dir\05_out\figures\e`age'_`male`sex''_caste_religion_present.gph", ///
	replace
	
	}
	}
	*/
	
	
	grc1leg ///
	"$dir\05_out\figures\e0_female_caste_religion.gph" ///
	"$dir\05_out\figures\e0_male_caste_religion.gph", ///
	graphregion(fcolor(white) lcolor(white)) ///
	xcom ycom row(2) imargin(0 8 4 0) ///
	note("life expectancy at birth", pos(9) orientation(vertical))
	graph save ///
	"$dir\05_out\figures\e0_caste_religion_present.gph", ///
	replace
	
	grc1leg ///
	"$dir\05_out\figures\e15_female_caste_religion.gph" ///
	"$dir\05_out\figures\e15_male_caste_religion.gph", ///
	graphregion(fcolor(white) lcolor(white)) ///
	xcom ycom row(2) imargin(0 8 4 0) ///
	note("life expectancy at age 15", pos(9) orientation(vertical))
	graph save ///
	"$dir\05_out\figures\e15_caste_religion_present.gph", ///
	replace
		
	grc1leg ///
	"$dir\05_out\figures\e60_female_caste_religion.gph" ///
	"$dir\05_out\figures\e60_male_caste_religion.gph", ///
	graphregion(fcolor(white) lcolor(white)) ///
	xcom ycom row(2) imargin(0 8 4 0) ///
	note("life expectancy at age 60", pos(9) ///
	orientation(vertical))
	graph save ///
	"$dir\05_out\figures\e60_caste_religion_present.gph", ///
	replace
	
	*combine 6 graphs 
	grc1leg ///
	"$dir\05_out\figures\e0_caste_religion_present.gph" ///
	"$dir\05_out\figures\e15_caste_religion_present.gph" ///
	"$dir\05_out\figures\e60_caste_religion_present.gph", ///
	graphregion(fcolor(white) lcolor(white)) ///
	xcom row(1) name(ex_caste_religion_main, replace) ///
	span note("{break}" ///
	"Note: 95% CIs calculated using a cluster-bootstrap approach. The number of bootstrap samples drawn was 100.", size(vsmall) pos(6))
	
	graph display ex_caste_religion_main, xsize(3) ysize(2)

	graph save ///
	"$dir\05_out\figures\ex_caste_religion_present.gph", ///
	replace
	
	graph export ///
	"$dir\05_out\figures\ex_caste_religion_present.tif", ///
	width(3000) replace
	
	graph export ///
	"$dir\05_out\figures\ex_caste_religion_present.pdf", ///
	replace
	
	
*bar graph, just for age 0 

	



*******************************************************************************
*export for estimates table

	*to make table s2 in the appendix
	
	drop sex*
	drop group

	*reshape 
	reshape wide ex*, i(female caste_religion round) j(age_group) 
	
	foreach age in 0 15 60 {
	
	cap drop e`age'_ci
	gen e`age'_ci = "[" + string(ex_lci`age', "%6.1f") + "-" + string(ex_uci`age', "%6.1f") + "]"

	}
	
	cap drop male
	gen male = female == 0
	
	sort round male caste_religion
	
	drop ex_lci0 ex_uci0 ex_lci15 ex_uci15 ex_lci60 ex_uci60 male
	
	order female round caste_religion ex0 e0_ci ex15 e15_ci ex60 e60_ci
	
	
	export excel ///
	using "$dir\05_out\estimates\table_s2.xls", ///
	firstrow(variables) replace

	
	listtab female round caste_religion ex0 e0_ci ex15 e15_ci ex60 e60_ci ///
	using "$dir\05_out\estimates\table_s2.tex", ///
	rstyle(tabular) replace
