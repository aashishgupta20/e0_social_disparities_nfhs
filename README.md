# Replication materials for "Large and persistent life expectancy disparities among India’s social groups"

This repository provides all stata do files necessary for replicating the results presented in [Gupta, A., & Sudharsanan, N. (2020). Large and persistent life expectancy disparities among india’s social groups.](https://osf.io/preprints/socarxiv/hu8t9/). Some code is in R. 

The code is commented throughout. The analysis relies on publicly available DHS data for India, which can be downloaded from https://dhsprogram.com/. Registration is required.

The folder 01_build creates files that use NFHS birth history file and the NFHS household members files to estimate deaths and person-years by age and social group. These files may be useful if you are interested in using mortality data from the NFHS surveys. 

Folder 02_analysis contains files that estimate age-specific mortality rates and life tables. The folder also includes code for running cluster-bootsrap to estimate standard errors for life table quantitites. 

We welcome feedback, please feel free to write to us for clarifications. Thanks! 

