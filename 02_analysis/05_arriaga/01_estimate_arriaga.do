**************************************************
*Project: Caste and mortality							 *
*Purpose: estimate arriaga contributions by age  *
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
	log using "$dir/02_logs/02analysis_nfhs_arriaga.txt", text replace
	
******************************************************
*Work with data
******************************************************

	*bring in estimates: nfhs 2
	use "$dir\05_out\estimates\nfhs2_group_life_tables_se.dta", clear
	
	*append nfhs4 estimates 
	append using "$dir\05_out\estimates\nfhs4_group_life_tables_se.dta"

	*keep necessary variables 
	keep caste_religion female round age_group lx ex nmx 

	*restimate life table functions 
		sort round female caste_religion age_group

		*n 
		gen n = . 
		bysort round female caste_religion: replace n = _n
		replace n = 0 if n == 1 
		replace n = 1 if n == 2 
		bysort round female caste_religion: replace n = 5 * (_n - 2) if _n > 2
		
		*work backwards for Tx 
		gen tx = lx * ex
		
		*now estimate nLx
		gen nlx = . 
		forval i=1(1)18 {
		bysort round female caste_religion: replace nlx = tx - tx[_n+1] if _n == `i'
		}
		bysort round female caste_religion: replace nlx = tx if _n == 19
		
*********************************************************************************
*now do an arriaga (arriaga 1984)
*********************************************************************************
	
	*reshape by group 
		keep if inlist(caste_religion, 1, 2, 3, 4, 5)
		reshape wide n nmx lx ex tx nlx, i(age_group female round) j(caste_religion)
		
	*first for SCs 
		*direct effect 
		gen de_sc_hc = (lx1) * ((nlx5/lx5) - (nlx1/lx1))
		
		*indirect effect 
		gen ie_sc_hc = . 
		sort female round age_group
		bysort female round: replace ie_sc_hc = (tx5[_n+1]) * ((lx1/lx5) - (lx1[_n+1]/lx5[_n+1])) if age!=85
		replace ie_sc_hc=0 if age==85
		
		*total effect 
		gen te_sc_hc = de_sc_hc + ie_sc_hc 

		*total te by group etc
		bysort female round: egen tte_sc_hc = total(te_sc_hc)
		
	*and now for STs 
		*direct effect 
		gen de_st_hc = (lx2) * ((nlx5/lx5) - (nlx2/lx2))
		
		*indirect effect 
		gen ie_st_hc = . 
		sort female round age_group
		bysort female round: replace ie_st_hc = (tx5[_n+1]) * ((lx2/lx5) - (lx2[_n+1]/lx5[_n+1])) if age!=85
		replace ie_st_hc=0 if age==85
		
		*total effect 
		gen te_st_hc = de_st_hc + ie_st_hc 

		*total te by group etc
		bysort female round: egen tte_st_hc = total(te_st_hc)
	
	*and now for muslims 
		*direct effect 
		gen de_mu_hc = (lx3) * ((nlx5/lx5) - (nlx3/lx3))
		
		*indirect effect 
		gen ie_mu_hc = . 
		sort female round age_group
		bysort female round: replace ie_mu_hc = (tx5[_n+1]) * ((lx3/lx5) - (lx3[_n+1]/lx5[_n+1])) if age!=85
		replace ie_mu_hc=0 if age==85
		
		*total effect 
		gen te_mu_hc = de_mu_hc + ie_mu_hc 

		*total te by group etc
		bysort female round: egen tte_mu_hc = total(te_mu_hc)
	
	*and OBCs
		*direct effect 
		gen de_obc_hc = (lx4) * ((nlx5/lx5) - (nlx4/lx4))
		
		*indirect effect 
		gen ie_obc_hc = . 
		sort female round age_group
		bysort female round: replace ie_obc_hc = (tx5[_n+1]) * ((lx4/lx5) - (lx4[_n+1]/lx5[_n+1])) if age!=85
		replace ie_obc_hc=0 if age==85
		
		*total effect 
		gen te_obc_hc = de_obc_hc + ie_obc_hc 

		*total te by group etc
		bysort female round: egen tte_obc_hc = total(te_obc_hc)
	
		
	*keep necessary variables 
	
		keep female age_group round te_sc_hc te_st_hc te_mu_hc te_obc_hc
		
	*save 
		save "$dir\05_out\estimates\nfhs_arriaga_contributions.dta", replace 
		
		
*generate standard errors for the arriaga approach 

	foreach round in 2 4 {
		
	forval rep = 1(1)100 {

	use "$dir\04_input\resamples\bstraps\nfhs`round'\group\nfhs`round'_rep`rep'_group.dta", clear 
	
	cap gen round = `round'
	
	cap gen rep = `rep'
	
	cap rename lx_rep`rep' lx 
	cap rename ex_rep`rep' ex 
	cap rename nmx_rep`rep' nmx

	
	*keep necessary variables 
	keep caste_religion female round age_group lx ex nmx rep 

	*restimate life table functions 
		sort round female caste_religion age_group

		*n 
		gen n = . 
		bysort round female caste_religion: replace n = _n
		replace n = 0 if n == 1 
		replace n = 1 if n == 2 
		bysort round female caste_religion: replace n = 5 * (_n - 2) if _n > 2
		
		*work backwards for Tx 
		gen tx = lx * ex
		
		*now estimate nLx
		gen nlx = . 
		forval i=1(1)18 {
		bysort round female caste_religion: replace nlx = tx - tx[_n+1] if _n == `i'
		}
		bysort round female caste_religion: replace nlx = tx if _n == 19
	
*********************************************************************************
*now do an arriaga (arriaga 1984)
*********************************************************************************
	
	*reshape by group 
		keep if inlist(caste_religion, 1, 2, 3, 4, 5)
		reshape wide n nmx lx ex tx nlx, i(age_group female round rep) j(caste_religion)
		
	*first for SCs 
		*direct effect 
		gen de_sc_hc = (lx1) * ((nlx5/lx5) - (nlx1/lx1))
		
		*indirect effect 
		gen ie_sc_hc = . 
		sort female round age_group
		bysort female round: replace ie_sc_hc = (tx5[_n+1]) * ((lx1/lx5) - (lx1[_n+1]/lx5[_n+1])) if age!=85
		replace ie_sc_hc=0 if age==85
		
		*total effect 
		gen te_sc_hc = de_sc_hc + ie_sc_hc 

		*total te by group etc
		bysort female round: egen tte_sc_hc = total(te_sc_hc)
		
	*and now for STs 
		*direct effect 
		gen de_st_hc = (lx2) * ((nlx5/lx5) - (nlx2/lx2))
		
		*indirect effect 
		gen ie_st_hc = . 
		sort female round age_group
		bysort female round: replace ie_st_hc = (tx5[_n+1]) * ((lx2/lx5) - (lx2[_n+1]/lx5[_n+1])) if age!=85
		replace ie_st_hc=0 if age==85
		
		*total effect 
		gen te_st_hc = de_st_hc + ie_st_hc 

		*total te by group etc
		bysort female round: egen tte_st_hc = total(te_st_hc)
	
	*and now for muslims 
		*direct effect 
		gen de_mu_hc = (lx3) * ((nlx5/lx5) - (nlx3/lx3))
		
		*indirect effect 
		gen ie_mu_hc = . 
		sort female round age_group
		bysort female round: replace ie_mu_hc = (tx5[_n+1]) * ((lx3/lx5) - (lx3[_n+1]/lx5[_n+1])) if age!=85
		replace ie_mu_hc=0 if age==85
		
		*total effect 
		gen te_mu_hc = de_mu_hc + ie_mu_hc 

		*total te by group etc
		bysort female round: egen tte_mu_hc = total(te_mu_hc)
	
	*and OBCs
		*direct effect 
		gen de_obc_hc = (lx4) * ((nlx5/lx5) - (nlx4/lx4))
		
		*indirect effect 
		gen ie_obc_hc = . 
		sort female round age_group
		bysort female round: replace ie_obc_hc = (tx5[_n+1]) * ((lx4/lx5) - (lx4[_n+1]/lx5[_n+1])) if age!=85
		replace ie_obc_hc=0 if age==85
		
		*total effect 
		gen te_obc_hc = de_obc_hc + ie_obc_hc 

		*total te by group etc
		bysort female round: egen tte_obc_hc = total(te_obc_hc)
	
		
	*keep necessary variables 
	
		keep female age_group round rep te_sc_hc te_st_hc te_mu_hc te_obc_hc
		
	*save 
		save "$dir\04_input\resamples\arriaga_bstraps\round`round'_rep`rep'.dta", replace 
		
	}
	}
		
cap log close
			
		
			
