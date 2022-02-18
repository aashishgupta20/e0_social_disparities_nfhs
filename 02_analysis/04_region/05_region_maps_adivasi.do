**************************************************
*Project: Caste and mortality							 *
*Purpose: Make maps by region					 		 *
*Last modified: 29 July 2020 by AG					 *
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
	log using "$dir/02_logs/02analysis_nfhs4_adivasi_region_maps.txt", text replace
	
******************************************************
*Work with data
******************************************************


	*set locals 
	
	local color =  "black"
	local fill = "Blues"
	
********************************************************
	*caste region 
********************************************************	
	
	*women 
	use "$dir/05_out/estimates/nfhs4_group_adivasi_region_life_tables_se.dta", clear  
		
		
		*keeps and drops
		keep if age_group==0
		keep if caste_religion == 2 | caste_religion == 5 
		keep if female==1 
		keep caste_religion adivasi_region ex ex_lci ex_uci 

		*reshape 
		reshape wide ex ex_lci ex_uci, i(adivasi_region) j(caste_religion)
		
		*rename
		rename ex2 ex_st
		rename ex5 ex_hc 

		*difference
		gen dif_st_hc = ex_hc - ex_st

		*gen id to match with maps 
		sort adivasi_region 
		gen _ID = adivasi_region
	
		*save
		saveold "$dir\03_intermediate\adivasi_region_ex_reshape_women.dta", replace
	
	*men 
	use "$dir/05_out/estimates/nfhs4_group_adivasi_region_life_tables_se.dta", clear  
	
		*keeps and drops
		keep if age_group==0
		keep if caste_religion == 2 | caste_religion == 5 
		keep if female==0
		keep caste_religion adivasi_region ex ex_lci ex_uci 

		*reshape 
		reshape wide ex ex_lci ex_uci, i(adivasi_region) j(caste_religion)
		
		*rename
		rename ex2 ex_st
		rename ex5 ex_hc 

		*difference
		gen dif_st_hc = ex_hc - ex_st

		*gen id to match with maps 
		sort adivasi_region 
		gen _ID = adivasi_region
	
		*save 
		saveold "$dir\03_intermediate\adivasi_region_ex_reshape_men.dta", replace
	
	
	*labels 
	
		*women: st v hc 
		use "$dir\03_intermediate\adivasi_region_ex_reshape_women.dta", clear 
		gen labtype = 1 
		
		append using "$dir\03_intermediate\adivasi_region_ex_reshape_women.dta"
		replace labtype = 2 if labtype == . 
		
		append using "$dir\03_intermediate\adivasi_region_ex_reshape_women.dta"
		replace labtype = 3 if labtype == . 

		append using "$dir\03_intermediate\adivasi_region_ex_reshape_women.dta"
		replace labtype = 4 if labtype == . 
		
		append using "$dir\03_intermediate\adivasi_region_ex_reshape_women.dta"
		replace labtype = 5 if labtype == . 
				
		append using "$dir\03_intermediate\adivasi_region_ex_reshape_women.dta"
		replace labtype = 6 if labtype == . 
		
		append using "$dir\03_intermediate\adivasi_region_ex_reshape_women.dta"
		replace labtype = 7 if labtype == . 
		
		*generate lables 
		gen ex_label = "ST e{sub:0}: " if labtype == 1
		replace ex_label = string(ex_st, "%6.1f") if labtype == 2 
		replace ex_label = "[" + string(ex_lci2, "%3.1f") + "-" + string(ex_uci2, "%3.1f") + "]"	if labtype == 3
		replace ex_label = "HC e{sub:0}: "  if labtype == 4
		replace ex_label = string(ex_hc, "%6.1f") if labtype == 5 
		replace ex_label = "[" + string(ex_lci5, "%3.1f") + "-" + string(ex_uci5, "%3.1f") + "]" if labtype == 6 
		
		replace ex_label = "1.Rest" if labtype == 7 & adivasi_region == 1 
		replace ex_label = "2.Central" if labtype == 7 & adivasi_region == 3
		replace ex_label = "3.North-east" if labtype == 7 & adivasi_region == 2

		
		cap drop _merge
		merge m:1 adivasi_region using ///
		"$dir/03_intermediate/maps/adivasi_region_centroid.dta"
		
		*adjust cetroids 
			
			*for hc, put them below
			replace y_stub = y_stub - 1.5 if labtype > 3 
			
			*for estimates, put them on the side
			replace x_stub = x_stub - 0.6 if labtype == 1 | labtype == 4 
			replace x_stub = x_stub + 1.5 if labtype == 2 | labtype == 5 
			replace x_stub = x_stub + 2.15 if labtype == 3 | labtype == 6
			
			*for CIs, put them a bit below
			replace y_stub = y_stub -0.7 if labtype == 3 | labtype == 6
	
					
			*for roi
			replace y_stub = y_stub + 6 if adivasi_region == 1
			
			*for central india 
			replace y_stub = y_stub + 0.6 if adivasi_region == 3 
			replace x_stub = x_stub + 2 if adivasi_region == 3
			
			*name position changes 
				*North-east
				replace x_stub = x_stub + 1 if labtype == 7 & adivasi_region == 2
				replace y_stub = y_stub + 5  if labtype == 7 & adivasi_region == 2
				
				*rest 
				replace x_stub = x_stub - 4.8 if labtype == 7 & adivasi_region == 1
				replace y_stub = y_stub + 3 if labtype == 7 & adivasi_region == 1
		
				*central 
				replace x_stub = x_stub + 9 if labtype == 7 & adivasi_region == 3
				replace y_stub = y_stub - 2.7 if labtype == 7 & adivasi_region == 3

		
		save "$dir/03_intermediate/nfhs4_women_lables_st.dta", replace 
		
	*men: st v hc 
	
		*append to creare 6 labels 
		use "$dir\03_intermediate\adivasi_region_ex_reshape_men.dta", clear 
		gen labtype = 1 
		
		append using "$dir\03_intermediate\adivasi_region_ex_reshape_men.dta"
		replace labtype = 2 if labtype == . 
		
		append using "$dir\03_intermediate\adivasi_region_ex_reshape_men.dta"
		replace labtype = 3 if labtype == . 

		append using "$dir\03_intermediate\adivasi_region_ex_reshape_men.dta"
		replace labtype = 4 if labtype == . 
		
		append using "$dir\03_intermediate\adivasi_region_ex_reshape_men.dta"
		replace labtype = 5 if labtype == . 
		
		append using "$dir\03_intermediate\adivasi_region_ex_reshape_men.dta"
		replace labtype = 6 if labtype == . 
		
		append using "$dir\03_intermediate\adivasi_region_ex_reshape_men.dta"
		replace labtype = 7 if labtype == . 

		*generate label variable 
		gen ex_label = "ST e{sub:0}: " if labtype == 1
		replace ex_label = string(ex_st, "%6.1f") if labtype == 2 
		replace ex_label = "[" + string(ex_lci2, "%3.1f") + "-" + string(ex_uci2, "%3.1f") + "]"	if labtype == 3
		replace ex_label = "HC e{sub:0}: "  if labtype == 4
		replace ex_label = string(ex_hc, "%6.1f") if labtype == 5 
		replace ex_label = "[" + string(ex_lci5, "%3.1f") + "-" + string(ex_uci5, "%3.1f") + "]" if labtype == 6 
		
		br
		replace ex_label = "1.Rest" if labtype == 7 & adivasi_region == 1 
		replace ex_label = "2.Central" if labtype == 7 & adivasi_region == 3
		replace ex_label = "3.North-east" if labtype == 7 & adivasi_region == 2

		
		*merge cetroids 
		cap drop _merge
		merge m:1 adivasi_region using ///
		"$dir/03_intermediate/maps/adivasi_region_centroid.dta"
		
		
		*adjust label positions 
			*for hc, put them below
			replace y_stub = y_stub - 1.5 if labtype > 3 
			
			*for estimates, put them on the side
			replace x_stub = x_stub - 0.6 if labtype == 1 | labtype == 4 
			replace x_stub = x_stub + 1.5 if labtype == 2 | labtype == 5 
			replace x_stub = x_stub + 2.15 if labtype == 3 | labtype == 6
			
			*for CIs, put them a bit below
			replace y_stub = y_stub -0.7 if labtype == 3 | labtype == 6
		
			*regional adjustments 
			*for roi
			replace y_stub = y_stub + 6 if adivasi_region == 1
			
			*for central india 
			replace y_stub = y_stub + 0.6 if adivasi_region == 3 
			replace x_stub = x_stub + 2 if adivasi_region == 3
			
			*name position changes 
				*North-east
				replace x_stub = x_stub + 1 if labtype == 7 & adivasi_region == 2
				replace y_stub = y_stub + 5  if labtype == 7 & adivasi_region == 2
				
				*rest 
				replace x_stub = x_stub - 4.8 if labtype == 7 & adivasi_region == 1
				replace y_stub = y_stub + 3 if labtype == 7 & adivasi_region == 1
		
				*central 
				replace x_stub = x_stub + 9 if labtype == 7 & adivasi_region == 3
				replace y_stub = y_stub - 2.7 if labtype == 7 & adivasi_region == 3

			
			*save 
			save  "$dir/03_intermediate/nfhs4_men_lables_st.dta", replace 

*******************************************************************************
	*map 
*******************************************************************************
	
	*women, st v hc 
	use  "$dir/03_intermediate/adivasi_region_ex_reshape_women.dta", clear 
		
	spmap ///
		dif_st_hc ///
		using "$dir/03_intermediate/maps/adivasi_region_coordinates.dta", ///
		id(_ID) ///
		clm(c)  ///
		clbreaks(-5 0 2.5 5 7.5 10) ///
		legend(off) ///
		fcolor("230 230 250%75" "216 191 216%75" "238 130 238%75" "255 0 255%75" "128 0 128%75" ..) ///
		plotregion(icolor(white) lcolor(white)) ///
		graphregion(icolor(white) ///
			fcolor(white)) ///
		ocolor(white ..) ///
		osize(medthin ..) ///	
		label(data("$dir/03_intermediate/nfhs4_women_lables_st.dta") ///
			xcoord(x_stub)  ///
			ycoord(y_stub) ///
			label(ex_label) ///
			by(labtype) ///
			size(*1.1 *1 *0.75 *1.2 *1 *0.75 *1 ..) ///
			color(black black gs4 black black gs4 navy ..)) ///
		subtitle("e) ST and HC women", size(*1.2)) name(women)
		graph save "$dir/05_out/figures/nfhs4_st_hc_women_map.gph", replace
	
	
	*men, st v hc 
	clear all
	use "$dir\03_intermediate\adivasi_region_ex_reshape_men.dta", clear 
		
	spmap ///
		dif_st_hc ///
		using "$dir/03_intermediate/maps/adivasi_region_coordinates.dta", ///
		id(_ID) ///
		clm(c)  ///
		clbreaks(-5 0 2.5 5 7.5 10) ///
	legend(title("e{subscript:0} difference between" ///
		"SCs/STs & HCs", bexpand justification(center) size(*.8))  ///
		position(5) ///
		symy(*1.5) symx(*1.5) size(*1.7) row(6) ring(0) ///
		bmargin(large) label(2 "less than 0 years") label(3 "0 to 2.5 years") ///
		label(4 "2.5 to 5 years") label(5 "5 to 7.5 years") label(6 "more than 7.5 years") ///
		label(7 "") region(lcolor(white))) ///
		fcolor("230 230 250%75" "216 191 216%75" "238 130 238%75" "255 0 255%75" "128 0 128%75" ..) ///
		plotregion(icolor(white) lcolor(white)) ///
		graphregion(icolor(white) ///
			fcolor(white)) ///
		ocolor(white ..) ///
		osize(medthin ..) ///	
		label(data("$dir/03_intermediate/nfhs4_men_lables_st.dta") ///
			xcoord(x_stub)  ///
			ycoord(y_stub) ///
			label(ex_label) ///
			by(labtype) ///
			size(*1.1 *1 *0.75 *1.2 *1 *0.75 *1 ..) ///
			color(black black gs4 black black gs4 navy ..)) ///
		subtitle("f) ST and HC men", size(*1.2)) name(men)
		graph save "$dir/05_out/figures/nfhs4_st_hc_men_map.gph", replace
***********************************************************************************
***********************************************************************************
	
	