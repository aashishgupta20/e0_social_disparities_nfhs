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
	
// 	*keep only core caste groups 
	drop if caste_religion > 5 

	
 	gen sgroup = caste_religion 
// 	replace sgroup = sgroup - 1 if caste_religion > 3

	*position
	gen pos = 50.5
	
	replace ex_lci = 49.5 if ex_lci < 49.5
	replace ex_uci = 75 if ex_lci > 75

	
	gen urban = rural == 0
	
	
	
	*create a variable 
	egen by_group = group(female round urban)
	replace by_group = by_group + 8 if by_group < 5 
	
	lab def by_group ///
	9 "Male, rural, 1997-2000" ///
	10 "Male, urban, 1997-2000" ///
	11 "Male, rural, 2013-2016" ///
	12 "Male, urban, 2013-2016" ///
	5 "Female, rural, 1997-2000" ///
	6 "Female, urban, 1997-2000" ///
	7 "Female, rural, 2013-2016" ///
	8 "Female, urban, 2013-2016" 
	lab val by_group by_group
	
	/*
*make a graph 

	graph twoway ///
	(bar ex sgroup if sgroup==1, ///
		barwidth(.65) fcolor(navy*.75) lcolor(navy)) ///
	(bar ex sgroup if sgroup==2, ///
		barwidth(.65) fcolor(sienna*.75) lcolor(sienna)) ///
	(bar ex sgroup if sgroup==3, ///
		barwidth(.65) fcolor(dkgreen*.75) lcolor(dkgreen)) ///
	(bar ex sgroup if sgroup==4, ///
		barwidth(.65) fcolor(red*.75) lcolor(red)) ///
	(bar ex sgroup if sgroup==5, ///
		barwidth(.65) fcolor(orange*.75) lcolor(orange)) ///
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
	xlabel(1 `" "Scheduled" "Caste" "' 2 `" "Scheduled" "Tribe" "' 3 "Muslim" 4 `" "Other" "Backward Class" "' ///
	5 "High Caste", labsize(*.55)) ///
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
		barwidth(.65) fcolor(navy*.75) lcolor(navy)) ///
	(bar ex sgroup if sgroup==2, ///
		barwidth(.65) fcolor(sienna*.75) lcolor(sienna)) ///
	(bar ex sgroup if sgroup==3, ///
		barwidth(.65) fcolor(dkgreen*.75) lcolor(dkgreen)) ///
	(bar ex sgroup if sgroup==4, ///
		barwidth(.65) fcolor(red*.75) lcolor(red)) ///
	(bar ex sgroup if sgroup==5, ///
		barwidth(.65) fcolor(orange*.75) lcolor(orange)) ///
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
	xlabel(1 `" "Scheduled" "Caste" "' 2 `" "Scheduled" "Tribe" "' 3 "Muslim" 4 `" "Other" "Backward Class" "' ///
	5 "High Caste", labsize(*.55)) ///
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
	*/
	
*over rural residence 
	drop rural age_group 
 	
	gen group_urban = . 
	replace group_urban = 4 if caste_religion == 1 & urban == 0
	replace group_urban = 5 if caste_religion == 1 & urban == 1
	replace group_urban = 1 if caste_religion == 2 & urban == 0
	replace group_urban = 2 if caste_religion == 2 & urban == 1
	replace group_urban = 7 if caste_religion == 3 & urban == 0
	replace group_urban = 8 if caste_religion == 3 & urban == 1
	replace group_urban = 10 if caste_religion == 4 & urban == 0
	replace group_urban = 11 if caste_religion == 4 & urban == 1
	replace group_urban = 13 if caste_religion == 5 & urban == 0
	replace group_urban = 14 if caste_religion == 5 & urban == 1
	
	gen round_female = . 
	replace round_female = 1 if round==2 & female==1 
	replace round_female = 2 if round==2 & female==0 
	replace round_female = 3 if round==4 & female==1 
	replace round_female = 4 if round==4 & female==0	
	lab def round_female 1 "a) Female, 1997-2000" 2 "b) Male, 1997-2000" ///
	3 "c) Female, 2013-2016" 4 "d) Male, 2013-2016"
	lab val round_female round_female
	
	
	
	twoway ///
	(bar ex group_urban if sgroup==1 & urban==0, ///
		barwidth(.95) fcolor(navy*.75) lcolor(navy)) ///
	(bar ex group_urban if sgroup==2 & urban==0, ///
		barwidth(.95) fcolor(sienna*.75) lcolor(sienna)) ///
	(bar ex group_urban if sgroup==3 & urban==0, ///
		barwidth(.95) fcolor(dkgreen*.75) lcolor(dkgreen)) ///
	(bar ex group_urban if sgroup==4  & urban==0, ///
		barwidth(.95) fcolor(red*.75) lcolor(red)) ///
	(bar ex group_urban if sgroup==5  & urban==0, ///
		barwidth(.95) fcolor(orange*.75) lcolor(orange)) ///
	(bar ex group_urban if sgroup==1 & urban==1, ///
		barwidth(.95) fcolor(navy*.05) lcolor(navy)) ///
	(bar ex group_urban if sgroup==2 & urban==1, ///
		barwidth(.95) fcolor(sienna*.05) lcolor(sienna)) ///
	(bar ex group_urban if sgroup==3 & urban==1, ///
		barwidth(.95) fcolor(dkgreen*.05) lcolor(dkgreen)) ///
	(bar ex group_urban if sgroup==4  & urban==1, ///
		barwidth(.95) fcolor(red*.05) lcolor(red)) ///
	(bar ex group_urban if sgroup==5  & urban==1, ///
		barwidth(.95) fcolor(orange*.05) lcolor(orange)) ///
	(rcap ex_uci ex_lci group_urban, ///
		lcolor(black) lwidth(thin) msize(0)) ///
	(scatter pos ex group_urban if urban==0, ///
		ms(none ..) mlab(ex) mlabcolor(white) mlabpos(0) mlabsize(*.7) mlabf(%2.1f)) ///
	(scatter pos ex group_urban if urban==1, ///
		ms(none ..) mlab(ex) mlabcolor(black) mlabpos(0) mlabsize(*.7) mlabf(%2.1f)) ///
	, ///
	by(round_female, ///
		graphregion(lcolor(white) fcolor(white)) ///
		note("") ///
		col(2) ///
		note("Urban estimates are shown by lightly colored bars and black text. Rural estimates are solid bars and white text." ///
	"Note: 95% CIs calculated using a cluster-bootstrap approach. The number of bootstrap samples drawn was 100. Some CIs may extend beyond y-axis limits." ///
	, size(*.6) pos(6))) ///
	graphregion(lcolor(white) fcolor(white)) ///
	subtitle(, fcolor(white) ///
		lcolor(white) size(*.7)) ///
	ylabel(50(5)75, nogrid labsize(*.6)) ///
	ysc(r(49.5 75)) ///
	xlabel(1.5 `" "Scheduled" "Tribe" "' 4.5 `" "Scheduled" "Caste" "' 7.5 "Muslim" 10.5 `" "Other" "Backward Class" "' ///
	13.5 "High Caste", labsize(*.55)) ///
	xtitle("") ///
	ytitle("Life expectancy at birth (e{sub:0}), years", size(*.8)) ///
	xsize(3) ysize(2) ///
	legend(order(1 "Rural" 6 "Urban") row(1) region(lcolor(none)) size(*.75) symy(*.75) symx(*.75))  
	
	
	gr_edit plotregion1.plotregion1[4].AddTextBox added_text editor 58 12.7
 	gr_edit plotregion1.plotregion1[4].added_text_new = 1
	gr_edit plotregion1.plotregion1[4].added_text_rec = 1
	gr_edit plotregion1.plotregion1[4].added_text[1].style.editstyle  angle(default) size( sztype(relative) ///
	val(3.4722) allow_pct(1)) color(black) horizontal(left) vertical(middle) margin( gleft( sztype(relative) val(0) ///
	allow_pct(1)) gright( sztype(relative) val(0) allow_pct(1)) gtop( sztype(relative) val(0) allow_pct(1)) ///
	gbottom( sztype(relative) val(0) allow_pct(1))) linegap( sztype(relative) val(0) allow_pct(1)) drawbox(no) ///
	boxmargin( gleft( sztype(relative) val(0) allow_pct(1)) gright( sztype(relative) val(0) allow_pct(1)) gtop( sztype(relative) ///
	val(0) allow_pct(1)) gbottom( sztype(relative) val(0) allow_pct(1))) fillcolor(bluishgray) linestyle( width( sztype(relative) ///
	val(.2) allow_pct(1)) color(black) pattern(solid) align(inside)) box_alignment(east) editcopy
	gr_edit plotregion1.plotregion1[4].added_text[1].style.editstyle size(2.5) editcopy
	gr_edit plotregion1.plotregion1[4].added_text[1]._set_orientation vertical
	gr_edit plotregion1.plotregion1[4].added_text[1].text = {}
	gr_edit plotregion1.plotregion1[4].added_text[1].text.Arrpush Rural
	gr_edit plotregion1.plotregion1[4].added_text[1].style.editstyle color(white) editcopy
	
	
	gr_edit plotregion1.plotregion1[4].AddTextBox added_text editor 58 13.7
	gr_edit plotregion1.plotregion1[4].added_text_new = 2
	gr_edit plotregion1.plotregion1[4].added_text_rec = 2
	gr_edit plotregion1.plotregion1[4].added_text[2].style.editstyle  angle(default) ///
	size( sztype(relative) val(2.5) allow_pct(1)) color(black) horizontal(left) vertical(middle) margin( gleft( sztype(relative) val(0) allow_pct(1)) ///
	gright( sztype(relative) val(0) allow_pct(1)) gtop( sztype(relative) val(0) allow_pct(1)) gbottom( sztype(relative) val(0) allow_pct(1))) ///
	linegap( sztype(relative) val(0) allow_pct(1)) drawbox(no) boxmargin( gleft( sztype(relative) val(0) allow_pct(1)) gright( sztype(relative) val(0) ///
	allow_pct(1)) gtop( sztype(relative) val(0) allow_pct(1)) gbottom( sztype(relative) val(0) allow_pct(1))) fillcolor(bluishgray) linestyle( width( sztype(relative) ///
	val(.2) allow_pct(1)) color(black) pattern(solid) align(inside)) box_alignment(east) editcopy
	gr_edit plotregion1.plotregion1[4].added_text[2].style.editstyle size(2.5) editcopy
	gr_edit plotregion1.plotregion1[4].added_text[2]._set_orientation vertical
	gr_edit plotregion1.plotregion1[4].added_text[2].text = {}
	gr_edit plotregion1.plotregion1[4].added_text[2].text.Arrpush Urban
		
	graph save ///
	"$dir\05_out\figures\ex_caste_residence_present.gph", ///
	replace
	
	graph export ///
	"$dir\05_out\figures\ex_caste_residence_present.tif", ///
	width(3000) replace
	
	graph export ///
	"$dir\05_out\figures\ex_caste_residence_present.pdf", ///
	replace
	
	graph export ///
	"$dir\05_out\figures\ex_caste_residence_present.eps", ///
	replace