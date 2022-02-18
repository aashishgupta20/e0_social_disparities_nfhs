**************************************************
*Project: Caste and mortality							*
*Purpose: Make maps by region					 		*
*Last modified: 29 July 2020 by AG						*
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
	log using "$dir/02_logs/02analysis_nfhs4_combine_maps.txt", text replace


*combine graph 
	graph combine ///
	"$dir/05_out/figures/nfhs4_sc_hc_women_map.gph" ///
	"$dir/05_out/figures/nfhs4_mu_hc_women_map.gph" ///
	"$dir/05_out/figures/nfhs4_st_hc_women_map.gph" ///
	"$dir/05_out/figures/nfhs4_sc_hc_men_map.gph" ///
	"$dir/05_out/figures/nfhs4_mu_hc_men_map.gph" ///
	"$dir/05_out/figures/nfhs4_st_hc_men_map.gph", ///
	graphregion(fcolor(white) lcolor(white)) ///
	row(2)  altshrink xsize(5) ysize(4) plotregion(margin(zero)) ///
	imargin(zero) ///
	note("Note: 95% CIs calculated using a cluster-bootstrap approach. The number of bootstrap samples drawn was 100.", pos(6) size(tiny))	
	graph export "$dir/05_out/figures/nfhs4_maps.pdf", replace
	graph export "$dir/05_out/figures/nfhs4_maps.tif", width(3000) replace
	graph export "$dir/05_out/figures/nfhs4_maps.eps", replace
