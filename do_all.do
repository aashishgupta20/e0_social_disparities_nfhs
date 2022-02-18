**********************************************************************************
*this do file brings together all the do files, estimates life expectancies, 
*and creates the figures and tables in gupta and sudharsanan 2022
**********************************************************************************

	
	*set directory 
	*set your local directory here
	
	*the file structure we followed for this project was: 
	/*
	- Directory
		 - 00_raw
		 - 01_do
			- 01_build
			- 02_analysis 
		02_logs 
		03_intermediate 
		04_input 
			- resamples 
		05_out
			- figures 
			- estimates 
			- tables 
	*/
	

*********************************************************************************
*deaths and person-years 
*********************************************************************************
	
	*nfhs 2 
	do "$dir\01_do\01_build\01_nfhs2\01_nfhs2_reshape_raw_data.do"
	
	do "$dir\01_do\01_build\01_nfhs2\02_nfhs2_clean_adult_data.do"

	do "$dir\01_do\01_build\01_nfhs2\03_nfhs2_clean_child_data.do"
	
	*nfhs 4 
	do "$dir\01_do\01_build\02_nfhs4\01_nfhs4_reshape_raw_data.do"

	do "$dir\01_do\01_build\02_nfhs4\02_nfhs4_clean_adult_data.do"

	do "$dir\01_do\01_build\02_nfhs4\03_nfhs4_clean_child_data.do"

*********************************************************************************
*overall expectancy and SEs, create a figure that compares with the SRS 
*********************************************************************************

	do "$dir\01_do\02_analysis\01_overall\01_nfhs2_resampling_overall.do"
	
	do "$dir\01_do\02_analysis\01_overall\02_nfhs2_estimates_overall.do"
	
	do "$dir\01_do\02_analysis\01_overall\03_nfhs4_resampling_overall.do"
	
	do "$dir\01_do\02_analysis\01_overall\04_nfhs4_estimates_overall.do"
	
	do "$dir\01_do\02_analysis\01_overall\05_graph_overall.do"
	
*********************************************************************************
*social group estimates and SEs, create a figure that with e0, e15, e60 
*********************************************************************************

	do "$dir\01_do\02_analysis\02_group\01_nfhs2_resampling_group.do"
	
	do "$dir\01_do\02_analysis\02_group\02_nfhs2_estimates_group.do"
	
	do "$dir\01_do\02_analysis\02_group\03_nfhs4_resampling_group.do"
	
	do "$dir\01_do\02_analysis\02_group\04_nfhs4_estimates_group.do"
	
	do "$dir\01_do\02_analysis\02_group\05_graph_group_ex_muslim_incl.do"
	
	do "$dir\01_do\02_analysis\02_group\06_graph_group_lx_muslim_incl.do"

	do "$dir\01_do\02_analysis\02_group\07_export_latex_files.do"
	
*********************************************************************************
*social group estimates and SEs, by residence, create a figure that with e0 
*********************************************************************************
	
	do "$dir\01_do\02_analysis\03_residence\01_nfhs2_resampling_group_residence.do"
	
	do "$dir\01_do\02_analysis\03_residence\02_nfhs2_estimates_group_residence.do"
	
	do "$dir\01_do\02_analysis\03_residence\03_nfhs4_resampling_group_residence.do"
	
	do "$dir\01_do\02_analysis\03_residence\04_nfhs4_estimates_group_residence.do"
	
	do "$dir\01_do\02_analysis\03_residence\05_graph_group_residence_incl_muslims.do"
	
*********************************************************************************
*social group estimates and SEs, by region, for nfhs4, create a map that with e0 
*********************** **********************************************************
	
	do "$dir\01_do\02_analysis\04_region\01_nfhs4_resampling_region.do"
	
	do "$dir\01_do\02_analysis\04_region\02_nfhs4_resampling_adivasi_region.do"

	do "$dir\01_do\02_analysis\04_region\03_nfhs4_region_estimates_se.do"

	do "$dir\01_do\02_analysis\04_region\04_region_maps_caste.do"

	do "$dir\01_do\02_analysis\04_region\05_region_maps_adivasi.do"
	
	do "$dir\01_do\02_analysis\04_region\06_region_maps_muslim.do"
	
	do "$dir\01_do\02_analysis\04_region\07_combine_maps.do"


*********************************************************************************
*arriaga decomposition 
*********************************************************************************

	do "$dir\01_do\02_analysis\05_arriaga\01_estimate_arriaga.do"

	do "$dir\01_do\02_analysis\05_arriaga\02_arriaga_graph_sc_st_muslim.do"
	
*********************************************************************************
*robustness 
*********************************************************************************

	do "$dir\01_do\02_analysis\06_robustness\01_nfhs_lt.do"
	
	

