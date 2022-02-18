**************************************************
*Project: Caste and mortality							*
*Purpose: Make maps by region					 		*
**************************************************

**************************************************
*Preamble													 *
**************************************************
	
	clear all
	set more off
	set maxvar  32767, perm 
	
	
	*Set user
	
	*Log
	cap log close
	log using "$dir/02_logs/02analysis_nfhs4_region_maps.txt", text replace
	
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
	use "$dir/05_out/estimates/nfhs4_group_region_life_tables_se.dta", clear  
		
		
		*keeps and drops
		keep if age_group==0
		keep if caste_religion == 3 | caste_religion == 5 
		keep if female==1 
		keep caste_religion region ex ex_lci ex_uci 

		*reshape 
		reshape wide ex ex_lci ex_uci, i(region) j(caste_religion)
		
		*rename
		rename ex3 ex_mu
		rename ex5 ex_hc 

		*difference
		gen dif_mu_hc = ex_hc - ex_mu

		*gen id to match with maps 
		sort region 
		gen _ID = region
	
		*save
		saveold "$dir\03_intermediate\region_ex_reshape_women_muslim.dta", replace
	
	*men 
	use "$dir/05_out/estimates/nfhs4_group_region_life_tables_se.dta", clear  
	
		*keeps and drops
		keep if age_group==0
		keep if caste_religion == 3 | caste_religion == 5 
		keep if female==0
		keep caste_religion region ex ex_lci ex_uci 

		*reshape 
		reshape wide ex ex_lci ex_uci, i(region) j(caste_religion)
		
		*rename
		rename ex3 ex_mu
		rename ex5 ex_hc 

		*difference
		gen dif_mu_hc = ex_hc - ex_mu

		*gen id to match with maps 
		sort region 
		gen _ID = region
	
		*save 
		saveold "$dir\03_intermediate\region_ex_reshape_men_muslim.dta", replace
	
	
	*labels 
	
		*women: muslim v hc 
		use "$dir\03_intermediate\region_ex_reshape_women_muslim.dta", clear 
		gen labtype = 1 
		
		append using "$dir\03_intermediate\region_ex_reshape_women_muslim.dta"
		replace labtype = 2 if labtype == . 
		
		append using "$dir\03_intermediate\region_ex_reshape_women_muslim.dta"
		replace labtype = 3 if labtype == . 

		append using "$dir\03_intermediate\region_ex_reshape_women_muslim.dta"
		replace labtype = 4 if labtype == . 
		
		append using "$dir\03_intermediate\region_ex_reshape_women_muslim.dta"
		replace labtype = 5 if labtype == . 
				
		append using "$dir\03_intermediate\region_ex_reshape_women_muslim.dta"
		replace labtype = 6 if labtype == . 
		
		append using "$dir\03_intermediate\region_ex_reshape_women_muslim.dta"
		replace labtype = 7 if labtype == . 
			
		*generate lables 
		gen ex_label = "Mu. e{sub:0}: " if labtype == 1
		replace ex_label = string(ex_mu, "%6.1f") if labtype == 2 
		replace ex_label = "[" + string(ex_lci3, "%3.1f") + "-" + string(ex_uci3, "%3.1f") + "]" if labtype == 3
		replace ex_label = "HC e{sub:0}: "  if labtype == 4
		replace ex_label = string(ex_hc, "%6.1f") if labtype == 5 
		replace ex_label = "[" + string(ex_lci5, "%3.1f") + "-" + string(ex_uci5, "%3.1f") + "]" if labtype == 6 
		
		br
		replace ex_label = "1.North" if labtype == 7 & region == 4
		replace ex_label = "2.Hindi-Belt" if labtype == 7 & region == 5
		replace ex_label = "3.North-east" if labtype == 7 & region == 6
		replace ex_label = "4.East" if labtype == 7 & region == 3
		replace ex_label = "5.South" if labtype == 7 & region == 1
		replace ex_label = "6.West" if labtype == 7 & region == 2


		
		
		cap drop _merge
		merge m:1 region using ///
		"$dir/03_intermediate/maps/region_centroid.dta"
		
		*for hc, put them below
		replace y_stub = y_stub - 1.5 if labtype > 3 
		
		*for estimates, put them on the side
		replace x_stub = x_stub - 0.6 if labtype == 1 | labtype == 4 
		replace x_stub = x_stub + 1.5 if labtype == 2 | labtype == 5 
		replace x_stub = x_stub + 2.15 if labtype == 3 | labtype == 6
		
		*for CIs, put them a bit below
		replace y_stub = y_stub -0.7 if labtype == 3 | labtype == 6

		
		*regional adjustments 
		
			*south
			replace x_stub = x_stub - 0.5 if region == 1

			*west
			replace y_stub = y_stub - .5 if region == 2 
			replace x_stub = x_stub + 1 if region == 2 

			*east
			replace y_stub = y_stub + .3 if region == 3 
			
			*north
			replace y_stub = y_stub + 1.2 if region == 4 
						
		*region name placement 
			
				*north
				replace x_stub = x_stub + 1 if labtype == 7 & region == 4
				replace y_stub = y_stub + 4 if labtype == 7 & region == 4

				*hindi belt 
				replace x_stub = x_stub + 5.5 if labtype == 7 & region == 5
				replace y_stub = y_stub + 4.5 if labtype == 7 & region == 5
				
				*east 
				replace x_stub = x_stub + 2 if labtype == 7 & region == 3
				replace y_stub = y_stub - 2 if labtype == 7 & region == 3
			
				*south
				replace x_stub = x_stub  if labtype == 7 & region == 1
				replace y_stub = y_stub - 6  if labtype == 7 & region == 1

				*West
				replace x_stub = x_stub-4 if labtype == 7 & region == 2
				replace y_stub = y_stub   if labtype == 7 & region == 2

				*North-east
				replace x_stub = x_stub +1 if labtype == 7 & region == 6
				replace y_stub = y_stub +5  if labtype == 7 & region == 6
		
		save "$dir/03_intermediate/nfhs4_women_lables_mu.dta", replace 
		
	*men: muslim v hc 
	
		*append to creare 6 labels 
		use "$dir\03_intermediate\region_ex_reshape_men_muslim.dta", clear 
		gen labtype = 1 
		
		append using "$dir\03_intermediate\region_ex_reshape_men_muslim.dta"
		replace labtype = 2 if labtype == . 
		
		append using "$dir\03_intermediate\region_ex_reshape_men_muslim.dta"
		replace labtype = 3 if labtype == . 

		append using "$dir\03_intermediate\region_ex_reshape_men_muslim.dta"
		replace labtype = 4 if labtype == . 
		
		append using "$dir\03_intermediate\region_ex_reshape_men_muslim.dta"
		replace labtype = 5 if labtype == . 
		
		append using "$dir\03_intermediate\region_ex_reshape_men_muslim.dta"
		replace labtype = 6 if labtype == . 
		
		append using "$dir\03_intermediate\region_ex_reshape_men_muslim.dta"
		replace labtype = 7 if labtype == . 

		*generate label variable 
		gen ex_label = "Mu. e{sub:0}: " if labtype == 1
		replace ex_label = string(ex_mu, "%6.1f") if labtype == 2 
		replace ex_label = "[" + string(ex_lci3, "%3.1f") + "-" + string(ex_uci3, "%3.1f") + "]"	if labtype == 3
		replace ex_label = "HC e{sub:0}: "  if labtype == 4
		replace ex_label = string(ex_hc, "%6.1f") if labtype == 5 
		replace ex_label = "[" + string(ex_lci5, "%3.1f") + "-" + string(ex_uci5, "%3.1f") + "]" if labtype == 6 
		
		br
		
		replace ex_label = "1.North" if labtype == 7 & region == 4
		replace ex_label = "2.Hindi-Belt" if labtype == 7 & region == 5
		replace ex_label = "3.North-east" if labtype == 7 & region == 6
		replace ex_label = "4.East" if labtype == 7 & region == 3
		replace ex_label = "5.South" if labtype == 7 & region == 1
		replace ex_label = "6.West" if labtype == 7 & region == 2

		
		
		*merge cetroids 
		cap drop _merge
		merge m:1 region using ///
		"$dir/03_intermediate/maps/region_centroid.dta"
		
		
		*adjust label positions 
			*for hc, put them below
			replace y_stub = y_stub - 1.5 if labtype > 3 
			
			*for estimates, put them on the side
			replace x_stub = x_stub - 0.6 if labtype == 1 | labtype == 4 
			replace x_stub = x_stub + 1.5 if labtype == 2 | labtype == 5 
			replace x_stub = x_stub + 2.15 if labtype == 3 | labtype == 6
			
			*region name placement 
			
				*north
				replace x_stub = x_stub + 1 if labtype == 7 & region == 4
				replace y_stub = y_stub + 4 if labtype == 7 & region == 4

				*hindi belt 
				replace x_stub = x_stub + 5.5 if labtype == 7 & region == 5
				replace y_stub = y_stub + 4.5 if labtype == 7 & region == 5
				
				*east 
				replace x_stub = x_stub + 2 if labtype == 7 & region == 3
				replace y_stub = y_stub - 2 if labtype == 7 & region == 3
			
				*south
				replace x_stub = x_stub  if labtype == 7 & region == 1
				replace y_stub = y_stub - 6  if labtype == 7 & region == 1

				*West
				replace x_stub = x_stub-4 if labtype == 7 & region == 2
				replace y_stub = y_stub   if labtype == 7 & region == 2

				*North-east
				replace x_stub = x_stub +1 if labtype == 7 & region == 6
				replace y_stub = y_stub +5  if labtype == 7 & region == 6
			
			*for CIs, put them a bit below
			replace y_stub = y_stub -0.7 if labtype == 3 | labtype == 6
			
			*regional adjustments 
				*south
				replace x_stub = x_stub - 0.5 if region == 1

				*west
				replace y_stub = y_stub - .5 if region == 2 
				replace x_stub = x_stub + 1 if region == 2 

				*east
				replace y_stub = y_stub + .3 if region == 3 
				
				*north
				replace y_stub = y_stub + 1.2 if region == 4 
			
			*save 
			save  "$dir/03_intermediate/nfhs4_men_lables_mu.dta", replace 

*******************************************************************************
	*map 
*******************************************************************************
	
	*women, muslim v hc 
	use  "$dir/03_intermediate/region_ex_reshape_women_muslim.dta", clear 
		
	spmap ///
		dif_mu_hc ///
		using "$dir/03_intermediate/maps/region_coordinates.dta", ///
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
		label(data("$dir/03_intermediate/nfhs4_women_lables_mu.dta") ///
			xcoord(x_stub)  ///
			ycoord(y_stub) ///
			label(ex_label) ///
			by(labtype) ///
			size(*1.1 *1 *0.75 *1.1 *1 *0.75 *1 ..) ///
			color(black black gs4 black black gs4 navy ..)) ///
		subtitle("c) Muslim and HC women", size(*1.2))
		graph save "$dir/05_out/figures/nfhs4_mu_hc_women_map.gph", replace
	
	
	*men, muslim v hc 
	use "$dir\03_intermediate\region_ex_reshape_men_muslim.dta", clear 
		
	spmap ///
		dif_mu_hc ///
		using "$dir/03_intermediate/maps/region_coordinates.dta", ///
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
		label(data("$dir/03_intermediate/nfhs4_men_lables_mu.dta") ///
			xcoord(x_stub)  ///
			ycoord(y_stub) ///
			label(ex_label) ///
			by(labtype) ///
			size(*1.1 *1 *0.75 *1.1 *1 *0.75 *1 ..) ///
			color(black black gs4 black black gs4 navy ..)) ///
		subtitle("d) Muslim and HC men", size(*1.2))
		graph save "$dir/05_out/figures/nfhs4_mu_hc_men_map.gph", replace
		
	